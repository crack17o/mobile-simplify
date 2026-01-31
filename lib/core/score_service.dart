import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_simplify/core/savings_service.dart';

/// Score (0-100) et éligibilité crédit (mock). Calcul simplifié selon dépôts, épargne, historique.
class ScoreService {
  static const _keyScorePrefix = 'simplify_score_';
  static const _keyDepositPrefix = 'simplify_deposit_count_';
  static const _keyWeeklyPrefix = 'simplify_weekly_deposits_';
  static const _keyLastResetPrefix = 'simplify_last_reset_week_';

  final _savings = SavingsService();

  String _norm(String msisdn) {
    if (msisdn.isEmpty) return '';
    var s = msisdn.replaceAll(RegExp(r'\D'), '');
    if (s.length == 9 && !s.startsWith('243')) s = '243$s';
    return s;
  }

  Future<int> getScore(String msisdn) async {
    msisdn = _norm(msisdn);
    if (msisdn.isEmpty) return 45;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_keyScorePrefix$msisdn') ?? 45;
  }

  Future<void> recalculateScore(String msisdn) async {
    msisdn = _norm(msisdn);
    if (msisdn.isEmpty) return;
    final savingsBalance = await _savings.getBalanceCdf(msisdn);
    final savingsEnabled = await _savings.isEnabled(msisdn);
    final depositCount = await _getDepositCount(msisdn);
    final weeklyDeposits = await _getWeeklyDeposits(msisdn);

    var score = 30;
    if (savingsEnabled && savingsBalance >= 5000) score += 20;
    if (savingsBalance >= 20000) score += 15;
    if (depositCount >= 3) score += 15;
    if (weeklyDeposits >= 3) score += 20;
    if (score > 100) score = 100;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_keyScorePrefix$msisdn', score);
  }

  Future<int> _getDepositCount(String msisdn) async {
    if (msisdn.isEmpty) return 0;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_keyDepositPrefix$msisdn') ?? 0;
  }

  Future<int> _getWeeklyDeposits(String msisdn) async {
    if (msisdn.isEmpty) return 0;
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final weekKey = now.difference(DateTime(now.year, 1, 1)).inDays ~/ 7;
    final lastWeek = prefs.getInt('$_keyLastResetPrefix$msisdn');
    if (lastWeek != weekKey) {
      await prefs.setInt('$_keyWeeklyPrefix$msisdn', 0);
      await prefs.setInt('$_keyLastResetPrefix$msisdn', weekKey);
    }
    return prefs.getInt('$_keyWeeklyPrefix$msisdn') ?? 0;
  }

  Future<void> incrementDeposit(String msisdn) async {
    msisdn = _norm(msisdn);
    if (msisdn.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt('$_keyDepositPrefix$msisdn') ?? 0;
    await prefs.setInt('$_keyDepositPrefix$msisdn', count + 1);
    final now = DateTime.now();
    final weekKey = now.difference(DateTime(now.year, 1, 1)).inDays ~/ 7;
    final lastWeek = prefs.getInt('$_keyLastResetPrefix$msisdn');
    int weekly = prefs.getInt('$_keyWeeklyPrefix$msisdn') ?? 0;
    if (lastWeek != weekKey) {
      weekly = 0;
      await prefs.setInt('$_keyLastResetPrefix$msisdn', weekKey);
    }
    await prefs.setInt('$_keyWeeklyPrefix$msisdn', weekly + 1);
    await recalculateScore(msisdn);
  }

  Future<bool> isEligibleForCredit(String msisdn) async {
    final score = await getScore(msisdn);
    return score >= 50;
  }

  Future<int> getPlafondCdf(String msisdn) async {
    final eligible = await isEligibleForCredit(msisdn);
    if (!eligible) return 0;
    final score = await getScore(msisdn);
    if (score >= 80) return 1000000;
    if (score >= 70) return 500000;
    if (score >= 60) return 300000;
    return 150000;
  }

  /// Liste des éléments manquants pour devenir éligible au crédit (coaching).
  Future<List<String>> getMissingReasonsForEligibility(String msisdn) async {
    msisdn = _norm(msisdn);
    final reasons = <String>[];
    final savingsBalance = await _savings.getBalanceCdf(msisdn);
    final savingsEnabled = await _savings.isEnabled(msisdn);
    final depositCount = await _getDepositCount(msisdn);
    final weeklyDeposits = await _getWeeklyDeposits(msisdn);

    if (!savingsEnabled || savingsBalance < 5000) {
      reasons.add('Garde au moins 5 000 CDF en épargne');
    }
    if (savingsBalance < 20000) {
      reasons.add('Atteins 20 000 CDF en épargne pour améliorer ton score');
    }
    if (depositCount < 3) {
      reasons.add('Fais au moins 3 dépôts (historique)');
    }
    if (weeklyDeposits < 3) {
      reasons.add('Fais 3 dépôts cette semaine');
    }
    return reasons;
  }
}

