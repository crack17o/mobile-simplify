import 'package:flutter/material.dart';
import 'package:mobile_simplify/models/user.dart';
import 'package:mobile_simplify/screens/client/home_wallet_screen.dart';
import 'package:mobile_simplify/screens/client/historique_screen.dart';
import 'package:mobile_simplify/screens/client/settings_screen.dart';
import 'package:mobile_simplify/theme/app_theme.dart';
import 'package:mobile_simplify/widgets/user_menu_button.dart';

/// Shell client : bottom nav Home, Historique, Paramètres.
class ClientShell extends StatefulWidget {
  final AppUser user;

  const ClientShell({super.key, required this.user});

  @override
  State<ClientShell> createState() => _ClientShellState();
}

class _ClientShellState extends State<ClientShell> {
  int _index = 0;

  final _screens = <Widget>[];

  @override
  void initState() {
    super.initState();
    _screens.addAll([
      HomeWalletScreen(user: widget.user),
      HistoriqueScreen(user: widget.user),
      SettingsScreen(user: widget.user),
    ]);
  }

  static const _navIcons = [
    Icons.account_balance_wallet_rounded,
    Icons.history_rounded,
    Icons.settings_rounded,
  ];
  static const _navLabels = ['Accueil', 'Historique', 'Paramètres'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      appBar: _buildAppBar(context, 'Simplify'),
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, String title) {
    return AppBar(
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
            Icons.account_balance_wallet_rounded,
            color: AppTheme.sidebarForeground,
            size: 40,
          ),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          letterSpacing: 0.5,
        ),
      ),
      actions: [
        UserMenuButton(user: widget.user),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border(top: BorderSide(color: AppTheme.cardDarkElevated, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navIcons.length, (i) {
              final selected = _index == i;
              return Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => setState(() => _index = i),
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppTheme.primary.withOpacity(0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _navIcons[i],
                            size: 26,
                            color: selected
                                ? AppTheme.primary
                                : Colors.white54,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _navLabels[i],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                              color: selected
                                  ? AppTheme.primary
                                  : Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
