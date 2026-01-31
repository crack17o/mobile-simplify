import 'package:flutter/material.dart';
import 'package:mobile_simplify/core/auth_service.dart';
import 'package:mobile_simplify/models/user.dart';
import 'package:mobile_simplify/theme/app_theme.dart';
import 'package:mobile_simplify/screens/login_screen.dart';
import 'package:mobile_simplify/screens/client/edit_info_screen.dart';
import 'package:mobile_simplify/screens/client/change_pin_screen.dart';

/// Paramètres : Changer PIN (MVP+), Déconnexion.
class SettingsScreen extends StatelessWidget {
  final AppUser user;

  const SettingsScreen({super.key, required this.user});

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusLarge)),
        title: const Text('Déconnexion', style: TextStyle(color: AppTheme.sidebarForeground)),
        content: const Text('Voulez-vous vous déconnecter ?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Annuler', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Déconnexion', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;
    await AuthService().logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Paramètres',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
        ),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardDark,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            border: Border.all(color: AppTheme.cardDarkElevated),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.person_rounded, color: AppTheme.primary, size: 22),
                ),
                title: const Text('Mes informations', style: TextStyle(fontWeight: FontWeight.w500, color: AppTheme.sidebarForeground)),
                subtitle: Text('Nom, email', style: TextStyle(color: Colors.white54, fontSize: 14)),
                trailing: Icon(Icons.chevron_right_rounded, color: Colors.white38),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EditInfoScreen(user: user)),
                ),
              ),
              Divider(height: 1, color: AppTheme.cardDarkElevated, indent: 72),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.phone_android_rounded, color: AppTheme.primary, size: 22),
                ),
                title: const Text('Téléphone', style: TextStyle(fontWeight: FontWeight.w500, color: AppTheme.sidebarForeground)),
                subtitle: Text(user.msisdn, style: TextStyle(color: Colors.white54, fontSize: 14)),
              ),
              Divider(height: 1, color: AppTheme.cardDarkElevated, indent: 72),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.cardDarkElevated,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.lock_rounded, color: Colors.white54, size: 22),
                ),
                title: const Text('Changer PIN', style: TextStyle(fontWeight: FontWeight.w500, color: AppTheme.sidebarForeground)),
                subtitle: Text('Modifier votre code secret', style: TextStyle(color: Colors.white38, fontSize: 12)),
                trailing: Icon(Icons.chevron_right_rounded, color: Colors.white38),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ChangePinScreen(user: user)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primary,
              side: const BorderSide(color: AppTheme.primary),
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radius),
              ),
            ),
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout_rounded, size: 20),
            label: const Text('Déconnexion'),
          ),
        ),
      ],
    );
  }
}
