import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../models/subscription_model.dart';
import '../providers/subscription_provider.dart';
import '../widgets/subscription_card.dart';
import '../widgets/gradient_button.dart';

/// Subscription plan screen showing monthly and yearly plans
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  PlanType _selectedPlan = PlanType.yearly;

  Future<void> _purchasePlan() async {
    final subProvider = context.read<SubscriptionProvider>();
    final success = await subProvider.purchasePlan(_selectedPlan);

    if (success && mounted) {
      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppConstants.successGreen.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppConstants.successGreen,
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Subscription Activated!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppConstants.surfaceDark,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                subProvider.subscription.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppConstants.grey600,
                ),
              ),
              const SizedBox(height: 24),
              GradientButton(
                text: 'Go to Home',
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final subProvider = context.watch<SubscriptionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Plan'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppConstants.surfaceDark,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8FAFF), Color(0xFFEEF2FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Header
              const Center(
                child: Column(
                  children: [
                    Text(
                      'Unlock Premium Services',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppConstants.surfaceDark,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Choose the plan that works best for you',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppConstants.grey600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Monthly Plan Card
              SubscriptionCard(
                planName: 'MONTHLY PLAN',
                price: AppConstants.monthlyPrice,
                duration: 'month',
                description:
                    'Perfect for short-term needs. Cancel anytime.',
                isBestValue: false,
                isSelected: _selectedPlan == PlanType.monthly,
                onTap: () {
                  setState(() => _selectedPlan = PlanType.monthly);
                },
              ),
              const SizedBox(height: 20),

              // Yearly Plan Card
              SubscriptionCard(
                planName: 'YEARLY PLAN',
                price: AppConstants.yearlyPrice,
                duration: 'year',
                description:
                    'Best value! Unlimited service calls for a full year.',
                isBestValue: true,
                isSelected: _selectedPlan == PlanType.yearly,
                onTap: () {
                  setState(() => _selectedPlan = PlanType.yearly);
                },
              ),
              const SizedBox(height: 16),

              // Price breakdown for yearly
              Center(
                child: Text(
                  'Yearly = ${AppConstants.currencySymbol}${AppConstants.monthlyPrice.toInt()} × 12 = ${AppConstants.currencySymbol}${AppConstants.yearlyPrice.toInt()}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppConstants.grey600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Purchase button
              GradientButton(
                text: 'Subscribe to ${_selectedPlan == PlanType.monthly ? "Monthly" : "Yearly"} Plan',
                isLoading: subProvider.isLoading,
                onPressed: _purchasePlan,
                icon: Icons.lock_open_rounded,
              ),
              const SizedBox(height: 16),

              // Terms
              Center(
                child: Text(
                  'By subscribing, you agree to our Terms of Service',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppConstants.grey600.withAlpha(180),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
