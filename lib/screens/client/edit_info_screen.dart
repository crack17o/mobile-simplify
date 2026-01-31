import 'package:flutter/material.dart';
import 'package:mobile_simplify/models/user.dart';
import 'package:mobile_simplify/core/profile_service.dart';
import 'package:mobile_simplify/theme/app_theme.dart';

/// Modification des informations personnelles : nom affiché, email.
class EditInfoScreen extends StatefulWidget {
  final AppUser user;

  const EditInfoScreen({super.key, required this.user});

  @override
  State<EditInfoScreen> createState() => _EditInfoScreenState();
}

class _EditInfoScreenState extends State<EditInfoScreen> {
  final _profile = ProfileService();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  late final TextEditingController _msisdnController;
  bool _loading = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _msisdnController = TextEditingController(text: widget.user.msisdn);
    _load();
  }

  Future<void> _load() async {
    final name = await _profile.getDisplayName();
    final email = await _profile.getEmail();
    if (mounted) {
      _displayNameController.text = name ?? '';
      _emailController.text = email ?? '';
      setState(() => _initialized = true);
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _msisdnController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    await _profile.save(
      displayName: _displayNameController.text.trim(),
      email: _emailController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informations enregistrées'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(color: Colors.white70),
      hintStyle: TextStyle(color: Colors.white38),
      filled: true,
      fillColor: AppTheme.cardDark,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSmall), borderSide: BorderSide(color: AppTheme.cardDarkElevated)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSmall), borderSide: BorderSide(color: AppTheme.cardDarkElevated)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSmall), borderSide: const BorderSide(color: AppTheme.primary)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return Scaffold(
        backgroundColor: AppTheme.surfaceDark,
        appBar: AppBar(
          title: const Text('Mes informations'),
          backgroundColor: AppTheme.sidebarBackground,
          foregroundColor: AppTheme.sidebarForeground,
        ),
        body: const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      appBar: AppBar(
        title: const Text('Mes informations'),
        backgroundColor: AppTheme.sidebarBackground,
        foregroundColor: AppTheme.sidebarForeground,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(AppTheme.radius),
              border: Border.all(color: AppTheme.cardDarkElevated),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.person_rounded, color: AppTheme.primary, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Profil',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.sidebarForeground, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Ces informations sont affichées uniquement sur cet appareil.',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _displayNameController,
            textCapitalization: TextCapitalization.words,
            style: const TextStyle(color: AppTheme.sidebarForeground),
            decoration: _inputDecoration('Nom affiché', 'Ex: Jean Kabongo').copyWith(
              prefixIcon: Icon(Icons.badge_rounded, color: AppTheme.primary, size: 22),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: AppTheme.sidebarForeground),
            decoration: _inputDecoration('Email (optionnel)', 'exemple@email.com').copyWith(
              prefixIcon: Icon(Icons.email_rounded, color: AppTheme.primary, size: 22),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            readOnly: true,
            controller: _msisdnController,
            style: TextStyle(color: Colors.white54, fontSize: 14),
            decoration: _inputDecoration('Téléphone (MSISDN)', '').copyWith(
              prefixIcon: Icon(Icons.phone_rounded, color: Colors.white38, size: 22),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Le numéro de téléphone ne peut pas être modifié ici.',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _loading ? null : _submit,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: AppTheme.primaryForeground),
              child: _loading
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryForeground))
                  : const Text('Enregistrer'),
            ),
          ),
        ],
      ),
    );
  }
}
