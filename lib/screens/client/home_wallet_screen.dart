import 'package:flutter/material.dart';
import 'package:mobile_simplify/models/user.dart';
import 'package:mobile_simplify/theme/app_theme.dart';
import 'package:mobile_simplify/core/savings_service.dart';
import 'package:mobile_simplify/screens/client/send_money_screen.dart';
import 'package:mobile_simplify/screens/client/deposit_screen.dart';
import 'package:mobile_simplify/screens/client/withdraw_screen.dart';
import 'package:mobile_simplify/screens/client/conversion_screen.dart';
import 'package:mobile_simplify/screens/client/epargne_screen.dart';
import 'package:mobile_simplify/screens/client/microcredit/microcredit_home_screen.dart';
import 'package:mobile_simplify/screens/client/tontine_list_screen.dart';

/// Home Wallet : soldes CDF / USD / Épargne + Envoyer, Dépôt, Retrait, Conversion, Épargne, Tontine.
class HomeWalletScreen extends StatefulWidget {
  final AppUser user;

  const HomeWalletScreen({super.key, required this.user});

  @override
  State<HomeWalletScreen> createState() => _HomeWalletScreenState();
}

class _HomeWalletScreenState extends State<HomeWalletScreen> {
  final _savings = SavingsService();
  bool _savingsEnabled = false;
  double _savingsBalanceCdf = 0;

  @override
  void initState() {
    super.initState();
    _loadSavings();
  }

  Future<void> _loadSavings() async {
    final msisdn = widget.user.msisdn;
    final enabled = await _savings.isEnabled(msisdn);
    final balance = await _savings.getBalanceCdf(msisdn);
    if (mounted) {
      setState(() {
        _savingsEnabled = enabled;
        _savingsBalanceCdf = balance;
      });
    }
  }

  static String _formatCdf(double n) {
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
    const soldeCdf = '1 250 000'; // mock
    const soldeUsd = '450'; // mock
    final user = widget.user;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Text(
            'Bonjour',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white54,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Votre portefeuille',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.sidebarForeground,
                ),
          ),
          const SizedBox(height: 24),
          _BalanceCard(
            label: 'Franc congolais',
            amount: '$soldeCdf CDF',
            icon: Icons.attach_money_rounded,
          ),
          const SizedBox(height: 14),
          _BalanceCard(
            label: 'Dollars américains',
            amount: '\$$soldeUsd USD',
            icon: Icons.monetization_on_rounded,
          ),
          if (_savingsEnabled) ...[
            const SizedBox(height: 14),
            _BalanceCard(
              label: 'Mon épargne',
              amount: _formatCdf(_savingsBalanceCdf),
              icon: Icons.savings_rounded,
            ),
          ],
          const SizedBox(height: 28),
          Text(
            'Actions rapides',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.95,
            children: [
              _ActionCard(
                icon: Icons.send_rounded,
                label: 'Envoyer',
                subtitle: 'P2P',
                color: AppTheme.success,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SendMoneyScreen(user: user)),
                ),
              ),
              _ActionCard(
                icon: Icons.add_circle_rounded,
                label: 'Dépôt',
                subtitle: 'Mobile Money',
                color: const Color(0xFF1976D2),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DepositScreen(user: user)),
                ),
              ),
              _ActionCard(
                icon: Icons.remove_circle_rounded,
                label: 'Retrait',
                subtitle: 'Code à l\'agent',
                color: AppTheme.warning,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => WithdrawScreen(user: user)),
                ),
              ),
              _ActionCard(
                icon: Icons.currency_exchange_rounded,
                label: 'Conversion',
                subtitle: 'USD ↔ CDF',
                color: AppTheme.primary,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ConversionScreen(user: user)),
                ),
              ),
              _ActionCard(
                icon: Icons.credit_score_rounded,
                label: 'Microcrédit',
                subtitle: 'Simuler • Demander • Mes crédits',
                color: AppTheme.primary,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MicrocreditHomeScreen(user: user)),
                ),
              ),
              _ActionCard(
                icon: Icons.savings_rounded,
                label: 'Épargne',
                subtitle: 'Activer / solde',
                color: AppTheme.success,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EpargneScreen(user: user)),
                ).then((_) => _loadSavings()),
              ),
              _ActionCard(
                icon: Icons.groups_rounded,
                label: 'Tontine',
                subtitle: 'Créer / rejoindre',
                color: AppTheme.primary,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TontineListScreen(user: user)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final String label;
  final String amount;
  final IconData icon;

  const _BalanceCard({
    required this.label,
    required this.amount,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: AppTheme.cardDarkElevated, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppTheme.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              amount,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                    letterSpacing: 0.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.cardDark,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            border: Border.all(color: AppTheme.cardDarkElevated),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 26, color: color),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppTheme.sidebarForeground,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white54,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
