/// Opération dépôt effectuée par l'agent (client donne cash → crédit wallet).
class AgentDepositOperation {
  final String id;
  final String phone;
  final String amount;
  final String? reference;
  final String date;

  const AgentDepositOperation({
    required this.id,
    required this.phone,
    required this.amount,
    this.reference,
    required this.date,
  });
}
