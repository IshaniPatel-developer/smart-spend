import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/constants/app_strings.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_event.dart';
import '../bloc/expense_state.dart';
import '../widgets/glass_card.dart';
import '../widgets/category_chart.dart';
import '../widgets/expense_list_item.dart';
import '../widgets/rupee_amount_text.dart';
import 'add_edit_expense_screen.dart';
import '../../../insights/presentation/screens/insights_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE, MMM dd').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.dashboardTitle)),
      body: AppTheme.radialGradientBackground(
        child: SafeArea(
          child: BlocBuilder<ExpenseBloc, ExpenseState>(
            builder: (context, state) {
              if (state is ExpenseLoadingState) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryAccent,
                  ),
                );
              }

              if (state is ExpenseErrorState) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppTheme.dangerAccent,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error: ${state.message}',
                        style: const TextStyle(color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<ExpenseBloc>().add(
                          LoadExpensesEvent(),
                        ),
                        child: const Text(AppStrings.retryLabel),
                      ),
                    ],
                  ),
                );
              }

              if (state is ExpenseLoadedState) {
                final expenses = state.expenses;
                final grandTotal = expenses.fold(
                  0.0,
                  (sum, item) => sum + item.amount,
                );

                // Get largest expense
                double maxAmount = 0;
                String largestMerchant = 'N/A';
                for (final exp in expenses) {
                  if (exp.amount > maxAmount) {
                    maxAmount = exp.amount;
                    largestMerchant = exp.merchantName;
                  }
                }

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800.0),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 10.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Welcome & Date
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Hello Guest,',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    AppStrings.welcomeBackLabel,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: -0.5,
                                          color: AppTheme.textPrimary,
                                        ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.glassCardFill,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppTheme.borderLight,
                                  ),
                                ),
                                child: Text(
                                  today,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.cyanAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Quick Stats Glass Card
                          GlassCard(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  child: _statWidget(
                                    label: AppStrings.totalSpentLabel,
                                    valueWidget: RupeeAmountText(
                                      amount: grandTotal,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.cyanAccent,
                                      ),
                                    ),
                                    color: AppTheme.cyanAccent,
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 40,
                                  color: AppTheme.borderLight,
                                ),

                                Expanded(
                                  child: _statWidget(
                                    label: AppStrings.transactionsLabel,
                                    valueWidget: Text(
                                      '${expenses.length}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.secondaryAccent,
                                      ),
                                    ),
                                    color: AppTheme.secondaryAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // AI Report & Manual triggers
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AddEditExpenseScreen(),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.obsidianCard,
                                    foregroundColor: Colors.white,
                                    side: const BorderSide(
                                      color: AppTheme.borderLight,
                                      width: 1.5,
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.add,
                                    color: AppTheme.primaryAccent,
                                  ),
                                  label: const Text(
                                    AppStrings.addExpenseButton,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => context
                                      .read<ExpenseBloc>()
                                      .showScanReceiptSheet(context),
                                  icon: const Icon(Icons.document_scanner),
                                  label: const Text(
                                    AppStrings.scanReceiptButton,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // AI Insights Quick Banner
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      InsightsScreen(expenses: expenses),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.primaryAccent.withOpacity(0.85),
                                    AppTheme.cyanAccent.withOpacity(0.85),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryAccent.withOpacity(
                                      0.2,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.auto_awesome,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppStrings.aiInsightsBannerTitle,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          AppStrings.aiInsightsBannerSub,
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Category breakdown chart card
                          if (expenses.isNotEmpty) ...[
                            GlassCard(child: CategoryChart(expenses: expenses)),
                            const SizedBox(height: 24),
                          ],

                          // History Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppStrings.expenseHistoryHeader,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                    ),
                              ),
                              if (expenses.isNotEmpty)
                                const Text(
                                  AppStrings.swipeToDeleteHint,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // History list
                          expenses.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 40.0,
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.receipt,
                                          size: 48,
                                          color: AppTheme.textSecondary
                                              .withOpacity(0.5),
                                        ),
                                        const SizedBox(height: 12),
                                        const Text(
                                          AppStrings.emptyHistoryMessage,
                                          style: TextStyle(
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: expenses.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 8),
                                  itemBuilder: (context, index) {
                                    final exp = expenses[index];
                                    return ExpenseListItem(
                                      expense: exp,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AddEditExpenseScreen(
                                                  expense: exp,
                                                ),
                                          ),
                                        );
                                      },
                                      onDelete: () {
                                        if (exp.id != null) {
                                          context.read<ExpenseBloc>().add(
                                            DeleteExpenseEvent(exp.id!),
                                          );
                                        }
                                      },
                                    );
                                  },
                                ),
                        ],
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

  Widget _statWidget({
    required String label,
    required Widget valueWidget,
    String? subtext,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        valueWidget,
        if (subtext != null) ...[
          const SizedBox(height: 2),
          Text(
            subtext,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 9,
              color: AppTheme.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}
