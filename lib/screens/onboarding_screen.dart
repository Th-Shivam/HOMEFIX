import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      'title': 'Luxury Home Care.\nHandled Seamlessly.',
      'subtitle':
          'Elevating the art of residence management through curated professional services.',
      'features': [
        {
          'icon': Icons.precision_manufacturing_outlined,
          'title': 'Smart Maintenance',
          'desc': 'Predictive scheduling for critical infrastructure.',
        },
        {
          'icon': Icons.verified_user_outlined,
          'title': 'Curated Professionals',
          'desc': 'Exclusive network of specialist craftsmen.',
        },
        {
          'icon': Icons.hotel_class_outlined,
          'title': 'Dedicated Concierge',
          'desc': 'Personal management for every residence detail.',
        },
      ],
    },
    {
      'title': 'Verified Experts.\nExceptional Care.',
      'subtitle':
          'From technicians to residence specialists, every service professional is carefully vetted for a seamless luxury experience.',
      'features': [
        {
          'icon': Icons.admin_panel_settings_outlined,
          'title': 'Verified Specialists',
          'desc': 'Professionally vetted luxury home experts.',
        },
        {
          'icon': Icons.event_available_outlined,
          'title': 'Priority Appointments',
          'desc': 'Fast access to premium scheduling.',
        },
        {
          'icon': Icons.support_agent_outlined,
          'title': 'Dedicated Concierge',
          'desc': 'Personalized support for every residence.',
        },
      ],
    },
    {
      'title': 'One Home.\nEverything Managed.',
      'subtitle':
          'Maintenance, upgrades, and residence operations unified through one seamless platform.',
      'features': [
        {
          'icon': Icons.dashboard_outlined,
          'title': 'Unified Home Dashboard',
          'desc': 'All residence operations in one place.',
        },
        {
          'icon': Icons.track_changes_outlined,
          'title': 'Smart Service Tracking',
          'desc': 'Track every service seamlessly.',
        },
        {
          'icon': Icons.lightbulb_outline,
          'title': 'Personalized Home Insights',
          'desc': 'Intelligent recommendations for your residence.',
        },
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0C0C0C),
    ));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() {
    context.read<AuthProvider>().completeOnboarding();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background Image & Overlays ──
          Image.asset(
            'assets/bg-splash.png',
            fit: BoxFit.cover,
            color: Colors.black.withOpacity(0.4),
            colorBlendMode: BlendMode.darken,
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black, Colors.transparent],
                  stops: [0.0, 1.0],
                ),
              ),
            ),
          ),

          // ── Content ──
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                children: [
                  // Header
                  _buildHeader(),

                  // Pages
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (idx) =>
                          setState(() => _currentPage = idx),
                      itemCount: _onboardingData.length,
                      itemBuilder: (context, index) {
                        return _buildPage(_onboardingData[index]);
                      },
                    ),
                  ),

                  // Footer
                  _buildFooter(),
                ],
              ),
            ),
          ),

          // ── Decorative Edges ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.home_outlined,
                color: Colors.white70, size: 20),
            const SizedBox(width: 12),
            Text(
              'NIVASA',
              style: GoogleFonts.raleway(
                fontSize: 11,
                fontWeight: FontWeight.w300,
                color: Colors.white.withOpacity(0.9),
                letterSpacing: 4.4, // 0.4em
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: _completeOnboarding,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'SKIP',
            style: GoogleFonts.manrope(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.4),
              letterSpacing: 2.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPage(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          data['title'],
          style: GoogleFonts.raleway(
            fontSize: 34,
            fontWeight: FontWeight.w200,
            color: Colors.white,
            height: 1.1,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          data['subtitle'],
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w300,
            color: Colors.white.withOpacity(0.5),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 48),
        ...List.generate((data['features'] as List).length, (index) {
          final feature = data['features'][index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildFeatureCard(feature),
          );
        }),
      ],
    );
  }

  Widget _buildFeatureCard(Map<String, dynamic> feature) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Icon(
                  feature['icon'],
                  color: Colors.white.withOpacity(0.7),
                  size: 16,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature['title'],
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.8),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      feature['desc'],
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        fontWeight: FontWeight.w300,
                        color: Colors.white.withOpacity(0.3),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: List.generate(3, (index) {
              bool isActive = _currentPage == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(right: 8),
                width: isActive ? 6 : 4,
                height: isActive ? 6 : 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? Colors.white
                      : Colors.white.withOpacity(0.2),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.3),
                            blurRadius: 8,
                          )
                        ]
                      : null,
                ),
              );
            }),
          ),
          GestureDetector(
            onTap: _onNext,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.6),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(
                    _currentPage == _onboardingData.length - 1
                        ? 'GET STARTED'
                        : 'CONTINUE',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 3.5, // 0.35em
                    ),
                  ),
                  const SizedBox(width: 20),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white.withOpacity(0.6),
                    size: 12,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
