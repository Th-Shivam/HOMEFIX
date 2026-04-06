import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/subscription_model.dart';
import '../services/mock_api_service.dart';

/// Manages subscription state for HomeFix Pro
class SubscriptionProvider extends ChangeNotifier {
  SubscriptionModel _subscription = SubscriptionModel.empty;
  bool _isLoading = false;

  SubscriptionModel get subscription => _subscription;
  bool get isLoading => _isLoading;
  bool get hasActiveSubscription => _subscription.isActive;
  PlanType get currentPlan => _subscription.planType;

  /// Purchase a subscription plan (mock)
  Future<bool> purchasePlan(PlanType planType) async {
    _isLoading = true;
    notifyListeners();

    try {
      final sub = await MockApiService.purchaseSubscription(planType);
      _subscription = sub;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Cancel subscription
  void cancelSubscription() {
    _subscription = SubscriptionModel.empty;
    notifyListeners();
  }

  /// Sync subscription data from Firestore
  Future<void> syncWithFirestore() async {
    _isLoading = true;
    notifyListeners();
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('subscriptions')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          final data = doc.data()!;
          if (data['paymentStatus'] == 'active' || data['paymentStatus'] == 'done') {
            _subscription = SubscriptionModel(
              planType: PlanType.yearly, 
              startDate: (data['subscriptionStartDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
              expiryDate: (data['subscriptionEndDate'] as Timestamp?)?.toDate() ?? DateTime.now().add(const Duration(days: 365)),
            );
          } else {
            _subscription = SubscriptionModel.empty;
          }
        } else {
          _subscription = SubscriptionModel.empty;
        }
      }
    } catch (e) {
      debugPrint('SyncError: $e');
    }
    _isLoading = false;
    notifyListeners();
  }
}
