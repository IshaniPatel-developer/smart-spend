class Validators {
  /// Ensures the merchant name is not null or empty and does not start with whitespace.
  static String? validateMerchantName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a merchant name';
    }
    if (value.startsWith(' ') || value.startsWith('\t')) {
      return 'Name cannot start with whitespace';
    }
    if (value.trim().isEmpty) {
      return 'Please enter a merchant name';
    }
    return null;
  }

  /// Ensures the amount is a valid positive number starting from at least 1.
  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an amount';
    }
    if (value.startsWith(' ') || value.startsWith('\t')) {
      return 'Amount cannot start with whitespace';
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
