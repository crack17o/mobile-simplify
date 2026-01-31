import 'package:flutter/material.dart';
import 'package:mobile_simplify/core/auth_service.dart';
import 'package:mobile_simplify/core/user_profile_service.dart';
import 'package:mobile_simplify/models/user.dart';
import 'package:mobile_simplify/theme/app_theme.dart';
import 'package:mobile_simplify/screens/client/client_shell.dart';

/// Création profil : nom, prénom, adresse, commune, activité (liste).
class RegistrationProfileScreen extends StatefulWidget {
  final String msisdn;
  final String pin;

  const RegistrationProfileScreen({super.key, required this.msisdn, required this.pin});

  @override
  State<RegistrationProfileScreen> createState() => _RegistrationProfileScreenState();
}

class _RegistrationProfileScreenState extends State<RegistrationProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _communeController = TextEditingController();
  String? _selectedActivite;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _communeController.dispose();
    super.dispose();
  }

  String? _required(String? v) {
    if ((v ?? '').trim().isEmpty) return 'Requis';
    return null;
  }

  Future<void> _submit() async {
    _error = null;
    if (!_formKey.currentState!.validate()) return;
    if (_selectedActivite == null || _selectedActivite!.isEmpty) {
      setState(() => _error = 'Choisissez une activité');
      return;
    }
    setState(() => _loading = true);
    try {
      final profile = UserProfileService();
      await profile.saveProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        commune: _communeController.text.trim().isEmpty ? null : _communeController.text.trim(),
        activite: _selectedActivite,
      );
      await profile.setOnboardingDone();
      final auth = AuthService();
      AppUser? user;
      if (widget.pin.isNotEmpty) {
        user = await auth.login(msisdn: widget.msisdn, pin: widget.pin);
      } else {
        await auth.loadFromStorage();
        user = auth.currentUser;
      }
      if (!mounted) return;
      if (user == null) {
        setState(() {
          _error = 'Erreur de connexion';
          _loading = false;
        });
        return;
      }
      setState(() => _loading = false);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => ClientShell(user: user!)),
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      appBar: AppBar(
        title: const Text('Votre profil'),
        backgroundColor: AppTheme.sidebarBackground,
        foregroundColor: AppTheme.sidebarForeground,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D0D0D), Color(0xFF1A1A1A)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Complétez votre profil',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nom, prénom, adresse et activité pour personnaliser votre compte.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _firstNameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: _inputDecoration('Prénom', 'Ex: Jean'),
                    style: const TextStyle(color: Colors.white),
                    validator: _required,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _lastNameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: _inputDecoration('Nom', 'Ex: Mukendi'),
                    style: const TextStyle(color: Colors.white),
                    validator: _required,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: _inputDecoration('Adresse', 'Ex: Avenue du Commerce'),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _communeController,
                    decoration: _inputDecoration('Commune', 'Ex: Gombe, Lingwala'),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedActivite,
                    decoration: _inputDecoration('Activité', null),
                    dropdownColor: AppTheme.cardDark,
                    style: const TextStyle(color: Colors.white),
                    hint: const Text('Choisir une activité', style: TextStyle(color: Colors.white54)),
                    items: UserProfileService.activites
                        .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedActivite = v),
                    validator: (v) => v == null || v.isEmpty ? 'Choisissez une activité' : null,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.destructive.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline_rounded, color: AppTheme.destructive, size: 20),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_error!, style: const TextStyle(color: AppTheme.destructive, fontSize: 14))),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: AppTheme.primaryForeground,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                      ),
                      child: _loading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryForeground),
                            )
                          : const Text('Créer mon compte'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, String? hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: AppTheme.cardDark,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSmall)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        borderSide: BorderSide(color: AppTheme.cardDarkElevated),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        borderSide: const BorderSide(color: AppTheme.primary, width: 2),
      ),
      labelStyle: const TextStyle(color: Colors.white70),
      hintStyle: TextStyle(color: Colors.white38),
    );
  }
}
