import 'package:flutter/material.dart';
import 'package:mobile_simplify/models/user.dart';
import 'package:mobile_simplify/models/tontine.dart';
import 'package:mobile_simplify/theme/app_theme.dart';
import 'package:mobile_simplify/core/savings_service.dart';

/// Créer une tontine : nom, montant, fréquence. Génère un PIN à partager.
/// Prérequis : compte épargne fonctionnel et fourni en argent.
class TontineCreateScreen extends StatefulWidget {
  final AppUser user;

  const TontineCreateScreen({super.key, required this.user});

  @override
  State<TontineCreateScreen> createState() => _TontineCreateScreenState();
}

class _TontineCreateScreenState extends State<TontineCreateScreen> {
  final _nameController = TextEditingController();
  final _montantController = TextEditingController();
  final _savings = SavingsService();
  TontineFrequence? _frequence;
  bool _loading = false;
  String? _createdPin;
  Tontine? _createdTontine;

  @override
  void dispose() {
    _nameController.dispose();
    _montantController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
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
    final pin = 'TNT${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    setState(() {
      _loading = false;
      _createdPin = pin;
      _createdTontine = Tontine(
        id: 'TNT${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        cotisationAmount: amount,
        frequence: _frequence!,
        status: TontineStatus.active,
        pin: pin,
        totalMembers: 1,
      );
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
    if (_createdPin != null && _createdTontine != null) {
      final t = _createdTontine!;
      return Scaffold(
        backgroundColor: AppTheme.surfaceDark,
        appBar: AppBar(
          title: const Text('Tontine créée'),
          backgroundColor: AppTheme.sidebarBackground,
          foregroundColor: AppTheme.sidebarForeground,
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.cardDark,
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                border: Border.all(color: AppTheme.success.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Tontine « ${t.name} » créée',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppTheme.sidebarForeground,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('PIN à partager pour rejoindre', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(AppTheme.radius),
                    ),
                    child: Text(
                      _createdPin!,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                            letterSpacing: 2,
                          ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Partage ce PIN aux personnes qui veulent adhérer. Elles doivent avoir au moins 20 % de la somme totale en épargne.',
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: AppTheme.primaryForeground,
                ),
                child: const Text('Terminer'),
              ),
            ),
          ],
        ),
      );
    }

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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardDark.withOpacity(0.5),
              borderRadius: BorderRadius.circular(AppTheme.radius),
              border: Border.all(color: AppTheme.cardDarkElevated),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: AppTheme.primary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Compte épargne fonctionnel et alimenté requis. Le PIN généré sera partagé pour adhérer.',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
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
