import 'package:flutter/material.dart';
import 'package:mobile_simplify/models/user.dart';
import 'package:mobile_simplify/models/tontine.dart';
import 'package:mobile_simplify/theme/app_theme.dart';

/// Créer une tontine : nom, montant cotisation, fréquence, confirmation.
class TontineCreateScreen extends StatefulWidget {
  final AppUser user;

  const TontineCreateScreen({super.key, required this.user});

  @override
  State<TontineCreateScreen> createState() => _TontineCreateScreenState();
}

class _TontineCreateScreenState extends State<TontineCreateScreen> {
  final _nameController = TextEditingController();
  final _montantController = TextEditingController();
  TontineFrequence? _frequence;
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _montantController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final montant = _montantController.text.trim();
    if (name.isEmpty || montant.isEmpty || _frequence == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nom, montant et fréquence requis'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final amount = double.tryParse(montant.replaceAll(' ', ''));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Montant invalide'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _loading = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _loading = false);
      final freqLabel = (Tontine(id: '', name: '', cotisationAmount: 0, frequence: _frequence!, status: TontineStatus.active).frequenceLabel);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tontine créée : $name — ${amount.toStringAsFixed(0)} CDF / $freqLabel'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.pop(context);
    });
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
        title: const Text('Créer une tontine'),
        backgroundColor: AppTheme.sidebarBackground,
        foregroundColor: AppTheme.sidebarForeground,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _nameController,
            style: const TextStyle(color: AppTheme.sidebarForeground, fontSize: 16),
            decoration: _inputDecoration('Nom de la tontine', 'Ex. Épargne quartier'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _montantController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppTheme.sidebarForeground, fontSize: 16),
            decoration: _inputDecoration('Montant de cotisation (CDF)', '0'),
          ),
          const SizedBox(height: 20),
          Text(
            'Fréquence',
            style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: TontineFrequence.values.map((f) {
              final t = Tontine(id: '', name: '', cotisationAmount: 0, frequence: f, status: TontineStatus.active);
              final selected = _frequence == f;
              return ChoiceChip(
                label: Text(t.frequenceLabel, style: TextStyle(color: selected ? AppTheme.primaryForeground : Colors.white70)),
                selected: selected,
                onSelected: (v) => setState(() => _frequence = v ? f : null),
                selectedColor: AppTheme.primary,
                backgroundColor: AppTheme.cardDark,
                side: BorderSide(color: selected ? AppTheme.primary : AppTheme.cardDarkElevated),
              );
            }).toList(),
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
                  : const Text('Créer la tontine'),
            ),
          ),
        ],
      ),
    );
  }
}
