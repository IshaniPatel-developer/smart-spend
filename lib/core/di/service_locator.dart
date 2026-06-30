import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../database/database_helper.dart';
import '../network/gemini_client.dart';

// Expense Management Feature
import '../../features/expense_management/data/datasource/expense_local_datasource.dart';
import '../../features/expense_management/data/repository/expense_repository_impl.dart';
import '../../features/expense_management/domain/repository/expense_repository.dart';
import '../../features/expense_management/domain/usecases/get_expenses.dart';
import '../../features/expense_management/domain/usecases/add_expense.dart';
import '../../features/expense_management/domain/usecases/update_expense.dart';
import '../../features/expense_management/domain/usecases/delete_expense.dart';
import '../../features/expense_management/presentation/bloc/expense_bloc.dart';
import '../../features/expense_management/presentation/bloc/expense_form_bloc.dart';

// Receipt Scanner Feature
import '../../features/receipt_scanner/data/repository/receipt_repository_impl.dart';
import '../../features/receipt_scanner/domain/repository/receipt_repository.dart';
import '../../features/receipt_scanner/domain/usecases/scan_receipt_usecase.dart';
import '../../features/receipt_scanner/presentation/bloc/receipt_bloc.dart';

// Insights Feature
import '../../features/insights/data/repository/insights_repository_impl.dart';
import '../../features/insights/domain/repository/insights_repository.dart';
import '../../features/insights/domain/usecases/generate_insights_usecase.dart';
import '../../features/insights/presentation/bloc/insights_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core
  final dbHelper = DatabaseHelper.instance;
  sl.registerSingleton<DatabaseHelper>(dbHelper);
  
  final dio = Dio();
  sl.registerLazySingleton<Dio>(() => dio);
  
  sl.registerLazySingleton<GeminiClient>(
    () => GeminiClient(dio: sl(), dbHelper: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<ExpenseLocalDataSource>(
    () => ExpenseLocalDataSourceImpl(dbHelper: sl()),
  );

  // Repositories
  sl.registerLazySingleton<ExpenseRepository>(
    () => ExpenseRepositoryImpl(
      localDataSource: sl(),
    ),
  );
  
  sl.registerLazySingleton<ReceiptRepository>(
    () => ReceiptRepositoryImpl(
      geminiClient: sl(),
    ),
  );
  
  sl.registerLazySingleton<InsightsRepository>(
    () => InsightsRepositoryImpl(
      geminiClient: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetExpenses(sl()));
  sl.registerLazySingleton(() => AddExpense(sl()));
  sl.registerLazySingleton(() => UpdateExpense(sl()));
  sl.registerLazySingleton(() => DeleteExpense(sl()));
  sl.registerLazySingleton(() => ScanReceipt(sl()));
  sl.registerLazySingleton(() => GenerateInsights(sl()));

  // BLoCs (Factory so new instances can be created if needed)
  sl.registerFactory(
    () => ExpenseBloc(
      getExpenses: sl(),
      addExpense: sl(),
      updateExpense: sl(),
      deleteExpense: sl(),
    ),
  );
  
  sl.registerFactory(
    () => ReceiptBloc(
      scanReceipt: sl(),
    ),
  );
  
  sl.registerFactory(
    () => InsightsBloc(
      generateInsights: sl(),
    ),
  );

  sl.registerFactory(
    () => ExpenseFormBloc(
      addExpense: sl(),
      updateExpense: sl(),
    ),
  );
}
