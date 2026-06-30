import '../../../../core/network/gemini_client.dart';
import '../../../expense_management/data/models/expense_model.dart';
import '../../../expense_management/domain/entities/expense.dart';
import '../../domain/entities/spending_insights.dart';
import '../../domain/repository/insights_repository.dart';

class InsightsRepositoryImpl implements InsightsRepository {
  final GeminiClient _geminiClient;

  InsightsRepositoryImpl({
    required GeminiClient geminiClient,
  }) : _geminiClient = geminiClient;

  @override
  Future<SpendingInsights> generateInsights(List<Expense> expenses) async {
    if (expenses.isEmpty) {
      return const SpendingInsights(
        totalSpending: 0.0,
        categoryBreakdown: {},
        largestExpense: 'None',
        spendingTrends: 'No expense records found. Add expenses to get trends.',
        recommendation: 'Start tracking by adding your first transaction. An excellent way to begin is to record every single minor expense for 7 days to identify hidden spending leaks.',
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
        ? '${largest.merchantName} (₹${largest.amount.toStringAsFixed(2)}) on ${largest.date.toIso8601String().split('T').first}'
        : 'None';

    final reportMarkdown = response['reportMarkdown']?.toString() ?? 'Failed to generate markdown report.';
    final spendingTrends = response['spendingTrends']?.toString() ?? 'Unable to determine spending trends.';
    final recommendation = response['recommendation']?.toString() ?? 'Review your highest spending category this week and consider setting a 10% lower budget limit for it next week.';

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
