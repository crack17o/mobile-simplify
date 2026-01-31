import 'package:flutter/material.dart';
import 'package:mobile_simplify/models/user.dart';
import 'package:mobile_simplify/theme/app_theme.dart';
import 'package:mobile_simplify/core/savings_service.dart';

/// Rejoindre une tontine : saisie PIN, vérification 20 % épargne, confirmation.
class TontineJoinScreen extends StatefulWidget {
  final AppUser user;

  const TontineJoinScreen({super.key, required this.user});

  @override
  State<TontineJoinScreen> createState() => _TontineJoinScreenState();
}

class _TontineJoinScreenState extends State<TontineJoinScreen> {
  final _pinController = TextEditingController();
  final _savings = SavingsService();
  bool _loading = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final pin = _pinController.text.trim();
    if (pin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saisissez le PIN de la tontine'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final msisdn = widget.user.msisdn;
    final savingsEnabled = await _savings.isEnabled(msisdn);
    final savingsBalance = await _savings.getBalanceCdf(msisdn);
    if (!savingsEnabled || savingsBalance <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compte épargne requis. Active et alimente ton épargne d\'abord.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.destructive,
        ),
      );
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    final cotisation = 5000.0;
    final members = 4;
    final totalTontine = cotisation * (members - 1);
    final minRequired = totalTontine * 0.2;
    if (savingsBalance < minRequired) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Épargne insuffisante. Minimum 20 % requis : ${minRequired.toStringAsFixed(0)} CDF. Tu as ${savingsBalance.toStringAsFixed(0)} CDF.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.destructive,
        ),
      );
      return;
    }
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Adhésion réussie. Bienvenue dans la tontine.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.success,
      ),
    );
    Navigator.pop(context);
  }

  InputDecoration _inputDecoration(String label, [String? hint]) {
    return InputDecoration(
      labelText: label,
      hintText: hint ?? '',
      labelStyle: const TextStyle(color: Colors.white70),
      hintStyle: TextStyle(color: Colors.white38),
      filled: true,
      fillColor: AppTheme.cardDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        borderSide: BorderSide(color: AppTheme.cardDarkElevated),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        borderSide: BorderSide(color: AppTheme.cardDarkElevated),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        borderSide: const BorderSide(color: AppTheme.primary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      appBar: AppBar(
        title: const Text('Rejoindre une tontine'),
        backgroundColor: AppTheme.sidebarBackground,
        foregroundColor: AppTheme.sidebarForeground,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              border: Border.all(color: AppTheme.cardDarkElevated),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: AppTheme.primary, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Entre le PIN fourni par l\'organisateur. Tu dois avoir au moins 20 % de la somme totale en épargne pour rejoindre.',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _pinController,
            style: const TextStyle(color: AppTheme.sidebarForeground, fontSize: 16),
            decoration: _inputDecoration('PIN de la tontine', 'Ex. TNT1234567'),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _loading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.primaryForeground,
              ),
              child: _loading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryForeground),
                    )
                  : const Text('Rejoindre'),
            ),
          ),
        ],
      ),
    );
  }
}
