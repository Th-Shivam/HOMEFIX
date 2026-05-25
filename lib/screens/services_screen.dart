import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  static const _background = Color(0xFF0C0E11);
  static const _surface = Color(0xFF1E2023);
  static const _text = Color(0xFFE2E2E6);
  static const _muted = Color(0xFFD0C5AF);
  static const _gold = Color(0xFFF2CA50);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
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
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MANAGEMENT',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 10,
                            letterSpacing: 4.0,
                            color: const Color(0xFFA3A19E).withOpacity(0.3),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Residence Services',
                          style: TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 36,
                            fontWeight: FontWeight.w200,
                            letterSpacing: 4.32,
                            color: Color(0xFFFBF8F4),
                            height: 1.2,
                            shadows: [
                              Shadow(color: Color(0x1AFBF8F4), blurRadius: 15),
                            ],
                          ),
                        ),
                        const SizedBox(height: 42),
                        _ServicesGrid(
                          onRequest: () => Navigator.pushNamed(context, '/service-request'),
                        ),
                        const SizedBox(height: 32),
                        _RequestButton(
                          onTap: () => Navigator.pushNamed(context, '/service-request'),
                        ),
                        const SizedBox(height: 50),
                        const _UpcomingSection(),
                      ],
                    ),
                  ),
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
          // Bottom OS Navigation
          Positioned(
            bottom: 32,
            left: 20,
            right: 20,
            child: _BottomNav(context: context),
          ),
        ],
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
            onTap: () => Navigator.pushNamed(context, '/profile'),
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

class _ServicesGrid extends StatelessWidget {
  const _ServicesGrid({required this.onRequest});

  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _GlassCard(
          height: 128,
          onTap: onRequest,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.handyman_outlined, color: Colors.white.withOpacity(0.4), size: 22),
                  Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.1), size: 18),
                ],
              ),
              _ServiceCopy(
                title: 'Maintenance',
                subtitle: 'Structural repairs or routine care',
                large: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Row(
          children: [
            Expanded(
              child: _SmallServiceCard(
                icon: Icons.shield_outlined,
                title: 'Security',
                subtitle: 'Home protection &\nsurveillance',
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _SmallServiceCard(
                icon: Icons.auto_awesome_outlined,
                title: 'Concierge',
                subtitle: 'Lifestyle assistance &\nbookings',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Row(
          children: [
            Expanded(
              child: _SmallServiceCard(
                icon: Icons.spa_outlined,
                title: 'Wellness',
                subtitle: 'Spa bookings & private\nchefs',
              ),
            ),
            SizedBox(width: 16),
            Expanded(child: _ClimateCard()),
          ],
        ),
        const SizedBox(height: 16),
        const _HousekeepingCard(),
      ],
    );
  }
}

class _SmallServiceCard extends StatelessWidget {
  const _SmallServiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      height: 128,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.4), size: 22),
          _ServiceCopy(title: title, subtitle: subtitle),
        ],
      ),
    );
  }
}

class _ClimateCard extends StatelessWidget {
  const _ClimateCard();

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      height: 128,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.thermostat_outlined, color: Colors.white.withOpacity(0.4), size: 22),
              Row(
                children: [
                  const Text(
                    '72°F',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 10,
                      color: Color(0xFFFBBC00),
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFBBC00).withOpacity(0.6),
                    ),
                  ),
                ],
              )
            ],
          ),
          const _ServiceCopy(
            title: 'Climate',
            subtitle: 'Indoor comfort control',
          ),
        ],
      ),
    );
  }
}

class _HousekeepingCard extends StatelessWidget {
  const _HousekeepingCard();

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      height: 128,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.cleaning_services_outlined, color: Colors.white.withOpacity(0.4), size: 22),
              Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.1), size: 18),
            ],
          ),
          const _ServiceCopy(
            title: 'Housekeeping',
            subtitle: 'Deep cleaning & laundry services',
          ),
        ],
      ),
    );
  }
}

