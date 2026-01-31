import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_simplify/core/savings_service.dart';

/// Score (0-100) et éligibilité crédit (mock). Calcul simplifié selon dépôts, épargne, historique.
class ScoreService {
  static const _keyScore = 'simplify_score';
  static const _keyDepositCount = 'simplify_deposit_count';
  static const _keyWeeklyDeposits = 'simplify_weekly_deposits';
  static const _keyLastResetWeek = 'simplify_last_reset_week';

  final _savings = SavingsService();

  Future<int> getScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyScore) ?? 45; // mock initial
  }

  Future<void> recalculateScore() async {
    final savingsBalance = await _savings.getBalanceCdf();
    final savingsEnabled = await _savings.isEnabled();
    final depositCount = await _getDepositCount();
    final weeklyDeposits = await _getWeeklyDeposits();

    // Scoring simplifié (mock)
    var score = 30;
    if (savingsEnabled && savingsBalance >= 5000) score += 20;
    if (savingsBalance >= 20000) score += 15;
    if (depositCount >= 3) score += 15;
    if (weeklyDeposits >= 3) score += 20;
    if (score > 100) score = 100;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyScore, score);
  }

  Future<int> _getDepositCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyDepositCount) ?? 0;
  }

  Future<int> _getWeeklyDeposits() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final weekKey = now.difference(DateTime(now.year, 1, 1)).inDays ~/ 7;
    final lastWeek = prefs.getInt(_keyLastResetWeek);
    if (lastWeek != weekKey) {
      await prefs.setInt(_keyWeeklyDeposits, 0);
      await prefs.setInt(_keyLastResetWeek, weekKey);
    }
    return prefs.getInt(_keyWeeklyDeposits) ?? 0;
  }

  Future<void> incrementDeposit() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_keyDepositCount) ?? 0;
    await prefs.setInt(_keyDepositCount, count + 1);
    final now = DateTime.now();
    final weekKey = now.difference(DateTime(now.year, 1, 1)).inDays ~/ 7;
    final lastWeek = prefs.getInt(_keyLastResetWeek);
    int weekly = prefs.getInt(_keyWeeklyDeposits) ?? 0;
    if (lastWeek != weekKey) {
      weekly = 0;
      await prefs.setInt(_keyLastResetWeek, weekKey);
    }
    await prefs.setInt(_keyWeeklyDeposits, weekly + 1);
    await recalculateScore();
  }

  Future<bool> isEligibleForCredit() async {
    final score = await getScore();
    return score >= 50;
  }

  Future<int> getPlafondCdf() async {
    final eligible = await isEligibleForCredit();
    if (!eligible) return 0;
    final score = await getScore();
    if (score >= 80) return 1000000;
    if (score >= 70) return 500000;
    if (score >= 60) return 300000;
    return 150000;
  }

  /// Liste des éléments manquants pour devenir éligible au crédit (coaching).
  Future<List<String>> getMissingReasonsForEligibility() async {
    final reasons = <String>[];
    final savingsBalance = await _savings.getBalanceCdf();
    final savingsEnabled = await _savings.isEnabled();
    final depositCount = await _getDepositCount();
    final weeklyDeposits = await _getWeeklyDeposits();

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

