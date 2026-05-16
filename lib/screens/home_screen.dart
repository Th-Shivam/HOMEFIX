import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _activityKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

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
                controller: _scrollController,
                padding: const EdgeInsets.only(top: 80, bottom: 120, left: 24, right: 24),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroSection(user.name),
                    const SizedBox(height: 60),
                    _buildOSModules(context),
                    const SizedBox(height: 60),
                    _buildResidenceFeed(key: _activityKey),
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
          // Bottom OS Navigation
          Positioned(
            bottom: 32,
            left: 20,
            right: 20,
            child: _buildBottomNav(context),
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

  Widget _buildHeroSection(String name) {
    final firstName = name.isNotEmpty ? name.split(' ').first : 'Guest';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good Evening, $firstName'.toUpperCase(),
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 9,
            letterSpacing: 3.6,
            color: const Color(0xFFA3A19E).withOpacity(0.5),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Welcome Home',
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
        const SizedBox(height: 32),
        Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
          ),
          padding: const EdgeInsets.only(left: 24, top: 4, bottom: 4),
          child: Text(
            'Everything at your residence is running smoothly.',
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
      ],
    );
  }

  Widget _buildOSModules(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 24),
          child: Text(
            'Residence Services'.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 10,
              letterSpacing: 4.0,
              color: const Color(0xFFA3A19E).withOpacity(0.3),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _buildSmokedGlassCard(
                onTap: () => Navigator.pushNamed(
                  context,
                  '/service-request',
                  arguments: 'plumber',
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.handyman_outlined, color: Colors.white.withOpacity(0.4), size: 22),
                        Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.1), size: 18),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'MAINTENANCE',
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
                          'Request structural repairs or routine care',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 10,
                            color: const Color(0xFFA3A19E).withOpacity(0.4),
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                height: 128,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSmokedGlassCard(
                onTap: () => _showModuleMessage(context, 'Security support is coming soon.'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.shield_outlined, color: Colors.white.withOpacity(0.4), size: 22),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SECURITY',
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
                          'Home protection',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 10,
                            color: const Color(0xFFA3A19E).withOpacity(0.4),
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                height: 128,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSmokedGlassCard(
                onTap: () => _showModuleMessage(context, 'Concierge assistance is coming soon.'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.auto_awesome_outlined, color: Colors.white.withOpacity(0.4), size: 22),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CONCIERGE',
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
                          'Lifestyle assistance',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 10,
                            color: const Color(0xFFA3A19E).withOpacity(0.4),
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                height: 128,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSmokedGlassCard(
                onTap: () => _showModuleMessage(context, 'Climate controls are coming soon.'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.thermostat_outlined, color: Colors.white.withOpacity(0.4), size: 22),
                        Row(
                          children: [
                            Text(
                              '72°F',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 10,
                                color: const Color(0xFFFBBC00).withOpacity(0.8),
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
                                color: const Color(0xFFFBBC00).withOpacity(0.6),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CLIMATE',
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
                          'Indoor comfort & air purification',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 10,
                            color: const Color(0xFFA3A19E).withOpacity(0.4),
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                height: 128,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSmokedGlassCard({
    required Widget child,
    required double height,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 48, sigmaY: 48),
          child: Container(
            height: height,
            padding: const EdgeInsets.all(24),
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

  Widget _buildResidenceFeed({Key? key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.03))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  'Today at Home'.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 10,
                    letterSpacing: 4.0,
                    color: const Color(0xFFA3A19E).withOpacity(0.3),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                'LOG',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 10,
                  letterSpacing: 1.0,
                  color: const Color(0xFFA3A19E).withOpacity(0.6),
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Stack(
          children: [
            Positioned(
              left: 21,
              top: 8,
              bottom: 8,
              child: Container(
                width: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.08),
                      Colors.white.withOpacity(0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Column(
              children: [
                _buildTimelineItem(
                  isActive: true,
                  title: 'Estate Cleaning',
                  description: ' is currently in progress. 2 of 3 zones complete.',
                  timeInfo: 'NOW • LEVEL 4 PENTHOUSE',
                ),
                const SizedBox(height: 48),
                _buildTimelineItem(
                  isActive: false,
                  title: 'Pool Maintenance',
                  description: ' scheduled for tomorrow.',
                  timeInfo: 'TOMORROW • 10:00 AM',
                ),
                const SizedBox(height: 48),
                _buildTimelineItem(
                  isActive: false,
                  title: 'HVAC Specialist',
                  description: ' is en route to the estate.',
                  timeInfo: 'ETA 12 MINS • SOUTH GATE',
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimelineItem({
    required bool isActive,
    required String title,
    required String description,
    required String timeInfo,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 44,
          child: Center(
            child: Container(
              width: isActive ? 10 : 6,
              height: isActive ? 10 : 6,
              margin: EdgeInsets.only(top: isActive ? 6 : 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? const Color(0xFFFBBC00) : const Color(0xFF0A0A0C),
                border: isActive ? null : Border.all(color: Colors.white.withOpacity(0.2)),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFBBC00).withOpacity(0.4),
                          blurRadius: 12,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: isActive ? const Color(0xE6FBF8F4) : const Color(0xCCFBF8F4),
                    height: 1.6,
                    letterSpacing: 0.28,
                  ),
                  children: [
                    TextSpan(
                      text: title,
                      style: TextStyle(
                        color: isActive ? const Color(0xFFFBBC00) : const Color(0xFFFBF8F4),
                        fontWeight: isActive ? FontWeight.w400 : FontWeight.w300,
                      ),
                    ),
                    TextSpan(text: description),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                timeInfo,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 10,
                  letterSpacing: 1.5,
                  color: const Color(0xFFA3A19E).withOpacity(0.4),
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav(BuildContext context) {
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
              _buildNavItem(
                icon: Icons.home_filled,
                label: 'HOME',
                isActive: true,
                onTap: _scrollToTop,
              ),
              _buildNavItem(
                icon: Icons.grid_view_outlined,
                label: 'SERVICES',
                isActive: false,
                onTap: () => Navigator.pushNamed(context, '/service-request'),
              ),
              _buildNavItem(
                icon: Icons.auto_awesome_outlined,
                label: 'CONCIERGE',
                isActive: false,
                onTap: () => _showModuleMessage(context, 'Concierge assistance is coming soon.'),
              ),
              _buildNavItem(
                icon: Icons.history_edu_outlined,
                label: 'ACTIVITY',
                isActive: false,
                onTap: _scrollToActivity,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
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
              color: isActive ? const Color(0xFFFBF8F4) : const Color(0xFFFBF8F4).withOpacity(0.3),
              size: 22,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 8,
                letterSpacing: 2.0,
                color: isActive ? const Color(0xFFFBF8F4).withOpacity(0.9) : const Color(0xFFFBF8F4).withOpacity(0.4),
                fontWeight: isActive ? FontWeight.w500 : FontWeight.w300,
              ),
            ),
            if (isActive) ...[
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

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  void _scrollToActivity() {
    final context = _activityKey.currentContext;
    if (context == null) {
      return;
    }

    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      alignment: 0.12,
    );
  }

  void _showModuleMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF15161A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 110),
      ),
    );
  }
}
