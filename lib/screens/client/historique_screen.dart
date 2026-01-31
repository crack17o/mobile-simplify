import 'package:flutter/material.dart';
import 'package:mobile_simplify/models/user.dart';
import 'package:mobile_simplify/theme/app_theme.dart';
import 'package:mobile_simplify/screens/client/historique_wallet_tab.dart';
import 'package:mobile_simplify/screens/client/historique_epargne_tab.dart';
import 'package:mobile_simplify/screens/client/historique_credit_tab.dart';
import 'package:mobile_simplify/screens/client/historique_tontine_tab.dart';

/// Historique central : onglets par module (Wallet, Épargne, Crédit, Tontine).
/// Chaque module a son interface distincte avec liste + détails d'opération.
class HistoriqueScreen extends StatefulWidget {
  final AppUser user;

  const HistoriqueScreen({super.key, required this.user});

  @override
  State<HistoriqueScreen> createState() => _HistoriqueScreenState();
}

class _HistoriqueScreenState extends State<HistoriqueScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: AppTheme.sidebarBackground,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: AppTheme.primary,
            unselectedLabelColor: Colors.white54,
            indicatorColor: AppTheme.primary,
            indicatorWeight: 3,
            tabs: const [
              Tab(icon: Icon(Icons.account_balance_wallet_rounded, size: 22), text: 'Wallet'),
              Tab(icon: Icon(Icons.savings_rounded, size: 22), text: 'Épargne'),
              Tab(icon: Icon(Icons.credit_score_rounded, size: 22), text: 'Crédit'),
              Tab(icon: Icon(Icons.groups_rounded, size: 22), text: 'Tontine'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              HistoriqueWalletTab(user: widget.user),
              HistoriqueEpargneTab(user: widget.user),
              HistoriqueCreditTab(user: widget.user),
              HistoriqueTontineTab(user: widget.user),
            ],
          ),
        ),
      ],
    );
  }
}
