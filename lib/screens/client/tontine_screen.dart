import 'package:flutter/material.dart';
import 'package:mobile_simplify/models/user.dart';
import 'package:mobile_simplify/theme/app_theme.dart';

/// Fréquences de paiement tontine.
enum TontineFrequence {
  hebdomadaire('Hebdomadaire'),
  bimensuelle('Bimensuelle'),
  mensuelle('Mensuelle');

  final String label;
  const TontineFrequence(this.label);
}

/// Page Tontine : créer ou rejoindre une tontine (montant + fréquence).
class TontineScreen extends StatefulWidget {
  final AppUser user;

  const TontineScreen({super.key, required this.user});

  @override
  State<TontineScreen> createState() => _TontineScreenState();
}

class _TontineScreenState extends State<TontineScreen> {
  bool? _choice; // true = créer, false = rejoindre
  final _montantController = TextEditingController();
  TontineFrequence? _frequence;
  bool _loading = false;

  @override
  void dispose() {
    _montantController.dispose();
    super.dispose();
  }

  void _submit() {
    final montant = _montantController.text.trim();
    if (montant.isEmpty || _frequence == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Montant et fréquence requis'),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_choice == true
              ? 'Tontine créée : ${amount.toStringAsFixed(0)} CDF / ${_frequence!.label}'
              : 'Demande envoyée pour rejoindre la tontine'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.pop(context);
    });
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      hintText: '0',
      labelStyle: TextStyle(color: Colors.white70),
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
        title: const Text('Tontine'),
        backgroundColor: AppTheme.sidebarBackground,
        foregroundColor: AppTheme.sidebarForeground,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              border: Border.all(color: AppTheme.cardDarkElevated),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.groups_rounded, color: AppTheme.primary, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Créez ou rejoignez une tontine. Définissez le montant et la fréquence de paiement.',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Que souhaitez-vous faire ?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ChoiceCard(
                  icon: Icons.add_circle_outline_rounded,
                  label: 'Créer une tontine',
                  selected: _choice == true,
                  onTap: () => setState(() => _choice = true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ChoiceCard(
                  icon: Icons.login_rounded,
                  label: 'Rejoindre une tontine',
                  selected: _choice == false,
                  onTap: () => setState(() => _choice = false),
                ),
              ),
            ],
          ),
          if (_choice != null) ...[
            const SizedBox(height: 24),
            TextField(
              controller: _montantController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppTheme.sidebarForeground, fontSize: 16),
              decoration: _inputDecoration('Montant à mettre (CDF)'),
            ),
            const SizedBox(height: 16),
            Text(
              'Fréquence de paiement',
              style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TontineFrequence.values.map((f) {
                final selected = _frequence == f;
                return ChoiceChip(
                  label: Text(f.label, style: TextStyle(color: selected ? AppTheme.primaryForeground : Colors.white70)),
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
                    : Text(_choice == true ? 'Créer la tontine' : 'Rejoindre'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardDark,
            borderRadius: BorderRadius.circular(AppTheme.radius),
            border: Border.all(
              color: selected ? AppTheme.primary : AppTheme.cardDarkElevated,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 36, color: selected ? AppTheme.primary : Colors.white54),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected ? AppTheme.primary : Colors.white70,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
