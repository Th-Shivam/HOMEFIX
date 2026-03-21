import '../models/subscription_model.dart';
import '../models/service_request_model.dart';

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

  /// Simulate service request
  static Future<ServiceRequestModel> requestService(ServiceType type) async {
    await Future.delayed(const Duration(seconds: 2));

    final techNames = {
      ServiceType.electrician: ['Rajesh Kumar', 'Amit Sharma', 'Vikram Singh'],
      ServiceType.plumber: ['Suresh Patel', 'Mohan Das', 'Ravi Verma'],
    };

    final names = techNames[type]!;
    final name = names[DateTime.now().millisecond % names.length];

    return ServiceRequestModel(
      serviceType: type,
      status: ServiceStatus.technicianOnWay,
      requestTime: DateTime.now(),
      technicianName: name,
    );
  }
}
