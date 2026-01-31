class Transaction {
  final String reference;
  final String type;
  final String status;
  final String amount;
  final String date;
  final String channel;
  final bool isCredit;

  const Transaction({
    required this.reference,
    required this.type,
    required this.status,
    required this.amount,
    required this.date,
    required this.channel,
    required this.isCredit,
  });
}
