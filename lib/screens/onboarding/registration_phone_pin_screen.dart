import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_simplify/theme/app_theme.dart';
import 'package:mobile_simplify/screens/onboarding/registration_otp_screen.dart';

/// Inscription : téléphone + PIN (MVP : 1 choix).
class RegistrationPhonePinScreen extends StatefulWidget {
  const RegistrationPhonePinScreen({super.key});

  @override
  State<RegistrationPhonePinScreen> createState() => _RegistrationPhonePinScreenState();
}

class _RegistrationPhonePinScreenState extends State<RegistrationPhonePinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _msisdnController = TextEditingController();
  final _pinController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _msisdnController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  String? _validateMsisdn(String? v) {
    var s = (v ?? '').replaceAll(RegExp(r'\D'), '');
    if (s.isEmpty) return 'Téléphone requis';
    if (s.length == 9) s = '243$s';
    if (s.length != 12 || !s.startsWith('243')) {
      return 'Format +243 XXX XXX XXXX (9 chiffres après 243)';
    }
    return null;
  }

  String? _validatePin(String? v) {
    final s = v ?? '';
    if (s.length != 4) return 'PIN à 4 chiffres';
    if (!RegExp(r'^\d{4}$').hasMatch(s)) return 'Chiffres uniquement';
    return null;
  }

  String _normalizeMsisdn(String v) {
    var s = v.replaceAll(RegExp(r'\D'), '');
    if (s.length == 9) s = '243$s';
    return s;
  }

  void _submit() {
    _error = null;
    if (!_formKey.currentState!.validate()) return;
    final msisdn = _normalizeMsisdn(_msisdnController.text);
    final pin = _pinController.text.trim();
    setState(() => _loading = true);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() => _loading = false);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => RegistrationOtpScreen(msisdn: msisdn, pin: pin),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      appBar: AppBar(
        title: const Text('Inscription'),
        backgroundColor: AppTheme.sidebarBackground,
        foregroundColor: AppTheme.sidebarForeground,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D0D0D), Color(0xFF1A1A1A)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Téléphone et PIN',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Utilisez votre numéro RDC (+243). Le PIN sert à confirmer les opérations.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _msisdnController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d\s+]')),
                      LengthLimitingTextInputFormatter(14),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Téléphone (MSISDN)',
                      hintText: '+243 812 345 678',
                      prefixIcon: Icon(Icons.phone_android_rounded, color: Colors.grey.shade400),
                      filled: true,
                      fillColor: AppTheme.cardDark,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSmall)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        borderSide: BorderSide(color: AppTheme.cardDarkElevated),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                      ),
                      labelStyle: const TextStyle(color: Colors.white70),
                      hintStyle: TextStyle(color: Colors.white38),
                    ),
                    style: const TextStyle(color: Colors.white),
                    validator: _validateMsisdn,
                    onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _pinController,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    decoration: InputDecoration(
                      labelText: 'PIN (4 chiffres)',
                      hintText: '••••',
                      prefixIcon: Icon(Icons.lock_rounded, color: Colors.grey.shade400),
                      filled: true,
                      fillColor: AppTheme.cardDark,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSmall)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        borderSide: BorderSide(color: AppTheme.cardDarkElevated),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                      ),
                      labelStyle: const TextStyle(color: Colors.white70),
                      hintStyle: TextStyle(color: Colors.white38),
                    ),
                    style: const TextStyle(color: Colors.white),
                    validator: _validatePin,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.destructive.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline_rounded, color: AppTheme.destructive, size: 20),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_error!, style: const TextStyle(color: AppTheme.destructive, fontSize: 14))),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: AppTheme.primaryForeground,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                      ),
                      child: _loading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryForeground),
                            )
                          : const Text('Continuer'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
