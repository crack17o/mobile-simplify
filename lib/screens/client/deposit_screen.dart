import 'package:flutter/material.dart';
import 'package:mobile_simplify/models/user.dart';
import 'package:mobile_simplify/theme/app_theme.dart';

/// Dépôt Mobile Money : montant + opérateur → PENDING, écran "en attente de confirmation" + pull to refresh.
class DepositScreen extends StatefulWidget {
  final AppUser user;

  const DepositScreen({super.key, required this.user});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  final _amountController = TextEditingController();
  String? _operator;
  bool _pending = false;
  bool _loading = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_amountController.text.trim().isEmpty || _operator == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Montant et opérateur requis')),
      );
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() {
      _loading = false;
      _pending = true;
    });
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _loading = false;
      _pending = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dépôt confirmé (simulation)')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_pending) {
      return Scaffold(
        backgroundColor: AppTheme.surfaceDark,
        appBar: AppBar(
          title: const Text('Dépôt en attente'),
          backgroundColor: AppTheme.sidebarBackground,
          foregroundColor: AppTheme.sidebarForeground,
        ),
        body: RefreshIndicator(
          onRefresh: _refresh,
          color: AppTheme.primary,
          backgroundColor: AppTheme.cardDark,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Icon(Icons.hourglass_empty, size: 64, color: AppTheme.primary),
                const SizedBox(height: 24),
                Text(
                  'En attente de confirmation',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.sidebarForeground),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Montant: ${_amountController.text.trim()} CDF\nOpérateur: $_operator',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 24),
                Text(
                  'Tirez pour actualiser',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white54),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      appBar: AppBar(
        title: const Text('Dépôt Mobile Money'),
        backgroundColor: AppTheme.sidebarBackground,
        foregroundColor: AppTheme.sidebarForeground,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppTheme.sidebarForeground),
            decoration: InputDecoration(
              labelText: 'Montant (CDF)',
              hintText: '0',
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
          DropdownButtonFormField<String>(
            value: _operator,
            dropdownColor: AppTheme.cardDark,
            decoration: InputDecoration(
              labelText: 'Opérateur',
              hintText: 'Choisir un opérateur',
              hintStyle: TextStyle(color: Colors.white38),
              labelStyle: TextStyle(color: Colors.white70),
              prefixIcon: Icon(Icons.sim_card_rounded, color: AppTheme.primary, size: 22),
              filled: true,
              fillColor: AppTheme.cardDark,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSmall), borderSide: BorderSide(color: AppTheme.cardDarkElevated)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSmall), borderSide: BorderSide(color: AppTheme.cardDarkElevated)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSmall), borderSide: const BorderSide(color: AppTheme.primary)),
            ),
            style: const TextStyle(color: AppTheme.sidebarForeground, fontSize: 15),
            icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.primary),
            items: ['Orange Money RDC', 'Vodacom M-Pesa', 'Airtel Money']
                .map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(color: AppTheme.sidebarForeground))))
                .toList(),
            onChanged: (v) => setState(() => _operator = v),
          ),
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
                  : const Text('Démarrer le dépôt'),
            ),
          ),
        ],
      ),
    );
  }
}
