import '../entities/expense.dart';
import '../entities/spending_insights.dart';
import '../repository/expense_repository.dart';

class GenerateInsights {
  final ExpenseRepository repository;

  GenerateInsights(this.repository);

  Future<SpendingInsights> call(List<Expense> expenses) async {
    return await repository.getSpendingInsights(expenses);
  }
}
