class AppStrings {
  // Common/General
  static const String appName = 'SMARTSPEND';
  static const String dollar = '\$';
  static const String rupee = '₹';
  static const String noInternetConnectionMessage = 'No internet connection. Please check your connectivity and try again.';

  // Splash Screen
  static const String splashTagline = 'AI-Powered Expense Management';

  // Dashboard Screen
  static const String dashboardTitle = 'SMARTSPEND';
  static const String welcomeBackLabel = 'Welcome';
  static const String retryLabel = 'Retry';
  static const String totalSpentLabel = 'Total Spent';
  static const String largestPurchaseLabel = 'Largest purchase';
  static const String transactionsLabel = 'Transactions';
  static const String emptyExpensesMessage = 'No expenses recorded yet. Start by scanning a receipt or adding one manually!';
  static const String addExpenseButton = 'Add Expense';
  static const String scanReceiptButton = 'Scan Receipt';
  static const String aiInsightsBannerTitle = 'Get AI Spending Insights';
  static const String aiInsightsBannerSub = 'Analyze categories, trends and recommendations.';
  static const String recentExpensesTitle = 'Recent Expenses';
  static const String expenseHistoryHeader = 'Expense History';
  static const String swipeToDeleteHint = 'Swipe left to delete';
  static const String emptyHistoryMessage = 'No expenses yet. Add or scan one above!';
  
  // Dialogs
  static const String deleteExpenseTitle = 'Delete Expense?';
  static const String deleteExpenseConfirmBase = 'Are you sure you want to remove this expense of ';
  static const String deleteExpenseConfirmAt = ' at ';
  static const String deleteExpenseConfirmQuestion = '?';
  static const String cancelLabel = 'Cancel';
  static const String deleteLabel = 'Delete';

  // Scanner Sheet
  static const String scannerSheetTitle = 'AI Receipt Scanner';
  static const String cameraLabel = 'Camera';
  static const String galleryLabel = 'Gallery';
  static const String failedToPickImage = 'Failed to pick image: ';

  // Add/Edit Screen
  static const String addExpenseTitle = 'ADD EXPENSE';
  static const String editExpenseTitle = 'EDIT EXPENSE';
  static const String transactionDetailsTitle = 'Transaction Details';
  static const String merchantNameLabel = 'Merchant Name';
  static const String amountLabel = 'Amount (₹)';
  static const String notesOptionalLabel = 'Notes (Optional)';
  static const String categorySelectionTitle = 'Category Selection';
  static const String savingLabel = 'Saving...';
  static const String saveTransactionLabel = 'Save Transaction';
  static const String updateTransactionLabel = 'Update Transaction';
  static const String transactionSavedMessage = 'Transaction saved!';
  static const String transactionUpdatedMessage = 'Transaction updated!';
  static const String aiAnalyzingReceiptMessage = 'Gemini AI is analyzing receipt...';
  static const String formAutofilledMessage = 'Form auto-filled by AI scanner!';
  static const String scanFailedFallbackMessage = 'Scan failed: ';
  static const String scanFailedSuffix = '. You can still fill manually.';
  
  // Insights Screen
  static const String insightsTitle = 'SPENDING INSIGHTS';
  static const String aiRecommendationTitle = 'AI Recommendation';
  static const String structuredMetricsTitle = 'Structured Metrics';
  static const String totalExpensesMetricLabel = 'Total Expenses';
  static const String largestSingleSpendMetricLabel = 'Largest Single Spend';
  static const String generalTrendMetricLabel = 'General Trend';
  static const String aiReportTitle = 'AI Financial Report';
  static const String refreshReportButton = 'Refresh AI Report';
  
  // Insights Screen Empty / Loading / Error
  static const String noInsightsTitle = 'No Insights Generated Yet';
  static const String noInsightsDescription = 'Click the button below to generate a natural-language spending report based on your history.';
  static const String generateAiReportButton = 'Generate AI Report';
  static const String addExpenseToAnalyzeMessage = 'Please add at least one expense to analyze.';
  static const String analyzingSpendingTitle = 'Analyzing Spending Patterns...';
  static const String analyzingSpendingSub = 'AI is calculating trends and generating recommendations...';
  static const String failedGenerateInsightsTitle = 'Failed to Generate Insights';
  static const String tryAgainButton = 'Try Again';

  // Categories
  static const String categoryFood = 'Food';
  static const String categoryShopping = 'Shopping';
  static const String categoryTravel = 'Travel';
  static const String categoryUtilities = 'Utilities';
  static const String categoryEntertainment = 'Entertainment';
  static const String categoryOthers = 'Others';
  static const String categoryBreakdownTitle = 'Category Breakdown';
  static const String totalSuffix = ' Total';
}
