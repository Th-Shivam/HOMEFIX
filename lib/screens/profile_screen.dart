import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/subscription_provider.dart';

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
      backgroundColor: const Color(0xFF0A0A0C),
      body: Stack(
        children: [
          // Cinematic Background
          Positioned.fill(
            child: Image.asset(
              'assets/nivasa-homescreen.png',
              fit: BoxFit.cover,
              color: const Color(0xFF0A0A0C).withOpacity(0.5),
              colorBlendMode: BlendMode.srcOver,
            ),
          ),
          // Vignette
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: [
                    Colors.transparent,
                    const Color(0xFF0A0A0C).withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ),
          // Vertical Gradient
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
          Positioned.fill(
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(top: 80, bottom: 120, left: 24, right: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Row(
                        children: [
                          Icon(Icons.arrow_back_ios, color: const Color(0xFFA3A19E).withOpacity(0.5), size: 12),
                          const SizedBox(width: 8),
                          Text(
                            'BACK',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 9,
                              letterSpacing: 3.6,
                              color: const Color(0xFFA3A19E).withOpacity(0.5),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Profile Header
                    _buildGlassContainer(
                      child: Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.05),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: Center(
                              child: Text(
                                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                                style: const TextStyle(
                                  fontFamily: 'Raleway',
                                  fontSize: 24,
                                  color: Color(0xFFFBF8F4),
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name,
                                  style: const TextStyle(
                                    fontFamily: 'Raleway',
                                    fontSize: 22,
                                    fontWeight: FontWeight.w300,
                                    color: Color(0xFFFBF8F4),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user.email,
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 12,
                                    color: const Color(0xFFA3A19E).withOpacity(0.7),
                                  ),
                                ),
                                if (user.phone.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    user.phone,
                                    style: TextStyle(
                                      fontFamily: 'Manrope',
                                      fontSize: 12,
                                      color: const Color(0xFFA3A19E).withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          // Edit Button
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/edit-profile'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withOpacity(0.1)),
                              ),
                              child: const Text(
                                'EDIT',
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 10,
                                  letterSpacing: 1.0,
                                  color: Color(0xFFFBF8F4),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Subscription Card
                    _buildGlassContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                hasSubscription ? Icons.verified_outlined : Icons.card_membership_outlined,
                                color: hasSubscription ? const Color(0xFFFBBC00) : Colors.white.withOpacity(0.4),
                                size: 24,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'SUBSCRIPTION',
                                      style: TextStyle(
                                        fontFamily: 'Manrope',
                                        fontSize: 12,
                                        letterSpacing: 1.2,
                                        color: Color(0xE6FBF8F4),
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      subscription.planName,
                                      style: TextStyle(
                                        fontFamily: 'Manrope',
                                        fontSize: 10,
                                        color: hasSubscription ? const Color(0xFFFBBC00).withOpacity(0.8) : const Color(0xFFA3A19E).withOpacity(0.4),
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (hasSubscription) ...[
                            const SizedBox(height: 20),
                            Container(height: 1, color: Colors.white.withOpacity(0.05)),
                            const SizedBox(height: 20),
                            _buildDetailRow('Plan', subscription.planName),
                            const SizedBox(height: 12),
                            _buildDetailRow('Expires', subscription.formattedExpiry),
                            const SizedBox(height: 12),
                            _buildDetailRow('Days Remaining', '${subscription.daysRemaining} days'),
                            const SizedBox(height: 12),
                            _buildDetailRow('Status', subscription.description),
                          ],
                          if (!hasSubscription) ...[
                            const SizedBox(height: 24),
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(context, '/subscription'),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFFBBC00).withOpacity(0.3)),
                                ),
                                child: const Center(
                                  child: Text(
                                    'GET A SUBSCRIPTION',
                                    style: TextStyle(
                                      fontFamily: 'Manrope',
                                      fontSize: 11,
                                      letterSpacing: 2.0,
                                      color: Color(0xFFFBBC00),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Menu Items
                    _buildGlassContainer(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _buildMenuItem(
                            context,
                            icon: Icons.history_outlined,
                            title: 'Service History',
                            subtitle: 'View past service requests',
                            onTap: () {},
                          ),
                          Container(height: 1, color: Colors.white.withOpacity(0.05)),
                          _buildMenuItem(
                            context,
                            icon: Icons.payment_outlined,
                            title: 'Payment Methods',
                            subtitle: 'Manage your payment options',
                            onTap: () {},
                          ),
                          Container(height: 1, color: Colors.white.withOpacity(0.05)),
                          _buildMenuItem(
                            context,
                            icon: Icons.notifications_outlined,
                            title: 'Notifications',
                            subtitle: 'Manage notification preferences',
                            onTap: () {},
                          ),
                          Container(height: 1, color: Colors.white.withOpacity(0.05)),
                          _buildMenuItem(
                            context,
                            icon: Icons.help_outline,
                            title: 'Help & Support',
                            subtitle: 'Get help or contact us',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Logout Button
                    GestureDetector(
                      onTap: () async {
                        await authProvider.logout();
                        if (context.mounted) {
                          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE53935).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE53935).withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout_rounded, color: const Color(0xFFE53935).withOpacity(0.8), size: 18),
                            const SizedBox(width: 12),
                            Text(
                              'LOGOUT',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 11,
                                letterSpacing: 2.0,
                                color: const Color(0xFFE53935).withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Top Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildHeader(context),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassContainer({required Widget child, EdgeInsetsGeometry? padding}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 48, sigmaY: 48),
        child: Container(
          width: double.infinity,
          padding: padding ?? const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF0E0E12).withOpacity(0.4),
            border: Border.all(color: Colors.white.withOpacity(0.05), width: 0.5),
            borderRadius: BorderRadius.circular(24),
          ),
          child: child,
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
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 12,
            color: const Color(0xFFA3A19E).withOpacity(0.6),
            fontWeight: FontWeight.w300,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 12,
            color: Color(0xE6FBF8F4),
            fontWeight: FontWeight.w400,
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
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          children: [
            Icon(icon, color: Colors.white.withOpacity(0.4), size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 14,
                      color: Color(0xE6FBF8F4),
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 10,
                      color: const Color(0xFFA3A19E).withOpacity(0.4),
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Colors.white.withOpacity(0.1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.only(top: 40, left: 32, right: 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF0A0A0C).withOpacity(0.8),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'NIVASA',
            style: TextStyle(
              fontFamily: 'Raleway',
              fontSize: 16,
              letterSpacing: 6.4,
              color: Color(0xFFFBF8F4),
              fontWeight: FontWeight.w300,
              shadows: [
                Shadow(color: Color(0x1AFBF8F4), blurRadius: 15),
              ],
            ),
          ),
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
                  Icons.person_outline,
                  color: const Color(0xFFFBF8F4).withOpacity(0.4),
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
