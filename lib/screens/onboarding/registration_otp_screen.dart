import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_simplify/theme/app_theme.dart';
import 'package:mobile_simplify/screens/onboarding/registration_profile_screen.dart';

/// OTP simulé : code à 6 chiffres envoyé au numéro (mock).
class RegistrationOtpScreen extends StatefulWidget {
  final String msisdn;
  final String pin;

  const RegistrationOtpScreen({super.key, required this.msisdn, required this.pin});

  @override
  State<RegistrationOtpScreen> createState() => _RegistrationOtpScreenState();
}

class _RegistrationOtpScreenState extends State<RegistrationOtpScreen> {
  final _codeController = TextEditingController();
  bool _loading = false;
  String? _error;
  static const String _mockOtp = '123456';

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _submit() {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      setState(() => _error = 'Code à 6 chiffres');
      return;
    }
    setState(() {
      _error = null;
      _loading = true;
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      if (code != _mockOtp) {
        setState(() {
          _error = 'Code incorrect. Démo : $_mockOtp';
          _loading = false;
        });
        return;
      }
      setState(() => _loading = false);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => RegistrationProfileScreen(msisdn: widget.msisdn, pin: widget.pin),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final masked = widget.msisdn.length >= 6
        ? '${widget.msisdn.substring(0, 4)} *** *** ${widget.msisdn.substring(widget.msisdn.length - 2)}'
        : widget.msisdn;
    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      appBar: AppBar(
        title: const Text('Vérification'),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Code de vérification',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Un code a été envoyé au $masked (simulation). Démo : $_mockOtp',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 24, letterSpacing: 8),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  decoration: InputDecoration(
                    hintText: '000000',
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
                    hintStyle: TextStyle(color: Colors.white24, letterSpacing: 8),
                  ),
                  onChanged: (_) => setState(() => _error = null),
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
                        : const Text('Vérifier'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
