import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/di/service_locator.dart' as di;
import '../../domain/entities/expense.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_event.dart';
import '../bloc/expense_form_bloc.dart';
import '../bloc/expense_form_event.dart';
import '../bloc/expense_form_state.dart';
import '../../../receipt_scanner/presentation/bloc/receipt_bloc.dart';
import '../../../receipt_scanner/presentation/bloc/receipt_state.dart';
import '../widgets/glass_card.dart';

class AddEditExpenseScreen extends StatelessWidget {
  final Expense? expense;
  final String? initialImagePath;

  const AddEditExpenseScreen({
    super.key,
    this.expense,
    this.initialImagePath,
  });

  static final _formKey = GlobalKey<FormState>();
  static const List<String> _categories = [
    'Food',
    'Shopping',
    'Travel',
    'Utilities',
    'Entertainment',
    'Others',
  ];

  @override
  Widget build(BuildContext context) {
    final isEditing = expense != null;

    return BlocProvider<ExpenseFormBloc>(
      create: (context) => di.sl<ExpenseFormBloc>()
        ..add(InitializeFormEvent(expense: expense, initialImagePath: initialImagePath)),
      child: Builder(
        builder: (context) {
          return BlocListener<ReceiptBloc, ReceiptState>(
            listener: (context, receiptState) {
              if (receiptState is ReceiptScannedState) {
                context.read<ExpenseFormBloc>().add(AutofillFromReceiptEvent(receiptState.result));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(AppStrings.formAutofilledMessage),
                    backgroundColor: AppTheme.secondaryAccent,
                  ),
                );
              } else if (receiptState is ReceiptScanErrorState) {
                context.read<ExpenseFormBloc>().showErrorSnackBar(
                  context,
                  '${AppStrings.scanFailedFallbackMessage}${receiptState.message}${AppStrings.scanFailedSuffix}',
                );
              }
            },
            child: BlocConsumer<ExpenseFormBloc, ExpenseFormState>(
              listenWhen: (prev, curr) => prev.isSuccess != curr.isSuccess || curr.errorMessage != null,
              listener: (context, state) {
                if (state.isSuccess) {
                  context.read<ExpenseBloc>().add(LoadExpensesEvent());
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isEditing ? AppStrings.transactionUpdatedMessage : AppStrings.transactionSavedMessage),
                      backgroundColor: AppTheme.secondaryAccent,
                    ),
                  );
                } else if (state.errorMessage != null) {
                  context.read<ExpenseFormBloc>().showErrorSnackBar(context, state.errorMessage!);
                }
              },
              builder: (context, state) {
                final formattedDate = Formatters.formatDate(state.date);

                return Scaffold(
                  appBar: AppBar(
                    title: Text(isEditing ? AppStrings.editExpenseTitle : AppStrings.addExpenseTitle),
                    actions: [
                      if (!isEditing)
                        IconButton(
                          icon: const Icon(
                            Icons.document_scanner,
                            color: AppTheme.cyanAccent,
                          ),
                          onPressed: () => context.read<ExpenseFormBloc>().showImagePickerSourceSelector(context),
                        ),
                    ],
                  ),
                  body: AppTheme.radialGradientBackground(
                    child: SafeArea(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 800.0),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(20.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // AI Scanning Status Box
                                  BlocBuilder<ReceiptBloc, ReceiptState>(
                                    builder: (context, receiptState) {
                                      if (receiptState is ReceiptScanningState) {
                                        return Container(
                                          margin: const EdgeInsets.only(bottom: 20),
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryAccent.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color: AppTheme.primaryAccent.withOpacity(0.3),
                                            ),
                                          ),
                                          child: const Row(
                                            children: [
                                              SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: AppTheme.primaryAccent,
                                                ),
                                              ),
                                              SizedBox(width: 14),
                                              Expanded(
                                                child: Text(
                                                  AppStrings.aiAnalyzingReceiptMessage,
                                                  style: const TextStyle(
                                                    color: AppTheme.textPrimary,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  ),

                                  // Receipt Image Preview
                                  if (state.imagePath != null) ...[
                                    Container(
                                      height: 200,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: AppTheme.borderLight),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(19),
                                        child: Image.file(
                                          File(state.imagePath!),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                  ],

                                  // Main Fields Card
                                  GlassCard(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          AppStrings.transactionDetailsTitle,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 16),

                                        // Merchant Field
                                        TextFormField(
                                          key: ValueKey('merchant_${state.autofillSessionId}'),
                                          initialValue: state.merchantName,
                                          onChanged: (val) => context
                                              .read<ExpenseFormBloc>()
                                              .add(UpdateMerchantEvent(val)),
                                          textCapitalization: TextCapitalization.words,
                                          style: const TextStyle(color: AppTheme.textPrimary),
                                          decoration: const InputDecoration(
                                            labelText: AppStrings.merchantNameLabel,
                                            prefixIcon: Icon(
                                              Icons.storefront,
                                              color: AppTheme.textSecondary,
                                            ),
                                          ),
                                          validator: Validators.validateMerchantName,
                                        ),
                                        const SizedBox(height: 16),

                                        // Amount Field
                                        TextFormField(
                                          key: ValueKey('amount_${state.autofillSessionId}'),
                                          initialValue: state.amount != null ? state.amount.toString() : '',
                                          onChanged: (val) => context
                                              .read<ExpenseFormBloc>()
                                              .add(UpdateAmountEvent(double.tryParse(val))),
                                          keyboardType: const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                          style: const TextStyle(color: AppTheme.textPrimary),
                                          decoration: const InputDecoration(
                                            labelText: AppStrings.amountLabel,
                                            prefixIcon: Icon(
                                              Icons.currency_rupee,
                                              color: AppTheme.textSecondary,
                                            ),
                                          ),
                                          validator: Validators.validateAmount,
                                        ),
                                        const SizedBox(height: 16),

                                        // Date Field
                                        InkWell(
                                          onTap: () => context.read<ExpenseFormBloc>().selectDate(context, state.date),
                                          borderRadius: BorderRadius.circular(16),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 18,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppTheme.glassCardFill,
                                              borderRadius: BorderRadius.circular(16),
                                              border: Border.all(
                                                color: AppTheme.borderLight,
                                                width: 1.5,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.calendar_today,
                                                  color: AppTheme.textSecondary,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  formattedDate,
                                                  style: const TextStyle(
                                                    color: AppTheme.textPrimary,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                const Spacer(),
                                                const Icon(
                                                  Icons.arrow_drop_down,
                                                  color: AppTheme.textSecondary,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Categories Selection
                                  const Text(
                                    AppStrings.categorySelectionTitle,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    height: 48,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _categories.length,
                                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                                      itemBuilder: (context, index) {
                                        final cat = _categories[index];
                                        final isSelected = state.category == cat;

                                        return ChoiceChip(
                                          label: Text(cat),
                                          selected: isSelected,
                                          onSelected: (selected) {
                                            if (selected) {
                                              context
                                                  .read<ExpenseFormBloc>()
                                                  .add(UpdateCategoryEvent(cat));
                                            }
                                          },
                                          selectedColor: AppTheme.primaryAccent,
                                          backgroundColor: AppTheme.glassCardFill,
                                          labelStyle: TextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                : AppTheme.textSecondary,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            side: BorderSide(
                                              color: isSelected
                                                  ? AppTheme.primaryAccent
                                                  : AppTheme.borderLight,
                                              width: 1.5,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 20),

                                  // Optional Notes Card
                                  GlassCard(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        TextFormField(
                                          key: ValueKey('notes_${state.autofillSessionId}'),
                                          initialValue: state.notes,
                                          onChanged: (val) => context
                                              .read<ExpenseFormBloc>()
                                              .add(UpdateNotesEvent(val)),
                                          maxLines: 2,
                                          style: const TextStyle(color: AppTheme.textPrimary),
                                          decoration: const InputDecoration(
                                            labelText: AppStrings.notesOptionalLabel,
                                            prefixIcon: Icon(
                                              Icons.notes,
                                              color: AppTheme.textSecondary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 30),

                                  // Save Button
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: state.isSubmitting
                                          ? null
                                          : () {
                                              if (_formKey.currentState!.validate()) {
                                                context.read<ExpenseFormBloc>().add(
                                                      SubmitFormEvent(originalExpense: expense),
                                                    );
                                              }
                                            },
                                      icon: state.isSubmitting
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Icon(Icons.check),
                                      label: Text(
                                        state.isSubmitting
                                            ? AppStrings.savingLabel
                                            : (isEditing ? AppStrings.updateTransactionLabel : AppStrings.saveTransactionLabel),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
