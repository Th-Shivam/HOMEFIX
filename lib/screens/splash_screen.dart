import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/subscription_provider.dart';
import '../services/subscription_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // ── Nivasa Design Tokens ──
  static const Color _bg = Color(0xFF0C0C0C);
  static const Color _champagne = Color(0xFFE2D1C3);

  late AnimationController _spinCtrl;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0C0C0C),
    ));

    _spinCtrl = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // ── Navigation logic (unchanged) ──
    Future.delayed(const Duration(milliseconds: 3500), () async {
      if (!mounted) return;
      final authProvider = context.read<AuthProvider>();

      int waited = 0;
      while (!authProvider.isAuthReady && waited < 50) {
        await Future.delayed(const Duration(milliseconds: 100));
        waited++;
      }

      if (!mounted) return;
      if (authProvider.isLoggedIn) {
        final paymentStatus = await SubscriptionService().getPaymentStatus();
        if (!mounted) return;
        if (paymentStatus == 'pending') {
          Navigator.pushReplacementNamed(context, '/pending');
        } else {
          await context.read<SubscriptionProvider>().syncWithFirestore();
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, '/main');
        }
      } else if (authProvider.hasSeenOnboarding) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    });
  }

  @override
  void dispose() {
    _spinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;
    // Responsive scale — designed at 390px width
    final s = (sw / 390).clamp(0.8, 1.3);
    // py-24 = 96px, px-margin-edge = 40px
    final hPad = 40.0 * s;
    final vPad = (96.0 * s).clamp(72.0, 120.0);

    return Scaffold(
      backgroundColor: _bg,
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── 1. Background image (full-screen, 70% right aligned) ──
          Image.asset(
            'assets/bg-splash.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            alignment: const Alignment(0.4, 0.0),
          ),

          // ── 2. Charcoal gradient overlay (left → right) ──
          // matches: linear-gradient(90deg, #0C0C0C 0%, #0C0C0C 40%,
          //          rgba(12,12,12,0.7) 70%, rgba(12,12,12,0) 100%)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFF0C0C0C),   // 0%
                    Color(0xFF0C0C0C),   // 40%
                    Color(0xB30C0C0C),   // 70% — rgba(12,12,12,0.7)
                    Color(0x000C0C0C),   // 100%
                  ],
                  stops: [0.0, 0.4, 0.7, 1.0],
                ),
              ),
            ),
          ),

          // ── 3. Warm amber tint — bg-amber-900/5 ──
          Positioned.fill(
            child: Container(color: const Color(0x0D78350F)),
          ),

          // ── 4. Main content — py-24 px-margin-edge, justify-between ──
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── TOP: Logo + Brand ──
                  _buildBrandSection(s),

                  const Spacer(),

                  // ── BOTTOM: Service grid (mb-12 = 48px) ──
                  _buildServiceGrid(s, sw),
                  SizedBox(height: 48 * s),
                ],
              ),
            ),
          ),

          // ── 5. Loading ring — fixed bottom-12, centered, opacity-40 ──
          Positioned(
            bottom: mq.padding.bottom + 48,
            left: 0,
            right: 0,
            child: Center(
              child: Opacity(
                opacity: 0.40,
                child: RotationTransition(
                  turns: _spinCtrl,
                  child: CustomPaint(
                    size: const Size(32, 32),
                    painter: _LoadingRingPainter(color: _champagne),
                  ),
                ),
              ),
            ),
          ),

          // ── 6. Screen border — border-tertiary/5 ──
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _champagne.withAlpha(13), // /5 opacity
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Top brand section: logo image + NIVASA + tagline
  Widget _buildBrandSection(double s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo image — w-10 h-10 mb-12 opacity-90
        Opacity(
          opacity: 0.90,
          child: Image.asset(
            'assets/splash-logo.png',
            width: 40 * s,
            height: 40 * s,
            fit: BoxFit.contain,
          ),
        ),

        SizedBox(height: 48 * s), // mb-12

        // Brand name — space-y-6 between h1 and p
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // h1: text-[32px] tracking-[0.5em] font-display-xl (Raleway)
            Text(
              'NIVASA',
              style: GoogleFonts.raleway(
                fontSize: 32 * s,
                fontWeight: FontWeight.w100,
                color: _champagne,
                letterSpacing: 32 * s * 0.5, // tracking-[0.5em]
                height: 1.0,
              ),
            ),

            SizedBox(height: 24 * s), // space-y-6

            // Tagline: text-[10px] tracking-[0.6em] text-tertiary/60
            Text(
              'YOUR HOME. FULLY MANAGED.',
              style: GoogleFonts.manrope(
                fontSize: 10 * s,
                fontWeight: FontWeight.w300,
                color: _champagne.withAlpha(153), // 60%
                letterSpacing: 10 * s * 0.6, // tracking-[0.6em]
                height: 1.0,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Service grid — grid-cols-2 gap-y-16 gap-x-12 max-w-[280px]
  Widget _buildServiceGrid(double s, double sw) {
    final items = [
      (Icons.home_repair_service, 'MAINTAIN'),
      (Icons.build, 'REPAIR'),
      (Icons.health_and_safety, 'CARE'),
      (Icons.upgrade, 'UPGRADE'),
      (Icons.cleaning_services, 'CLEAN'),
      (Icons.manage_accounts, 'MANAGE'),
    ];

    // gap-y-16 = 64px, gap-x-12 = 48px
    final gapY = 64.0 * s;
    final gapX = 48.0 * s;
    final itemW = (280 * s - gapX) / 2;

    return SizedBox(
      width: math.min(280 * s, sw - 80 * s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int row = 0; row < 3; row++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _serviceItem(items[row * 2], s, itemW),
                SizedBox(width: gapX),
                _serviceItem(items[row * 2 + 1], s, itemW),
              ],
            ),
            if (row < 2) SizedBox(height: gapY),
          ],
        ],
      ),
    );
  }

  /// Single service item — icon + label with gap-4
  Widget _serviceItem((IconData, String) item, double s, double width) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // icon: text-xl (20px), text-tertiary/80
          Icon(
            item.$1,
            size: 20 * s,
            color: _champagne.withAlpha(204), // 80%
          ),
          SizedBox(height: 16 * s), // gap-4
          // label: text-[9px] tracking-[0.4em] text-tertiary/40
          Text(
            item.$2,
            style: GoogleFonts.manrope(
              fontSize: 9 * s,
              fontWeight: FontWeight.w300,
              color: _champagne.withAlpha(102), // 40%
              letterSpacing: 9 * s * 0.4, // tracking-[0.4em]
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

/// CSS loading-ring equivalent:
/// border: 1px solid rgba(226,209,195,0.05) — full circle dim
/// border-top: 1px solid #E2D1C3 — bright arc at top
class _LoadingRingPainter extends CustomPainter {
  final Color color;
  _LoadingRingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0.5, 0.5, size.width - 1, size.height - 1);

    // Dim full ring — rgba(226,209,195,0.05)
    canvas.drawArc(
      rect, 0, math.pi * 2, false,
      Paint()
        ..color = color.withAlpha(13)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke,
    );

    // Bright top arc — border-top: 1px solid #E2D1C3
    canvas.drawArc(
      rect,
      -math.pi / 2,  // start at top
      math.pi / 2,   // quarter arc
      false,
      Paint()
        ..color = color
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}
