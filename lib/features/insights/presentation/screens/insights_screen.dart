import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../expense_management/domain/entities/expense.dart';
import '../bloc/insights_bloc.dart';
import '../bloc/insights_event.dart';
import '../bloc/insights_state.dart';
import '../../../expense_management/presentation/widgets/glass_card.dart';
import '../../../expense_management/presentation/widgets/category_chart.dart';
import '../../../expense_management/presentation/widgets/rupee_amount_text.dart';
import '../widgets/markdown_report_view.dart';

class InsightsScreen extends StatelessWidget {
  final List<Expense> expenses;

  const InsightsScreen({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.insightsTitle),
      ),
      body: AppTheme.radialGradientBackground(
        child: SafeArea(
          child: BlocBuilder<InsightsBloc, InsightsState>(
            builder: (context, state) {
              if (state is InsightsInitialState) {
                return _buildEmptyState(context);
              }

              if (state is InsightsGeneratingState) {
                return _buildLoadingState();
              }

              if (state is InsightsErrorState) {
                return _buildErrorState(context, state.message);
              }

              if (state is InsightsGeneratedState) {
                final insights = state.insights;
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800.0),
                    child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<InsightsBloc>().add(GenerateInsightsEvent(expenses));
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Recommendation Callout
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.primaryAccent, AppTheme.cyanAccent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryAccent.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 2.0),
                                child: Icon(Icons.tips_and_updates, color: Colors.white, size: 24),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppStrings.aiRecommendationTitle,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      insights.recommendation,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        height: 1.4,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Local Calculations Stats Card
                        GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                AppStrings.structuredMetricsTitle,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildStatRow(
                                AppStrings.totalExpensesMetricLabel,
                                RupeeAmountText(
                                  amount: insights.totalSpending,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.cyanAccent,
                                  ),
                                ),
                                AppTheme.cyanAccent,
                              ),
                              const Divider(height: 20),
                              _buildStatRow(AppStrings.largestSingleSpendMetricLabel, insights.largestExpense, AppTheme.textPrimary),
                              const Divider(height: 20),
                              _buildStatRow(AppStrings.generalTrendMetricLabel, insights.spendingTrends, AppTheme.textSecondary, isLongText: true),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Interactive Category Chart inside Insights
                        GlassCard(
                          child: CategoryChart(expenses: expenses),
                        ),
                        const SizedBox(height: 20),

                        // Natural Language AI Report
                        const Padding(
                          padding: EdgeInsets.only(left: 4.0, bottom: 10),
                          child: Text(
                            AppStrings.aiReportTitle,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        GlassCard(
                          child: MarkdownReportView(markdown: insights.rawReportMarkdown),
                        ),
                        const SizedBox(height: 24),

                        // Regenerate trigger button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppTheme.borderLight, width: 2),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: () {
                              context.read<InsightsBloc>().add(GenerateInsightsEvent(expenses));
                            },
                            icon: const Icon(Icons.refresh, color: AppTheme.cyanAccent),
                            label: const Text(AppStrings.refreshReportButton, style: TextStyle(color: AppTheme.cyanAccent)),
                          ),
                        ),
                      ],
                    ),
                  ),
                    ),
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, dynamic value, Color valueColor, {bool isLongText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        if (value is Widget)
          value
        else
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: isLongText ? 13 : 15,
              fontWeight: isLongText ? FontWeight.normal : FontWeight.bold,
              color: valueColor,
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryAccent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.analytics,
                size: 64,
                color: AppTheme.primaryAccent,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              AppStrings.noInsightsTitle,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              AppStrings.noInsightsDescription,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: expenses.isEmpty
                  ? null
                  : () {
                      context.read<InsightsBloc>().add(GenerateInsightsEvent(expenses));
                    },
              icon: const Icon(Icons.rocket_launch),
              label: const Text(AppStrings.generateAiReportButton),
            ),
            if (expenses.isEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                AppStrings.addExpenseToAnalyzeMessage,
                style: TextStyle(color: AppTheme.dangerAccent, fontSize: 12),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppTheme.primaryAccent),
            const SizedBox(height: 24),
            const Text(
              AppStrings.analyzingSpendingTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              AppStrings.analyzingSpendingSub,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.dangerAccent,
            ),
            const SizedBox(height: 20),
            const Text(
              AppStrings.failedGenerateInsightsTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<InsightsBloc>().add(GenerateInsightsEvent(expenses));
              },
              icon: const Icon(Icons.refresh),
              label: const Text(AppStrings.tryAgainButton),
            ),
          ],
        ),
      ),
    );
  }


}
