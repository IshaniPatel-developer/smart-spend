import '../../../expense_management/domain/entities/expense.dart';
import '../entities/spending_insights.dart';

abstract class InsightsRepository {
  Future<SpendingInsights> generateInsights(List<Expense> expenses);
}
