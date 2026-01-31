import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Préférence, solde, plan auto et historique épargne (mock local).
class SavingsService {
  static const _keyEnabled = 'simplify_savings_enabled';
  static const _keyBalanceCdf = 'simplify_savings_balance_cdf';
  static const _keyAutoAmount = 'simplify_savings_auto_amount';
  static const _keyAutoFreq = 'simplify_savings_auto_freq';
  static const _keyAutoNext = 'simplify_savings_auto_next';
  static const _keyAutoActive = 'simplify_savings_auto_active';
  static const _keyHistory = 'simplify_savings_history';
  static const _keyPoints = 'simplify_savings_points';
  static const _keyWithdrawCountWeek = 'simplify_withdraw_count_week';
  static const _keyWithdrawWeekKey = 'simplify_withdraw_week_key';
  static const _plancherCdf = 5000.0; // Solde plancher minimum

  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyEnabled) ?? false;
  }

  Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyEnabled, value);
  }

  Future<double> getBalanceCdf() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyBalanceCdf) ?? 0.0;
  }

  Future<void> setBalanceCdf(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyBalanceCdf, value);
  }

  Future<void> addToBalance(double amount) async {
    final b = await getBalanceCdf();
    await setBalanceCdf(b + amount);
  }

  // Plan auto-épargne
  Future<double?> getAutoAmount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyAutoAmount);
  }
  Future<String?> getAutoFreq() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAutoFreq);
  }
  Future<String?> getAutoNext() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAutoNext);
  }
  Future<bool> getAutoActive() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyAutoActive) ?? false;
  }
  Future<void> setAutoPlan({double? amount, String? freq, String? next, bool? active}) async {
    final prefs = await SharedPreferences.getInstance();
    if (amount != null) await prefs.setDouble(_keyAutoAmount, amount);
    if (freq != null) await prefs.setString(_keyAutoFreq, freq);
    if (next != null) await prefs.setString(_keyAutoNext, next);
    if (active != null) await prefs.setBool(_keyAutoActive, active);
  }

  // Historique prélèvements
  Future<List<Map<String, dynamic>>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keyHistory);
    if (json == null) return [];
    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list.map((e) => e as Map<String, dynamic>).toList();
    } catch (_) {
      return [];
    }
  }
  Future<int> getPoints() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyPoints) ?? 0;
  }

  Future<void> addPoints(int pts) async {
    final prefs = await SharedPreferences.getInstance();
    final p = prefs.getInt(_keyPoints) ?? 0;
    await prefs.setInt(_keyPoints, p + pts);
  }

  double get plancherCdf => _plancherCdf;

  Future<int> getWithdrawCountThisWeek() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final weekKey = now.difference(DateTime(now.year, 1, 1)).inDays ~/ 7;
    final last = prefs.getInt(_keyWithdrawWeekKey);
    if (last != weekKey) return 0;
    return prefs.getInt(_keyWithdrawCountWeek) ?? 0;
  }

  Future<void> incrementWithdrawCount() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final weekKey = now.difference(DateTime(now.year, 1, 1)).inDays ~/ 7;
    final last = prefs.getInt(_keyWithdrawWeekKey);
    int count = prefs.getInt(_keyWithdrawCountWeek) ?? 0;
    if (last != weekKey) {
      count = 0;
      await prefs.setInt(_keyWithdrawWeekKey, weekKey);
    }
    await prefs.setInt(_keyWithdrawCountWeek, count + 1);
  }

  Future<void> addHistoryEntry(String date, double amount, String status, [String? reason]) async {
    final list = await getHistory();
    list.insert(0, {'date': date, 'amount': amount, 'status': status, 'reason': reason});
    if (list.length > 50) list.removeRange(50, list.length);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyHistory, jsonEncode(list));
  }
}
