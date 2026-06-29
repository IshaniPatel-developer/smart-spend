import '../entities/expense.dart';
import '../repository/expense_repository.dart';

class UpdateExpense {
  final ExpenseRepository repository;

  UpdateExpense(this.repository);

  Future<int> call(Expense expense) async {
    return await repository.updateExpense(expense);
  }
}
