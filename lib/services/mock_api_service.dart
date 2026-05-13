import '../models/subscription_model.dart';

/// Mock API service that simulates backend calls using Future.delayed
class MockApiService {
  MockApiService._();

  /// Simulate login call
  static Future<Map<String, dynamic>> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));
    return {
      'success': true,
      'user': {
        'name': 'Arya Yadav',
        'email': email,
        'phone': '+91 98765 43210',
      },
    };
  }

  /// Simulate signup call
  static Future<Map<String, dynamic>> signup(
    String name,
    String email,
    String phone,
    String password,
  ) async {
    await Future.delayed(const Duration(seconds: 2));
    return {
      'success': true,
      'user': {
        'name': name,
        'email': email,
        'phone': phone,
      },
    };
  }

  /// Simulate OTP verification
  static Future<bool> verifyOtp(String otp) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    return otp.length == 6; // Any 6-digit OTP is valid in mock
  }

  /// Simulate subscription purchase
  static Future<SubscriptionModel> purchaseSubscription(PlanType planType) async {
    await Future.delayed(const Duration(seconds: 2));
    final now = DateTime.now();
    final expiry = planType == PlanType.monthly
        ? now.add(const Duration(days: 30))
        : now.add(const Duration(days: 365));

    return SubscriptionModel(
      planType: planType,
      startDate: now,
      expiryDate: expiry,
    );
  }
}
