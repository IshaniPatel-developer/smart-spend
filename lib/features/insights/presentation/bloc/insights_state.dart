import '../../domain/entities/spending_insights.dart';

abstract class InsightsState {}

class InsightsInitialState extends InsightsState {}

class InsightsGeneratingState extends InsightsState {}

class InsightsGeneratedState extends InsightsState {
  final SpendingInsights insights;
  InsightsGeneratedState(this.insights);
}

class InsightsErrorState extends InsightsState {
  final String message;
  InsightsErrorState(this.message);
}
