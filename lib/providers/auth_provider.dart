import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Manages authentication state for HomeFix Pro using Firebase Auth.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel _user = UserModel.guest;
  bool _isLoading = false;
  bool _hasSeenOnboarding = false;
  bool _isAuthReady = false; // true once Firebase auth state is first resolved
  String? _errorMessage;

  UserModel get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user.isLoggedIn;
  bool get hasSeenOnboarding => _hasSeenOnboarding;
  bool get isAuthReady => _isAuthReady;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    // Listen to Firebase auth state changes so the app reacts automatically
    // when a user logs in or out (including on cold start / app restart).
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _user = UserModel.guest;
    } else {
      try {
        _user = await _authService.getUserModel(firebaseUser);
      } catch (_) {
        // Fallback if Firestore is unavailable
        _user = UserModel(
          uid: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'User',
          email: firebaseUser.email ?? '',
          phone: '',
          isLoggedIn: true,
        );
      }
    }
    _isAuthReady = true;
    notifyListeners();
  }

  /// Mark onboarding as seen
  void completeOnboarding() {
    _hasSeenOnboarding = true;
    notifyListeners();
  }

  /// Sign in with email and password
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = AuthService.getErrorMessage(e);
    } catch (_) {
      _errorMessage = 'Something went wrong. Please try again.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Sign up with name, email, phone, and password
  Future<bool> signup(
      String name, String email, String phone, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _authService.signUpWithEmail(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = AuthService.getErrorMessage(e);
    } catch (_) {
      _errorMessage = 'Something went wrong. Please try again.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Sign out
  Future<void> logout() async {
    await _authService.signOut();
    // _onAuthStateChanged will update _user to guest automatically
  }

  /// Sign in with Google.
  /// Returns true on success, false if user cancelled or an error occurred.
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.signInWithGoogle();

      // User cancelled the Google picker — not an error
      if (result == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _user = result;
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = AuthService.getErrorMessage(e);
    } catch (_) {
      _errorMessage = 'Google Sign-In failed. Please try again.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Clear any displayed error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
