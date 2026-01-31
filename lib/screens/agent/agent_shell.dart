import 'package:flutter/material.dart';
import 'package:mobile_simplify/models/user.dart';
import 'package:mobile_simplify/screens/agent/agent_clients_screen.dart';
import 'package:mobile_simplify/screens/agent/agent_caisse_screen.dart';
import 'package:mobile_simplify/screens/agent/agent_history_screen.dart';
import 'package:mobile_simplify/theme/app_theme.dart';
import 'package:mobile_simplify/widgets/user_menu_button.dart';

/// Shell agent : onglets Clients, Caisse (Dépôt/Retrait), Historique.
class AgentShell extends StatefulWidget {
  final AppUser user;

  const AgentShell({super.key, required this.user});

  @override
  State<AgentShell> createState() => _AgentShellState();
}

class _AgentShellState extends State<AgentShell> with SingleTickerProviderStateMixin {
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
    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: AppTheme.sidebarBackground,
        foregroundColor: AppTheme.sidebarForeground,
        elevation: 0,
        leadingWidth: 120,
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: Image.asset(
            'assets/logo-light.png',
            height: 72,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Icon(
              Icons.point_of_sale_rounded,
              color: AppTheme.sidebarForeground,
              size: 40,
            ),
          ),
        ),
        title: const Text(
          'Simplify Agent',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          UserMenuButton(user: widget.user),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: AppTheme.sidebarBackground,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.primary,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: AppTheme.primary,
              unselectedLabelColor: Colors.white70,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              tabs: const [
                Tab(
                  icon: Icon(Icons.people_rounded, size: 22),
                  text: 'Clients',
                ),
                Tab(
                  icon: Icon(Icons.point_of_sale_rounded, size: 22),
                  text: 'Caisse',
                ),
                Tab(
                  icon: Icon(Icons.history_rounded, size: 22),
                  text: 'Historique',
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          AgentClientsScreen(user: widget.user),
          AgentCaisseScreen(user: widget.user),
          AgentHistoryScreen(user: widget.user),
        ],
      ),
    );
  }
}
