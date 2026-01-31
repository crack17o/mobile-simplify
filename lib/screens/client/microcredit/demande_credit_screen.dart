import 'package:flutter/material.dart';
import 'package:mobile_simplify/models/user.dart';
import 'package:mobile_simplify/theme/app_theme.dart';
import 'package:mobile_simplify/core/score_service.dart';

/// Demande de crédit : montant, durée, motif. Confirmation PIN → statut PENDING.
class DemandeCreditScreen extends StatefulWidget {
  final AppUser user;
  final double? prefillMontant;
  final int? prefillDuree;

  const DemandeCreditScreen({super.key, required this.user, this.prefillMontant, this.prefillDuree});

  @override
  State<DemandeCreditScreen> createState() => _DemandeCreditScreenState();
}

class _DemandeCreditScreenState extends State<DemandeCreditScreen> {
  final _montantController = TextEditingController();
  final _motifController = TextEditingController();
  final _pinController = TextEditingController();
  final _scoreService = ScoreService();
  int _dureeMois = 6;
  bool _loading = false;
  bool _success = false;
  bool _eligibilityLoaded = false;
  bool _isEligible = false;
  int _plafond = 0;
  List<String> _missingReasons = [];

  @override
  void initState() {
    super.initState();
    if (widget.prefillMontant != null) _montantController.text = widget.prefillMontant!.toStringAsFixed(0);
    if (widget.prefillDuree != null) _dureeMois = widget.prefillDuree!;
    _checkEligibility();
  }

  Future<void> _checkEligibility() async {
    final msisdn = widget.user.msisdn;
    final eligible = await _scoreService.isEligibleForCredit(msisdn);
    final plafond = await _scoreService.getPlafondCdf(msisdn);
    final missing = await _scoreService.getMissingReasonsForEligibility(msisdn);
    if (mounted) {
      setState(() {
        _isEligible = eligible;
        _plafond = plafond;
        _missingReasons = missing;
        _eligibilityLoaded = true;
      });
    }
  }

  @override
  void dispose() {
    _montantController.dispose();
    _motifController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final montant = double.tryParse(_montantController.text.trim().replaceAll(' ', ''));
    if (montant == null || montant <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Montant invalide'), behavior: SnackBarBehavior.floating));
      return;
    }
    if (_pinController.text.trim().length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN requis (4 chiffres)'), behavior: SnackBarBehavior.floating));
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() {
      _loading = false;
      _success = true;
    });
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

  InputDecoration _decoration(String label, [String? hint]) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
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
    if (_success) {
      return Scaffold(
        backgroundColor: AppTheme.surfaceDark,
        appBar: AppBar(title: const Text('Demande de crédit'), backgroundColor: AppTheme.sidebarBackground, foregroundColor: AppTheme.sidebarForeground),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_rounded, size: 80, color: AppTheme.success),
              const SizedBox(height: 24),
              Text('Demande créée', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.sidebarForeground)),
              const SizedBox(height: 8),
              Text('Statut : PENDING (en attente de validation)', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: AppTheme.primaryForeground),
                  child: const Text('Retour à l\'accueil'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!_eligibilityLoaded) {
      return Scaffold(
        backgroundColor: AppTheme.surfaceDark,
        appBar: AppBar(title: const Text('Demande de crédit'), backgroundColor: AppTheme.sidebarBackground, foregroundColor: AppTheme.sidebarForeground),
        body: const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    if (!_isEligible) {
      return Scaffold(
        backgroundColor: AppTheme.surfaceDark,
        appBar: AppBar(
          title: const Text('Demande de crédit'),
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
                border: Border.all(color: AppTheme.destructive.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.cancel_rounded, color: AppTheme.destructive, size: 28),
                      const SizedBox(width: 12),
                      Text('Non éligible', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.sidebarForeground, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Ce qu\'il te manque pour que ce crédit soit accordé :',
                    style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  ..._missingReasons.map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.chevron_right_rounded, color: AppTheme.primary, size: 20),
                            const SizedBox(width: 8),
                            Expanded(child: Text(r, style: TextStyle(color: Colors.white70, fontSize: 14))),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Atteins ces objectifs puis reviens faire une demande.',
              style: TextStyle(color: Colors.white54, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      appBar: AppBar(
        title: const Text('Demande de crédit'),
        backgroundColor: AppTheme.sidebarBackground,
        foregroundColor: AppTheme.sidebarForeground,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (_plafond > 0) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radius),
                border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: AppTheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Plafond éligible : ${_fmt(_plafond.toDouble())} CDF',
                      style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
          TextField(
            controller: _montantController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppTheme.sidebarForeground),
            decoration: _decoration('Montant (CDF)', '0'),
          ),
          const SizedBox(height: 16),
          Text('Durée (mois)', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [3, 6, 12, 24].map((m) {
              final selected = _dureeMois == m;
              return ChoiceChip(
                label: Text('$m mois', style: TextStyle(color: selected ? AppTheme.primaryForeground : Colors.white70)),
                selected: selected,
                onSelected: (v) => setState(() => _dureeMois = m),
                selectedColor: AppTheme.primary,
                backgroundColor: AppTheme.cardDark,
                side: BorderSide(color: selected ? AppTheme.primary : AppTheme.cardDarkElevated),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _motifController,
            style: const TextStyle(color: AppTheme.sidebarForeground),
            decoration: _decoration('Motif (optionnel)', 'Ex: stock commerce'),
            maxLines: 2,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _pinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppTheme.sidebarForeground),
            decoration: _decoration('Confirmer avec votre PIN', '••••'),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _loading ? null : _submit,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: AppTheme.primaryForeground),
              child: _loading
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryForeground))
                  : const Text('Envoyer la demande'),
            ),
          ),
        ],
      ),
    );
  }
}
