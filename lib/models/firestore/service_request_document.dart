import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/db/collections.dart';
import '../../core/db/firestore_mapper.dart';
import '../../core/db/schema_enums.dart';

/// Production Firestore document for `service_requests/{docId}`.
class ServiceRequestDocument {
  final String docId;
  final String requestId;
  final String userId;
  final String category;
  final String issueTitle;
  final String description;
  final String location;
  final String contactPhone;
  final String notes;
  final String priority;
  final String status;
  final DateTime? scheduledDate;
  final String? timeSlot;
  final String? assignedWorkerId;
  final String? assignedWorkerName;
  final Map<String, dynamic>? aiAnalysis;
  final List<String> imageUrls;
  final bool subscriptionActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;

  const ServiceRequestDocument({
    required this.docId,
    required this.requestId,
    required this.userId,
    required this.category,
    required this.issueTitle,
    required this.description,
    required this.location,
    required this.contactPhone,
    this.notes = '',
    required this.priority,
    required this.status,
    this.scheduledDate,
    this.timeSlot,
    this.assignedWorkerId,
    this.assignedWorkerName,
    this.aiAnalysis,
    this.imageUrls = const [],
    this.subscriptionActive = false,
    this.createdAt,
    this.updatedAt,
    this.completedAt,
  });

  factory ServiceRequestDocument.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snap,
  ) {
    final data = snap.data() ?? {};
    return ServiceRequestDocument(
      docId: snap.id,
      requestId: FirestoreMapper.readString(data, DbFields.requestId),
      userId: FirestoreMapper.readString(data, DbFields.userId),
      category: FirestoreMapper.readString(data, DbFields.category),
      issueTitle: FirestoreMapper.readString(data, DbFields.issueTitle),
      description: FirestoreMapper.readString(data, DbFields.description),
      location: FirestoreMapper.readString(data, DbFields.location),
      contactPhone: FirestoreMapper.readString(data, DbFields.contactPhone),
      notes: FirestoreMapper.readString(data, DbFields.notes),
      priority: FirestoreMapper.readString(data, DbFields.priority),
      status: FirestoreMapper.readString(data, DbFields.status),
      scheduledDate: FirestoreMapper.timestampToDate(data[DbFields.scheduledDate]),
      timeSlot: data[DbFields.timeSlot] as String?,
      assignedWorkerId: data[DbFields.assignedWorkerId] as String?,
      assignedWorkerName: data[DbFields.assignedWorkerName] as String?,
      aiAnalysis: data[DbFields.aiAnalysis] as Map<String, dynamic>?,
      imageUrls: FirestoreMapper.readStringList(data, DbFields.imageUrls),
      subscriptionActive: FirestoreMapper.readBool(data, DbFields.subscriptionActive),
      createdAt: FirestoreMapper.timestampToDate(data[DbFields.createdAt]),
      updatedAt: FirestoreMapper.timestampToDate(data[DbFields.updatedAt]),
      completedAt: FirestoreMapper.timestampToDate(data[DbFields.completedAt]),
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      ...FirestoreMapper.baseFields(),
      DbFields.requestId: requestId,
      DbFields.userId: userId,
      DbFields.category: category,
      DbFields.issueTitle: issueTitle,
      DbFields.description: description,
      DbFields.location: location,
      DbFields.contactPhone: contactPhone,
      DbFields.notes: notes,
      DbFields.priority: priority,
      DbFields.status: status,
      if (scheduledDate != null)
        DbFields.scheduledDate: Timestamp.fromDate(scheduledDate!),
      if (timeSlot != null) DbFields.timeSlot: timeSlot,
      if (aiAnalysis != null) DbFields.aiAnalysis: aiAnalysis,
      DbFields.imageUrls: imageUrls,
      DbFields.subscriptionActive: subscriptionActive,
    };
  }

  bool get isOpen =>
      status != DbEnums.statusCompleted && status != DbEnums.statusCancelled;
}
