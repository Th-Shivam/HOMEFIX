import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/subscription_repository.dart';

/// Backward-compatible facade — delegates to [SubscriptionRepository].
class SubscriptionService {
  SubscriptionService({SubscriptionRepository? repository})
      : _repository = repository ?? SubscriptionRepository();

  final SubscriptionRepository _repository;

  Future<void> saveSubscription({
    required String name,
    required String mobile,
    required String alternateMobile,
    required String address,
    required String paymentStatus,
  }) async {
    await _repository.saveSubscription(
      name: name,
      mobile: mobile,
      alternateMobile: alternateMobile,
      address: address,
      planType: 'yearly',
    );
  }

  Future<String?> getPaymentStatus() => _repository.getPaymentStatus();
}
