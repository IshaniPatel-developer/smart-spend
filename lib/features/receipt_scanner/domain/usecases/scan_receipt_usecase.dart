import '../entities/receipt_scan_result.dart';
import '../repository/receipt_repository.dart';

class ScanReceipt {
  final ReceiptRepository repository;

  ScanReceipt(this.repository);

  Future<ReceiptScanResult> call(String imagePath) async {
    return await repository.scanReceipt(imagePath);
  }
}
