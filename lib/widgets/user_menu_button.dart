import 'package:flutter/material.dart';
import 'package:mobile_simplify/core/auth_service.dart';
import 'package:mobile_simplify/core/profile_service.dart';
import 'package:mobile_simplify/models/user.dart';
import 'package:mobile_simplify/screens/client/edit_info_screen.dart';
import 'package:mobile_simplify/screens/login_screen.dart';
import 'package:mobile_simplify/theme/app_theme.dart';

/// Bouton navbar : cercle avec initiales (ou icône). Clic → menu Gérer profil / Se déconnecter.
class UserMenuButton extends StatefulWidget {
  final AppUser user;

  const UserMenuButton({super.key, required this.user});

  @override
  State<UserMenuButton> createState() => _UserMenuButtonState();
}

class _UserMenuButtonState extends State<UserMenuButton> {
  String _initials = '?';

  @override
  void initState() {
    super.initState();
    _loadInitials();
  }

  Future<void> _loadInitials() async {
    final name = await ProfileService().getDisplayName();
    if (!mounted) return;
    if (name != null && name.trim().isNotEmpty) {
      final parts = name.trim().split(RegExp(r'\s+'));
      if (parts.length >= 2) {
        setState(() => _initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase());
        return;
      }
      if (parts.isNotEmpty && parts.first.isNotEmpty) {
        setState(() => _initials = parts.first.substring(0, 1).toUpperCase());
        return;
      }
    }
    if (widget.user.msisdn.length >= 2) {
      setState(() => _initials = widget.user.msisdn.substring(widget.user.msisdn.length - 2));
    }
  }

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
    return PopupMenuButton<String>(
      offset: const Offset(0, 48),
      color: AppTheme.cardDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radius)),
      onSelected: (value) {
        if (value == 'profile') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EditInfoScreen(user: widget.user)),
          );
        } else if (value == 'logout') {
          _logout(context);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              Icon(Icons.person_rounded, color: AppTheme.primary, size: 22),
              SizedBox(width: 12),
              Text('Gérer son profil', style: TextStyle(color: AppTheme.sidebarForeground)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout_rounded, color: AppTheme.destructive, size: 22),
              SizedBox(width: 12),
              Text('Se déconnecter', style: TextStyle(color: AppTheme.destructive)),
            ],
          ),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: AppTheme.primary.withOpacity(0.3),
          child: Text(
            _initials,
            style: const TextStyle(
              color: AppTheme.sidebarForeground,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
