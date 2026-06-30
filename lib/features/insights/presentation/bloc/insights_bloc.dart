import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/network_info.dart';
import '../../domain/usecases/generate_insights_usecase.dart';
import 'insights_event.dart';
import 'insights_state.dart';

class InsightsBloc extends Bloc<InsightsEvent, InsightsState> {
  final GenerateInsights _generateInsights;

  InsightsBloc({
    required GenerateInsights generateInsights,
  })  : _generateInsights = generateInsights,
        super(InsightsInitialState()) {
    on<GenerateInsightsEvent>(_onGenerateInsights);
    on<ClearInsightsEvent>(_onClearInsights);
  }

  Future<void> _onGenerateInsights(
    GenerateInsightsEvent event,
    Emitter<InsightsState> emit,
  ) async {
    emit(InsightsGeneratingState());
    if (!await NetworkInfo.isConnected) {
      emit(InsightsErrorState(AppStrings.noInternetConnectionMessage));
      return;
    }
    try {
      final insights = await _generateInsights(event.expenses);
      emit(InsightsGeneratedState(insights));
    } catch (e) {
      emit(InsightsErrorState(e.toString()));
    }
  }

  void _onClearInsights(
    ClearInsightsEvent event,
    Emitter<InsightsState> emit,
  ) {
    emit(InsightsInitialState());
  }
}
