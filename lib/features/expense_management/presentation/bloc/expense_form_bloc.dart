import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/expense.dart';
import '../../domain/usecases/add_expense.dart';
import '../../domain/usecases/update_expense.dart';
import 'expense_form_event.dart';
import 'expense_form_state.dart';

class ExpenseFormBloc extends Bloc<ExpenseFormEvent, ExpenseFormState> {
  final AddExpense _addExpense;
  final UpdateExpense _updateExpense;

  ExpenseFormBloc({
    required AddExpense addExpense,
    required UpdateExpense updateExpense,
  })  : _addExpense = addExpense,
        _updateExpense = updateExpense,
        super(ExpenseFormState.initial()) {
    on<InitializeFormEvent>(_onInitializeForm);
    on<UpdateMerchantEvent>(_onUpdateMerchant);
    on<UpdateAmountEvent>(_onUpdateAmount);
    on<UpdateCategoryEvent>(_onUpdateCategory);
    on<UpdateDateEvent>(_onUpdateDate);
    on<UpdateNotesEvent>(_onUpdateNotes);
    on<UpdateImageEvent>(_onUpdateImage);
    on<AutofillFromReceiptEvent>(_onAutofillFromReceipt);
    on<SubmitFormEvent>(_onSubmitForm);
  }

  void _onInitializeForm(InitializeFormEvent event, Emitter<ExpenseFormState> emit) {
    final exp = event.expense;
    if (exp != null) {
      emit(ExpenseFormState(
        merchantName: exp.merchantName,
        amount: exp.amount,
        category: exp.category,
        date: exp.date,
        notes: exp.notes ?? '',
        imagePath: exp.imagePath,
        autofillSessionId: 'edit_${exp.id}_${DateTime.now().millisecondsSinceEpoch}',
      ));
    } else {
      emit(ExpenseFormState.initial(initialDate: DateTime.now())
          .copyWith(autofillSessionId: 'add_${DateTime.now().millisecondsSinceEpoch}'));
    }
  }

  void _onUpdateMerchant(UpdateMerchantEvent event, Emitter<ExpenseFormState> emit) {
    emit(state.copyWith(merchantName: event.merchantName));
  }

  void _onUpdateAmount(UpdateAmountEvent event, Emitter<ExpenseFormState> emit) {
    emit(state.copyWith(amount: event.amount));
  }

  void _onUpdateCategory(UpdateCategoryEvent event, Emitter<ExpenseFormState> emit) {
    emit(state.copyWith(category: event.category));
  }

  void _onUpdateDate(UpdateDateEvent event, Emitter<ExpenseFormState> emit) {
    emit(state.copyWith(date: event.date));
  }

  void _onUpdateNotes(UpdateNotesEvent event, Emitter<ExpenseFormState> emit) {
    emit(state.copyWith(notes: event.notes));
  }

  void _onUpdateImage(UpdateImageEvent event, Emitter<ExpenseFormState> emit) {
    emit(state.copyWith(imagePath: event.imagePath));
  }

  void _onAutofillFromReceipt(AutofillFromReceiptEvent event, Emitter<ExpenseFormState> emit) {
    emit(state.copyWith(
      merchantName: event.result.merchantName,
      amount: event.result.amount,
      category: event.result.category,
      date: event.result.date,
      autofillSessionId: 'autofill_${DateTime.now().millisecondsSinceEpoch}',
    ));
  }

  Future<void> _onSubmitForm(SubmitFormEvent event, Emitter<ExpenseFormState> emit) async {
    if (state.merchantName.trim().isEmpty) {
      emit(state.copyWith(errorMessage: 'Please enter a merchant name'));
      return;
    }
    if (state.amount == null || state.amount! <= 0) {
      emit(state.copyWith(errorMessage: 'Please enter a valid amount'));
      return;
    }

    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    try {
      final original = event.originalExpense;
      if (original != null) {
        final updated = original.copyWith(
          merchantName: state.merchantName,
          amount: state.amount!,
          category: state.category,
          date: state.date,
          notes: state.notes,
          imagePath: state.imagePath,
        );
        await _updateExpense(updated);
      } else {
        final newExpense = Expense(
          merchantName: state.merchantName,
          amount: state.amount!,
          category: state.category,
          date: state.date,
          notes: state.notes,
          imagePath: state.imagePath,
        );
        await _addExpense(newExpense);
      }
      emit(state.copyWith(isSubmitting: false, isSuccess: true));
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, errorMessage: e.toString()));
    }
  }
}
