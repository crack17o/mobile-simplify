import 'package:flutter/material.dart';
import 'package:mobile_simplify/models/user.dart';
import 'package:mobile_simplify/models/tontine.dart';
import 'package:mobile_simplify/theme/app_theme.dart';
import 'package:mobile_simplify/screens/client/tontine_detail_screen.dart';
import 'package:mobile_simplify/screens/client/tontine_create_screen.dart';
import 'package:mobile_simplify/screens/client/tontine_join_screen.dart';

/// Tontines – Liste : mes tontines (actives), CTA Rejoindre, Créer.
class TontineListScreen extends StatelessWidget {
  final AppUser user;

  const TontineListScreen({super.key, required this.user});

  static final _mockTontines = [
    const Tontine(
      id: 'TNT001',
      name: 'Épargne quartier',
      cotisationAmount: 5000,
      frequence: TontineFrequence.semaine,
      status: TontineStatus.active,
      nextRoundDate: '08/02/2025',
      nextBeneficiary: 'Marie K.',
      memberNames: ['Vous', 'Marie K.', 'Jean B.', 'Anne M.'],
    ),
    const Tontine(
      id: 'TNT002',
      name: 'Solidarité travail',
      cotisationAmount: 10000,
      frequence: TontineFrequence.mois,
      status: TontineStatus.active,
      nextRoundDate: '28/02/2025',
      nextBeneficiary: null,
      memberNames: ['Vous', 'Paul L.', 'Sophie D.'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      appBar: AppBar(
        title: const Text('Tontines'),
        backgroundColor: AppTheme.sidebarBackground,
        foregroundColor: AppTheme.sidebarForeground,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Expanded(
                child: _CtaCard(
                  icon: Icons.login_rounded,
                  label: 'Rejoindre',
                  subtitle: 'Code d\'invitation',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TontineJoinScreen(user: user)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CtaCard(
                  icon: Icons.add_circle_outline_rounded,
                  label: 'Créer',
                  subtitle: 'Nouvelle tontine',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TontineCreateScreen(user: user)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Mes tontines',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          ..._mockTontines.where((t) => t.status == TontineStatus.active).map((t) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _TontineTile(
                    tontine: t,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TontineDetailScreen(user: user, tontine: t),
                      ),
                    ),
                  ),
                );
              }),
        ],
      ),
    );
  }
}

class _CtaCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _CtaCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardDark,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            border: Border.all(color: AppTheme.cardDarkElevated),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppTheme.primary, size: 28),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.sidebarForeground,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TontineTile extends StatelessWidget {
  final Tontine tontine;
  final VoidCallback onTap;

  const _TontineTile({required this.tontine, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = tontine;
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.groups_rounded, color: AppTheme.primary, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.name,
                      style: const TextStyle(
                        color: AppTheme.sidebarForeground,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${t.cotisationAmount.toStringAsFixed(0)} CDF • ${t.frequenceLabel}',
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                    ),
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
