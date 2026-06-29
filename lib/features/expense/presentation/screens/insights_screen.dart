import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/theme.dart';
import '../../domain/entities/expense.dart';
import '../bloc/insights_bloc.dart';
import '../bloc/insights_event.dart';
import '../bloc/insights_state.dart';
import '../widgets/glass_card.dart';
import '../widgets/category_chart.dart';

class InsightsScreen extends StatelessWidget {
  final List<Expense> expenses;

  const InsightsScreen({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI SPENDING INSIGHTS'),
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
                return RefreshIndicator(
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
                                    const Text(
                                      'AI Recommendation',
                                      style: TextStyle(
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
                                'Structured Metrics',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildStatRow('Total Expenses', '\$${insights.totalSpending.toStringAsFixed(2)}', AppTheme.cyanAccent),
                              const Divider(height: 20),
                              _buildStatRow('Largest Single Spend', insights.largestExpense, AppTheme.textPrimary),
                              const Divider(height: 20),
                              _buildStatRow('General Trend', insights.spendingTrends, AppTheme.textSecondary, isLongText: true),
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
                            'AI Financial Report',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _parseMarkdown(insights.rawReportMarkdown),
                          ),
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
                            label: const Text('Refresh AI Report', style: TextStyle(color: AppTheme.cyanAccent)),
                          ),
                        ),
                      ],
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

  Widget _buildStatRow(String label, String value, Color valueColor, {bool isLongText = false}) {
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
        Text(
          value,
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
              'No Insights Generated Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Click the button below to generate a natural-language spending report based on your history.',
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
              label: const Text('Generate AI Report'),
            ),
            if (expenses.isEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Please add at least one expense to analyze.',
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
              'Analyzing Spending Patterns...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'AI is calculating trends and generating recommendations...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary.withOpacity(0.8),
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
              'Failed to Generate Insights',
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
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  /// Parses markdown headings, lists, and bold text without third-party packages.
  List<Widget> _parseMarkdown(String markdown) {
    final lines = markdown.split('\n');
    final List<Widget> widgets = [];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      if (trimmed.startsWith('###')) {
        // H3
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 14.0, bottom: 6.0),
            child: Text(
              trimmed.substring(3).trim(),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppTheme.cyanAccent,
              ),
            ),
          ),
        );
      } else if (trimmed.startsWith('##')) {
        // H2
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
            child: Text(
              trimmed.substring(2).trim(),
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryAccent,
              ),
            ),
          ),
        );
      } else if (trimmed.startsWith('#')) {
        // H1
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
            child: Text(
              trimmed.substring(1).trim(),
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        );
      } else if (trimmed.startsWith('-') || trimmed.startsWith('*')) {
        // Bullet points
        final content = trimmed.substring(1).trim();
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 6.0, right: 8.0, left: 4.0),
                  child: Icon(Icons.circle, size: 6, color: AppTheme.primaryAccent),
                ),
                Expanded(
                  child: _richTextParser(content),
                ),
              ],
            ),
          ),
        );
      } else {
        // Normal paragraph
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: _richTextParser(trimmed),
          ),
        );
      }
    }
    return widgets;
  }

  /// Helper to parse bold markdown (e.g. **bold**) in text.
  Widget _richTextParser(String text) {
    final RegExp regExp = RegExp(r'\*\*(.*?)\*\*');
    final List<TextSpan> spans = [];
    int start = 0;

    for (final Match match in regExp.allMatches(text)) {
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start)));
      }
      spans.add(
        TextSpan(
          text: match.group(1),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      );
      start = match.end;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 13.5,
          height: 1.4,
        ),
        children: spans,
      ),
    );
  }
}
