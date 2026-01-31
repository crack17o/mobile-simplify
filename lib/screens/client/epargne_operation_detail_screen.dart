import 'package:flutter/material.dart';
import 'package:mobile_simplify/theme/app_theme.dart';

/// Détails d'une opération épargne : montant, date, statut, motif si échec.
class EpargneOperationDetailScreen extends StatelessWidget {
  final double amount;
  final String date;
  final String status;
  final String? reason;

  const EpargneOperationDetailScreen({
    super.key,
    required this.amount,
    required this.date,
    required this.status,
    this.reason,
  });

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
    final isSuccess = status == 'SUCCESS';
    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      appBar: AppBar(
        title: const Text('Détail opération'),
        backgroundColor: AppTheme.sidebarBackground,
        foregroundColor: AppTheme.sidebarForeground,
        elevation: 0,
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
                        color: (isSuccess ? AppTheme.success : AppTheme.destructive).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isSuccess ? Icons.check_circle_rounded : Icons.cancel_rounded,
                        color: isSuccess ? AppTheme.success : AppTheme.destructive,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isSuccess ? 'Versement réussi' : 'Échec',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.sidebarForeground,
                                ),
                          ),
                          Text(_fmtCdf(amount), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.primary)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Divider(color: AppTheme.cardDarkElevated),
                const SizedBox(height: 8),
                _DetailRow('Montant', _fmtCdf(amount), valueColor: AppTheme.primary),
                _DetailRow('Date', date),
                _DetailRow('Statut', status, valueColor: isSuccess ? AppTheme.success : AppTheme.destructive),
                if (reason != null && reason!.isNotEmpty) _DetailRow('Motif', reason!, valueColor: AppTheme.destructive),
              ],
            ),
          ),
        ],
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
        children: [
          Text(label, style: TextStyle(color: Colors.white54, fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: valueColor ?? AppTheme.sidebarForeground,
            ),
          ),
        ],
      ),
    );
  }
}
