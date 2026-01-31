import 'package:flutter/material.dart';
import 'package:mobile_simplify/models/user.dart';
import 'package:mobile_simplify/models/transaction.dart';
import 'package:mobile_simplify/theme/app_theme.dart';
import 'package:mobile_simplify/screens/client/transaction_detail_screen.dart';

/// Onglet Wallet : historique des transactions (dépôts, retraits, P2P).
class HistoriqueWalletTab extends StatefulWidget {
  final AppUser user;

  const HistoriqueWalletTab({super.key, required this.user});

  @override
  State<HistoriqueWalletTab> createState() => _HistoriqueWalletTabState();
}

class _HistoriqueWalletTabState extends State<HistoriqueWalletTab> {
  String? _filterType;
  String? _filterStatus;
  final _transactions = _mockTransactions;

  static final _mockTransactions = [
    const Transaction(
      reference: 'TXN001234',
      type: 'Dépôt',
      status: 'SUCCESS',
      amount: '+150 000 CDF',
      date: '29/01/2024 14:32',
      channel: 'USSD',
      isCredit: true,
    ),
    const Transaction(
      reference: 'TXN001235',
      type: 'Retrait',
      status: 'SUCCESS',
      amount: '-25 000 CDF',
      date: '29/01/2024 14:28',
      channel: 'APP',
      isCredit: false,
    ),
    const Transaction(
      reference: 'TXN001236',
      type: 'Transfert P2P',
      status: 'EN_COURS',
      amount: '-50 000 CDF',
      date: '29/01/2024 14:15',
      channel: 'USSD',
      isCredit: false,
    ),
  ];

  List<Transaction> get _filtered {
    var list = _transactions;
    if (_filterType != null && _filterType!.isNotEmpty) {
      list = list.where((t) => t.type == _filterType).toList();
    }
    if (_filterStatus != null && _filterStatus!.isNotEmpty) {
      list = list.where((t) => t.status == _filterStatus).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) setState(() {});
      },
      color: AppTheme.primary,
      backgroundColor: AppTheme.cardDark,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Text(
                'Transactions Wallet',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _DarkDropdown<String>(
                      value: _filterType,
                      hint: 'Type',
                      items: const ['Dépôt', 'Retrait', 'Transfert P2P'],
                      onChanged: (v) => setState(() => _filterType = v),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DarkDropdown<String>(
                      value: _filterStatus,
                      hint: 'Statut',
                      items: const ['SUCCESS', 'EN_COURS', 'FAILED'],
                      onChanged: (v) => setState(() => _filterStatus = v),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final t = _filtered[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _TransactionTile(transaction: t),
                  );
                },
                childCount: _filtered.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _DarkDropdown<T> extends StatelessWidget {
  final T? value;
  final String hint;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final String Function(T)? itemLabel;

  const _DarkDropdown({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
    this.itemLabel,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      dropdownColor: AppTheme.cardDark,
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: AppTheme.cardDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSmall), borderSide: const BorderSide(color: AppTheme.cardDarkElevated)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSmall), borderSide: const BorderSide(color: AppTheme.cardDarkElevated)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSmall), borderSide: const BorderSide(color: AppTheme.primary)),
      ),
      style: const TextStyle(color: AppTheme.sidebarForeground, fontSize: 14),
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.primary),
      items: [
        DropdownMenuItem<T>(value: null, child: Text('Tous', style: TextStyle(color: Colors.white70))),
        ...items.map((e) => DropdownMenuItem<T>(value: e, child: Text(itemLabel != null ? itemLabel!(e) : e.toString(), style: const TextStyle(color: AppTheme.sidebarForeground)))),
      ],
      onChanged: onChanged,
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Transaction transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    final color = t.isCredit ? AppTheme.success : AppTheme.destructive;
    final amountColor = t.isCredit ? AppTheme.primary : color;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TransactionDetailScreen(transaction: t)),
        ),
        borderRadius: BorderRadius.circular(AppTheme.radius),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardDark,
            borderRadius: BorderRadius.circular(AppTheme.radius),
            border: Border.all(color: AppTheme.cardDarkElevated),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  t.isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.type,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: AppTheme.sidebarForeground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${t.reference} • ${t.date}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                t.amount,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: amountColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
