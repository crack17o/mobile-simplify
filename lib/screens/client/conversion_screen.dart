import 'package:flutter/material.dart';
import 'package:mobile_simplify/models/user.dart';
import 'package:mobile_simplify/theme/app_theme.dart';
import 'package:mobile_simplify/core/conversion_rate.dart';

/// Conversion USD ↔ CDF avec taux défini par l'admin.
class ConversionScreen extends StatefulWidget {
  final AppUser user;

  const ConversionScreen({super.key, required this.user});

  @override
  State<ConversionScreen> createState() => _ConversionScreenState();
}

class _ConversionScreenState extends State<ConversionScreen> {
  final _amountController = TextEditingController();
  bool _directionUsdToCdf = true; // true = USD → CDF
  double? _result;
  String? _error;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _convert() {
    final text = _amountController.text.trim().replaceAll(' ', '');
    if (text.isEmpty) {
      setState(() {
        _error = 'Saisissez un montant';
        _result = null;
      });
      return;
    }
    final amount = double.tryParse(text);
    if (amount == null || amount <= 0) {
      setState(() {
        _error = 'Montant invalide';
        _result = null;
      });
      return;
    }
    setState(() {
      _error = null;
      _result = _directionUsdToCdf
          ? amount * ConversionRate.usdToCdf
          : amount * ConversionRate.cdfToUsd;
    });
  }

  void _swapDirection() {
    setState(() {
      _directionUsdToCdf = !_directionUsdToCdf;
      _result = null;
      _error = null;
    });
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      hintText: '0',
      labelStyle: TextStyle(color: Colors.white70),
      hintStyle: TextStyle(color: Colors.white38),
      filled: true,
      fillColor: AppTheme.cardDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        borderSide: BorderSide(color: AppTheme.cardDarkElevated),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        borderSide: BorderSide(color: AppTheme.cardDarkElevated),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        borderSide: const BorderSide(color: AppTheme.primary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      appBar: AppBar(
        title: const Text('Conversion'),
        backgroundColor: AppTheme.sidebarBackground,
        foregroundColor: AppTheme.sidebarForeground,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(AppTheme.radius),
              border: Border.all(color: AppTheme.cardDarkElevated),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: AppTheme.primary, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Taux admin : 1 USD = ${ConversionRate.usdToCdf.toStringAsFixed(0)} CDF',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _directionUsdToCdf ? 'De USD vers CDF' : 'De CDF vers USD',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: AppTheme.sidebarForeground, fontSize: 18),
            decoration: _inputDecoration(
              _directionUsdToCdf ? 'Montant (USD)' : 'Montant (CDF)',
            ),
            onChanged: (_) => setState(() {
              _result = null;
              _error = null;
            }),
          ),
          const SizedBox(height: 16),
          Center(
            child: IconButton(
              onPressed: _swapDirection,
              icon: Icon(Icons.swap_vert_rounded, color: AppTheme.primary, size: 32),
              tooltip: 'Inverser',
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _convert,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.primaryForeground,
              ),
              icon: const Icon(Icons.compare_arrows_rounded, size: 22),
              label: const Text('Convertir'),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.destructive.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline_rounded, color: AppTheme.destructive, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_error!, style: TextStyle(color: AppTheme.destructive, fontSize: 14))),
                ],
              ),
            ),
          ],
          if (_result != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.cardDark,
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                border: Border.all(color: AppTheme.primary.withOpacity(0.5)),
              ),
              child: Column(
                children: [
                  Text(
                    'Résultat',
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _directionUsdToCdf
                        ? ConversionRate.formatCdf(_result!)
                        : ConversionRate.formatUsd(_result!),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
