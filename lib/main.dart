import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app.dart';

/// Entry point for HomeFix Pro
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase using google-services.json (Android native config).
  // No firebase_options.dart needed — the google-services.json file placed
  // in android/app/ handles everything automatically.
  await Firebase.initializeApp();

  // Set preferred orientations and status bar style
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const HomefixProApp());
}
