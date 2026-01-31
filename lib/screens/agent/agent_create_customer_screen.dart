import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_simplify/models/user.dart';
import 'package:mobile_simplify/theme/app_theme.dart';
import 'package:mobile_simplify/core/agent_api_service.dart';

/// Créer un client — POST /api/agent/customers/
/// phone_number, first_name, last_name, email, initial_pin (optionnel, 4 chiffres)
class AgentCreateCustomerScreen extends StatefulWidget {
  final AppUser user;

  const AgentCreateCustomerScreen({super.key, required this.user});

  @override
  State<AgentCreateCustomerScreen> createState() => _AgentCreateCustomerScreenState();
}

class _AgentCreateCustomerScreenState extends State<AgentCreateCustomerScreen> {
  late final AgentApiService _api;
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _pinController = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _success = false;
  Map<String, dynamic>? _created;

  @override
  void initState() {
    super.initState();
    _api = AgentApiService(accessToken: widget.user.token, useMock: true);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    _error = null;
    if (!_formKey.currentState!.validate()) return;
    final pin = _pinController.text.trim();
    if (pin.isNotEmpty && (pin.length != 4 || !RegExp(r'^\d{4}$').hasMatch(pin))) {
      setState(() => _error = 'PIN à 4 chiffres');
      return;
    }
    setState(() => _loading = true);
    final phone = _phoneController.text.trim().replaceAll(RegExp(r'\D'), '');
    final phoneNorm = phone.length == 9 ? '243$phone' : phone;
    final result = await _api.createCustomer(
      phoneNumber: phoneNorm,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      initialPin: pin.isEmpty ? null : pin,
    );
    if (!mounted) return;
    if (result != null) {
      setState(() {
        _loading = false;
        _success = true;
        _created = result;
      });
    } else {
      setState(() {
        _loading = false;
        _error = 'Erreur lors de la création';
      });
    }
  }

  InputDecoration _decoration(String label, [String? hint]) => InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: AppTheme.cardDark,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSmall)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSmall), borderSide: BorderSide(color: AppTheme.cardDarkElevated)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSmall), borderSide: const BorderSide(color: AppTheme.primary)),
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: TextStyle(color: Colors.white38),
      );

  @override
  Widget build(BuildContext context) {
    if (_success && _created != null) {
      return Scaffold(
        backgroundColor: AppTheme.surfaceDark,
        appBar: AppBar(title: const Text('Client créé'), backgroundColor: AppTheme.sidebarBackground, foregroundColor: AppTheme.sidebarForeground),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_rounded, size: 80, color: AppTheme.success),
              const SizedBox(height: 24),
              Text('Client créé avec succès', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.sidebarForeground)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: AppTheme.cardDark, borderRadius: BorderRadius.circular(AppTheme.radius), border: Border.all(color: AppTheme.cardDarkElevated)),
                child: Column(
                  children: [
                    _row('Téléphone', _created!['phone_number']?.toString() ?? '-'),
                    _row('Nom', '${_created!['first_name']} ${_created!['last_name']}'),
                    _row('ID', _created!['id']?.toString() ?? '-'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: AppTheme.primaryForeground),
                  child: const Text('Terminer'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      appBar: AppBar(
        title: const Text('Créer un client'),
        backgroundColor: AppTheme.sidebarBackground,
        foregroundColor: AppTheme.sidebarForeground,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d\s+]')), LengthLimitingTextInputFormatter(14)],
                  decoration: _decoration('Téléphone (phone_number)', '+243 812 345 678'),
                  style: const TextStyle(color: AppTheme.sidebarForeground),
                  validator: (v) {
                    final s = (v ?? '').replaceAll(RegExp(r'\D'), '');
                    if (s.isEmpty) return 'Requis';
                    if (s.length < 9) return '9 chiffres min (après 243)';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _firstNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: _decoration('Prénom (first_name)'),
                  style: const TextStyle(color: AppTheme.sidebarForeground),
                  validator: (v) => (v ?? '').trim().isEmpty ? 'Requis' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lastNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: _decoration('Nom (last_name)'),
                  style: const TextStyle(color: AppTheme.sidebarForeground),
                  validator: (v) => (v ?? '').trim().isEmpty ? 'Requis' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _decoration('Email (optionnel)', 'client@example.com'),
                  style: const TextStyle(color: AppTheme.sidebarForeground),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
                  decoration: _decoration('PIN initial (optionnel, 4 chiffres)', '••••'),
                  style: const TextStyle(color: AppTheme.sidebarForeground),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppTheme.destructive.withOpacity(0.1), borderRadius: BorderRadius.circular(AppTheme.radiusSmall)),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline_rounded, color: AppTheme.destructive, size: 20),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_error!, style: const TextStyle(color: AppTheme.destructive))),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: AppTheme.primaryForeground),
                    child: _loading
                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryForeground))
                        : const Text('Créer le client'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: Colors.white54, fontSize: 14)),
            Text(value, style: const TextStyle(color: AppTheme.sidebarForeground, fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      );
}
