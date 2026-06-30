abstract class ReceiptEvent {}

class ScanReceiptEvent extends ReceiptEvent {
  final String imagePath;
  ScanReceiptEvent(this.imagePath);
}

class ClearReceiptScanEvent extends ReceiptEvent {}
