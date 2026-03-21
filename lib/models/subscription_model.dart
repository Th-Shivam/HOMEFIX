/// Subscription plan types
enum PlanType { none, monthly, yearly }

/// Subscription model for HomeFix Pro
class SubscriptionModel {
  final PlanType planType;
  final DateTime? startDate;
  final DateTime? expiryDate;

  const SubscriptionModel({
    this.planType = PlanType.none,
    this.startDate,
    this.expiryDate,
  });

  /// Whether the subscription is currently active
  bool get isActive {
    if (planType == PlanType.none || expiryDate == null) return false;
    return DateTime.now().isBefore(expiryDate!);
  }

  /// Human-readable plan name
  String get planName {
    switch (planType) {
      case PlanType.monthly:
        return 'Monthly Plan';
      case PlanType.yearly:
        return 'Yearly Plan';
      case PlanType.none:
        return 'No Active Plan';
    }
  }

  /// Formatted expiry date
  String get formattedExpiry {
    if (expiryDate == null) return 'N/A';
    return '${expiryDate!.day}/${expiryDate!.month}/${expiryDate!.year}';
  }

  /// Days remaining in the subscription
  int get daysRemaining {
    if (expiryDate == null) return 0;
    final diff = expiryDate!.difference(DateTime.now()).inDays;
    return diff > 0 ? diff : 0;
  }

  /// Description based on plan type
  String get description {
    switch (planType) {
      case PlanType.yearly:
        return 'Unlimited service calls for 1 year';
      case PlanType.monthly:
        return 'Unlimited service calls for 30 days';
      case PlanType.none:
        return 'Subscribe to access services';
    }
  }

  /// Create a copy with updated fields
  SubscriptionModel copyWith({
    PlanType? planType,
    DateTime? startDate,
    DateTime? expiryDate,
  }) {
    return SubscriptionModel(
      planType: planType ?? this.planType,
      startDate: startDate ?? this.startDate,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }

  /// Default empty subscription
  static const SubscriptionModel empty = SubscriptionModel();
}
