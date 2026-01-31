/// Statut d'une demande de crédit.
enum CreditRequestStatus { pending, approved, rejected }

/// Statut d'un crédit actif.
enum CreditStatus { active, late, closed }

/// Demande de crédit (PENDING / APPROVED / REJECTED).
class CreditRequest {
  final String id;
  final double amount;
  final int durationMonths;
  final String? motif;
  final CreditRequestStatus status;
  final String createdAt;
  /// Raisons du refus ou ce qui manquait pour accord (REJECTED).
  final List<String>? missingReasons;

  const CreditRequest({
    required this.id,
    required this.amount,
    required this.durationMonths,
    this.motif,
    required this.status,
    required this.createdAt,
    this.missingReasons,
  });
}

/// Crédit actif ou clôturé (ACTIVE / LATE / CLOSED).
class Credit {
  final String id;
  final double principal;
  final double remainingDue;
  final String nextDueDate;
  final CreditStatus status;
  final int durationMonths;
  final double monthlyPayment;

  const Credit({
    required this.id,
    required this.principal,
    required this.remainingDue,
    required this.nextDueDate,
    required this.status,
    required this.durationMonths,
    required this.monthlyPayment,
  });
}
