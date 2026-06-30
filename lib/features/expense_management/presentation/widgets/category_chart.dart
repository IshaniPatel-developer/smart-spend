import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/constants/app_strings.dart';
import '../widgets/rupee_amount_text.dart';
import '../../domain/entities/expense.dart';

class CategoryChart extends StatelessWidget {
  final List<Expense> expenses;

  const CategoryChart({super.key, required this.expenses});

  Map<String, double> get _calculateTotals {
    final Map<String, double> totals = {};
    for (final exp in expenses) {
      totals[exp.category] = (totals[exp.category] ?? 0.0) + exp.amount;
    }
    return totals;
  }

  double get _grandTotal {
    return expenses.fold(0.0, (sum, exp) => sum + exp.amount);
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food':
        return AppTheme.amberCategory; // Amber
      case 'Shopping':
        return AppTheme.pinkCategory; // Pink
      case 'Travel':
        return AppTheme.blueCategory; // Blue
      case 'Utilities':
        return AppTheme.yellowCategory; // Yellow
      case 'Entertainment':
        return AppTheme.primaryAccent; // Violet
      case 'Others':
      default:
        return AppTheme.secondaryAccent; // Emerald
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant;
      case 'Shopping':
        return Icons.shopping_bag;
      case 'Travel':
        return Icons.flight;
      case 'Utilities':
        return Icons.bolt;
      case 'Entertainment':
        return Icons.movie;
      case 'Others':
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final totals = _calculateTotals;
    final grandTotal = _grandTotal;

    if (expenses.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Text(
            'No transaction data available.',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
      );
    }

    // Sort categories by amount descending
    final sortedCategories = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                AppStrings.categoryBreakdownTitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            Row(
              children: [
                RupeeAmountText(
                  amount: grandTotal,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.cyanAccent,
                  ),
                ),
                const Text(
                  AppStrings.totalSuffix,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.cyanAccent,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortedCategories.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final entry = sortedCategories[index];
            final categoryName = entry.key;
            final amount = entry.value;
            final percentage = grandTotal > 0 ? (amount / grandTotal) : 0.0;
            final color = _getCategoryColor(categoryName);
            final icon = _getCategoryIcon(categoryName);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 16, color: color),
                    const SizedBox(width: 8),
                    Text(
                      categoryName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    RupeeAmountText(
                      amount: amount,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${(percentage * 100).toStringAsFixed(0)}%)',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppTheme.borderLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: percentage,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.4),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
