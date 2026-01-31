import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_simplify/theme/app_theme.dart';
import 'package:mobile_simplify/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: AppTheme.sidebarBackground,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const SimplifyApp());
}

class SimplifyApp extends StatelessWidget {
  const SimplifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.light;
    return MaterialApp(
      title: 'Simplify',
      debugShowCheckedModeBanner: false,
      theme: theme.copyWith(
        textTheme: GoogleFonts.montserratTextTheme(theme.textTheme),
      ),
      home: const SplashScreen(),
    );
  }
}
