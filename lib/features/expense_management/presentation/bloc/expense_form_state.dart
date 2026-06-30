class ExpenseFormState {
  final String merchantName;
  final double? amount;
  final String category;
  final DateTime date;
  final String notes;
  final String? imagePath;
  final String autofillSessionId;
  final bool isSubmitting;
  final bool isSuccess;
  final String? errorMessage;

  const ExpenseFormState({
    required this.merchantName,
    this.amount,
    required this.category,
    required this.date,
    required this.notes,
    this.imagePath,
    required this.autofillSessionId,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  factory ExpenseFormState.initial({DateTime? initialDate}) {
    return ExpenseFormState(
      merchantName: '',
      amount: null,
      category: 'Others',
      date: initialDate ?? DateTime.now(),
      notes: '',
      imagePath: null,
      autofillSessionId: 'initial',
    );
  }

  ExpenseFormState copyWith({
    String? merchantName,
    double? amount,
    String? category,
    DateTime? date,
    String? notes,
    String? imagePath,
    String? autofillSessionId,
    bool? isSubmitting,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return ExpenseFormState(
      merchantName: merchantName ?? this.merchantName,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      imagePath: imagePath ?? this.imagePath,
      autofillSessionId: autofillSessionId ?? this.autofillSessionId,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
