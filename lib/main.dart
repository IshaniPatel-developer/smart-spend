import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/service_locator.dart' as di;
import 'core/theme/theme.dart';
import 'features/expense_management/presentation/bloc/expense_bloc.dart';
import 'features/receipt_scanner/presentation/bloc/receipt_bloc.dart';
import 'features/insights/presentation/bloc/insights_bloc.dart';
import 'features/expense_management/presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection
  await di.init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ExpenseBloc>(
          create: (context) => di.sl<ExpenseBloc>(),
        ),
        BlocProvider<ReceiptBloc>(
          create: (context) => di.sl<ReceiptBloc>(),
        ),
        BlocProvider<InsightsBloc>(
          create: (context) => di.sl<InsightsBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'SmartSpend',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
