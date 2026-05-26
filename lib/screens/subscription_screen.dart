// lib/screens/subscription_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/subscription_model.dart';
import '../providers/subscription_provider.dart';
import '../widgets/subscription_card.dart';

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
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 48, sigmaY: 48),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: const Color(0xFF0E0E12).withOpacity(0.8),
                border: Border.all(color: const Color(0xFFFBBC00).withOpacity(0.3), width: 0.5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.workspace_premium_outlined,
                    color: const Color(0xFFFBBC00),
                    size: 48,
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'MEMBERSHIP\nACTIVATED',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 20,
                      fontWeight: FontWeight.w300,
                      color: Color(0xFFFBF8F4),
                      letterSpacing: 4.0,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.read<SubscriptionProvider>().subscription.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 13,
                      color: const Color(0xFFA3A19E).withOpacity(0.8),
                      fontWeight: FontWeight.w300,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 48),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBBC00),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text(
                          'CONTINUE',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2.4,
                            color: Color(0xFF0A0A0C),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subProvider = context.watch<SubscriptionProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0C),
      body: Stack(
        children: [
          // Cinematic Background
          Positioned.fill(
            child: Image.asset(
              'assets/nivasa-homescreen.png',
              fit: BoxFit.cover,
              color: const Color(0xFF0A0A0C).withOpacity(0.6),
              colorBlendMode: BlendMode.srcOver,
              errorBuilder: (context, error, stackTrace) => Container(),
            ),
          ),
          // Vignette & Gradients
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    Colors.transparent,
                    const Color(0xFF0A0A0C).withOpacity(0.9),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0A0A0C),
                    Colors.transparent,
                    Colors.transparent,
                    Color(0xFF0A0A0C),
                  ],
                  stops: [0.0, 0.2, 0.8, 1.0],
                ),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40, left: 32, right: 32, bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.05),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.arrow_back_ios_new,
                                color: const Color(0xFFFBF8F4).withOpacity(0.6),
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                        const Text(
                          'NIVASA PRO',
                          style: TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 14,
                            letterSpacing: 6.0,
                            color: Color(0xFFFBF8F4),
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        const SizedBox(width: 40), // Balance the back button
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 32),
                        Text(
                          'ELEVATE YOUR\nESTATE',
                          style: TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 32,
                            fontWeight: FontWeight.w200,
                            letterSpacing: 4.0,
                            color: const Color(0xFFFBF8F4),
                            height: 1.3,
                            shadows: [
                              Shadow(color: const Color(0x1AFBF8F4), blurRadius: 15),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(color: Colors.white.withOpacity(0.1)),
                            ),
                          ),
                          padding: const EdgeInsets.only(left: 24, top: 4, bottom: 4),
                          child: Text(
                            'Choose a membership tier that aligns with your residence requirements.',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                              color: const Color(0xFFA3A19E).withOpacity(0.7),
                              height: 1.6,
                              letterSpacing: 0.28,
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Yearly Plan Card
                        SubscriptionCard(
                          planName: 'ANNUAL MEMBERSHIP',
                          price: 3600, // Hardcoded for aesthetics or use AppConstants.yearlyPrice
                          duration: 'year',
                          description: 'Complete peace of mind for a full year with priority concierge.',
                          isBestValue: true,
                          isSelected: _selectedPlan == PlanType.yearly,
                          onTap: () => setState(() => _selectedPlan = PlanType.yearly),
                        ),
                        const SizedBox(height: 24),

                        // Monthly Plan Card
                        SubscriptionCard(
                          planName: 'MONTHLY ACCESS',
                          price: 300,
                          duration: 'month',
                          description: 'Flexible access to all premium estate services.',
                          isBestValue: false,
                          isSelected: _selectedPlan == PlanType.monthly,
                          onTap: () => setState(() => _selectedPlan = PlanType.monthly),
                        ),
                        const SizedBox(height: 140), // Space for bottom button
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom Action
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(32, 32, 32, 48),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF0A0A0C).withOpacity(0.2),
                        const Color(0xFF0A0A0C).withOpacity(0.9),
                        const Color(0xFF0A0A0C),
                      ],
                    ),
                  ),
                  child: GestureDetector(
                    onTap: subProvider.isLoading ? null : _purchasePlan,
                    child: Container(
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBF8F4),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: subProvider.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Color(0xFF0A0A0C),
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'AUTHORIZE PLAN',
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 3.0,
                                  color: const Color(0xFF0A0A0C),
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
