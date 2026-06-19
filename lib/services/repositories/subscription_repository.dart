import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants.dart';
import '../../core/db/collections.dart';
import '../../core/db/firestore_mapper.dart';
import '../../core/db/schema_enums.dart';
import '../../models/firestore/payment_document.dart';

/// Production repository for `subscriptions` (v2) and `payments`.
class SubscriptionRepository {
  SubscriptionRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _subscriptions =>
      _firestore.collection(DbCollections.subscriptions);

  /// Legacy v1 path: subscriptions/{userId}
  DocumentReference<Map<String, dynamic>> _legacySubscriptionRef(String uid) =>
      _subscriptions.doc(uid);

  CollectionReference<Map<String, dynamic>> get _payments =>
      _firestore.collection(DbCollections.payments);

  Future<void> saveSubscription({
    required String name,
    required String mobile,
    required String alternateMobile,
    required String address,
    required String planType,
    String? addressId,
    String paymentMethod = DbEnums.gatewayUpiManual,
    String? paymentReference,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('You must be signed in to subscribe.');
    }

    final amount = planType == DbEnums.planMonthly
        ? AppConstants.monthlyPrice
        : AppConstants.yearlyPrice;

    final startDate = DateTime.now();
    final endDate = planType == DbEnums.planMonthly
        ? startDate.add(const Duration(days: 30))
        : DateTime(startDate.year + 1, startDate.month, startDate.day);

    final planId = planType == DbEnums.planMonthly ? 'monthly_standard' : 'yearly_standard';

    // v2: auto-generated subscriptionId, multiple subs per user allowed
    final v2Ref = _subscriptions.doc();
    await v2Ref.set({
      ...FirestoreMapper.baseFields(),
      DbFields.subscriptionId: v2Ref.id,
      DbFields.userId: user.uid,
      DbFields.planId: planId,
      DbFields.planType: planType,
      DbFields.name: name.trim(),
      DbFields.mobile: mobile.trim(),
      DbFields.alternateMobile: alternateMobile.trim(),
      DbFields.address: address.trim(),
      if (addressId != null) DbFields.addressIdRef: addressId,
      DbFields.email: user.email ?? '',
      DbFields.amount: amount,
      DbFields.currency: 'INR',
      DbFields.startDate: Timestamp.fromDate(startDate),
      DbFields.endDate: Timestamp.fromDate(endDate),
      DbFields.status: DbEnums.subPending,
      DbFields.autoRenew: false,
      DbFields.paymentMethod: paymentMethod,
      if (paymentReference != null) DbFields.paymentReference: paymentReference,
    });

    // v1 legacy mirror for existing splash/pending flow
    await _legacySubscriptionRef(user.uid).set({
      ...FirestoreMapper.baseFields(),
      DbFields.userId: user.uid,
      DbFields.email: user.email ?? '',
      DbFields.name: name.trim(),
      DbFields.mobile: mobile.trim(),
      DbFields.alternateMobile: alternateMobile.trim(),
      DbFields.address: address.trim(),
      DbFields.planType: planType,
      DbFields.amount: amount,
      DbFields.currency: 'INR',
      DbFields.subscriptionStartDate: FieldValue.serverTimestamp(),
      DbFields.subscriptionEndDate: Timestamp.fromDate(endDate),
      DbFields.paymentStatus: DbEnums.paymentPending,
      DbFields.paymentMethod: paymentMethod,
      if (paymentReference != null) DbFields.paymentReference: paymentReference,
      DbFields.autoRenew: false,
      DbFields.subscriptionId: v2Ref.id,
    }, SetOptions(merge: true));
  }

  Future<String?> getPaymentStatus() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    // Try v2 active subscription first
    final v2Snap = await _subscriptions
        .where(DbFields.userId, isEqualTo: user.uid)
        .where(DbFields.status, isEqualTo: DbEnums.subPending)
        .limit(1)
        .get();
    if (v2Snap.docs.isNotEmpty) {
      return v2Snap.docs.first.data()[DbFields.status] as String?;
    }

    // Legacy fallback
    final legacy = await _legacySubscriptionRef(user.uid).get();
    if (!legacy.exists) return null;
    return legacy.data()?[DbFields.paymentStatus] as String?;
  }

  Future<Map<String, dynamic>?> getActiveSubscription() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final v2Snap = await _subscriptions
        .where(DbFields.userId, isEqualTo: user.uid)
        .where(DbFields.status, whereIn: [DbEnums.subActive, DbEnums.subPending])
        .orderBy(DbFields.endDate, descending: true)
        .limit(1)
        .get();
    if (v2Snap.docs.isNotEmpty) return v2Snap.docs.first.data();

    final legacy = await _legacySubscriptionRef(user.uid).get();
    if (!legacy.exists) return null;
    return legacy.data();
  }

  Future<bool> isSubscriptionActive() async {
    final data = await getActiveSubscription();
    if (data == null) return false;

    final status = (data[DbFields.status] ?? data[DbFields.paymentStatus]) as String?;
    if (!DbEnums.isSubscriptionActive(status)) return false;

    final end = FirestoreMapper.timestampToDate(
      data[DbFields.endDate] ?? data[DbFields.subscriptionEndDate],
    );
    if (end == null) return false;
    return DateTime.now().isBefore(end);
  }

  Future<PaymentDocument> recordPayment({
    required String planType,
    String? subscriptionId,
    String method = DbEnums.gatewayUpiManual,
    String? proofImageUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated.');

    final amount = planType == DbEnums.planMonthly
        ? AppConstants.monthlyPrice
        : AppConstants.yearlyPrice;

    final today = DateTime.now().toIso8601String().substring(0, 10);
    final idempotencyKey = '${user.uid}_${planType}_$today';

    final existing = await _payments
        .where(DbFields.idempotencyKey, isEqualTo: idempotencyKey)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) {
      return PaymentDocument.fromFirestore(existing.docs.first);
    }

    final docRef = _payments.doc();
    final payment = PaymentDocument(
      paymentId: docRef.id,
      userId: user.uid,
      subscriptionId: subscriptionId ?? user.uid,
      amount: amount,
      currency: 'INR',
      planType: planType,
      status: DbEnums.txnPending,
      method: method,
      idempotencyKey: idempotencyKey,
      proofImageUrl: proofImageUrl,
    );

    await docRef.set(payment.toCreateMap());
    return PaymentDocument.fromFirestore((await docRef.get()));
  }
}
