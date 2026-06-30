import '../../domain/entities/expense.dart';

class ExpenseModel extends Expense {
  const ExpenseModel({
    super.id,
    required super.merchantName,
    required super.amount,
    required super.date,
    required super.category,
    super.notes,
    super.imagePath,
  });

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as int?,
      merchantName: map['merchant_name'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      category: map['category'] as String,
      notes: map['notes'] as String?,
      imagePath: map['image_path'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'merchant_name': merchantName,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
      'notes': notes,
      'image_path': imagePath,
    };
  }

  factory ExpenseModel.fromEntity(Expense entity) {
    return ExpenseModel(
      id: entity.id,
      merchantName: entity.merchantName,
      amount: entity.amount,
      date: entity.date,
      category: entity.category,
      notes: entity.notes,
      imagePath: entity.imagePath,
    );
  }
}
