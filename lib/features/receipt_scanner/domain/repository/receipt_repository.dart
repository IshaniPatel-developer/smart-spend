import '../entities/receipt_scan_result.dart';

abstract class ReceiptRepository {
  Future<ReceiptScanResult> scanReceipt(String imagePath);
}
