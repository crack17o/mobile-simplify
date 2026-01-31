import 'package:flutter/material.dart';
import 'package:mobile_simplify/models/user.dart';
import 'package:mobile_simplify/models/tontine.dart';
import 'package:mobile_simplify/theme/app_theme.dart';
import 'package:mobile_simplify/screens/client/tontine_cotiser_screen.dart';

/// Détail tontine : membres, prochain tour, montant cotisation, CTA Cotiser.
class TontineDetailScreen extends StatelessWidget {
  final AppUser user;
  final Tontine tontine;

  const TontineDetailScreen({super.key, required this.user, required this.tontine});

  static String _formatCdf(double n) {
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
    final t = tontine;
    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      appBar: AppBar(
        title: Text(t.name),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.payments_rounded, color: AppTheme.primary, size: 24),
                    const SizedBox(width: 10),
                    Text(
                      'Cotisation : ${_formatCdf(t.cotisationAmount)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Fréquence : ${t.frequenceLabel}',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ma progression',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tours restants avant la mise', style: TextStyle(color: Colors.white54, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(
                            '${t.toursRestantsAvantMise}',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 40, color: AppTheme.cardDarkElevated),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Somme déjà mise', style: TextStyle(color: Colors.white54, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(
                            _formatCdf(t.sommeDejaMise),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppTheme.sidebarForeground,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Prochain tour',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(AppTheme.radius),
              border: Border.all(color: AppTheme.cardDarkElevated),
            ),
            child: Row(
              children: [
                Icon(Icons.event_rounded, color: AppTheme.primary, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.nextRoundDate ?? '–',
                        style: const TextStyle(
                          color: AppTheme.sidebarForeground,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      if (t.nextBeneficiary != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Bénéficiaire : ${t.nextBeneficiary}',
                          style: TextStyle(color: Colors.white54, fontSize: 13),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Membres (${t.memberNames.length})',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          ...t.memberNames.map((name) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppTheme.primary.withOpacity(0.2),
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      name,
                      style: const TextStyle(
                        color: AppTheme.sidebarForeground,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: t.status == TontineStatus.active
                  ? () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TontineCotiserScreen(user: user, tontine: t),
                        ),
                      )
                  : null,
              icon: const Icon(Icons.add_rounded, size: 22),
              label: const Text('Cotiser'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.primaryForeground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
