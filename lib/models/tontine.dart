/// Statut d'une tontine.
enum TontineStatus { active, closed }

/// Statut d'une cotisation.
enum CotisationStatus { pending, success, failed }

/// Fréquence de cotisation.
enum TontineFrequence { jour, semaine, mois }

/// Tontine : groupe, montant, prochain tour.
class Tontine {
  final String id;
  final String name;
  final double cotisationAmount;
  final TontineFrequence frequence;
  final TontineStatus status;
  final String? nextRoundDate;
  final String? nextBeneficiary;
  final List<String> memberNames;

  const Tontine({
    required this.id,
    required this.name,
    required this.cotisationAmount,
    required this.frequence,
    required this.status,
    this.nextRoundDate,
    this.nextBeneficiary,
    this.memberNames = const [],
  });

  String get frequenceLabel {
    switch (frequence) {
      case TontineFrequence.jour:
        return 'Quotidien';
      case TontineFrequence.semaine:
        return 'Hebdomadaire';
      case TontineFrequence.mois:
        return 'Mensuel';
    }
  }
}
