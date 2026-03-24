import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

/// AuthService — handles all Firebase Authentication operations.
/// Supports Email/Password sign-in and Google Sign-In.
class AuthService {
  // ── Firebase instances ───────────────────────────────────────────────────
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // GoogleSignIn instance — scopes define what user data we request
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // ── Auth state stream ────────────────────────────────────────────────────

  /// Emits a [User] whenever the user logs in/out.
  /// AuthProvider listens to this to keep the UI in sync automatically.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// The currently signed-in Firebase user (null if not logged in).
  User? get currentFirebaseUser => _auth.currentUser;

  // ── Email / Password ─────────────────────────────────────────────────────

  /// Helper method to validate email structure
  bool _isValidEmail(String email) {
    final regex = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return regex.hasMatch(email);
  }

  /// Creates a new account with email + password.
  /// Validates inputs and saves extra profile data to Firestore.
  Future<UserModel> signUpWithEmail({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    // 1. Input Validation
    if (!_isValidEmail(email)) {
      throw Exception('Invalid email format.');
    }
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters.');
    }
    if (name.trim().isEmpty) {
      throw Exception('Name cannot be empty.');
    }

    try {
      // 2. Create user in Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user!;

      // 3. Set display name so it shows in Firebase Console
      await user.updateDisplayName(name.trim());

      // 4. Save extra info in Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'photoUrl': null,
        'provider': 'email',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return UserModel(
        uid: user.uid,
        name: name.trim(),
        email: email.trim(),
        phone: phone.trim(),
        isLoggedIn: true,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  /// Signs in an existing user with email + password.
  /// Validates inputs and handles errors properly.
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    // 1. Input Validation
    if (!_isValidEmail(email)) {
      throw Exception('Invalid email format.');
    }
    if (password.isEmpty) {
      throw Exception('Password cannot be empty.');
    }

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user!;

      // Fetch extra profile data from Firestore
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final data = doc.data();

      return UserModel(
        uid: user.uid,
        name: data?['name'] as String? ?? user.displayName ?? 'User',
        email: user.email ?? email,
        phone: data?['phone'] as String? ?? '',
        isLoggedIn: true,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(getErrorMessage(e));
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  // ── Google Sign-In ───────────────────────────────────────────────────────

  /// Triggers the Google account picker and signs the user into Firebase.
  ///
  /// Flow:
  ///   1. Open Google account chooser (GoogleSignIn)
  ///   2. Get an auth token from Google
  ///   3. Pass it to Firebase Auth → get a Firebase session
  ///   4. Save / update the user profile in Firestore
  ///   5. Return a [UserModel] with name, email, and photo URL
  Future<UserModel?> signInWithGoogle() async {
    // Step 1: Open the Google account picker
    final GoogleSignInAccount? googleAccount = await _googleSignIn.signIn();

    // User cancelled the picker — return null (not an error)
    if (googleAccount == null) return null;

    // Step 2: Get Google auth tokens
    final GoogleSignInAuthentication googleAuth =
        await googleAccount.authentication;

    // Step 3: Create a Firebase credential using Google tokens
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Step 4: Sign in to Firebase with that credential
    final UserCredential userCredential =
        await _auth.signInWithCredential(credential);
    final User firebaseUser = userCredential.user!;

    // Step 5: Save / update profile in Firestore
    // merge: true → won't overwrite existing data if the user re-logs in
    await _firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .set({
      'uid': firebaseUser.uid,
      'name': firebaseUser.displayName ?? googleAccount.displayName ?? 'User',
      'email': firebaseUser.email ?? '',
      'photoUrl': firebaseUser.photoURL,
      'phone': '', // Google doesn't provide phone number
      'provider': 'google',
      'lastLoginAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Step 6: Return UserModel
    return UserModel(
      uid: firebaseUser.uid,
      name: firebaseUser.displayName ?? 'User',
      email: firebaseUser.email ?? '',
      phone: '',
      photoUrl: firebaseUser.photoURL,
      isLoggedIn: true,
    );
  }

  // ── Shared Helper ────────────────────────────────────────────────────────

  /// Builds a [UserModel] from an already-signed-in Firebase user.
  /// Called by AuthProvider at app startup via authStateChanges.
  Future<UserModel> getUserModel(User firebaseUser) async {
    final doc =
        await _firestore.collection('users').doc(firebaseUser.uid).get();
    final data = doc.data();

    return UserModel(
      uid: firebaseUser.uid,
      name: data?['name'] as String? ?? firebaseUser.displayName ?? 'User',
      email: firebaseUser.email ?? '',
      phone: data?['phone'] as String? ?? '',
      photoUrl: data?['photoUrl'] as String? ?? firebaseUser.photoURL,
      isLoggedIn: true,
    );
  }

  // ── Sign Out ─────────────────────────────────────────────────────────────

  /// Signs out from both Firebase Auth and Google Sign-In.
  /// Signing out of GoogleSignIn ensures the account picker shows next time.
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(), // clears Google session too
      ]);
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  // ── Error Handling ───────────────────────────────────────────────────────

  /// Converts FirebaseAuthException error codes to user-friendly messages.
  static String getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered. Please login.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
