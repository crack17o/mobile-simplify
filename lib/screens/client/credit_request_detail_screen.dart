import 'package:flutter/material.dart';
import 'package:mobile_simplify/models/user.dart';
import 'package:mobile_simplify/models/credit.dart';
import 'package:mobile_simplify/theme/app_theme.dart';

/// Détails d'une demande de crédit.
/// Si REJECTED : affiche "Ce qui nous manque pour que ce crédit soit accordé".
class CreditRequestDetailScreen extends StatelessWidget {
  final AppUser user;
  final CreditRequest request;

  const CreditRequestDetailScreen({super.key, required this.user, required this.request});

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
    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      appBar: AppBar(
        title: Text('Demande ${request.id}'),
        backgroundColor: AppTheme.sidebarBackground,
        foregroundColor: AppTheme.sidebarForeground,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.cardDark,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      border: Border.all(color: AppTheme.cardDarkElevated),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                request.status == CreditRequestStatus.approved
                                    ? Icons.check_circle_rounded
                                    : request.status == CreditRequestStatus.rejected
                                        ? Icons.cancel_rounded
                                        : Icons.schedule_rounded,
                                color: color,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _statusLabel(request.status),
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.sidebarForeground,
                                        ),
                                  ),
                                  Text('${_fmt(request.amount)} CDF • ${request.durationMonths} mois', style: TextStyle(color: Colors.white70, fontSize: 14)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Divider(color: AppTheme.cardDarkElevated),
                        const SizedBox(height: 8),
                        _DetailRow('Référence', request.id),
                        _DetailRow('Montant', '${_fmt(request.amount)} CDF', valueColor: AppTheme.primary),
                        _DetailRow('Durée', '${request.durationMonths} mois'),
                        _DetailRow('Date demande', request.createdAt),
                        _DetailRow('Statut', _statusLabel(request.status), valueColor: color),
                        if (request.motif != null && request.motif!.isNotEmpty) _DetailRow('Motif', request.motif!),
                      ],
                    ),
                  ),
                  if (request.status == CreditRequestStatus.rejected && request.missingReasons != null && request.missingReasons!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.cardDark,
                        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                        border: Border.all(color: AppTheme.destructive.withOpacity(0.5)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.info_outline_rounded, color: AppTheme.primary, size: 24),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Ce qu\'il te manque pour que ce crédit soit accordé',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.sidebarForeground,
                                      ),
                                  softWrap: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ...request.missingReasons!.map((r) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
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
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 1,
            child: Text(label, style: TextStyle(color: Colors.white54, fontSize: 14)),
          ),
          const SizedBox(width: 12),
          Flexible(
            flex: 2,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: valueColor ?? AppTheme.sidebarForeground,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }
}
