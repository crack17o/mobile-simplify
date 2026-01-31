import 'package:flutter/material.dart';
import 'package:mobile_simplify/models/user.dart';
import 'package:mobile_simplify/theme/app_theme.dart';
import 'package:mobile_simplify/core/savings_service.dart';

/// Épargne manuelle : montant + PIN → SUCCESS/FAILED.
class EpargneManuelleScreen extends StatefulWidget {
  final AppUser user;

  const EpargneManuelleScreen({super.key, required this.user});

  @override
  State<EpargneManuelleScreen> createState() => _EpargneManuelleScreenState();
}

class _EpargneManuelleScreenState extends State<EpargneManuelleScreen> {
  final _montantController = TextEditingController();
  final _pinController = TextEditingController();
  final _savings = SavingsService();
  bool _loading = false;
  bool? _success;
  String? _error;

  @override
  void dispose() {
    _montantController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_montantController.text.trim().replaceAll(' ', ''));
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Montant invalide');
      return;
    }
    if (_pinController.text.trim().length < 4) {
      setState(() => _error = 'PIN requis (4 chiffres)');
      return;
    }
    setState(() {
      _error = null;
      _loading = true;
    });
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    final ok = _pinController.text.trim() == '0000'; // mock: PIN 0000 = success
    if (ok) {
      await _savings.addToBalance(amount);
      await _savings.addHistoryEntry(
        '${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year} ${DateTime.now().hour}:${DateTime.now().minute}',
        amount,
        'SUCCESS',
      );
    } else {
      await _savings.addHistoryEntry(
        '${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}',
        amount,
        'FAILED',
        'PIN incorrect',
      );
    }
    if (mounted) {
      setState(() {
        _loading = false;
        _success = ok;
      });
    }
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white70),
      hintStyle: TextStyle(color: Colors.white38),
      filled: true,
      fillColor: AppTheme.cardDark,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSmall), borderSide: BorderSide(color: AppTheme.cardDarkElevated)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSmall), borderSide: BorderSide(color: AppTheme.cardDarkElevated)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSmall), borderSide: const BorderSide(color: AppTheme.primary)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_success != null) {
      return Scaffold(
        backgroundColor: AppTheme.surfaceDark,
        appBar: AppBar(title: const Text('Épargne manuelle'), backgroundColor: AppTheme.sidebarBackground, foregroundColor: AppTheme.sidebarForeground),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_success! ? Icons.check_circle_rounded : Icons.cancel_rounded, size: 80, color: _success! ? AppTheme.success : AppTheme.destructive),
              const SizedBox(height: 24),
              Text(_success! ? 'Transaction réussie' : 'Échec', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.sidebarForeground)),
              if (!_success!) Text(_error ?? 'Fonds insuffisants ou PIN incorrect', style: TextStyle(color: Colors.white70), textAlign: TextAlign.center),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: AppTheme.primaryForeground),
                  child: const Text('Retour'),
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
        title: const Text('Épargner maintenant'),
        backgroundColor: AppTheme.sidebarBackground,
        foregroundColor: AppTheme.sidebarForeground,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _montantController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppTheme.sidebarForeground, fontSize: 18),
            decoration: _decoration('Montant (CDF)'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _pinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppTheme.sidebarForeground),
            decoration: _decoration('Confirmer avec votre PIN'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppTheme.destructive.withOpacity(0.15), borderRadius: BorderRadius.circular(AppTheme.radiusSmall)),
              child: Row(
                children: [
                  Icon(Icons.error_outline_rounded, color: AppTheme.destructive, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_error!, style: TextStyle(color: AppTheme.destructive, fontSize: 14))),
                ],
              ),
            ),
          ],
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _loading ? null : _submit,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: AppTheme.primaryForeground),
              child: _loading
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryForeground))
                  : const Text('Épargner'),
            ),
          ),
        ],
      ),
    );
  }
}
