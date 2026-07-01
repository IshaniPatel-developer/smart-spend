import '../../domain/entities/expense.dart';
import '../../domain/repository/expense_repository.dart';
import '../datasource/expense_local_datasource.dart';
import '../models/expense_model.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDataSource _localDataSource;

  ExpenseRepositoryImpl({
    required ExpenseLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  @override
  Future<List<Expense>> getExpenses() async {
    return await _localDataSource.getExpenses();
  }

  @override
  Future<void> addExpense(Expense expense) async {
    final model = ExpenseModel.fromEntity(expense);
    await _localDataSource.addExpense(model);
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    final model = ExpenseModel.fromEntity(expense);
    await _localDataSource.updateExpense(model);
  }

  @override
  Future<void> deleteExpense(int id) async {
    await _localDataSource.deleteExpense(id);
  }
}
