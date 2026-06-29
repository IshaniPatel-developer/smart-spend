import '../../domain/entities/receipt_scan_result.dart';

abstract class ReceiptState {}

class ReceiptInitialState extends ReceiptState {}

class ReceiptScanningState extends ReceiptState {}

class ReceiptScannedState extends ReceiptState {
  final ReceiptScanResult result;
  ReceiptScannedState(this.result);
}

class ReceiptScanErrorState extends ReceiptState {
  final String message;
  ReceiptScanErrorState(this.message);
}
