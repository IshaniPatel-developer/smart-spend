import '../../../../core/network/gemini_client.dart';
import '../../domain/entities/receipt_scan_result.dart';
import '../../domain/repository/receipt_repository.dart';

class ReceiptRepositoryImpl implements ReceiptRepository {
  final GeminiClient _geminiClient;

  ReceiptRepositoryImpl({
    required GeminiClient geminiClient,
  }) : _geminiClient = geminiClient;

  @override
  Future<ReceiptScanResult> scanReceipt(String imagePath) async {
    final json = await _geminiClient.scanReceipt(imagePath);

    // Sanitize and handle invalid/incomplete API responses gracefully
    final merchantName = json['merchantName']?.toString() ?? 'Unknown Merchant';
    final amount = double.tryParse(json['amount']?.toString() ?? '0.0') ?? 0.0;
    
    DateTime date;
    try {
      final dateStr = json['date']?.toString() ?? '';
      date = DateTime.parse(dateStr);
    } catch (_) {
      date = DateTime.now(); // Fallback to current date
    }

    final rawCategory = json['category']?.toString() ?? 'Others';
    final allowedCategories = ['Food', 'Shopping', 'Travel', 'Utilities', 'Entertainment', 'Others'];
    final category = allowedCategories.firstWhere(
      (c) => c.toLowerCase() == rawCategory.toLowerCase().trim(),
      orElse: () => 'Others',
    );

    return ReceiptScanResult(
      merchantName: merchantName,
      amount: amount,
      date: date,
      category: category,
    );
  }
}
