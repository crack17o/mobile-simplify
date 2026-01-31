import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_simplify/models/user.dart';
import 'package:mobile_simplify/theme/app_theme.dart';
import 'package:screenshot/screenshot.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

/// Retrait : client initie → montant + PIN → code + expiration.
/// Le client peut télécharger le code en image et le présenter à l'agent.
class WithdrawScreen extends StatefulWidget {
  final AppUser user;

  const WithdrawScreen({super.key, required this.user});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final _amountController = TextEditingController();
  final _pinController = TextEditingController();
  final _screenshotController = ScreenshotController();
  bool _loading = false;
  bool _saving = false;
  String? _code;
  String? _expiration;
  String? _amount;

  @override
  void dispose() {
    _amountController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_amountController.text.trim().isEmpty || _pinController.text.trim().length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Montant et PIN requis')),
      );
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() {
      _loading = false;
      _amount = _amountController.text.trim();
      _code = 'WDR${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';
      _expiration = 'Valide 8h';
    });
  }

  Future<void> _saveAsImage() async {
    if (_code == null) return;
    setState(() => _saving = true);
    try {
      final image = await _screenshotController.capture(pixelRatio: 2.0);
      if (image != null && mounted) {
        await ImageGallerySaver.saveImage(image, name: 'retrait_$_code');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Code sauvegardé dans la galerie'), backgroundColor: AppTheme.success),
          );
        }
      }
    } on PlatformException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.message ?? "Permission refusée"}'), backgroundColor: AppTheme.destructive),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: AppTheme.destructive),
        );
      }
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_code != null) {
      return Scaffold(
        backgroundColor: AppTheme.surfaceDark,
        appBar: AppBar(
          title: const Text('Code de retrait'),
          backgroundColor: AppTheme.sidebarBackground,
          foregroundColor: AppTheme.sidebarForeground,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Screenshot(
                controller: _screenshotController,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.cardDark,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    border: Border.all(color: AppTheme.primary.withOpacity(0.5), width: 2),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/logo-light.png',
                        height: 48,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(Icons.account_balance_wallet_rounded, size: 48, color: AppTheme.primary),
                      ),
                      const SizedBox(height: 16),
                      Text('Code retrait', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70)),
                      const SizedBox(height: 8),
                      Text(
                        _code!,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary,
                              letterSpacing: 2,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Text('Montant: $_amount CDF', style: const TextStyle(color: AppTheme.sidebarForeground, fontWeight: FontWeight.w600)),
                      Text(_expiration!, style: TextStyle(color: Colors.white54, fontSize: 13)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Donnez ce code à un agent Simplify. Il le saisira pour valider le retrait et vous remettra l\'argent en main.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white54),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _saveAsImage,
                  icon: _saving ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryForeground)) : const Icon(Icons.download_rounded, size: 22),
                  label: Text(_saving ? 'Enregistrement...' : 'Télécharger en image'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: AppTheme.primaryForeground),
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
        title: const Text('Générer un code retrait'),
        backgroundColor: AppTheme.sidebarBackground,
        foregroundColor: AppTheme.sidebarForeground,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppTheme.sidebarForeground),
            decoration: InputDecoration(
              labelText: 'Montant (CDF)',
              hintText: '0',
              labelStyle: TextStyle(color: Colors.white70),
              hintStyle: TextStyle(color: Colors.white38),
              filled: true,
              fillColor: AppTheme.cardDark,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSmall), borderSide: BorderSide(color: AppTheme.cardDarkElevated)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSmall), borderSide: BorderSide(color: AppTheme.cardDarkElevated)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSmall), borderSide: const BorderSide(color: AppTheme.primary)),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _pinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppTheme.sidebarForeground),
            decoration: InputDecoration(
              labelText: 'PIN',
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
              onPressed: _loading ? null : _submit,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: AppTheme.primaryForeground),
              child: _loading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryForeground),
                    )
                  : const Text('Générer le code'),
            ),
          ),
        ],
      ),
    );
  }
}
