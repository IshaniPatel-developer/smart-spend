import '../../../expense_management/domain/entities/expense.dart';
import '../entities/spending_insights.dart';
import '../repository/insights_repository.dart';

class GenerateInsights {
  final InsightsRepository repository;

  GenerateInsights(this.repository);

  Future<SpendingInsights> call(List<Expense> expenses) async {
    return await repository.generateInsights(expenses);
  }
}
