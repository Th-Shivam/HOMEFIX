import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/mock_api_service.dart';

/// Manages authentication state for HomeFix Pro
class AuthProvider extends ChangeNotifier {
  UserModel _user = UserModel.guest;
  bool _isLoading = false;
  bool _hasSeenOnboarding = false;

  UserModel get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user.isLoggedIn;
  bool get hasSeenOnboarding => _hasSeenOnboarding;

  /// Mark onboarding as completed
  void completeOnboarding() {
    _hasSeenOnboarding = true;
    notifyListeners();
  }

  /// Login with email and password (mock)
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await MockApiService.login(email, password);
      if (result['success'] == true) {
        final userData = result['user'] as Map<String, dynamic>;
        _user = UserModel(
          name: userData['name'] as String,
          email: userData['email'] as String,
          phone: userData['phone'] as String,
          isLoggedIn: true,
        );
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      // Handle error silently in mock
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Signup with name, email, phone, password (mock)
  Future<bool> signup(String name, String email, String phone, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await MockApiService.signup(name, email, phone, password);
      if (result['success'] == true) {
        final userData = result['user'] as Map<String, dynamic>;
        _user = UserModel(
          name: userData['name'] as String,
          email: userData['email'] as String,
          phone: userData['phone'] as String,
          isLoggedIn: true,
        );
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      // Handle error silently in mock
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  /// Logout
  void logout() {
    _user = UserModel.guest;
    notifyListeners();
  }
}
