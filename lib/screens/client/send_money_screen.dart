import 'package:flutter/material.dart';
import 'package:mobile_simplify/models/user.dart';
import 'package:mobile_simplify/theme/app_theme.dart';

/// Envoyer argent (P2P) : destinataire (msisdn), montant, motif optionnel → Confirmation (PIN).
class SendMoneyScreen extends StatefulWidget {
  final AppUser user;

  const SendMoneyScreen({super.key, required this.user});

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  final _msisdnController = TextEditingController();
  final _amountController = TextEditingController();
  final _motifController = TextEditingController();
  bool _stepConfirm = false;
  final _pinController = TextEditingController();

  @override
  void dispose() {
    _msisdnController.dispose();
    _amountController.dispose();
    _motifController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _goConfirm() {
    if (_msisdnController.text.trim().isEmpty || _amountController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Destinataire et montant requis')),
      );
      return;
    }
    setState(() => _stepConfirm = true);
  }

  void _submit() {
    if (_pinController.text.trim().length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN invalide')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transfert en cours...')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_stepConfirm) {
      return Scaffold(
        backgroundColor: AppTheme.surfaceDark,
        appBar: AppBar(
          title: const Text('Confirmer transfert'),
          backgroundColor: AppTheme.sidebarBackground,
          foregroundColor: AppTheme.sidebarForeground,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => setState(() => _stepConfirm = false),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardDark,
                borderRadius: BorderRadius.circular(AppTheme.radius),
                border: Border.all(color: AppTheme.cardDarkElevated),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Destinataire: ${_msisdnController.text.trim()}', style: const TextStyle(color: AppTheme.sidebarForeground)),
                  Text('Montant: ${_amountController.text.trim()} CDF', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
                  if (_motifController.text.trim().isNotEmpty) Text('Motif: ${_motifController.text.trim()}', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppTheme.sidebarForeground),
              decoration: InputDecoration(
                labelText: 'Entrez votre PIN',
                hintText: '••••',
                labelStyle: TextStyle(color: Colors.white70),
                hintStyle: TextStyle(color: Colors.white38),
                filled: true,
                fillColor: AppTheme.cardDark,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSmall), borderSide: BorderSide(color: AppTheme.cardDarkElevated)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSmall), borderSide: BorderSide(color: AppTheme.cardDarkElevated)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSmall), borderSide: const BorderSide(color: AppTheme.primary)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: AppTheme.primaryForeground),
                child: const Text('Confirmer'),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      appBar: AppBar(
        title: const Text('Envoyer argent'),
        backgroundColor: AppTheme.sidebarBackground,
        foregroundColor: AppTheme.sidebarForeground,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _darkTextField(
            controller: _msisdnController,
            keyboardType: TextInputType.phone,
            label: 'Téléphone destinataire (MSISDN)',
            hint: '+243 XXX XXX XXXX',
          ),
          const SizedBox(height: 16),
          _darkTextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            label: 'Montant (CDF)',
            hint: '0',
          ),
          const SizedBox(height: 16),
          _darkTextField(
            controller: _motifController,
            label: 'Motif (optionnel)',
            hint: 'Ex: Remboursement',
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _goConfirm,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: AppTheme.primaryForeground),
              child: const Text('Continuer'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _darkTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppTheme.sidebarForeground),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: Colors.white70),
        hintStyle: TextStyle(color: Colors.white38),
        filled: true,
        fillColor: AppTheme.cardDark,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSmall), borderSide: BorderSide(color: AppTheme.cardDarkElevated)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSmall), borderSide: BorderSide(color: AppTheme.cardDarkElevated)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSmall), borderSide: const BorderSide(color: AppTheme.primary)),
      ),
    );
  }
}
