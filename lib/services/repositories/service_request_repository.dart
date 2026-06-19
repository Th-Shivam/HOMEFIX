import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/db/collections.dart';
import '../../core/db/schema_enums.dart';
import '../../models/firestore/service_request_document.dart';

/// Production repository for `service_requests` collection.
class ServiceRequestRepository {
  ServiceRequestRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(DbCollections.serviceRequests);

  DocumentReference<Map<String, dynamic>> get _ticketCounter => _firestore
      .collection(DbCollections.counters)
      .doc(DbDocuments.serviceTickets);

  /// Atomically generates `NVS-{number}` via counter transaction.
  Future<String> _nextTicketId() async {
    return _firestore.runTransaction((tx) async {
      final snap = await tx.get(_ticketCounter);
      int next;
      if (!snap.exists) {
        next = 10001;
        tx.set(_ticketCounter, {
          DbFields.lastNumber: next,
          DbFields.updatedAt: FieldValue.serverTimestamp(),
        });
      } else {
        next = (snap.data()![DbFields.lastNumber] as num).toInt() + 1;
        tx.update(_ticketCounter, {
          DbFields.lastNumber: next,
          DbFields.updatedAt: FieldValue.serverTimestamp(),
        });
      }
      return 'NVS-$next';
    });
  }

  Future<int> countOpenRequests(String userId) async {
    final snap = await _collection
        .where(DbFields.userId, isEqualTo: userId)
        .where(DbFields.isDeleted, isEqualTo: false)
        .where(DbFields.status, whereIn: [
          DbEnums.statusRequested,
          DbEnums.statusFindingTechnician,
          DbEnums.statusAssigned,
          DbEnums.statusInProgress,
          DbEnums.statusOnTheWay,
        ])
        .get();
    return snap.docs.length;
  }

  /// Creates a new service request and returns the saved document.
  Future<ServiceRequestDocument> create({
    required String categoryLabel,
    required String issueTitle,
    required String description,
    required String location,
    required String contactPhone,
    String notes = '',
    required String priorityLabel,
    DateTime? scheduledDate,
    String? timeSlot,
    String? addressId,
    Map<String, dynamic>? aiAnalysis,
    double? estimatedCost,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('You must be signed in to submit a service request.');
    }

    final openCount = await countOpenRequests(user.uid);
    if (openCount >= 3) {
      throw Exception('You already have 3 open requests. Please wait for one to complete.');
    }

    final ticketId = await _nextTicketId();
    final docRef = _collection.doc();

    final document = ServiceRequestDocument(
      docId: docRef.id,
      requestId: ticketId,
      userId: user.uid,
      categoryId: DbEnums.categoryFromLabel(categoryLabel),
      title: issueTitle.trim(),
      description: description.trim(),
      addressId: addressId,
      contactPhone: contactPhone.trim(),
      notes: notes.trim(),
      priority: DbEnums.priorityFromLabel(priorityLabel),
      status: DbEnums.statusRequested,
      scheduledAt: scheduledDate,
      timeSlot: timeSlot,
      aiAnalysis: aiAnalysis,
      estimatedCost: estimatedCost,
    );

    final data = document.toCreateMap();
    if (addressId == null && location.trim().isNotEmpty) {
      data[DbFields.location] = location.trim();
    }

    await docRef.set(data);
    final saved = await docRef.get();
    return ServiceRequestDocument.fromFirestore(saved);
  }

  Stream<List<ServiceRequestDocument>> watchUserRequests(String userId) {
    return _collection
        .where(DbFields.userId, isEqualTo: userId)
        .where(DbFields.isDeleted, isEqualTo: false)
        .orderBy(DbFields.createdAt, descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map(ServiceRequestDocument.fromFirestore)
            .toList());
  }

  Future<ServiceRequestDocument?> getByRequestId(String requestId) async {
    final snap = await _collection
        .where(DbFields.requestId, isEqualTo: requestId)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return ServiceRequestDocument.fromFirestore(snap.docs.first);
  }

  Future<void> cancelRequest(String docId, {String reason = ''}) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated.');

    await _collection.doc(docId).update({
      DbFields.status: DbEnums.statusCancelled,
      DbFields.cancelReason: reason,
      DbFields.cancelledAt: FieldValue.serverTimestamp(),
      DbFields.updatedAt: FieldValue.serverTimestamp(),
    });
  }
}
