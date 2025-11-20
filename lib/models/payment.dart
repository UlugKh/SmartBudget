class Payment {
  final String id;
  final double amount;
  final String category;
  final String note;
  final DateTime date;
  final bool isIncome;

  Payment({
    required this.id,
    required this.amount,
    required this.category,
    required this.note,
    required this.date,
    required this.isIncome,
  });
}
