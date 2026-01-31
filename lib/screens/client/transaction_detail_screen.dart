import 'package:flutter/material.dart';
import 'package:mobile_simplify/models/transaction.dart';
import 'package:mobile_simplify/theme/app_theme.dart';

/// Détails transaction : reference, type, status, amount, date, channel.
class TransactionDetailScreen extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    final color = t.isCredit ? AppTheme.success : AppTheme.destructive;
    final amountColor = t.isCredit ? AppTheme.primary : color;
    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      appBar: AppBar(
        title: const Text('Détail transaction'),
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
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        t.isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                        color: color,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.type, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: AppTheme.sidebarForeground)),
                          Text(t.reference, style: TextStyle(color: Colors.white54, fontSize: 13)),
                        ],
                      ),
                    ),
                    Text(
                      t.amount,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: amountColor),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Divider(color: AppTheme.cardDarkElevated),
                const SizedBox(height: 8),
                _Row('Référence', t.reference),
                _Row('Type', t.type),
                _Row('Statut', t.status),
                _Row('Montant', t.amount, valueColor: amountColor),
                _Row('Date', t.date),
                _Row('Canal', t.channel),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _Row(this.label, this.value, {this.valueColor});

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
