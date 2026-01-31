import 'package:flutter/material.dart';
import 'package:mobile_simplify/models/agent_deposit_operation.dart';
import 'package:mobile_simplify/theme/app_theme.dart';

/// Onglet Dépôt : historique des dépôts wallet effectués par l'agent.
class AgentHistoryDepositTab extends StatelessWidget {
  static final _mockDeposits = [
    const AgentDepositOperation(
      id: 'DEP001',
      phone: '+243 812 345 678',
      amount: '75 000 CDF',
      reference: 'Caisse 1',
      date: '30/01/2025 09:15',
    ),
    const AgentDepositOperation(
      id: 'DEP002',
      phone: '+243 998 112 233',
      amount: '50 000 CDF',
      date: '29/01/2025 14:22',
    ),
    const AgentDepositOperation(
      id: 'DEP003',
      phone: '+243 815 667 889',
      amount: '120 000 CDF',
      reference: 'Paiement vente',
      date: '28/01/2025 11:40',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _mockDeposits.length,
      itemBuilder: (context, i) {
        final op = _mockDeposits[i];
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
              backgroundColor: AppTheme.success.withOpacity(0.2),
              child: const Icon(Icons.add_circle_rounded, color: AppTheme.success),
            ),
            title: Text(
              op.phone,
              style: const TextStyle(color: AppTheme.sidebarForeground, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${op.amount} • ${op.date}',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
            trailing: Text(
              op.amount,
              style: const TextStyle(color: AppTheme.success, fontWeight: FontWeight.w600),
            ),
          ),
        );
      },
    );
  }
}
