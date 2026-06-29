import '../entities/receipt_scan_result.dart';
import '../repository/expense_repository.dart';

class ScanReceipt {
  final ExpenseRepository repository;

  ScanReceipt(this.repository);

  Future<ReceiptScanResult> call(String imagePath) async {
    return await repository.scanReceipt(imagePath);
  }
}
