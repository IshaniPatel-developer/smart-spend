import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/theme.dart';
import '../../../receipt_scanner/presentation/bloc/receipt_bloc.dart';
import '../../../receipt_scanner/presentation/bloc/receipt_event.dart';
import '../screens/add_edit_expense_screen.dart';
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

  static final _picker = ImagePicker();

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

  // UI helpers moved to BLoC as requested
  Future<void> scanReceiptFromCameraOrGallery(BuildContext context, ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (pickedFile != null && context.mounted) {
        // Clear previous state and trigger scanning on the scanning bloc
        context.read<ReceiptBloc>().add(ClearReceiptScanEvent());
        context.read<ReceiptBloc>().add(ScanReceiptEvent(pickedFile.path));
        
        // Push the add_edit screen and pass the scan action forward
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddEditExpenseScreen(
              initialImagePath: pickedFile.path,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: AppTheme.dangerAccent,
        ),
      );
    }
  }

  void showScanReceiptSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.obsidianCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AI Receipt Scanner',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _actionColumnButton(
                    context: modalContext,
                    outerContext: context,
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    color: AppTheme.cyanAccent,
                    source: ImageSource.camera,
                  ),
                  _actionColumnButton(
                    context: modalContext,
                    outerContext: context,
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    color: AppTheme.primaryAccent,
                    source: ImageSource.gallery,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionColumnButton({
    required BuildContext context,
    required BuildContext outerContext,
    required IconData icon,
    required String label,
    required Color color,
    required ImageSource source,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        scanReceiptFromCameraOrGallery(outerContext, source);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.glassCardFill,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderLight),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
