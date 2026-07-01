class ReceiptScanResult {
  final String merchantName;
  final double amount;
  final DateTime date;
  final String category;

  const ReceiptScanResult({
    required this.merchantName,
    required this.amount,
    required this.date,
    required this.category,
  });
}
