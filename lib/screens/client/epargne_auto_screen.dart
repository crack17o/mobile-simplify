import 'package:flutter/material.dart';
import 'package:mobile_simplify/models/user.dart';
import 'package:mobile_simplify/theme/app_theme.dart';
import 'package:mobile_simplify/core/savings_service.dart';

/// Auto-épargne : Activer/désactiver, montant + fréquence (jour/semaine/mois), prochaine exécution.
class EpargneAutoScreen extends StatefulWidget {
  final AppUser user;

  const EpargneAutoScreen({super.key, required this.user});

  @override
  State<EpargneAutoScreen> createState() => _EpargneAutoScreenState();
}

class _EpargneAutoScreenState extends State<EpargneAutoScreen> {
  final _savings = SavingsService();
  final _montantController = TextEditingController();
  bool _loading = true;
  bool _active = false;
  double? _amount;
  String? _freq;
  String? _next;
  String _selectedFreq = 'Mensuel';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _montantController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final msisdn = widget.user.msisdn;
    final active = await _savings.getAutoActive(msisdn);
    final amount = await _savings.getAutoAmount(msisdn);
    final freq = await _savings.getAutoFreq(msisdn);
    final next = await _savings.getAutoNext(msisdn);
    if (mounted) {
      setState(() {
        _active = active;
        _amount = amount;
        _freq = freq;
        _next = next;
        _montantController.text = amount?.toStringAsFixed(0) ?? '';
        _selectedFreq = freq ?? 'Mensuel';
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    final amount = double.tryParse(_montantController.text.trim().replaceAll(' ', ''));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Montant invalide'), behavior: SnackBarBehavior.floating));
      return;
    }
    final next = '${DateTime.now().day + ( _selectedFreq == 'Quotidien' ? 1 : _selectedFreq == 'Hebdo' ? 7 : 30) }/${DateTime.now().month}/${DateTime.now().year}';
    await _savings.setAutoPlan(widget.user.msisdn, amount: amount, freq: _selectedFreq, next: next, active: true);
    if (mounted) {
      setState(() {
        _active = true;
        _amount = amount;
        _freq = _selectedFreq;
        _next = next;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Plan auto-épargne activé'), behavior: SnackBarBehavior.floating, backgroundColor: AppTheme.success));
    }
  }

  Future<void> _disable() async {
    await _savings.setAutoPlan(widget.user.msisdn, active: false);
    if (mounted) {
      setState(() => _active = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Plan auto-épargne désactivé'), behavior: SnackBarBehavior.floating));
    }
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white70),
      filled: true,
      fillColor: AppTheme.cardDark,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSmall), borderSide: BorderSide(color: AppTheme.cardDarkElevated)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSmall), borderSide: BorderSide(color: AppTheme.cardDarkElevated)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSmall), borderSide: const BorderSide(color: AppTheme.primary)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppTheme.surfaceDark,
        appBar: AppBar(title: const Text('Auto-épargne'), backgroundColor: AppTheme.sidebarBackground, foregroundColor: AppTheme.sidebarForeground),
        body: const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      appBar: AppBar(
        title: const Text('Configurer auto-épargne'),
        backgroundColor: AppTheme.sidebarBackground,
        foregroundColor: AppTheme.sidebarForeground,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SwitchListTile(
            value: _active,
            onChanged: (v) => v ? _save() : _disable(),
            title: Text('Plan auto-épargne', style: TextStyle(color: AppTheme.sidebarForeground, fontWeight: FontWeight.w600)),
            subtitle: Text(_active ? 'ACTIVE' : 'PAUSED', style: TextStyle(color: _active ? AppTheme.success : Colors.white54, fontSize: 12)),
            activeColor: AppTheme.primary,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _montantController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppTheme.sidebarForeground),
            decoration: _decoration('Montant par prélèvement (CDF)'),
          ),
          const SizedBox(height: 16),
          Text('Fréquence', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Quotidien', 'Hebdo', 'Mensuel'].map((f) {
              final selected = _selectedFreq == f;
              return ChoiceChip(
                label: Text(f, style: TextStyle(color: selected ? AppTheme.primaryForeground : Colors.white70)),
                selected: selected,
                onSelected: (v) => setState(() => _selectedFreq = f),
                selectedColor: AppTheme.primary,
                backgroundColor: AppTheme.cardDark,
                side: BorderSide(color: selected ? AppTheme.primary : AppTheme.cardDarkElevated),
              );
            }).toList(),
          ),
          if (_active && _next != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppTheme.cardDark, borderRadius: BorderRadius.circular(AppTheme.radius), border: Border.all(color: AppTheme.cardDarkElevated)),
              child: Row(
                children: [
                  Icon(Icons.schedule_rounded, color: AppTheme.primary),
                  const SizedBox(width: 12),
                  Text('Prochaine exécution : $_next', style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: AppTheme.primaryForeground),
              child: Text(_active ? 'Mettre à jour' : 'Activer le plan'),
            ),
          ),
        ],
      ),
    );
  }
}
