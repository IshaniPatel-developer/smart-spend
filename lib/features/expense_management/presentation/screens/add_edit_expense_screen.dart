import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/expense.dart';
import '../../../receipt_scanner/domain/entities/receipt_scan_result.dart';
import '../bloc/expense_bloc.dart';
import '../bloc/expense_event.dart';
import '../../../receipt_scanner/presentation/bloc/receipt_bloc.dart';
import '../../../receipt_scanner/presentation/bloc/receipt_event.dart';
import '../../../receipt_scanner/presentation/bloc/receipt_state.dart';
import '../widgets/glass_card.dart';

class AddEditExpenseScreen extends StatefulWidget {
  final Expense? expense;

  const AddEditExpenseScreen({super.key, this.expense});

  @override
  State<AddEditExpenseScreen> createState() => _AddEditExpenseScreenState();
}

class _AddEditExpenseScreenState extends State<AddEditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _merchantController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'Food';
  String? _imagePath;
  bool _isAutofilledByAI = false;

  final List<String> _categories = [
    'Food',
    'Shopping',
    'Travel',
    'Utilities',
    'Entertainment',
    'Others',
  ];

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      final exp = widget.expense!;
      _merchantController.text = exp.merchantName;
      _amountController.text = exp.amount.toString();
      _notesController.text = exp.notes ?? '';
      _selectedDate = exp.date;
      _selectedCategory = exp.category;
      _imagePath = exp.imagePath;
    }
    // Clear receipt bloc state on screen open
    context.read<ReceiptBloc>().add(ClearReceiptScanEvent());
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primaryAccent,
              onPrimary: Colors.white,
              surface: AppTheme.obsidianCard,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imagePath = pickedFile.path;
        });
        if (mounted) {
          context.read<ReceiptBloc>().add(ScanReceiptEvent(pickedFile.path));
        }
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: $e');
    }
  }

  void _showImagePickerSourceSelector() {
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
                'Scan Receipt',
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
                  _sourceButton(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  _sourceButton(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
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

  Widget _sourceButton({
    required IconData icon,
    required String label,
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
            Icon(icon, size: 36, color: AppTheme.primaryAccent),
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

  void _autofillForm(ReceiptScanResult result) {
    setState(() {
      _merchantController.text = result.merchantName;
      _amountController.text = result.amount.toString();
      _selectedCategory = result.category;
      _selectedDate = result.date;
      _isAutofilledByAI = true;
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.dangerAccent),
    );
  }

  void _saveForm() {
    if (!_formKey.currentState!.validate()) return;

    final name = _merchantController.text.trim();
    final amount = double.parse(_amountController.text.trim());
    final notes = _notesController.text.trim();

    final expense = Expense(
      id: widget.expense?.id,
      merchantName: name,
      amount: amount,
      date: _selectedDate,
      category: _selectedCategory,
      notes: notes.isEmpty ? null : notes,
      imagePath: _imagePath,
    );

    if (widget.expense == null) {
      context.read<ExpenseBloc>().add(AddExpenseEvent(expense));
    } else {
      context.read<ExpenseBloc>().add(UpdateExpenseEvent(expense));
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.expense != null;
    final formattedDate = Formatters.formatDate(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'EDIT EXPENSE' : 'ADD EXPENSE'),
        actions: [
          if (!isEditing)
            IconButton(
              icon: const Icon(
                Icons.document_scanner,
                color: AppTheme.cyanAccent,
              ),
              tooltip: 'Scan Receipt with AI',
              onPressed: _showImagePickerSourceSelector,
            ),
        ],
      ),
      body: AppTheme.radialGradientBackground(
        child: SafeArea(
          child: BlocListener<ReceiptBloc, ReceiptState>(
            listener: (context, state) {
              if (state is ReceiptScannedState) {
                _autofillForm(state.result);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Form auto-filled by AI scanner!'),
                    backgroundColor: AppTheme.secondaryAccent,
                  ),
                );
              } else if (state is ReceiptScanErrorState) {
                _showErrorSnackBar(
                  'Scan failed: ${state.message}. You can still fill manually.',
                );
              }
            },
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800.0),
                child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // AI Scanning Status Box
                    BlocBuilder<ReceiptBloc, ReceiptState>(
                      builder: (context, state) {
                        if (state is ReceiptScanningState) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.cyanAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppTheme.cyanAccent.withOpacity(0.3),
                              ),
                            ),
                            child: const Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppTheme.cyanAccent,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    'AI is reading your receipt image... please wait.',
                                    style: TextStyle(
                                      color: AppTheme.cyanAccent,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        if (_isAutofilledByAI) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.secondaryAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppTheme.secondaryAccent.withOpacity(
                                  0.3,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_outline,
                                  color: AppTheme.secondaryAccent,
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'AI Scan Successful! Please review the highlighted fields before saving.',
                                    style: TextStyle(
                                      color: AppTheme.secondaryAccent,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    size: 18,
                                    color: AppTheme.textSecondary,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isAutofilledByAI = false;
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    ),

                    // Receipt Preview Card
                    if (_imagePath != null) ...[
                      const Text(
                        'Receipt Image',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GlassCard(
                        padding: EdgeInsets.zero,
                        child: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: Image.file(
                                File(_imagePath!),
                                height: 180,
                                width: double.infinity,
                                fit: coverOrContain(_imagePath!),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: CircleAvatar(
                                backgroundColor: Colors.black.withOpacity(0.6),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: AppTheme.dangerAccent,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _imagePath = null;
                                      _isAutofilledByAI = false;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Main Fields Card
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Transaction Details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Merchant Field
                          TextFormField(
                            controller: _merchantController,
                            textCapitalization: TextCapitalization.words,
                            style: const TextStyle(color: AppTheme.textPrimary),
                            decoration: InputDecoration(
                              labelText: 'Merchant Name',
                              prefixIcon: Icon(
                                Icons.storefront,
                                color: _isAutofilledByAI
                                    ? AppTheme.secondaryAccent
                                    : AppTheme.textSecondary,
                              ),
                              enabledBorder: _isAutofilledByAI
                                  ? OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                        color: AppTheme.secondaryAccent,
                                        width: 1.5,
                                      ),
                                    )
                                  : null,
                            ),
                            validator: Validators.validateMerchantName,
                          ),
                          const SizedBox(height: 16),

                          // Amount Field
                          TextFormField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            style: const TextStyle(color: AppTheme.textPrimary),
                            decoration: InputDecoration(
                              labelText: 'Amount (\$)',
                              prefixIcon: Icon(
                                Icons.attach_money,
                                color: _isAutofilledByAI
                                    ? AppTheme.secondaryAccent
                                    : AppTheme.textSecondary,
                              ),
                              enabledBorder: _isAutofilledByAI
                                  ? OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                        color: AppTheme.secondaryAccent,
                                        width: 1.5,
                                      ),
                                    )
                                  : null,
                            ),
                            validator: Validators.validateAmount,
                          ),
                          const SizedBox(height: 16),

                          // Date Field
                          InkWell(
                            onTap: () => _selectDate(context),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 18,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.glassCardFill,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _isAutofilledByAI
                                      ? AppTheme.secondaryAccent
                                      : AppTheme.borderLight,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    color: _isAutofilledByAI
                                        ? AppTheme.secondaryAccent
                                        : AppTheme.textSecondary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    formattedDate,
                                    style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(
                                    Icons.arrow_drop_down,
                                    color: AppTheme.textSecondary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Categories Selection
                    const Text(
                      'Category Selection',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 48,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final cat = _categories[index];
                          final isSelected = _selectedCategory == cat;

                          return ChoiceChip(
                            label: Text(cat),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedCategory = cat;
                                });
                              }
                            },
                            selectedColor: AppTheme.primaryAccent,
                            backgroundColor: AppTheme.glassCardFill,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isSelected
                                    ? AppTheme.primaryAccent
                                    : (_isAutofilledByAI &&
                                              cat == _selectedCategory
                                          ? AppTheme.secondaryAccent
                                          : AppTheme.borderLight),
                                width: 1.5,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Optional Notes Card
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _notesController,
                            maxLines: 2,
                            style: const TextStyle(color: AppTheme.textPrimary),
                            decoration: const InputDecoration(
                              labelText: 'Notes (Optional)',
                              prefixIcon: Icon(
                                Icons.notes,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saveForm,
                        icon: const Icon(Icons.check),
                        label: Text(
                          isEditing ? 'Update Transaction' : 'Save Transaction',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
      ),
    );
  }

  BoxFit coverOrContain(String path) {
    return BoxFit.cover;
  }
}
