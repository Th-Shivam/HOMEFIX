import 'package:flutter/material.dart';
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
}
