class Expense {
  final int? id;
  final String merchantName;
  final double amount;
  final DateTime date;
  final String category;
  final String? notes;
  final String? imagePath;

  const Expense({
    this.id,
    required this.merchantName,
    required this.amount,
    required this.date,
    required this.category,
    this.notes,
    this.imagePath,
  });

  Expense copyWith({
    int? id,
    String? merchantName,
    double? amount,
    DateTime? date,
    String? category,
    String? notes,
    String? imagePath,
  }) {
    return Expense(
      id: id ?? this.id,
      merchantName: merchantName ?? this.merchantName,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
