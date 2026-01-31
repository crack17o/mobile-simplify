import 'package:flutter/material.dart';
import 'package:mobile_simplify/models/user.dart';
import 'package:mobile_simplify/models/credit.dart';
import 'package:mobile_simplify/theme/app_theme.dart';
import 'package:mobile_simplify/screens/client/microcredit/credit_detail_screen.dart';

/// Mes crédits : liste actifs + clôturés. Principal, dû restant, prochaine échéance, statut.
class MesCreditsScreen extends StatelessWidget {
  final AppUser user;

  const MesCreditsScreen({super.key, required this.user});

  static final _mockCredits = [
    const Credit(
      id: 'CRD001',
      principal: 150000,
      remainingDue: 120000,
      nextDueDate: '15/02/2025',
      status: CreditStatus.active,
      durationMonths: 6,
      monthlyPayment: 26500,
    ),
    const Credit(
      id: 'CRD002',
      principal: 50000,
      remainingDue: 0,
      nextDueDate: '-',
      status: CreditStatus.closed,
      durationMonths: 3,
      monthlyPayment: 17500,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      appBar: AppBar(
        title: const Text('Mes crédits'),
        backgroundColor: AppTheme.sidebarBackground,
        foregroundColor: AppTheme.sidebarForeground,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _mockCredits.length,
        itemBuilder: (context, i) {
          final c = _mockCredits[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _CreditTile(
              credit: c,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CreditDetailScreen(user: user, credit: c)),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CreditTile extends StatelessWidget {
  final Credit credit;
  final VoidCallback onTap;

  const _CreditTile({required this.credit, required this.onTap});

  static String _statusLabel(CreditStatus s) {
    switch (s) {
      case CreditStatus.active:
        return 'Actif';
      case CreditStatus.late:
        return 'En retard';
      case CreditStatus.closed:
        return 'Clôturé';
    }
  }

  static Color _statusColor(CreditStatus s) {
    switch (s) {
      case CreditStatus.active:
        return AppTheme.success;
      case CreditStatus.late:
        return AppTheme.destructive;
      case CreditStatus.closed:
        return Colors.white54;
    }
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Crédit ${credit.id}', style: const TextStyle(color: AppTheme.sidebarForeground, fontWeight: FontWeight.w600, fontSize: 16)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor(credit.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(_statusLabel(credit.status), style: TextStyle(color: _statusColor(credit.status), fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _Row('Principal', '${_fmt(credit.principal)} CDF'),
              _Row('Dû restant', '${_fmt(credit.remainingDue)} CDF'),
              _Row('Prochaine échéance', credit.nextDueDate),
              const SizedBox(height: 8),
              Icon(Icons.chevron_right_rounded, color: Colors.white54, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;

  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white54, fontSize: 13)),
          Text(value, style: const TextStyle(color: AppTheme.sidebarForeground, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
