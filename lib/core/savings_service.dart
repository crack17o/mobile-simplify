import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Préférence, solde, plan auto et historique épargne (mock local).
/// Stockage par téléphone (msisdn) pour supporter client + agent (dépôt agent → client).
String _norm(String? msisdn) {
  if (msisdn == null || msisdn.isEmpty) return '';
  var s = msisdn.replaceAll(RegExp(r'\D'), '');
  if (s.length == 9 && !s.startsWith('243')) s = '243$s';
  return s;
}

class SavingsService {
  static const _keyBalances = 'simplify_savings_balances';
  static const _keyEnabledMap = 'simplify_savings_enabled_map';
  static const _keyHistoryPrefix = 'simplify_savings_history_';
  static const _keyAutoPrefix = 'simplify_savings_auto_';
  static const _keyPointsPrefix = 'simplify_savings_points_';
  static const _keyWithdrawPrefix = 'simplify_withdraw_';
  static const _plancherCdf = 5000.0;

  /// Migration : anciennes clés vers nouveau format par phone.
  Future<void> _migrateIfNeeded(String msisdn) async {
    final prefs = await SharedPreferences.getInstance();
    final migrated = prefs.getBool('simplify_savings_migrated_v2');
    if (migrated == true) return;

    final oldBalance = prefs.getDouble('simplify_savings_balance_cdf');
    final oldEnabled = prefs.getBool('simplify_savings_enabled');
    final oldHistory = prefs.getString('simplify_savings_history');
    final targetMsisdn = msisdn.isNotEmpty ? msisdn : '243812345678';

    if (targetMsisdn.isNotEmpty && (oldBalance != null && oldBalance > 0 || oldEnabled == true)) {
      final balances = await _getBalancesMap();
      if (!balances.containsKey(targetMsisdn) || (balances[targetMsisdn] ?? 0) == 0) {
        balances[targetMsisdn] = oldBalance ?? 0;
        await prefs.setString(_keyBalances, jsonEncode(balances));
      }
      final enabledMap = await _getEnabledMap();
      enabledMap[targetMsisdn] = oldEnabled ?? (oldBalance != null && oldBalance > 0);
      await prefs.setString(_keyEnabledMap, jsonEncode(enabledMap));
      if (oldHistory != null) {
        try {
          final list = jsonDecode(oldHistory) as List;
          await prefs.setString('$_keyHistoryPrefix$targetMsisdn', jsonEncode(list));
        } catch (_) {}
      }
    }
    await prefs.setBool('simplify_savings_migrated_v2', true);
  }

