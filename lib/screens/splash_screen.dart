import 'package:flutter/material.dart';
import 'package:mobile_simplify/core/auth_service.dart';
import 'package:mobile_simplify/core/user_profile_service.dart';
import 'package:mobile_simplify/screens/login_screen.dart';
import 'package:mobile_simplify/screens/client/client_shell.dart';
import 'package:mobile_simplify/screens/agent/agent_shell.dart';
import 'package:mobile_simplify/screens/onboarding/registration_profile_screen.dart';
import 'package:mobile_simplify/theme/app_theme.dart';

/// Vérifie le token au démarrage et redirige : Login, Onboarding (profil), ou Client/Agent.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _auth = AuthService();
  final _profile = UserProfileService();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await _auth.loadFromStorage();
    if (!mounted) return;
    final user = _auth.currentUser;
    if (user == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }
    if (user.isClient) {
      final onboardingDone = await _profile.hasCompletedOnboarding();
      if (!mounted) return;
      if (!onboardingDone) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => RegistrationProfileScreen(msisdn: user.msisdn, pin: '')),
        );
        return;
      }
    }
    if (user.isClient) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => ClientShell(user: user)),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => AgentShell(user: user)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D0D0D),
              Color(0xFF1A1A1A),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo-light.png',
                height: 120,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.account_balance_wallet_rounded, size: 64, color: AppTheme.primary),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Simplify',
                style: TextStyle(
                  color: AppTheme.sidebarForeground,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppTheme.primary,
                  backgroundColor: AppTheme.primary.withOpacity(0.2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
