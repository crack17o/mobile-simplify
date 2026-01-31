import 'package:flutter/material.dart';
import 'package:mobile_simplify/models/user.dart';
import 'package:mobile_simplify/models/credit.dart';
import 'package:mobile_simplify/theme/app_theme.dart';

/// Détail crédit : échéancier simplifié, historique paiements, CTA Payer maintenant (MVP+).
class CreditDetailScreen extends StatelessWidget {
  final AppUser user;
  final Credit credit;

  const CreditDetailScreen({super.key, required this.user, required this.credit});

  static String _fmt(double n) {
    final s = n.toStringAsFixed(0);
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final echeances = List.generate(credit.durationMonths, (i) => 'Échéance ${i + 1} : ${_fmt(credit.monthlyPayment)} CDF');
    final historique = [
      ('15/01/2025', '26 500 CDF', 'Payé'),
      ('15/12/2024', '26 500 CDF', 'Payé'),
    ];
    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      appBar: AppBar(
        title: Text('Crédit ${credit.id}'),
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
                _DetailRow('Principal', '${_fmt(credit.principal)} CDF'),
                _DetailRow('Dû restant', '${_fmt(credit.remainingDue)} CDF'),
                _DetailRow('Prochaine échéance', credit.nextDueDate),
                _DetailRow('Mensualité', '${_fmt(credit.monthlyPayment)} CDF'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Échéancier (simplifié)', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(AppTheme.radius),
              border: Border.all(color: AppTheme.cardDarkElevated),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: echeances.take(6).map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(e, style: TextStyle(color: Colors.white70, fontSize: 14)),
              )).toList(),
            ),
          ),
          const SizedBox(height: 24),
          Text('Historique paiements', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...historique.map((h) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(AppTheme.radius),
              border: Border.all(color: AppTheme.cardDarkElevated),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(h.$1, style: TextStyle(color: Colors.white54, fontSize: 13)),
                    Text(h.$2, style: const TextStyle(color: AppTheme.sidebarForeground, fontWeight: FontWeight.w600)),
                  ],
                ),
                Text(h.$3, style: TextStyle(color: AppTheme.success, fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          )),
          if (credit.status == CreditStatus.active && credit.remainingDue > 0) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Paiement direct (MVP+) à venir'), behavior: SnackBarBehavior.floating),
                  );
                },
                icon: const Icon(Icons.payment_rounded, size: 22),
                label: const Text('Payer maintenant'),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: AppTheme.primaryForeground),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white54, fontSize: 14)),
          Text(value, style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }
}
