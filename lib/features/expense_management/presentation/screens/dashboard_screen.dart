import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/formatters.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_event.dart';
import '../bloc/expense_state.dart';
import '../../../receipt_scanner/presentation/bloc/receipt_bloc.dart';
import '../../../receipt_scanner/presentation/bloc/receipt_event.dart';
import '../widgets/glass_card.dart';
import '../widgets/category_chart.dart';
import '../widgets/expense_list_item.dart';
import 'add_edit_expense_screen.dart';
import '../../../insights/presentation/screens/insights_screen.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Load expenses initially
    context.read<ExpenseBloc>().add(LoadExpensesEvent());
  }

  Future<void> _scanReceiptFromCameraOrGallery(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (pickedFile != null && mounted) {
        // Clear previous state and trigger scanning on the scanning bloc
        context.read<ReceiptBloc>().add(ClearReceiptScanEvent());
        context.read<ReceiptBloc>().add(ScanReceiptEvent(pickedFile.path));
        
        // Push the add_edit screen and pass the scan action forward
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddEditExpenseScreen(
              // The screen listens to ReceiptBloc and will auto-populate
              // when the scan event finishes
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: AppTheme.dangerAccent,
        ),
      );
    }
  }

  void _showScanReceiptSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.obsidianCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AI Receipt Scanner',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _actionColumnButton(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    color: AppTheme.cyanAccent,
                    onTap: () {
                      Navigator.pop(context);
                      _scanReceiptFromCameraOrGallery(ImageSource.camera);
                    },
                  ),
                  _actionColumnButton(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    color: AppTheme.primaryAccent,
                    onTap: () {
                      Navigator.pop(context);
                      _scanReceiptFromCameraOrGallery(ImageSource.gallery);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionColumnButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppTheme.glassCardFill,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderLight),
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE, MMM dd').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('SMARTSPEND'),
      ),
      body: AppTheme.radialGradientBackground(
        child: SafeArea(
          child: BlocBuilder<ExpenseBloc, ExpenseState>(
            builder: (context, state) {
              if (state is ExpenseLoadingState) {
                return const Center(child: CircularProgressIndicator(color: AppTheme.primaryAccent));
              }

              if (state is ExpenseErrorState) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: AppTheme.dangerAccent, size: 48),
                      const SizedBox(height: 16),
                      Text('Error: ${state.message}', style: const TextStyle(color: AppTheme.textSecondary)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<ExpenseBloc>().add(LoadExpensesEvent()),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (state is ExpenseLoadedState) {
                final expenses = state.expenses;
                final grandTotal = expenses.fold(0.0, (sum, item) => sum + item.amount);
                
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
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
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
                                'Welcome Back',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.5,
                                    ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.glassCardFill,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.borderLight),
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
                                label: 'Total Spent',
                                value: Formatters.formatCurrency(grandTotal),
                                color: AppTheme.cyanAccent,
                              ),
                            ),
                            Container(width: 1, height: 40, color: AppTheme.borderLight),
                            Expanded(
                              child: _statWidget(
                                label: 'Largest purchase',
                                value: maxAmount > 0 ? Formatters.formatCurrency(maxAmount) : '\$0.00',
                                subtext: maxAmount > 0 ? largestMerchant : null,
                                color: AppTheme.primaryAccent,
                              ),
                            ),
                            Container(width: 1, height: 40, color: AppTheme.borderLight),
                            Expanded(
                              child: _statWidget(
                                label: 'Transactions',
                                value: '${expenses.length}',
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
                                    builder: (context) => AddEditExpenseScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.obsidianCard,
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: AppTheme.borderLight, width: 1.5),
                              ),
                              icon: const Icon(Icons.add, color: AppTheme.primaryAccent),
                              label: const Text('Add Expense'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _showScanReceiptSheet,
                              icon: const Icon(Icons.document_scanner),
                              label: const Text('Scan Receipt'),
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
                              builder: (context) => InsightsScreen(expenses: expenses),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryAccent.withOpacity(0.85),
                                AppTheme.cyanAccent.withOpacity(0.85)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryAccent.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.auto_awesome, color: Colors.white, size: 24),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Get AI Spending Insights',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Analyze categories, trends and recommendations.',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Category breakdown chart card
                      if (expenses.isNotEmpty) ...[
                        GlassCard(
                          child: CategoryChart(expenses: expenses),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // History Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Expense History',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          if (expenses.isNotEmpty)
                            const Text(
                              'Swipe left to delete',
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
                                padding: const EdgeInsets.symmetric(vertical: 40.0),
                                child: Column(
                                  children: [
                                    Icon(Icons.receipt, size: 48, color: AppTheme.textSecondary.withOpacity(0.5)),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'No expenses yet. Add or scan one above!',
                                      style: TextStyle(color: AppTheme.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: expenses.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final exp = expenses[index];
                                return ExpenseListItem(
                                  expense: exp,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AddEditExpenseScreen(expense: exp),
                                      ),
                                    );
                                  },
                                  onDelete: () {
                                    if (exp.id != null) {
                                      context.read<ExpenseBloc>().add(DeleteExpenseEvent(exp.id!));
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
    required String value,
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
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
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
          )
        ]
      ],
    );
  }
}
