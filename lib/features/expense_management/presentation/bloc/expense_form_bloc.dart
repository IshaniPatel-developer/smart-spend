import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../receipt_scanner/presentation/bloc/receipt_bloc.dart';
import '../../../receipt_scanner/presentation/bloc/receipt_event.dart';
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
  }) : _addExpense = addExpense,
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

  void _onInitializeForm(
    InitializeFormEvent event,
    Emitter<ExpenseFormState> emit,
  ) {
    final exp = event.expense;
    if (exp != null) {
      emit(
        ExpenseFormState(
          merchantName: exp.merchantName,
          amount: exp.amount,
          category: exp.category,
          date: exp.date,
          notes: exp.notes ?? '',
          imagePath: exp.imagePath,
          autofillSessionId:
              'edit_${exp.id}_${DateTime.now().millisecondsSinceEpoch}',
        ),
      );
    } else {
      emit(
        ExpenseFormState.initial(initialDate: DateTime.now()).copyWith(
          imagePath: event.initialImagePath,
          autofillSessionId: 'add_${DateTime.now().millisecondsSinceEpoch}',
        ),
      );
    }
  }

  void _onUpdateMerchant(
    UpdateMerchantEvent event,
    Emitter<ExpenseFormState> emit,
  ) {
    emit(state.copyWith(merchantName: event.merchantName));
  }

  void _onUpdateAmount(
    UpdateAmountEvent event,
    Emitter<ExpenseFormState> emit,
  ) {
    emit(state.copyWith(amount: event.amount));
  }

  void _onUpdateCategory(
    UpdateCategoryEvent event,
    Emitter<ExpenseFormState> emit,
  ) {
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

  void _onAutofillFromReceipt(
    AutofillFromReceiptEvent event,
    Emitter<ExpenseFormState> emit,
  ) {
    emit(
      state.copyWith(
        merchantName: event.result.merchantName,
        amount: event.result.amount,
        category: event.result.category,
        date: event.result.date,
        autofillSessionId: 'autofill_${DateTime.now().millisecondsSinceEpoch}',
      ),
    );
  }

  Future<void> _onSubmitForm(
    SubmitFormEvent event,
    Emitter<ExpenseFormState> emit,
  ) async {
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

  // UI helpers inside ExpenseFormBloc
  Future<void> selectDate(BuildContext context, DateTime currentDate) async {
    final now = DateTime.now();
    final initial = currentDate.isAfter(now) ? now : currentDate;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primaryAccent,
              onPrimary: Colors.white,
              surface: AppTheme.obsidianCard,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != currentDate) {
      add(UpdateDateEvent(picked));
    }
  }

  static final _picker = ImagePicker();

  Future<void> pickImage(BuildContext context, ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (pickedFile != null && context.mounted) {
        add(UpdateImageEvent(pickedFile.path));
        context.read<ReceiptBloc>().add(ScanReceiptEvent(pickedFile.path));
      }
    } catch (e) {
      showErrorSnackBar(context, '${AppStrings.failedToPickImage}$e');
    }
  }

  void showImagePickerSourceSelector(BuildContext context) {
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
                AppStrings.scannerSheetTitle,
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
                    label: AppStrings.cameraLabel,
                    color: AppTheme.cyanAccent,
                    source: ImageSource.camera,
                  ),
                  _actionColumnButton(
                    context: modalContext,
                    outerContext: context,
                    icon: Icons.photo_library,
                    label: AppStrings.galleryLabel,
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
        pickImage(outerContext, source);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppTheme.glassCardFill,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderLight),
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.dangerAccent),
    );
  }
}