  Future<Map<String, double>> _getBalancesMap() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keyBalances);
    if (json == null) return {};
    try {
      final m = jsonDecode(json) as Map<String, dynamic>;
      return m.map((k, v) => MapEntry(k, (v as num).toDouble()));
    } catch (_) {
      return {};
    }
  }

  Future<Map<String, bool>> _getEnabledMap() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keyEnabledMap);
    if (json == null) return {};
    try {
      final m = jsonDecode(json) as Map<String, dynamic>;
      return m.map((k, v) => MapEntry(k, v == true));
    } catch (_) {
      return {};
    }
  }

  Future<bool> isEnabled(String msisdn) async {
    msisdn = _norm(msisdn);
    if (msisdn.isEmpty) return false;
    await _migrateIfNeeded(msisdn);
    final map = await _getEnabledMap();
    final balance = await getBalanceCdf(msisdn);
    return map[msisdn] ?? (balance > 0);
  }

  Future<void> setEnabled(String msisdn, bool value) async {
    msisdn = _norm(msisdn);
    if (msisdn.isEmpty) return;
    final map = await _getEnabledMap();
    map[msisdn] = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEnabledMap, jsonEncode(map));
  }

  Future<double> getBalanceCdf(String msisdn) async {
    msisdn = _norm(msisdn);
    if (msisdn.isEmpty) return 0.0;
    await _migrateIfNeeded(msisdn);
    final map = await _getBalancesMap();
    return map[msisdn] ?? 0.0;
  }

  Future<void> setBalanceCdf(String msisdn, double value) async {
    msisdn = _norm(msisdn);
    if (msisdn.isEmpty) return;
    final map = await _getBalancesMap();
    map[msisdn] = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBalances, jsonEncode(map));
  }

  Future<void> addToBalance(String msisdn, double amount) async {
    msisdn = _norm(msisdn);
    if (msisdn.isEmpty) return;
    final b = await getBalanceCdf(msisdn);
    await setBalanceCdf(msisdn, b + amount);
    await setEnabled(msisdn, true);
  }

  // Plan auto-épargne (par msisdn)
  Future<double?> getAutoAmount(String msisdn) async {
    msisdn = _norm(msisdn);
    if (msisdn.isEmpty) return null;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('${_keyAutoPrefix}amount_$msisdn');
  }

  Future<String?> getAutoFreq(String msisdn) async {
    msisdn = _norm(msisdn);
    if (msisdn.isEmpty) return null;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('${_keyAutoPrefix}freq_$msisdn');
  }

  Future<String?> getAutoNext(String msisdn) async {
    msisdn = _norm(msisdn);
    if (msisdn.isEmpty) return null;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('${_keyAutoPrefix}next_$msisdn');
  }

  Future<bool> getAutoActive(String msisdn) async {
    msisdn = _norm(msisdn);
    if (msisdn.isEmpty) return false;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('${_keyAutoPrefix}active_$msisdn') ?? false;
  }

  Future<void> setAutoPlan(String msisdn, {double? amount, String? freq, String? next, bool? active}) async {
    msisdn = _norm(msisdn);
    if (msisdn.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    if (amount != null) await prefs.setDouble('${_keyAutoPrefix}amount_$msisdn', amount);
    if (freq != null) await prefs.setString('${_keyAutoPrefix}freq_$msisdn', freq);
    if (next != null) await prefs.setString('${_keyAutoPrefix}next_$msisdn', next);
    if (active != null) await prefs.setBool('${_keyAutoPrefix}active_$msisdn', active);
  }

  Future<List<Map<String, dynamic>>> getHistory(String msisdn) async {
    msisdn = _norm(msisdn);
    if (msisdn.isEmpty) return [];
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('$_keyHistoryPrefix$msisdn');
    if (json == null) return [];
    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list.map((e) => e as Map<String, dynamic>).toList();
    } catch (_) {
      return [];
    }
  }

  Future<int> getPoints(String msisdn) async {
    msisdn = _norm(msisdn);
    if (msisdn.isEmpty) return 0;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('${_keyPointsPrefix}$msisdn') ?? 0;
  }

  Future<void> addPoints(String msisdn, int pts) async {
    msisdn = _norm(msisdn);
    if (msisdn.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final p = prefs.getInt('${_keyPointsPrefix}$msisdn') ?? 0;
    await prefs.setInt('${_keyPointsPrefix}$msisdn', p + pts);
  }

  double get plancherCdf => _plancherCdf;

  Future<int> getWithdrawCountThisWeek(String msisdn) async {
    msisdn = _norm(msisdn);
    if (msisdn.isEmpty) return 0;
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final weekKey = now.difference(DateTime(now.year, 1, 1)).inDays ~/ 7;
    final last = prefs.getInt('${_keyWithdrawPrefix}week_$msisdn');
    if (last != weekKey) return 0;
    return prefs.getInt('${_keyWithdrawPrefix}count_$msisdn') ?? 0;
  }

  Future<void> incrementWithdrawCount(String msisdn) async {
    msisdn = _norm(msisdn);
    if (msisdn.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final weekKey = now.difference(DateTime(now.year, 1, 1)).inDays ~/ 7;
    final last = prefs.getInt('${_keyWithdrawPrefix}week_$msisdn');
    int count = prefs.getInt('${_keyWithdrawPrefix}count_$msisdn') ?? 0;
    if (last != weekKey) {
      count = 0;
      await prefs.setInt('${_keyWithdrawPrefix}week_$msisdn', weekKey);
    }
    await prefs.setInt('${_keyWithdrawPrefix}count_$msisdn', count + 1);
  }

  Future<void> addHistoryEntry(String msisdn, String date, double amount, String status, [String? reason]) async {
    msisdn = _norm(msisdn);
    if (msisdn.isEmpty) return;
    final list = await getHistory(msisdn);
    list.insert(0, {'date': date, 'amount': amount, 'status': status, 'reason': reason});
    if (list.length > 50) list.removeRange(50, list.length);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_keyHistoryPrefix$msisdn', jsonEncode(list));
  }
}
