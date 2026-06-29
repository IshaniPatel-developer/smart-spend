import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/scan_receipt_usecase.dart';
import 'receipt_event.dart';
import 'receipt_state.dart';

class ReceiptBloc extends Bloc<ReceiptEvent, ReceiptState> {
  final ScanReceipt _scanReceipt;

  ReceiptBloc({
    required ScanReceipt scanReceipt,
  })  : _scanReceipt = scanReceipt,
        super(ReceiptInitialState()) {
    on<ScanReceiptEvent>(_onScanReceipt);
    on<ClearReceiptScanEvent>(_onClearReceiptScan);
  }

  Future<void> _onScanReceipt(
    ScanReceiptEvent event,
    Emitter<ReceiptState> emit,
  ) async {
    emit(ReceiptScanningState());
    try {
      final result = await _scanReceipt(event.imagePath);
      emit(ReceiptScannedState(result));
    } catch (e) {
      emit(ReceiptScanErrorState(e.toString()));
    }
  }

  void _onClearReceiptScan(
    ClearReceiptScanEvent event,
    Emitter<ReceiptState> emit,
  ) {
    emit(ReceiptInitialState());
  }
}
