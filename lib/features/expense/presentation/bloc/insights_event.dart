import '../../domain/entities/expense.dart';

abstract class InsightsEvent {}

class GenerateInsightsEvent extends InsightsEvent {
  final List<Expense> expenses;
  GenerateInsightsEvent(this.expenses);
}

class ClearInsightsEvent extends InsightsEvent {}
