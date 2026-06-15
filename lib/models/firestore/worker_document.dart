import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/db/collections.dart';
import '../../core/db/firestore_mapper.dart';

class WorkerDocument {
  final String workerId;
  final String name;
  final String phone;
  final String type;
  final List<String> skills;
  final double rating;
  final int ratingCount;
  final String location;
  final List<String> serviceAreas;
  final bool available;
  final bool verified;
  final String? linkedUserId;

  const WorkerDocument({
    required this.workerId,
    required this.name,
    required this.phone,
    required this.type,
    this.skills = const [],
    this.rating = 0,
    this.ratingCount = 0,
    required this.location,
    this.serviceAreas = const [],
    this.available = true,
    this.verified = false,
    this.linkedUserId,
  });

  factory WorkerDocument.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snap,
  ) {
    final data = snap.data() ?? {};
    return WorkerDocument(
      workerId: snap.id,
      name: FirestoreMapper.readString(data, DbFields.name),
      phone: FirestoreMapper.readString(data, DbFields.phone),
      type: FirestoreMapper.readString(data, DbFields.type),
      skills: FirestoreMapper.readStringList(data, DbFields.skills),
      rating: FirestoreMapper.readDouble(data, DbFields.rating),
      ratingCount: (data[DbFields.ratingCount] as num?)?.toInt() ?? 0,
      location: FirestoreMapper.readString(data, DbFields.location),
      serviceAreas: FirestoreMapper.readStringList(data, DbFields.serviceAreas),
      available: FirestoreMapper.readBool(data, DbFields.available, fallback: true),
      verified: FirestoreMapper.readBool(data, DbFields.verified),
      linkedUserId: data[DbFields.linkedUserId] as String?,
    );
  }

  Map<String, dynamic> toCreateMap() {
    return {
      ...FirestoreMapper.baseFields(),
      DbFields.workerId: workerId,
      DbFields.name: name,
      DbFields.phone: phone,
      DbFields.type: type,
      DbFields.skills: skills,
      DbFields.rating: rating,
      DbFields.ratingCount: ratingCount,
      DbFields.location: location,
      DbFields.serviceAreas: serviceAreas,
      DbFields.available: available,
      DbFields.verified: verified,
      if (linkedUserId != null) DbFields.linkedUserId: linkedUserId,
    };
  }
}
