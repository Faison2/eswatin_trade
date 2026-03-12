import 'package:ese/screens/splash/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const ESEApp());
}

class ESEApp extends StatelessWidget {
  const ESEApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ESE – Eswatini Stock Exchange',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: ESEColors.primary,
          brightness: Brightness.dark,
        ),
        fontFamily: 'Georgia',
      ),
      home: const SplashScreen(),
    );
  }
}

// ─── Brand Colors ────────────────────────────────────────────────────────────
class ESEColors {
  static const Color primary   = Color(0xFF1A5FAD); // ESE blue
  static const Color accent    = Color(0xFFE8612C); // ESE orange
  static const Color darkNavy  = Color(0xFF0A1E3D); // deep background
  static const Color midNavy   = Color(0xFF122B55); // card bg
  static const Color lightBlue = Color(0xFF4A90D9); // highlight
  static const Color cream     = Color(0xFFF5F0E8); // warm text
  static const Color gold      = Color(0xFFD4A843); // premium accent
}