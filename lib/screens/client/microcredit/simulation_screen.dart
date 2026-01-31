import 'package:flutter/material.dart';
import 'package:mobile_simplify/models/user.dart';
import 'package:mobile_simplify/theme/app_theme.dart';
import 'package:mobile_simplify/screens/client/microcredit/demande_credit_screen.dart';

/// Simulation : montant, durée → mensualité, total, taux. CTA Faire demande.
class SimulationScreen extends StatefulWidget {
  final AppUser user;

  const SimulationScreen({super.key, required this.user});

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {
  final _montantController = TextEditingController(text: '100000');
  int _dureeMois = 6;
  static const _tauxAnnuel = 10.0; // % intérêt annuel

  @override
  void dispose() {
    _montantController.dispose();
    super.dispose();
  }

  double get _montant => double.tryParse(_montantController.text.replaceAll(' ', '')) ?? 0;
  double get _mensualite {
    if (_montant <= 0 || _dureeMois <= 0) return 0;
    final r = (_tauxAnnuel / 100) / 12;
    if (r == 0) return _montant / _dureeMois;
    final x = (1 + r) * _dureeMois; // simplified: use (1+r)^n via repeated mult
    double pow = 1;
    for (var i = 0; i < _dureeMois; i++) pow *= (1 + r);
    return _montant * (r * pow) / (pow - 1);
  }
  double get _totalRembourse => _mensualite * _dureeMois;

  InputDecoration _inputDecoration(String label) {
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
    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      appBar: AppBar(
        title: const Text('Simulation'),
        backgroundColor: AppTheme.sidebarBackground,
        foregroundColor: AppTheme.sidebarForeground,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _montantController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppTheme.sidebarForeground, fontSize: 16),
            decoration: _inputDecoration('Montant (CDF)'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          Text('Durée (mois)', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            children: [3, 6, 12, 24].map((m) {
              final selected = _dureeMois == m;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text('$m mois', style: TextStyle(color: selected ? AppTheme.primaryForeground : Colors.white70)),
                  selected: selected,
                  onSelected: (v) => setState(() => _dureeMois = m),
                  selectedColor: AppTheme.primary,
                  backgroundColor: AppTheme.cardDark,
                  side: BorderSide(color: selected ? AppTheme.primary : AppTheme.cardDarkElevated),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              border: Border.all(color: AppTheme.primary.withOpacity(0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ResultRow('Mensualité / échéance', '${_mensualite.toStringAsFixed(0)} CDF'),
                const SizedBox(height: 12),
                _ResultRow('Total à rembourser', '${_totalRembourse.toStringAsFixed(0)} CDF'),
                const SizedBox(height: 12),
                _ResultRow('Taux (info)', '$_tauxAnnuel % annuel'),
              ],
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DemandeCreditScreen(user: widget.user, prefillMontant: _montant, prefillDuree: _dureeMois)),
              ),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: AppTheme.primaryForeground),
              child: const Text('Faire une demande'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;

  const _ResultRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 14)),
        Text(value, style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 14)),
      ],
    );
  }
}
