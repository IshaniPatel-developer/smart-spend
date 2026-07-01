class SpendingInsights {
  final double totalSpending;
  final Map<String, double> categoryBreakdown;
  final String largestExpense;
  final String spendingTrends;
  final String recommendation;
  final String rawReportMarkdown;

  const SpendingInsights({
    required this.totalSpending,
    required this.categoryBreakdown,
    required this.largestExpense,
    required this.spendingTrends,
    required this.recommendation,
    required this.rawReportMarkdown,
  });
}
