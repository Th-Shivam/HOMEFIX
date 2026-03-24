import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants.dart';
import '../providers/auth_provider.dart';
import '../providers/subscription_provider.dart';
import '../widgets/gradient_button.dart';

/// Profile screen showing user info, subscription status, and logout
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final subProvider = context.watch<SubscriptionProvider>();
    final user = authProvider.user;
    final subscription = subProvider.subscription;
    final hasSubscription = subProvider.hasActiveSubscription;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8FAFF), Color(0xFFEEF2FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 24),

                // ── Profile Header ──
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: AppConstants.primaryGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppConstants.primaryBlue.withAlpha(50),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Avatar
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(40),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withAlpha(80),
                            width: 3,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            user.name.isNotEmpty
                                ? user.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withAlpha(200),
                        ),
                      ),
                      if (user.phone.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          user.phone,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withAlpha(200),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Subscription Card ──
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(10),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: hasSubscription
                                  ? AppConstants.successGreen.withAlpha(20)
                                  : AppConstants.grey100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              hasSubscription
                                  ? Icons.verified_rounded
                                  : Icons.card_membership_rounded,
                              color: hasSubscription
                                  ? AppConstants.successGreen
                                  : AppConstants.grey600,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Subscription',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppConstants.surfaceDark,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  subscription.planName,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: hasSubscription
                                        ? AppConstants.successGreen
                                        : AppConstants.grey600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (hasSubscription) ...[
                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 16),
                        _buildDetailRow('Plan', subscription.planName),
                        const SizedBox(height: 10),
                        _buildDetailRow(
                          'Expires',
                          subscription.formattedExpiry,
                        ),
                        const SizedBox(height: 10),
                        _buildDetailRow(
                          'Days Remaining',
                          '${subscription.daysRemaining} days',
                        ),
                        const SizedBox(height: 10),
                        _buildDetailRow(
                          'Status',
                          subscription.description,
                        ),
                      ],
                      if (!hasSubscription) ...[
                        const SizedBox(height: 16),
                        GradientButton(
                          text: 'Get a Subscription',
                          icon: Icons.star_rounded,
                          gradient: AppConstants.accentGradient,
                          onPressed: () {
                            Navigator.pushNamed(context, '/subscription');
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Menu Items ──
                _buildMenuItem(
                  context,
                  icon: Icons.history_rounded,
                  title: 'Service History',
                  subtitle: 'View past service requests',
                  onTap: () {},
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.payment_rounded,
                  title: 'Payment Methods',
                  subtitle: 'Manage your payment options',
                  onTap: () {},
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'Manage notification preferences',
                  onTap: () {},
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.help_outline_rounded,
                  title: 'Help & Support',
                  subtitle: 'Get help or contact us',
                  onTap: () {},
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.info_outline_rounded,
                  title: 'About HomeFix Pro',
                  subtitle: 'Version 1.0.0',
                  onTap: () {},
                ),

                const SizedBox(height: 16),

                // ── Logout Button ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GradientButton(
                    text: 'Logout',
                    icon: Icons.logout_rounded,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE53935), Color(0xFFEF5350)],
                    ),
                    onPressed: () async {
                      await authProvider.logout();
                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false,
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppConstants.grey600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppConstants.surfaceDark,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppConstants.primaryBlue.withAlpha(15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      Icon(icon, color: AppConstants.primaryBlue, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppConstants.surfaceDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppConstants.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppConstants.grey300,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
