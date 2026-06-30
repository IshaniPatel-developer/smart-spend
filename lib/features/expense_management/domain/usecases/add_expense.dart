import '../entities/expense.dart';
import '../repository/expense_repository.dart';

class AddExpense {
  final ExpenseRepository repository;

  AddExpense(this.repository);

  Future<void> call(Expense expense) async {
    return await repository.addExpense(expense);
  }
}
