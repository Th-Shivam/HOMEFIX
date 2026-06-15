import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants.dart';
import '../../core/db/collections.dart';
import '../../core/db/firestore_mapper.dart';
import '../../core/db/schema_enums.dart';
import '../../models/firestore/payment_document.dart';

/// Production repository for `subscriptions` and `payments`.
class SubscriptionRepository {
  SubscriptionRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  DocumentReference<Map<String, dynamic>> _subscriptionRef(String uid) =>
      _firestore.collection(DbCollections.subscriptions).doc(uid);

  CollectionReference<Map<String, dynamic>> get _payments =>
      _firestore.collection(DbCollections.payments);

  Future<void> saveSubscription({
    required String name,
    required String mobile,
    required String alternateMobile,
    required String address,
    required String planType,
    String paymentMethod = DbEnums.methodUpiManual,
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

    await _subscriptionRef(user.uid).set({
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
    }, SetOptions(merge: true));
  }

  Future<String?> getPaymentStatus() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _subscriptionRef(user.uid).get();
    if (!doc.exists) return null;
    return doc.data()?[DbFields.paymentStatus] as String?;
  }

  Future<Map<String, dynamic>?> getSubscription() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _subscriptionRef(user.uid).get();
    if (!doc.exists) return null;
    return doc.data();
  }

  Future<bool> isSubscriptionActive() async {
    final data = await getSubscription();
    if (data == null) return false;

    final status = data[DbFields.paymentStatus] as String?;
    if (!DbEnums.isSubscriptionActive(status)) return false;

    final end = FirestoreMapper.timestampToDate(data[DbFields.subscriptionEndDate]);
    if (end == null) return false;
    return DateTime.now().isBefore(end);
  }

  /// Creates an idempotent payment record alongside subscription pending state.
  Future<PaymentDocument> recordPayment({
    required String planType,
    String method = DbEnums.methodUpiManual,
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
      subscriptionId: user.uid,
      amount: amount,
      currency: 'INR',
      planType: planType,
      status: DbEnums.txnPending,
      method: method,
      idempotencyKey: idempotencyKey,
      proofImageUrl: proofImageUrl,
    );

    await docRef.set(payment.toCreateMap());
    final saved = await docRef.get();
    return PaymentDocument.fromFirestore(saved);
  }
}
