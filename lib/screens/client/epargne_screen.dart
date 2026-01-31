import 'package:flutter/material.dart';
import 'package:mobile_simplify/models/user.dart';
import 'package:mobile_simplify/theme/app_theme.dart';
import 'package:mobile_simplify/core/savings_service.dart';
import 'package:mobile_simplify/screens/client/epargne_manuelle_screen.dart';
import 'package:mobile_simplify/screens/client/epargne_auto_screen.dart';
import 'package:mobile_simplify/screens/client/epargne_historique_screen.dart';

/// Épargne – Accueil : total épargné, plan actif, CTA Épargner maintenant, Configurer auto-épargne, Historique.
class EpargneScreen extends StatefulWidget {
  final AppUser user;

  const EpargneScreen({super.key, required this.user});

  @override
  State<EpargneScreen> createState() => _EpargneScreenState();
}

class _EpargneScreenState extends State<EpargneScreen> {
  final _savings = SavingsService();
  bool _loading = true;
  double _balanceCdf = 0;
  bool _autoActive = false;
  double? _autoAmount;
  String? _autoFreq;
  String? _autoNext;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final balance = await _savings.getBalanceCdf();
    final autoActive = await _savings.getAutoActive();
    final autoAmount = await _savings.getAutoAmount();
    final autoFreq = await _savings.getAutoFreq();
    final autoNext = await _savings.getAutoNext();
    if (mounted) {
      setState(() {
        _balanceCdf = balance;
        _autoActive = autoActive;
        _autoAmount = autoAmount;
        _autoFreq = autoFreq;
        _autoNext = autoNext;
        _loading = false;
      });
    }
  }

  static String _fmtCdf(double n) {
    final s = n.toStringAsFixed(0);
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return '${buf} CDF';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppTheme.surfaceDark,
        appBar: AppBar(title: const Text('Épargne'), backgroundColor: AppTheme.sidebarBackground, foregroundColor: AppTheme.sidebarForeground),
        body: const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      appBar: AppBar(
        title: const Text('Épargne'),
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
              border: Border.all(color: AppTheme.primary.withOpacity(0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total épargné', style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 8),
                Text(_fmtCdf(_balanceCdf), style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppTheme.primary, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          if (_autoActive && _autoAmount != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardDark,
                borderRadius: BorderRadius.circular(AppTheme.radius),
                border: Border.all(color: AppTheme.cardDarkElevated),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.schedule_rounded, color: AppTheme.primary, size: 22),
                      const SizedBox(width: 8),
                      Text('Plan actif', style: TextStyle(color: AppTheme.sidebarForeground, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Montant : ${_fmtCdf(_autoAmount!)} • ${_autoFreq ?? "Mensuel"}', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  if (_autoNext != null) Text('Prochaine exécution : $_autoNext', style: TextStyle(color: Colors.white54, fontSize: 13)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 28),
          Text('Actions', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          _ActionTile(
            icon: Icons.add_circle_rounded,
            label: 'Épargner maintenant',
            subtitle: 'Versement manuel',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EpargneManuelleScreen(user: widget.user))).then((_) => _load()),
          ),
          const SizedBox(height: 10),
          _ActionTile(
            icon: Icons.settings_rounded,
            label: 'Configurer auto-épargne',
            subtitle: 'Montant + fréquence',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EpargneAutoScreen(user: widget.user))).then((_) => _load()),
          ),
          const SizedBox(height: 10),
          _ActionTile(
            icon: Icons.history_rounded,
            label: 'Historique épargne',
            subtitle: 'Liste des prélèvements',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EpargneHistoriqueScreen(user: widget.user))),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({required this.icon, required this.label, required this.subtitle, required this.onTap});

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
            border: Border.all(color: AppTheme.cardDarkElevated),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: AppTheme.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(color: AppTheme.sidebarForeground, fontWeight: FontWeight.w600, fontSize: 16)),
                    Text(subtitle, style: TextStyle(color: Colors.white54, fontSize: 13)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }
}
