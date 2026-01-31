import 'package:flutter/material.dart';
import 'package:mobile_simplify/models/user.dart';
import 'package:mobile_simplify/theme/app_theme.dart';
import 'package:mobile_simplify/core/savings_service.dart';
import 'package:mobile_simplify/screens/client/epargne_operation_detail_screen.dart';

/// Historique épargne : liste des prélèvements (SUCCESS/FAILED).
class EpargneHistoriqueScreen extends StatefulWidget {
  final AppUser user;

  const EpargneHistoriqueScreen({super.key, required this.user});

  @override
  State<EpargneHistoriqueScreen> createState() => _EpargneHistoriqueScreenState();
}

class _EpargneHistoriqueScreenState extends State<EpargneHistoriqueScreen> {
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
    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      appBar: AppBar(
        title: const Text('Historique épargne'),
        backgroundColor: AppTheme.sidebarBackground,
        foregroundColor: AppTheme.sidebarForeground,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : _items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history_rounded, size: 64, color: Colors.white24),
                      const SizedBox(height: 16),
                      Text('Aucun prélèvement', style: TextStyle(color: Colors.white54, fontSize: 16)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppTheme.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _items.length,
                    itemBuilder: (context, i) {
                      final e = _items[i];
                      final status = e['status'] as String? ?? 'UNKNOWN';
                      final isSuccess = status == 'SUCCESS';
                      final amount = (e['amount'] as num?)?.toDouble() ?? 0;
                      final date = e['date'] as String? ?? '-';
                      final reason = e['reason'] as String?;
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
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
                          borderRadius: BorderRadius.circular(AppTheme.radius),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
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
                                  if (reason != null && reason.isNotEmpty) Text(reason, style: TextStyle(color: AppTheme.destructive, fontSize: 12)),
                                ],
                              ),
                            ),
                            Text(status, style: TextStyle(color: isSuccess ? AppTheme.success : AppTheme.destructive, fontWeight: FontWeight.w600, fontSize: 13)),
                          ],
                        ),
                      ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
