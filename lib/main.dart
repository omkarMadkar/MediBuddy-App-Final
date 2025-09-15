import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'pages/splash_screen.dart';

void main() {
  runApp(const MediBuddyApp());
}

class MediBuddyApp extends StatelessWidget {
  const MediBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return MaterialApp(
      title: 'MediBuddy',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
