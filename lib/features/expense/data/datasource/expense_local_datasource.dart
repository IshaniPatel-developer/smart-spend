import '../../../../core/database/database_helper.dart';
import '../models/expense_model.dart';

abstract class ExpenseLocalDataSource {
  Future<List<ExpenseModel>> getExpenses();
  Future<int> addExpense(ExpenseModel expense);
  Future<int> updateExpense(ExpenseModel expense);
  Future<int> deleteExpense(int id);
}

class ExpenseLocalDataSourceImpl implements ExpenseLocalDataSource {
  final DatabaseHelper _dbHelper;

  ExpenseLocalDataSourceImpl({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  @override
  Future<List<ExpenseModel>> getExpenses() async {
    final list = await _dbHelper.queryAllExpenses();
    return list.map((item) => ExpenseModel.fromMap(item)).toList();
  }

  @override
  Future<int> addExpense(ExpenseModel expense) async {
    return await _dbHelper.insertExpense(expense.toMap());
  }

  @override
  Future<int> updateExpense(ExpenseModel expense) async {
    return await _dbHelper.updateExpense(expense.toMap());
  }

  @override
  Future<int> deleteExpense(int id) async {
    return await _dbHelper.deleteExpense(id);
  }
}
