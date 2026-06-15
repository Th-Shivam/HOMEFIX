import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/db/collections.dart';
import '../core/db/firestore_mapper.dart';
import '../core/db/schema_enums.dart';
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
            .collection(DbCollections.subscriptions)
            .doc(user.uid)
            .get();
        if (doc.exists) {
          final data = doc.data()!;
          if (DbEnums.isSubscriptionActive(data[DbFields.paymentStatus] as String?)) {
            final plan = data[DbFields.planType] as String? ?? DbEnums.planYearly;
            _subscription = SubscriptionModel(
              planType: plan == DbEnums.planMonthly ? PlanType.monthly : PlanType.yearly,
              startDate: FirestoreMapper.timestampToDate(data[DbFields.subscriptionStartDate]) ?? DateTime.now(),
              expiryDate: FirestoreMapper.timestampToDate(data[DbFields.subscriptionEndDate]) ?? DateTime.now().add(const Duration(days: 365)),
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
