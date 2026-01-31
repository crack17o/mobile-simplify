import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_simplify/models/user.dart';
import 'package:mobile_simplify/theme/app_theme.dart';
import 'package:mobile_simplify/screens/agent/agent_client_detail_screen.dart';
import 'package:mobile_simplify/screens/agent/agent_deposit_screen.dart';
import 'package:mobile_simplify/screens/agent/agent_deposit_epargne_screen.dart';
import 'package:mobile_simplify/screens/agent/redeem_cashout_screen.dart';

/// Caisse : Dépôt (client → agent), Encaisser retrait (client donne code).
/// Consultation par téléphone : solde, score, éligibilité.
class AgentCaisseScreen extends StatefulWidget {
  final AppUser user;

  const AgentCaisseScreen({super.key, required this.user});

  @override
  State<AgentCaisseScreen> createState() => _AgentCaisseScreenState();
}

class _AgentCaisseScreenState extends State<AgentCaisseScreen> {
  final _phoneController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String _normalizePhone(String v) {
    var s = v.replaceAll(RegExp(r'\D'), '');
    if (s.length == 9 && !s.startsWith('243')) s = '243$s';
    return s;
  }

  bool _validatePhone() {
    final phone = _normalizePhone(_phoneController.text.trim());
    if (phone.isEmpty) {
      setState(() => _error = 'Téléphone requis');
      return false;
    }
    if (phone.length < 12) {
      setState(() => _error = 'Format +243 XXX XXX XXXX');
      return false;
    }
    setState(() => _error = null);
    return true;
  }

  void _consultation() {
    if (!_validatePhone()) return;
    final phone = _normalizePhone(_phoneController.text.trim());
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AgentClientDetailScreen(user: widget.user, phone: phone)),
    );
  }

  void _deposit() {
    if (!_validatePhone()) return;
    final phone = _normalizePhone(_phoneController.text.trim());
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AgentDepositScreen(user: widget.user, phone: phone)),
    );
  }

  void _depositEpargne() {
    if (!_validatePhone()) return;
    final phone = _normalizePhone(_phoneController.text.trim());
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AgentDepositEpargneScreen(user: widget.user, phone: phone)),
    );
  }

  void _encaisserRetrait() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RedeemCashoutScreen(user: widget.user)),
    );
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Dépôt / Retrait wallet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Téléphone : consultation, dépôt wallet ou dépôt épargne. Retrait : le client génère un code, vous le saisissez.',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d\s+]')), LengthLimitingTextInputFormatter(14)],
            decoration: _decoration('Téléphone client', '+243 812 345 678'),
            style: const TextStyle(color: AppTheme.sidebarForeground),
            onChanged: (_) => setState(() => _error = null),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
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
            child: OutlinedButton.icon(
              onPressed: _consultation,
              icon: const Icon(Icons.search_rounded, size: 22),
              label: const Text('Consulter (solde, score, éligibilité)'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primary,
                side: const BorderSide(color: AppTheme.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSmall)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _deposit,
              icon: const Icon(Icons.add_circle_rounded, size: 22),
              label: const Text('Dépôt wallet (caisse)'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _encaisserRetrait,
              icon: const Icon(Icons.qr_code_scanner_rounded, size: 22),
              label: const Text('Encaisser retrait (code client)'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.warning, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ),
        ],
      ),
    );
  }
}
