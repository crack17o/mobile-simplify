import 'package:flutter/material.dart';
import 'package:mobile_simplify/models/user.dart';
import 'package:mobile_simplify/theme/app_theme.dart';
import 'package:mobile_simplify/core/savings_service.dart';
import 'package:mobile_simplify/screens/client/epargne_operation_detail_screen.dart';

/// Onglet Épargne : historique des prélèvements (versements, retraits).
/// Tap → détails de l'opération.
class HistoriqueEpargneTab extends StatefulWidget {
  final AppUser user;

  const HistoriqueEpargneTab({super.key, required this.user});

  @override
  State<HistoriqueEpargneTab> createState() => _HistoriqueEpargneTabState();
}

class _HistoriqueEpargneTabState extends State<HistoriqueEpargneTab> {
  final _savings = SavingsService();
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await _savings.getHistory(widget.user.msisdn);
    if (mounted) {
      setState(() {
        _items = list;
        _loading = false;
      });
    }
  }

  static String _fmtCdf(double n) {
    final s = n.toStringAsFixed(0);
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return '${buf} CDF';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
    }
    if (_items.isEmpty) {
      return RefreshIndicator(
        onRefresh: _load,
        color: AppTheme.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.savings_rounded, size: 64, color: Colors.white24),
                  const SizedBox(height: 16),
                  Text('Aucune opération d\'épargne', style: TextStyle(color: Colors.white54, fontSize: 16)),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      color: AppTheme.primary,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Text(
                'Opérations Épargne',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final e = _items[i];
                  final status = e['status'] as String? ?? 'UNKNOWN';
                  final isSuccess = status == 'SUCCESS';
                  final amount = (e['amount'] as num?)?.toDouble() ?? 0;
                  final date = e['date'] as String? ?? '-';
                  final reason = e['reason'] as String?;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _EpargneTile(
                      amount: amount,
                      date: date,
                      status: status,
                      reason: reason,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EpargneOperationDetailScreen(
                            amount: amount,
                            date: date,
                            status: status,
                            reason: reason,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                childCount: _items.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _EpargneTile extends StatelessWidget {
  final double amount;
  final String date;
  final String status;
  final String? reason;
  final VoidCallback onTap;

  const _EpargneTile({
    required this.amount,
    required this.date,
    required this.status,
    this.reason,
    required this.onTap,
  });

  static String _fmtCdf(double n) {
    final s = n.toStringAsFixed(0);
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return '${buf} CDF';
  }

  @override
  Widget build(BuildContext context) {
    final isSuccess = status == 'SUCCESS';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardDark,
            borderRadius: BorderRadius.circular(AppTheme.radius),
            border: Border.all(color: AppTheme.cardDarkElevated),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (isSuccess ? AppTheme.success : AppTheme.destructive).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isSuccess ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  color: isSuccess ? AppTheme.success : AppTheme.destructive,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_fmtCdf(amount), style: const TextStyle(color: AppTheme.sidebarForeground, fontWeight: FontWeight.w600, fontSize: 16)),
                    Text(date, style: TextStyle(color: Colors.white54, fontSize: 13)),
                    if (reason != null && reason!.isNotEmpty) Text(reason!, style: TextStyle(color: AppTheme.destructive, fontSize: 12)),
                  ],
                ),
              ),
              Text(status, style: TextStyle(color: isSuccess ? AppTheme.success : AppTheme.destructive, fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}
