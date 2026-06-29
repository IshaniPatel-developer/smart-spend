import '../../domain/entities/expense.dart';
import '../../domain/entities/receipt_scan_result.dart';
import '../../domain/entities/spending_insights.dart';
import '../../domain/repository/expense_repository.dart';
import '../datasource/expense_local_datasource.dart';
import '../models/expense_model.dart';
import '../../../../core/network/gemini_client.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDataSource _localDataSource;
  final GeminiClient _geminiClient;

  ExpenseRepositoryImpl({
    required ExpenseLocalDataSource localDataSource,
    required GeminiClient geminiClient,
  })  : _localDataSource = localDataSource,
        _geminiClient = geminiClient;

  @override
  Future<List<Expense>> getExpenses() async {
    return await _localDataSource.getExpenses();
  }

  @override
  Future<int> addExpense(Expense expense) async {
    final model = ExpenseModel.fromEntity(expense);
    return await _localDataSource.addExpense(model);
  }

  @override
  Future<int> updateExpense(Expense expense) async {
    final model = ExpenseModel.fromEntity(expense);
    return await _localDataSource.updateExpense(model);
  }

  @override
  Future<int> deleteExpense(int id) async {
    return await _localDataSource.deleteExpense(id);
  }

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

  @override
  Future<SpendingInsights> getSpendingInsights(List<Expense> expenses) async {
    if (expenses.isEmpty) {
      return const SpendingInsights(
        totalSpending: 0.0,
        categoryBreakdown: {},
        largestExpense: 'None',
        spendingTrends: 'No expense records found. Add expenses to get trends.',
        recommendation: 'Add some expenses to get AI-powered recommendations.',
        rawReportMarkdown: '### Spending Report\nNo transactions have been recorded yet. Please add transactions to generate spending insights.',
      );
    }

    // Convert list of entities to map representation for sending to Gemini
    final expensesMap = expenses.map((e) => ExpenseModel.fromEntity(e).toMap()).toList();

    // Trigger Gemini client to generate insights report
    final response = await _geminiClient.generateSpendingInsights(expensesMap);

    // Perform local calculations for guaranteed correctness
    double total = 0.0;
    final Map<String, double> breakdown = {};
    Expense? largest;

    for (final exp in expenses) {
      total += exp.amount;
      breakdown[exp.category] = (breakdown[exp.category] ?? 0.0) + exp.amount;

      if (largest == null || exp.amount > largest.amount) {
        largest = exp;
      }
    }

    final largestExpenseStr = largest != null
        ? '${largest.merchantName} (\$${largest.amount.toStringAsFixed(2)}) on ${largest.date.toIso8601String().split('T').first}'
        : 'None';

    final reportMarkdown = response['reportMarkdown']?.toString() ?? 'Failed to generate markdown report.';
    final spendingTrends = response['spendingTrends']?.toString() ?? 'Unable to determine spending trends.';
    final recommendation = response['recommendation']?.toString() ?? 'Keep tracking your expenses to build habits.';

    return SpendingInsights(
      totalSpending: total,
      categoryBreakdown: breakdown,
      largestExpense: largestExpenseStr,
      spendingTrends: spendingTrends,
      recommendation: recommendation,
      rawReportMarkdown: reportMarkdown,
    );
  }
}
