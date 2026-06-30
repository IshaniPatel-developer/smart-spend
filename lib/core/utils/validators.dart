class Validators {
  /// Ensures the merchant name is not null or empty.
  static String? validateMerchantName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a merchant name';
    }
    return null;
  }

  /// Ensures the amount is a valid positive number.
  static String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter an amount';
    }
    final amount = double.tryParse(value);
    if (amount == null || amount <= 0) {
      return 'Please enter a valid positive number';
    }
    return null;
  }
}
