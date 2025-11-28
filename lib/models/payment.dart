enum Category {
  food,
  transport,
  shopping,
  entertainment,
  other,
}

class Payment {
  final String id;
  final double amount;
  final Category category;
  final String note;
  final DateTime date;
  final bool isIncome;
  final bool isSaving;

  Payment({
    required this.id,
    required this.amount,
    required this.category,
    required this.note,
    required this.date,
    required this.isIncome,
    required this.isSaving,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category.name, // store enum as string
      'note': note,
      'date': date.toIso8601String(),
      'isIncome': isIncome ? 1 : 0,
      'isSaving': isSaving ? 1 : 0,
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'],
      amount: (map['amount'] as num).toDouble(),
      category: Category.values.firstWhere((e) => e.name == map['category']),
      note: map['note'] ?? '',
      date: DateTime.parse(map['date']),
      isIncome: map['isIncome'] == 1,
      isSaving: map['isSaving'] == 1,
    );
  }
}
