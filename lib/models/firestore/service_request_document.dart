import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/db/collections.dart';
import '../../core/db/firestore_mapper.dart';
import '../../core/db/schema_enums.dart';

/// Production Firestore document for `service_requests/{docId}` (schema v2).
class ServiceRequestDocument {
  final String docId;
  final String requestId;
  final String userId;
  final String categoryId;
  final String title;
  final String description;
  final String? addressId;
  final String contactPhone;
  final String notes;
  final String priority;
  final String status;
  final DateTime? scheduledAt;
  final String? timeSlot;
  final DateTime? requestedAt;
  final Map<String, dynamic>? aiAnalysis;
  final double? estimatedCost;
  final double? finalCost;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;

  const ServiceRequestDocument({
    required this.docId,
    required this.requestId,
    required this.userId,
    required this.categoryId,
    required this.title,
    required this.description,
    this.addressId,
    required this.contactPhone,
    this.notes = '',
    required this.priority,
    required this.status,
    this.scheduledAt,
    this.timeSlot,
    this.requestedAt,
    this.aiAnalysis,
    this.estimatedCost,
    this.finalCost,
    this.createdAt,
    this.updatedAt,
    this.completedAt,
    this.cancelledAt,
  });

  factory ServiceRequestDocument.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snap,
  ) {
    final data = snap.data() ?? {};
    return ServiceRequestDocument(
      docId: snap.id,
      requestId: FirestoreMapper.readString(data, DbFields.requestId),
      userId: FirestoreMapper.readString(data, DbFields.userId),
      categoryId: FirestoreMapper.readString(data, DbFields.categoryId,
          fallback: FirestoreMapper.readString(data, DbFields.category)),
      title: FirestoreMapper.readString(data, DbFields.title,
          fallback: FirestoreMapper.readString(data, DbFields.issueTitle)),
      description: FirestoreMapper.readString(data, DbFields.description),
      addressId: data[DbFields.addressIdRef] as String?,
      contactPhone: FirestoreMapper.readString(data, DbFields.contactPhone),
      notes: FirestoreMapper.readString(data, DbFields.notes),
      priority: FirestoreMapper.readString(data, DbFields.priority),
      status: FirestoreMapper.readString(data, DbFields.status),
      scheduledAt: FirestoreMapper.timestampToDate(
            data[DbFields.scheduledAt] ?? data[DbFields.scheduledDate]),
      timeSlot: data[DbFields.timeSlot] as String?,
      requestedAt: FirestoreMapper.timestampToDate(data[DbFields.requestedAt]),
      aiAnalysis: data[DbFields.aiAnalysis] as Map<String, dynamic>?,
      estimatedCost: (data[DbFields.estimatedCost] as num?)?.toDouble(),
      finalCost: (data[DbFields.finalCost] as num?)?.toDouble(),
      createdAt: FirestoreMapper.timestampToDate(data[DbFields.createdAt]),
      updatedAt: FirestoreMapper.timestampToDate(data[DbFields.updatedAt]),
      completedAt: FirestoreMapper.timestampToDate(data[DbFields.completedAt]),
      cancelledAt: FirestoreMapper.timestampToDate(data[DbFields.cancelledAt]),
    );
  }

  Map<String, dynamic> toCreateMap() {
    final now = FieldValue.serverTimestamp();
    return {
      ...FirestoreMapper.baseFields(),
      DbFields.requestId: requestId,
      DbFields.userId: userId,
      DbFields.categoryId: categoryId,
      DbFields.title: title,
      DbFields.description: description,
      if (addressId != null) DbFields.addressIdRef: addressId,
      DbFields.contactPhone: contactPhone,
      DbFields.notes: notes,
      DbFields.priority: priority,
      DbFields.status: status,
      DbFields.requestedAt: now,
      if (scheduledAt != null)
        DbFields.scheduledAt: Timestamp.fromDate(scheduledAt!),
      if (timeSlot != null) DbFields.timeSlot: timeSlot,
      if (aiAnalysis != null) DbFields.aiAnalysis: aiAnalysis,
      if (estimatedCost != null) DbFields.estimatedCost: estimatedCost,
      // legacy compat for existing queries/rules
      DbFields.category: categoryId,
      DbFields.issueTitle: title,
    };
  }

  bool get isOpen =>
      status != DbEnums.statusCompleted && status != DbEnums.statusCancelled;
}
