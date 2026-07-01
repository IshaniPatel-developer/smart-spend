class Validators {
  /// Ensures the merchant name is not null or empty.
  static String? validateMerchantName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a merchant name';
    }
    return null;
  }

  /// Ensures the amount is a valid positive number starting from at least 1.
  static String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter an amount';
    }
    final trimmed = value.trim();
    if (trimmed.startsWith('0')) {
      return 'Amount cannot start with 0';
    }
    final amount = double.tryParse(trimmed);
    if (amount == null) {
      return 'Please enter a valid positive number';
    }
    if (amount < 1) {
      return 'Amount must be at least 1';
    }
    return null;
  }
}
