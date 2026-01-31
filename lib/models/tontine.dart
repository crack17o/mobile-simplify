/// Statut d'une tontine.
enum TontineStatus { active, closed }

/// Statut d'une cotisation.
enum CotisationStatus { pending, success, failed }

/// Fréquence de cotisation.
enum TontineFrequence { jour, semaine, mois }

/// Tontine : groupe, montant, prochain tour.
/// - totalMembers : nombre de membres (la tontine s'arrête quand tout le monde a touché).
/// - currentRound : tour actuel (1 à N).
/// - myPositionInOrder : position de l'user pour toucher (1 = 1er, 2 = 2e...).
/// - toursRestantsAvantMise : tours restants avant que l'user touche la mise.
/// - sommeDejaMise : montant déjà cotisé par l'user.
/// - pin : PIN à partager pour adhérer (créateur).
class Tontine {
  final String id;
  final String name;
  final double cotisationAmount;
  final TontineFrequence frequence;
  final TontineStatus status;
  final String? nextRoundDate;
  final String? nextBeneficiary;
  final List<String> memberNames;
  /// Nombre total de membres.
  final int totalMembers;
  /// Tour actuel (1 à N).
  final int currentRound;
  /// Position de l'user dans l'ordre de réception (1 = 1er à toucher).
  final int myPositionInOrder;
  /// PIN pour rejoindre (généré à la création).
  final String? pin;

  const Tontine({
    required this.id,
    required this.name,
    required this.cotisationAmount,
    required this.frequence,
    required this.status,
    this.nextRoundDate,
    this.nextBeneficiary,
    this.memberNames = const [],
    this.totalMembers = 0,
    this.currentRound = 1,
    this.myPositionInOrder = 1,
    this.pin,
  });

  /// Tours restants avant que l'user touche la mise (0 si déjà touché ou terminé).
  int get toursRestantsAvantMise {
    if (currentRound >= myPositionInOrder) return 0;
    return myPositionInOrder - currentRound;
  }

  /// Somme déjà mise par l'user (cotisations versées jusqu'ici).
  double get sommeDejaMise {
    if (currentRound <= 1) return 0;
    final roundsContributed = currentRound - 1;
    return cotisationAmount * roundsContributed;
  }

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
