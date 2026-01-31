import 'package:flutter/material.dart';
import 'package:mobile_simplify/models/user.dart';
import 'package:mobile_simplify/theme/app_theme.dart';

/// Encaisser un retrait : input code + montant (ou code seul si backend garde montant).
/// Confirmation OK / refus (expiré, déjà utilisé). Génération reçu simple (ref + date).
class RedeemCashoutScreen extends StatefulWidget {
  final AppUser user;

  const RedeemCashoutScreen({super.key, required this.user});

  @override
  State<RedeemCashoutScreen> createState() => _RedeemCashoutScreenState();
}

class _RedeemCashoutScreenState extends State<RedeemCashoutScreen> {
  final _codeController = TextEditingController();
  final _amountController = TextEditingController();
  bool _loading = false;
  bool? _success;
  String? _receiptRef;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_codeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code requis')),
      );
      return;
    }
    setState(() {
      _loading = true;
      _success = null;
      _error = null;
    });
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    // Mock: code ABC123 = OK, autre = refus (expiré)
    final code = _codeController.text.trim().toUpperCase();
    final ok = code.startsWith('ABC');
    setState(() {
      _loading = false;
      _success = ok;
      if (ok) {
        _receiptRef = 'RCP-${DateTime.now().millisecondsSinceEpoch}';
      } else {
        _error = 'Code expiré ou déjà utilisé';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_success == true && _receiptRef != null) {
      return Scaffold(
        backgroundColor: AppTheme.surfaceDark,
        appBar: AppBar(
          title: const Text('Reçu'),
          backgroundColor: AppTheme.sidebarBackground,
          foregroundColor: AppTheme.sidebarForeground,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_rounded, size: 80, color: AppTheme.success),
              const SizedBox(height: 24),
              Text('Encaissement réussi', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.sidebarForeground)),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.cardDark,
                  borderRadius: BorderRadius.circular(AppTheme.radius),
                  border: Border.all(color: AppTheme.cardDarkElevated),
                ),
                child: Column(
                  children: [
                    Text('Réf. reçu: $_receiptRef', style: const TextStyle(color: AppTheme.sidebarForeground)),
                    Text('Date: ${DateTime.now().toString().substring(0, 19)}', style: TextStyle(color: Colors.white54)),
                    if (_amountController.text.trim().isNotEmpty)
                      Text('Montant: ${_amountController.text.trim()} CDF', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: AppTheme.primaryForeground),
                  child: const Text('Terminer'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_success == false && _error != null) {
      return Scaffold(
        backgroundColor: AppTheme.surfaceDark,
        appBar: AppBar(
          title: const Text('Encaisser retrait'),
          backgroundColor: AppTheme.sidebarBackground,
          foregroundColor: AppTheme.sidebarForeground,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cancel_rounded, size: 80, color: AppTheme.destructive),
              const SizedBox(height: 24),
              Text(_error!, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.sidebarForeground), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => setState(() {
                    _success = null;
                    _error = null;
                  }),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: AppTheme.primaryForeground),
                  child: const Text('Réessayer'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      appBar: AppBar(
        title: const Text('Encaisser retrait'),
        backgroundColor: AppTheme.sidebarBackground,
        foregroundColor: AppTheme.sidebarForeground,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _codeController,
            style: const TextStyle(color: AppTheme.sidebarForeground),
            decoration: InputDecoration(
              labelText: 'Code retrait',
              hintText: 'Ex: ABC123',
              labelStyle: TextStyle(color: Colors.white70),
              hintStyle: TextStyle(color: Colors.white38),
              filled: true,
              fillColor: AppTheme.cardDark,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSmall), borderSide: BorderSide(color: AppTheme.cardDarkElevated)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSmall), borderSide: BorderSide(color: AppTheme.cardDarkElevated)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSmall), borderSide: const BorderSide(color: AppTheme.primary)),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppTheme.sidebarForeground),
            decoration: InputDecoration(
              labelText: 'Montant (optionnel)',
              hintText: 'CDF',
              labelStyle: TextStyle(color: Colors.white70),
              hintStyle: TextStyle(color: Colors.white38),
              filled: true,
              fillColor: AppTheme.cardDark,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSmall), borderSide: BorderSide(color: AppTheme.cardDarkElevated)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSmall), borderSide: BorderSide(color: AppTheme.cardDarkElevated)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSmall), borderSide: const BorderSide(color: AppTheme.primary)),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: AppTheme.destructive)),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _loading ? null : _submit,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: AppTheme.primaryForeground),
              child: _loading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryForeground),
                    )
                  : const Text('Valider encaissement'),
            ),
          ),
        ],
      ),
    );
  }
}
