import 'package:flutter/material.dart';
import 'package:mobile_simplify/models/user.dart';
import 'package:mobile_simplify/models/credit.dart';
import 'package:mobile_simplify/theme/app_theme.dart';
import 'package:mobile_simplify/screens/client/credit_request_detail_screen.dart';

/// Onglet Vérification crédit : demandes vérifiées par l'agent.
/// Tap → détails. Si refusé : raisons comme pour le client.
class AgentHistoryCreditTab extends StatelessWidget {
  final AppUser user;

  const AgentHistoryCreditTab({super.key, required this.user});

  static final _mockVerifications = [
    CreditRequest(
      id: 'VCR001',
      amount: 150000,
      durationMonths: 6,
      motif: 'Stock commerce',
      status: CreditRequestStatus.approved,
      createdAt: '30/01/2025 09:30',
    ),
    CreditRequest(
      id: 'VCR002',
      amount: 50000,
      durationMonths: 3,
      status: CreditRequestStatus.rejected,
      createdAt: '29/01/2025 14:10',
      missingReasons: [
        'Client : garde au moins 5 000 CDF en épargne',
        'Client : fais 3 dépôts cette semaine',
      ],
    ),
    CreditRequest(
      id: 'VCR003',
      amount: 200000,
      durationMonths: 6,
      motif: 'Achat matériel',
      status: CreditRequestStatus.rejected,
      createdAt: '28/01/2025 11:55',
      missingReasons: [
        'Client : atteins 20 000 CDF en épargne pour améliorer ton score',
        'Client : fais au moins 3 dépôts (historique)',
      ],
    ),
    CreditRequest(
      id: 'VCR004',
      amount: 80000,
      durationMonths: 4,
      motif: 'Réapprovisionnement',
      status: CreditRequestStatus.approved,
      createdAt: '27/01/2025 16:20',
    ),
  ];

  static String _statusLabel(CreditRequestStatus s) {
    switch (s) {
      case CreditRequestStatus.pending:
        return 'En attente';
      case CreditRequestStatus.approved:
        return 'Approuvé';
      case CreditRequestStatus.rejected:
        return 'Refusé';
    }
  }

  static Color _statusColor(CreditRequestStatus s) {
    switch (s) {
      case CreditRequestStatus.pending:
        return AppTheme.warning;
      case CreditRequestStatus.approved:
        return AppTheme.success;
      case CreditRequestStatus.rejected:
        return AppTheme.destructive;
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
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _mockVerifications.length,
      itemBuilder: (context, i) {
        final req = _mockVerifications[i];
        final color = _statusColor(req.status);
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CreditRequestDetailScreen(user: user, request: req),
              ),
            ),
            borderRadius: BorderRadius.circular(AppTheme.radius),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: AppTheme.cardDark,
                borderRadius: BorderRadius.circular(AppTheme.radius),
                border: Border.all(color: AppTheme.cardDarkElevated),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: color.withOpacity(0.2),
                  child: Icon(
                    req.status == CreditRequestStatus.approved
                        ? Icons.check_circle_rounded
                        : req.status == CreditRequestStatus.rejected
                            ? Icons.cancel_rounded
                            : Icons.schedule_rounded,
                    color: color,
                    size: 22,
                  ),
                ),
                title: Text(
                  'Demande ${req.id}',
                  style: const TextStyle(color: AppTheme.sidebarForeground, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '${_fmt(req.amount)} CDF • ${req.createdAt}${req.status == CreditRequestStatus.rejected && req.missingReasons != null && req.missingReasons!.isNotEmpty ? " • ${req.missingReasons!.length} raisons" : ""}',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _statusLabel(req.status),
                      style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    Text(
                      '${_fmt(req.amount)} CDF',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
