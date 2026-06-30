import '../entities/expense.dart';
import '../repository/expense_repository.dart';

class GetExpenses {
  final ExpenseRepository repository;

  GetExpenses(this.repository);

  Future<List<Expense>> call() async {
    return await repository.getExpenses();
  }
}
