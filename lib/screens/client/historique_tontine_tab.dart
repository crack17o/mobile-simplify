import 'package:flutter/material.dart';
import 'package:mobile_simplify/models/user.dart';
import 'package:mobile_simplify/theme/app_theme.dart';
import 'package:mobile_simplify/screens/client/tontine_detail_screen.dart';
import 'package:mobile_simplify/models/tontine.dart';

/// Onglet Tontine : historique des cotisations (liste des opérations tontine).
/// Tap → détails de l'opération.
class HistoriqueTontineTab extends StatefulWidget {
  final AppUser user;

  const HistoriqueTontineTab({super.key, required this.user});

  @override
  State<HistoriqueTontineTab> createState() => _HistoriqueTontineTabState();
}

class _HistoriqueTontineTabState extends State<HistoriqueTontineTab> {
  static final _mockCotisations = [
    {'id': 'TNT001', 'name': 'Mutuelles Lingwala', 'date': '28/01/2025', 'amount': 10000, 'status': 'SUCCESS', 'type': 'Cotisation'},
    {'id': 'TNT001', 'name': 'Mutuelles Lingwala', 'date': '21/01/2025', 'amount': 10000, 'status': 'SUCCESS', 'type': 'Cotisation'},
    {'id': 'TNT002', 'name': 'Solidarité Commerce', 'date': '25/01/2025', 'amount': 25000, 'status': 'SUCCESS', 'type': 'Cotisation'},
  ];

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 400));
        if (mounted) setState(() {});
      },
      color: AppTheme.primary,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Text(
                'Opérations Tontine',
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
                  final c = _mockCotisations[i];
                  final name = c['name'] as String;
                  final date = c['date'] as String;
                  final amount = (c['amount'] as num).toDouble();
                  final status = c['status'] as String;
                  final type = c['type'] as String;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _TontineTile(
                      name: name,
                      date: date,
                      amount: amount,
                      status: status,
                      type: type,
                      onTap: () => _showDetail(context, c),
                    ),
                  );
                },
                childCount: _mockCotisations.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context, Map<String, dynamic> c) {
    final amount = (c['amount'] as num).toDouble();
    final tontine = Tontine(
      id: c['id'] as String,
      name: c['name'] as String,
      cotisationAmount: amount,
      frequence: TontineFrequence.semaine,
      status: TontineStatus.active,
      nextRoundDate: '04/02/2025',
      memberNames: ['Vous', 'Marie K.', 'Jean B.'],
      totalMembers: 3,
      currentRound: 2,
      myPositionInOrder: 3,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TontineDetailScreen(user: widget.user, tontine: tontine),
      ),
    );
  }
}

class _TontineTile extends StatelessWidget {
  final String name;
  final String date;
  final double amount;
  final String status;
  final String type;
  final VoidCallback onTap;

  const _TontineTile({
    required this.name,
    required this.date,
    required this.amount,
    required this.status,
    required this.type,
    required this.onTap,
  });

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
                  color: AppTheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.groups_rounded, color: AppTheme.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(color: AppTheme.sidebarForeground, fontWeight: FontWeight.w600, fontSize: 16)),
                    Text('$type • $date', style: TextStyle(color: Colors.white54, fontSize: 13)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${_fmt(amount)} CDF', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primary, fontSize: 15)),
                  Text(status, style: TextStyle(color: isSuccess ? AppTheme.success : AppTheme.destructive, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
