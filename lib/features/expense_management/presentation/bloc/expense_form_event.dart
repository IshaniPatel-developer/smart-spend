import '../../domain/entities/expense.dart';
import '../../../receipt_scanner/domain/entities/receipt_scan_result.dart';

abstract class ExpenseFormEvent {}

class InitializeFormEvent extends ExpenseFormEvent {
  final Expense? expense;
  InitializeFormEvent({this.expense});
}

class UpdateMerchantEvent extends ExpenseFormEvent {
  final String merchantName;
  UpdateMerchantEvent(this.merchantName);
}

class UpdateAmountEvent extends ExpenseFormEvent {
  final double? amount;
  UpdateAmountEvent(this.amount);
}

class UpdateCategoryEvent extends ExpenseFormEvent {
  final String category;
  UpdateCategoryEvent(this.category);
}

class UpdateDateEvent extends ExpenseFormEvent {
  final DateTime date;
  UpdateDateEvent(this.date);
}

class UpdateNotesEvent extends ExpenseFormEvent {
  final String notes;
  UpdateNotesEvent(this.notes);
}

class UpdateImageEvent extends ExpenseFormEvent {
  final String? imagePath;
  UpdateImageEvent(this.imagePath);
}

class AutofillFromReceiptEvent extends ExpenseFormEvent {
  final ReceiptScanResult result;
  AutofillFromReceiptEvent(this.result);
}

class SubmitFormEvent extends ExpenseFormEvent {
  final Expense? originalExpense;
  SubmitFormEvent({this.originalExpense});
}
