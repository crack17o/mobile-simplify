import 'package:flutter/material.dart';
import 'package:mobile_simplify/models/user.dart';
import 'package:mobile_simplify/theme/app_theme.dart';
import 'package:mobile_simplify/screens/agent/agent_history_deposit_tab.dart';
import 'package:mobile_simplify/screens/agent/agent_history_withdraw_tab.dart';
import 'package:mobile_simplify/screens/agent/agent_history_credit_tab.dart';

/// Historique agent : 3 onglets (Dépôt, Retrait, Vérification crédit).
/// Dépôt = dépôts wallet ; Retrait = retraits encaissés (code client) ; Crédit = vérifications avec raisons en cas de refus.
class AgentHistoryScreen extends StatefulWidget {
  final AppUser user;

  const AgentHistoryScreen({super.key, required this.user});

  @override
  State<AgentHistoryScreen> createState() => _AgentHistoryScreenState();
}

class _AgentHistoryScreenState extends State<AgentHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
            indicatorColor: AppTheme.primary,
            indicatorWeight: 3,
            labelColor: AppTheme.primary,
            unselectedLabelColor: Colors.white70,
            labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            tabs: const [
              Tab(text: 'Dépôt'),
              Tab(text: 'Retrait'),
              Tab(text: 'Vérif. crédit'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              AgentHistoryDepositTab(),
              AgentHistoryWithdrawTab(),
              AgentHistoryCreditTab(user: widget.user),
            ],
          ),
        ),
      ],
    );
  }
}
