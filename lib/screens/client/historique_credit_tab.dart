import 'package:flutter/material.dart';
import 'package:mobile_simplify/models/user.dart';
import 'package:mobile_simplify/models/credit.dart';
import 'package:mobile_simplify/theme/app_theme.dart';
import 'package:mobile_simplify/screens/client/microcredit/credit_detail_screen.dart';
import 'package:mobile_simplify/screens/client/credit_request_detail_screen.dart';

/// Onglet Crédit : historique des demandes (pending, approved, rejected) + crédits actifs/clôturés.
/// Tap → détails. Si rejeté : affiche "ce qui nous manque".
class HistoriqueCreditTab extends StatefulWidget {
  final AppUser user;

  const HistoriqueCreditTab({super.key, required this.user});

  @override
  State<HistoriqueCreditTab> createState() => _HistoriqueCreditTabState();
}

class _HistoriqueCreditTabState extends State<HistoriqueCreditTab> {
  int _activeTab = 0;

  static final _mockRequests = [
    CreditRequest(
      id: 'REQ001',
      amount: 150000,
      durationMonths: 6,
      motif: 'Stock commerce',
      status: CreditRequestStatus.approved,
      createdAt: '15/01/2025',
    ),
    CreditRequest(
      id: 'REQ002',
      amount: 50000,
      durationMonths: 3,
      status: CreditRequestStatus.rejected,
      createdAt: '10/12/2024',
      missingReasons: [
        'Garde au moins 5 000 CDF en épargne',
        'Fais 3 dépôts cette semaine',
      ],
    ),
    CreditRequest(
      id: 'REQ003',
      amount: 300000,
      durationMonths: 12,
      status: CreditRequestStatus.pending,
      createdAt: '28/01/2025',
    ),
    CreditRequest(
      id: 'REQ004',
      amount: 200000,
      durationMonths: 6,
      motif: 'Achat matériel',
      status: CreditRequestStatus.rejected,
      createdAt: '05/01/2025',
      missingReasons: [
        'Atteins 20 000 CDF en épargne pour améliorer ton score',
        'Fais au moins 3 dépôts (historique)',
      ],
    ),
    CreditRequest(
      id: 'REQ005',
      amount: 750000,
      durationMonths: 12,
      motif: 'Extension commerce',
      status: CreditRequestStatus.rejected,
      createdAt: '20/12/2024',
      missingReasons: [
        'Garde au moins 5 000 CDF en épargne',
        'Fais 3 dépôts cette semaine',
        'Atteins 20 000 CDF en épargne pour améliorer ton score',
      ],
    ),
  ];

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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => setState(() => _activeTab = 0),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _activeTab == 0 ? AppTheme.primary.withOpacity(0.2) : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        border: Border.all(
                          color: _activeTab == 0 ? AppTheme.primary : AppTheme.cardDarkElevated,
                        ),
                      ),
                      child: Text(
                        'Demandes',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _activeTab == 0 ? AppTheme.primary : Colors.white54,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => setState(() => _activeTab = 1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _activeTab == 1 ? AppTheme.primary.withOpacity(0.2) : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        border: Border.all(
                          color: _activeTab == 1 ? AppTheme.primary : AppTheme.cardDarkElevated,
                        ),
                      ),
                      child: Text(
                        'Crédits',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _activeTab == 1 ? AppTheme.primary : Colors.white54,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _activeTab == 0
              ? _buildDemandesList()
              : _buildCreditsList(),
        ),
      ],
    );
  }

  Widget _buildDemandesList() {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 400));
        if (mounted) setState(() {});
      },
      color: AppTheme.primary,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: _mockRequests.length,
        itemBuilder: (context, i) {
          final r = _mockRequests[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _DemandeTile(
              request: r,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreditRequestDetailScreen(user: widget.user, request: r),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCreditsList() {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 400));
        if (mounted) setState(() {});
      },
      color: AppTheme.primary,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: _mockCredits.length,
        itemBuilder: (context, i) {
          final c = _mockCredits[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _CreditTile(
              credit: c,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreditDetailScreen(user: widget.user, credit: c),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DemandeTile extends StatelessWidget {
  final CreditRequest request;
  final VoidCallback onTap;

  const _DemandeTile({required this.request, required this.onTap});

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
    final color = _statusColor(request.status);
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
                  Text('Demande ${request.id}', style: const TextStyle(color: AppTheme.sidebarForeground, fontWeight: FontWeight.w600, fontSize: 16)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(_statusLabel(request.status), style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('${_fmt(request.amount)} CDF • ${request.durationMonths} mois', style: TextStyle(color: Colors.white70, fontSize: 14)),
              Text(request.createdAt, style: TextStyle(color: Colors.white54, fontSize: 12)),
              if (request.status == CreditRequestStatus.rejected && request.missingReasons != null && request.missingReasons!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Voir ce qui manque →', style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ],
          ),
        ),
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
    final color = _statusColor(credit.status);
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
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(_statusLabel(credit.status), style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Principal : ${_fmt(credit.principal)} CDF', style: TextStyle(color: Colors.white70, fontSize: 13)),
              Text('Dû restant : ${_fmt(credit.remainingDue)} CDF', style: TextStyle(color: Colors.white54, fontSize: 13)),
              Text('Prochaine échéance : ${credit.nextDueDate}', style: TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