class _ServiceCopy extends StatelessWidget {
  const _ServiceCopy({
    required this.title,
    required this.subtitle,
    this.large = false,
  });

  final String title;
  final String subtitle;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 12,
            letterSpacing: 1.2,
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
    );
  }
}


class _GlassCard extends StatelessWidget {
  const _GlassCard({
    required this.child,
    required this.height,
    required this.padding,
    this.onTap,
  });

  final Widget child;
  final double height;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 48, sigmaY: 48),
          child: Container(
            height: height,
            width: double.infinity,
            padding: padding,
            decoration: BoxDecoration(
              color: const Color(0xFF0E0E12).withOpacity(0.4),
              border: Border.all(color: Colors.white.withOpacity(0.05), width: 0.5),
              borderRadius: BorderRadius.circular(24),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _RequestButton extends StatelessWidget {
  const _RequestButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 66,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.38)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.34),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.rotate(
              angle: 0.52,
              child: const Icon(
                Icons.rocket_launch_outlined,
                color: ServicesScreen._gold,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'RAISE A SERVICE REQUEST',
              style: GoogleFonts.manrope(
                color: ServicesScreen._gold,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpcomingSection extends StatelessWidget {
  const _UpcomingSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'UPCOMING',
              style: GoogleFonts.manrope(
                color: ServicesScreen._muted.withOpacity(0.55),
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.6,
              ),
            ),
            Text(
              'VIEW ALL',
              style: GoogleFonts.manrope(
                color: ServicesScreen._gold,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 26),
        const _UpcomingItem(
          active: true,
          title: 'Garden Landscaping',
          time: 'TOMORROW • 08:00 AM',
        ),
        const SizedBox(height: 20),
        const _UpcomingItem(
          active: false,
          title: 'Window Cleaning',
          time: 'FRIDAY • 10:00 AM',
        ),
      ],
    );
  }
}

class _UpcomingItem extends StatelessWidget {
  const _UpcomingItem({
    required this.active,
    required this.title,
    required this.time,
  });

  final bool active;
  final String title;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? ServicesScreen._gold : ServicesScreen._muted.withOpacity(0.2),
            shape: BoxShape.circle,
            boxShadow: active
                ? [
                    BoxShadow(
                      color: ServicesScreen._gold.withOpacity(0.5),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.manrope(
                color: ServicesScreen._text,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              time,
              style: GoogleFonts.manrope(
                color: ServicesScreen._muted.withOpacity(0.45),
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 3,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.context});

  final BuildContext context;

  @override
  Widget build(BuildContext _) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A0E).withOpacity(0.85),
            border: Border.all(color: Colors.white.withOpacity(0.03), width: 0.5),
            borderRadius: BorderRadius.circular(32),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_filled,
                label: 'HOME',
                active: false,
                onTap: () => Navigator.pop(context),
              ),
              _NavItem(
                icon: Icons.grid_view_outlined,
                label: 'SERVICES',
                active: true,
                onTap: () {},
              ),
              _NavItem(
                icon: Icons.auto_awesome_outlined,
                label: 'CONCIERGE',
                active: false,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Concierge assistance is coming soon.'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: const Color(0xFF15161A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      margin: const EdgeInsets.fromLTRB(20, 0, 20, 110),
                    ),
                  );
                },
              ),
              _NavItem(
                icon: Icons.history_edu_outlined,
                label: 'ACTIVITY',
                active: false,
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    this.active = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 70,
        height: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: active ? const Color(0xFFFBF8F4) : const Color(0xFFFBF8F4).withOpacity(0.3),
              size: 22,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 8,
                letterSpacing: 2.0,
                color: active ? const Color(0xFFFBF8F4).withOpacity(0.9) : const Color(0xFFFBF8F4).withOpacity(0.4),
                fontWeight: active ? FontWeight.w500 : FontWeight.w300,
              ),
            ),
            if (active) ...[
              const SizedBox(height: 4),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFBBC00),
                ),
              ),
            ] else ...[
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}
