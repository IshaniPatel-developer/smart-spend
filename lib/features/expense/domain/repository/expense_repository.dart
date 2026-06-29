import '../entities/expense.dart';
import '../entities/receipt_scan_result.dart';
import '../entities/spending_insights.dart';

abstract class ExpenseRepository {
  Future<List<Expense>> getExpenses();
  Future<int> addExpense(Expense expense);
  Future<int> updateExpense(Expense expense);
  Future<int> deleteExpense(int id);
  Future<ReceiptScanResult> scanReceipt(String imagePath);
  Future<SpendingInsights> getSpendingInsights(List<Expense> expenses);
}
