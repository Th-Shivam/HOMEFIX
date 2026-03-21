import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';

/// Entry point for HomeFix Pro
void main() {
  WidgetsFlutterBinding.ensureInitialized();

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
