import 'package:flutter/material.dart';
import 'package:mobile_simplify/models/user.dart';
import 'package:mobile_simplify/models/cashout_operation.dart';
import 'package:mobile_simplify/theme/app_theme.dart';

/// Historique opérations agent : liste des cashouts confirmés.
/// Endpoint: GET /api/v1/agent/operations?limit=20
class AgentHistoryScreen extends StatelessWidget {
  final AppUser user;

  const AgentHistoryScreen({super.key, required this.user});

  static final _mockOps = [
    const CashoutOperation(
      id: 'OP001',
      code: 'ABC123',
      amount: '25 000 CDF',
      date: '29/01/2024 11:32',
      status: 'CONFIRMED',
    ),
    const CashoutOperation(
      id: 'OP002',
      code: 'DEF456',
      amount: '50 000 CDF',
      date: '29/01/2024 10:15',
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
              backgroundColor: AppTheme.success.withOpacity(0.2),
              child: Icon(Icons.check_rounded, color: AppTheme.success),
            ),
            title: Text('Code ${op.code}', style: const TextStyle(color: AppTheme.sidebarForeground, fontWeight: FontWeight.w600)),
            subtitle: Text('${op.amount} • ${op.date}', style: TextStyle(color: Colors.white54, fontSize: 13)),
            trailing: Text(op.status, style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
          ),
        );
      },
    );
  }
}
