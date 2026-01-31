import 'package:flutter/material.dart';
import 'package:mobile_simplify/models/user.dart';
import 'package:mobile_simplify/theme/app_theme.dart';
import 'package:mobile_simplify/screens/client/microcredit/simulation_screen.dart';
import 'package:mobile_simplify/screens/client/microcredit/demande_credit_screen.dart';
import 'package:mobile_simplify/screens/client/microcredit/mes_credits_screen.dart';

/// Microcrédit – Accueil : plafond éligible, statut, CTA Simuler, Demander, Mes crédits.
class MicrocreditHomeScreen extends StatelessWidget {
  final AppUser user;

  const MicrocreditHomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    const plafondEligible = '500 000'; // CDF mock
    const isEligible = true; // mock
    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      appBar: AppBar(
        title: const Text('Microcrédit'),
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
              border: Border.all(color: AppTheme.cardDarkElevated),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (isEligible ? AppTheme.success : AppTheme.destructive).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isEligible ? Icons.check_circle_rounded : Icons.cancel_rounded,
                        color: isEligible ? AppTheme.success : AppTheme.destructive,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEligible ? 'Éligible au microcrédit' : 'Non éligible',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: AppTheme.sidebarForeground,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Plafond éligible : $plafondEligible CDF • Taux : +10 % intérêt',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          _ActionTile(
            icon: Icons.calculate_rounded,
            label: 'Simuler',
            subtitle: 'Mensualité, total, taux',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SimulationScreen(user: user)),
            ),
          ),
          const SizedBox(height: 10),
          _ActionTile(
            icon: Icons.add_circle_outline_rounded,
            label: 'Demander un crédit',
            subtitle: 'Montant, durée, motif',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DemandeCreditScreen(user: user)),
            ),
          ),
          const SizedBox(height: 10),
          _ActionTile(
            icon: Icons.list_alt_rounded,
            label: 'Mes crédits',
            subtitle: 'Actifs et clôturés',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MesCreditsScreen(user: user)),
            ),
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

  const _ActionTile({
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
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
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
