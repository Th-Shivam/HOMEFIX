import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/db/collections.dart';
import '../../core/db/firestore_mapper.dart';
import '../../core/db/schema_enums.dart';

/// Production repository for `users` profile CRUD.
class UserRepository {
  UserRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  DocumentReference<Map<String, dynamic>> _userRef(String uid) =>
      _firestore.collection(DbCollections.users).doc(uid);

  /// Base fields written on first account creation.
  Map<String, dynamic> newUserFields({
    required String uid,
    required String name,
    required String email,
    required String phone,
    required String authProvider,
  }) {
    return {
      ...FirestoreMapper.baseFields(),
      DbFields.uid: uid,
      DbFields.name: name.trim(),
      DbFields.email: email.trim(),
      DbFields.phone: phone.trim(),
      DbFields.authProvider: authProvider,
      DbFields.role: DbEnums.roleCustomer,
      DbFields.onboardingCompleted: false,
    };
  }

  Future<void> updateProfile({
    required String name,
    required String phone,
    String? address,
    String? photoUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated.');

    await _userRef(user.uid).update({
      DbFields.name: name.trim(),
      DbFields.phone: phone.trim(),
      if (address != null) DbFields.address: address.trim(),
      if (photoUrl != null) DbFields.photoUrl: photoUrl,
      ...FirestoreMapper.updateFields(),
    });

    if (name.trim().isNotEmpty && name.trim() != user.displayName) {
      await user.updateDisplayName(name.trim());
    }
  }

  Future<void> markOnboardingComplete() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _userRef(user.uid).update({
      DbFields.onboardingCompleted: true,
      ...FirestoreMapper.updateFields(),
    });
  }

  Future<void> updateFcmToken(String token) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _userRef(user.uid).update({
      DbFields.fcmToken: token,
      ...FirestoreMapper.updateFields(),
    });
  }

  Future<Map<String, dynamic>?> getProfile(String uid) async {
    final doc = await _userRef(uid).get();
    if (!doc.exists) return null;
    return doc.data();
  }
}
