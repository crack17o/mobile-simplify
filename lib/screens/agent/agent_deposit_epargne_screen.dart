import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_simplify/models/user.dart';
import 'package:mobile_simplify/theme/app_theme.dart';
import 'package:mobile_simplify/core/savings_service.dart';
import 'package:mobile_simplify/core/score_service.dart';

/// Dépôt épargne — agent crédite l'épargne d'un client par téléphone.
class AgentDepositEpargneScreen extends StatefulWidget {
  final AppUser user;
  final String phone;

  const AgentDepositEpargneScreen({super.key, required this.user, required this.phone});

  @override
  State<AgentDepositEpargneScreen> createState() => _AgentDepositEpargneScreenState();
}

class _AgentDepositEpargneScreenState extends State<AgentDepositEpargneScreen> {
  final _amountController = TextEditingController();
  final _savings = SavingsService();
  final _scoreService = ScoreService();
  bool _loading = false;
  String? _error;
  bool _success = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String _normalizePhone(String v) {
    var s = v.replaceAll(RegExp(r'\D'), '');
    if (s.length == 9 && !s.startsWith('243')) s = '243$s';
    return s;
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountController.text.trim().replaceAll(' ', ''));
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Montant invalide');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    final msisdn = _normalizePhone(widget.phone);
    if (msisdn.isEmpty || msisdn.length < 12) {
      setState(() {
        _loading = false;
        _error = 'Téléphone client invalide';
      });
      return;
    }
    await _savings.setEnabled(msisdn, true);
    await _savings.addToBalance(msisdn, amount);
    await _savings.addHistoryEntry(
      msisdn,
      '${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year} ${DateTime.now().hour}:${DateTime.now().minute}',
      amount,
      'SUCCESS',
      'Dépôt agent',
    );
    await _scoreService.incrementDeposit(msisdn);
    if (mounted) {
      setState(() {
        _loading = false;
        _success = true;
      });
    }
  }

  static String _fmt(double n) {
    final s = n.toStringAsFixed(0);
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  InputDecoration _decoration(String label, [String? hint]) => InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: AppTheme.cardDark,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSmall)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSmall), borderSide: BorderSide(color: AppTheme.cardDarkElevated)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSmall), borderSide: const BorderSide(color: AppTheme.primary)),
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: TextStyle(color: Colors.white38),
      );

  @override
  Widget build(BuildContext context) {
    if (_success) {
      final amount = double.tryParse(_amountController.text.trim().replaceAll(' ', '')) ?? 0;
      return Scaffold(
        backgroundColor: AppTheme.surfaceDark,
        appBar: AppBar(title: const Text('Dépôt épargne effectué'), backgroundColor: AppTheme.sidebarBackground, foregroundColor: AppTheme.sidebarForeground),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_rounded, size: 80, color: AppTheme.success),
              const SizedBox(height: 24),
              Text('Dépôt épargne réussi', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.sidebarForeground)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppTheme.cardDark, borderRadius: BorderRadius.circular(AppTheme.radius), border: Border.all(color: AppTheme.cardDarkElevated)),
                child: Column(
                  children: [
                    _row('Client', widget.phone),
                    _row('Montant', '${_fmt(amount)} CDF'),
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

    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      appBar: AppBar(
        title: const Text('Dépôt épargne'),
        backgroundColor: AppTheme.sidebarBackground,
        foregroundColor: AppTheme.sidebarForeground,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppTheme.cardDark, borderRadius: BorderRadius.circular(AppTheme.radius), border: Border.all(color: AppTheme.cardDarkElevated)),
            child: Text('Client: ${widget.phone}', style: const TextStyle(color: AppTheme.sidebarForeground, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d\s]'))],
            decoration: _decoration('Montant (CDF)', '0'),
            style: const TextStyle(color: AppTheme.sidebarForeground),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppTheme.destructive.withOpacity(0.1), borderRadius: BorderRadius.circular(AppTheme.radiusSmall)),
              child: Row(
                children: [
                  Icon(Icons.error_outline_rounded, color: AppTheme.destructive, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_error!, style: const TextStyle(color: AppTheme.destructive))),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _loading ? null : _submit,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: AppTheme.primaryForeground),
              child: _loading
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryForeground))
                  : const Text('Valider le dépôt épargne'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: Colors.white54, fontSize: 14)),
            Text(value, style: const TextStyle(color: AppTheme.sidebarForeground, fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      );
}
