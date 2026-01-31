import 'package:flutter/material.dart';
import 'package:mobile_simplify/models/user.dart';
import 'package:mobile_simplify/theme/app_theme.dart';
import 'package:mobile_simplify/core/agent_api_service.dart';
import 'package:mobile_simplify/screens/agent/agent_deposit_screen.dart';
import 'package:mobile_simplify/screens/agent/agent_deposit_epargne_screen.dart';

/// Consultation par téléphone : solde wallet, score, éligibilité crédit.
/// GET /api/wallet/summary/?phone= | /api/score/?phone= | /api/loans/eligibility/?phone=
class AgentClientDetailScreen extends StatefulWidget {
  final AppUser user;
  final String phone;
  final String customerName;

  const AgentClientDetailScreen({super.key, required this.user, required this.phone, this.customerName = ''});

  @override
  State<AgentClientDetailScreen> createState() => _AgentClientDetailScreenState();
}

class _AgentClientDetailScreenState extends State<AgentClientDetailScreen> {
  Map<String, dynamic>? _wallet;
  Map<String, dynamic>? _score;
  Map<String, dynamic>? _eligibility;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final api = AgentApiService(accessToken: widget.user.token, useMock: true);
    final wallet = await api.getWalletSummary(widget.phone);
    final score = await api.getScore(widget.phone);
    final eligibility = await api.getEligibility(widget.phone);
    if (mounted) {
      setState(() {
        _wallet = wallet;
        _score = score;
        _eligibility = eligibility;
        _loading = false;
      });
    }
  }

  static String _fmt(double n) {
    final s = n.toStringAsFixed(0);
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      appBar: AppBar(
        title: Text(widget.customerName.isEmpty ? 'Client' : widget.customerName),
        backgroundColor: AppTheme.sidebarBackground,
        foregroundColor: AppTheme.sidebarForeground,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : RefreshIndicator(
              onRefresh: _load,
              color: AppTheme.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          Text(widget.phone, style: TextStyle(color: Colors.white54, fontSize: 14)),
                          const SizedBox(height: 8),
                          Text('Solde Wallet', style: TextStyle(color: Colors.white70, fontSize: 14)),
                          Text('${_fmt((_wallet?['balance_cdf'] ?? 0).toDouble())} CDF', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 22)),
                          if (_wallet?['balance_usd'] != null)
                            Text('\$${_wallet!['balance_usd']} USD', style: TextStyle(color: Colors.white70, fontSize: 14)),
                          if (_wallet?['savings_cdf'] != null) ...[
                            const SizedBox(height: 12),
                            Text('Épargne', style: TextStyle(color: Colors.white70, fontSize: 14)),
                            Text('${_fmt((_wallet!['savings_cdf'] as num).toDouble())} CDF', style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.w600, fontSize: 18)),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _InfoCard(
                            label: 'Score',
                            value: '${_score?['score'] ?? '-'}',
                            sub: _score?['risk_band'] != null ? 'Bande ${_score!['risk_band']}' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InfoCard(
                            label: 'Éligibilité crédit',
                            value: _eligibility?['eligible'] == true ? 'Oui' : 'Non',
                            sub: _eligibility?['max_loan'] != null ? 'Plafond: ${_fmt((_eligibility!['max_loan'] as num).toDouble())} CDF' : null,
                            valueColor: _eligibility?['eligible'] == true ? AppTheme.success : AppTheme.destructive,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AgentDepositScreen(user: widget.user, phone: widget.phone)),
                        ).then((_) => _load()),
                        icon: const Icon(Icons.account_balance_wallet_rounded, size: 22),
                        label: const Text('Dépôt wallet (client vous donne du cash)'),
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AgentDepositEpargneScreen(user: widget.user, phone: widget.phone)),
                        ).then((_) => _load()),
                        icon: const Icon(Icons.savings_rounded, size: 22),
                        label: const Text('Dépôt épargne'),
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: AppTheme.primaryForeground, padding: const EdgeInsets.symmetric(vertical: 14)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final String? sub;
  final Color? valueColor;

  const _InfoCard({required this.label, required this.value, this.sub, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppTheme.cardDarkElevated),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: valueColor ?? AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 18)),
          if (sub != null) Text(sub!, style: TextStyle(color: Colors.white54, fontSize: 11)),
        ],
      ),
    );
  }
}
