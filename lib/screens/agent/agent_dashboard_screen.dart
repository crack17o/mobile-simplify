import 'package:flutter/material.dart';
import 'package:mobile_simplify/models/user.dart';
import 'package:mobile_simplify/screens/agent/redeem_cashout_screen.dart';
import 'package:mobile_simplify/theme/app_theme.dart';

/// Dashboard agent : action principale = Encaisser retrait (cashout).
class AgentDashboardScreen extends StatelessWidget {
  final AppUser user;

  const AgentDashboardScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.point_of_sale_rounded, size: 80, color: AppTheme.primary),
            const SizedBox(height: 24),
            Text(
              'Encaisser un retrait',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.sidebarForeground),
            ),
            const SizedBox(height: 8),
            Text(
              'Saisissez le code du client pour valider l\'encaissement.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white54),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RedeemCashoutScreen(user: user),
                  ),
                ),
                icon: const Icon(Icons.qr_code_scanner_rounded),
                label: const Text('Encaisser un retrait'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: AppTheme.primaryForeground,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
