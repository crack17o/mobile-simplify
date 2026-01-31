import 'package:flutter/material.dart';
import 'package:mobile_simplify/models/cashout_operation.dart';
import 'package:mobile_simplify/theme/app_theme.dart';

/// Onglet Retrait : historique des retraits encaissés par l'agent (code client).
class AgentHistoryWithdrawTab extends StatelessWidget {
  static final _mockOps = [
    const CashoutOperation(
      id: 'RET001',
      code: 'WDR123456',
      amount: '25 000 CDF',
      date: '30/01/2025 10:32',
      status: 'CONFIRMED',
    ),
    const CashoutOperation(
      id: 'RET002',
      code: 'WDR789012',
      amount: '50 000 CDF',
      date: '29/01/2025 14:15',
      status: 'CONFIRMED',
    ),
    const CashoutOperation(
      id: 'RET003',
      code: 'ABC123',
      amount: '15 000 CDF',
      date: '28/01/2025 11:20',
      status: 'CONFIRMED',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _mockOps.length,
      itemBuilder: (context, i) {
        final op = _mockOps[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppTheme.cardDark,
            borderRadius: BorderRadius.circular(AppTheme.radius),
            border: Border.all(color: AppTheme.cardDarkElevated),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: AppTheme.warning.withOpacity(0.2),
              child: const Icon(Icons.remove_circle_rounded, color: AppTheme.warning),
            ),
            title: Text(
              'Code ${op.code}',
              style: const TextStyle(color: AppTheme.sidebarForeground, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${op.amount} • ${op.date}',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
            trailing: Text(
              op.amount,
              style: const TextStyle(color: AppTheme.warning, fontWeight: FontWeight.w600),
            ),
          ),
        );
      },
    );
  }
}
