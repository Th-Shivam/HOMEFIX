import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants.dart';
import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/subscription_provider.dart';
import 'providers/service_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/registration_screen.dart';
import 'screens/home_screen.dart';
import 'screens/subscription_screen.dart';
import 'screens/service_request_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/pending_verification_screen.dart';

/// Main app scaffold
class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}

/// The root app widget
class HomefixProApp extends StatelessWidget {
  const HomefixProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
        ChangeNotifierProvider(create: (_) => ServiceProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegistrationScreen(),
          '/main': (context) => const MainScaffold(),
          '/subscription': (context) => const SubscriptionScreen(),
          '/service-request': (context) => const ServiceRequestScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/pending': (context) => const PendingVerificationScreen(),
        },
      ),
    );
  }
}
