import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/db/collections.dart';
import '../../core/db/schema_enums.dart';
import '../../models/firestore/worker_document.dart';

/// Production repository for `workers` collection.
class WorkerRepository {
  WorkerRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(DbCollections.workers);

  Future<List<WorkerDocument>> listAvailable({
    String? type,
    int limit = 20,
  }) async {
    Query<Map<String, dynamic>> query = _collection
        .where(DbFields.available, isEqualTo: true)
        .where(DbFields.verified, isEqualTo: true)
        .where(DbFields.isDeleted, isEqualTo: false);

    if (type != null) {
      query = query.where(DbFields.type, isEqualTo: type);
    }

    final snap = await query.orderBy(DbFields.rating, descending: true).limit(limit).get();
    return snap.docs.map(WorkerDocument.fromFirestore).toList();
  }

  Future<List<WorkerDocument>> listByType(String type) {
    return listAvailable(type: type);
  }

  Future<WorkerDocument?> getById(String workerId) async {
    final doc = await _collection.doc(workerId).get();
    if (!doc.exists) return null;
    return WorkerDocument.fromFirestore(doc);
  }

  /// Maps legacy demo worker type strings to DB enum values.
  static String normalizeType(String type) {
    switch (type.toLowerCase()) {
      case 'plumber':
        return DbEnums.workerPlumber;
      case 'electrician':
        return DbEnums.workerElectrician;
      default:
        return DbEnums.workerGeneral;
    }
  }
}
