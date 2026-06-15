import 'package:cloud_firestore/cloud_firestore.dart';
import 'collections.dart';

/// Shared Firestore serialization helpers.
abstract final class FirestoreMapper {
  static Map<String, dynamic> baseFields() => {
        DbFields.schemaVersion: kSchemaVersion,
        DbFields.createdAt: FieldValue.serverTimestamp(),
        DbFields.updatedAt: FieldValue.serverTimestamp(),
        DbFields.isDeleted: false,
      };

  static Map<String, dynamic> updateFields() => {
        DbFields.updatedAt: FieldValue.serverTimestamp(),
      };

  static DateTime? timestampToDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  static String readString(Map<String, dynamic> data, String key,
      {String fallback = ''}) {
    final value = data[key];
    if (value is String) return value;
    return fallback;
  }

  static bool readBool(Map<String, dynamic> data, String key,
      {bool fallback = false}) {
    final value = data[key];
    if (value is bool) return value;
    return fallback;
  }

  static double readDouble(Map<String, dynamic> data, String key,
      {double fallback = 0}) {
    final value = data[key];
    if (value is num) return value.toDouble();
    return fallback;
  }

  static List<String> readStringList(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is List) {
      return value.whereType<String>().toList();
    }
    return [];
  }
}
