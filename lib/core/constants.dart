import 'package:flutter/material.dart';

/// App-wide constants for HomeFix Pro
class AppConstants {
  AppConstants._();

  // ── App Info ──
  static const String appName = 'HomeFix Pro';
  static const String appTagline = 'Your Home, Our Priority';

  // ── Subscription Prices ──
  static const double monthlyPrice = 300;
  static double get yearlyPrice => monthlyPrice * 12;

  // ── Colors ──
  static const Color primaryBlue = Color(0xFF0D47A1);
  static const Color primaryDark = Color(0xFF002171);
  static const Color primaryLight = Color(0xFF5472D3);
  static const Color accentOrange = Color(0xFFFF6D00);
  static const Color accentGold = Color(0xFFFFAB00);
  static const Color surfaceDark = Color(0xFF0A1929);
  static const Color cardDark = Color(0xFF132F4C);
  static const Color successGreen = Color(0xFF00C853);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey800 = Color(0xFF424242);

  // ── Gradient ──
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, Color(0xFF1565C0), Color(0xFF1976D2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentOrange, Color(0xFFFF9100)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [surfaceDark, Color(0xFF0D2137)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Strings ──
  static const String currencySymbol = '₹';

  // ── Onboarding ──
  static const List<Map<String, String>> onboardingData = [
    {
      'title': 'Expert Home Services',
      'subtitle':
          'Get professional electricians and plumbers at your doorstep with just a tap.',
      'icon': 'build',
    },
    {
      'title': 'Flexible Subscriptions',
      'subtitle':
          'Choose monthly or yearly plans that fit your budget. Unlimited service calls included.',
      'icon': 'card_membership',
    },
    {
      'title': 'Fast & Reliable',
      'subtitle':
          'Our verified technicians arrive quickly and get the job done right, every time.',
      'icon': 'speed',
    },
  ];
}
