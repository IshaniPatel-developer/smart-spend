import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_expenses.dart';
import '../../domain/usecases/add_expense.dart';
import '../../domain/usecases/update_expense.dart';
import '../../domain/usecases/delete_expense.dart';
import 'expense_event.dart';
import 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final GetExpenses _getExpenses;
  final AddExpense _addExpense;
  final UpdateExpense _updateExpense;
  final DeleteExpense _deleteExpense;

  ExpenseBloc({
    required GetExpenses getExpenses,
    required AddExpense addExpense,
    required UpdateExpense updateExpense,
    required DeleteExpense deleteExpense,
  })  : _getExpenses = getExpenses,
        _addExpense = addExpense,
        _updateExpense = updateExpense,
        _deleteExpense = deleteExpense,
        super(ExpenseInitialState()) {
    on<LoadExpensesEvent>(_onLoadExpenses);
    on<AddExpenseEvent>(_onAddExpense);
    on<UpdateExpenseEvent>(_onUpdateExpense);
    on<DeleteExpenseEvent>(_onDeleteExpense);
  }

  Future<void> _onLoadExpenses(
    LoadExpensesEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoadingState());
    try {
      final expenses = await _getExpenses();
      emit(ExpenseLoadedState(expenses));
    } catch (e) {
      emit(ExpenseErrorState(e.toString()));
    }
  }

  Future<void> _onAddExpense(
    AddExpenseEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoadingState());
    try {
      await _addExpense(event.expense);
      final expenses = await _getExpenses();
      emit(ExpenseLoadedState(expenses));
    } catch (e) {
      emit(ExpenseErrorState(e.toString()));
    }
  }

  Future<void> _onUpdateExpense(
    UpdateExpenseEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoadingState());
    try {
      await _updateExpense(event.expense);
      final expenses = await _getExpenses();
      emit(ExpenseLoadedState(expenses));
    } catch (e) {
      emit(ExpenseErrorState(e.toString()));
    }
  }

  Future<void> _onDeleteExpense(
    DeleteExpenseEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoadingState());
    try {
      await _deleteExpense(event.id);
      final expenses = await _getExpenses();
      emit(ExpenseLoadedState(expenses));
    } catch (e) {
      emit(ExpenseErrorState(e.toString()));
    }
  }
}
