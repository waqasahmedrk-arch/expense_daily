import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/expense_model.dart';
import '../theme/app_theme.dart';

class AddExpenseSheet extends StatefulWidget {
  final ExpenseModel? expense;

  const AddExpenseSheet({super.key, this.expense});

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late String _selectedCategory;
  late DateTime _selectedDate;
  bool _isSaving = false;

  bool get _isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.expense?.title ?? '');
    _amountController = TextEditingController(
        text: widget.expense != null
            ? widget.expense!.amount.toStringAsFixed(0)
            : '');
    _selectedCategory = widget.expense?.category ?? 'Food';
    _selectedDate = widget.expense?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // ─── Date Picker ───────────────────────────────────────────────────────────

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primaryBlue,
              onPrimary: Colors.white,
              surface: AppTheme.darkSurface,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  // ─── Delete Confirmation ───────────────────────────────────────────────────

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18)),
        icon: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.delete_outline_rounded,
              color: Colors.redAccent, size: 28),
        ),
        title: const Text(
          'Delete Expense',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to delete "${widget.expense!.title}"?\nThis action cannot be undone.',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(110, 42),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              minimumSize: const Size(110, 42),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await context
            .read<AppProvider>()
            .deleteExpense(widget.expense!.id);
        if (!context.mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Expense deleted successfully'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  // ─── Save / Update ─────────────────────────────────────────────────────────

  void _save() async {
    if (_titleController.text.trim().isEmpty ||
        _amountController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill title and amount'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid amount'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final updatedExpense = ExpenseModel(
        id: _isEditing
            ? widget.expense!.id
            : DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        amount: amount,
        category: _selectedCategory,
        date: _selectedDate,
        color: categoryColors[_selectedCategory] ??
            const Color(0xFF9B59B6),
      );

      if (_isEditing) {
        await context
            .read<AppProvider>()
            .updateExpense(updatedExpense);
      } else {
        await context
            .read<AppProvider>()
            .addExpense(updatedExpense);
      }

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing
              ? 'Expense updated successfully!'
              : 'Expense added successfully!'),
          backgroundColor: AppTheme.primaryBlue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save expense: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurface : Colors.white,
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24)),
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.only(
              left: 20,                   // ✅ reduced from 24 → prevents horizontal overflow
              right: 20,                  // ✅ reduced from 24 → prevents horizontal overflow
              top: 16,                    // ✅ reduced from 24 → prevents vertical overflow
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            children: [
              // ── Handle bar ────────────────────────────────────────────
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppTheme.darkCardAlt
                        : const Color(0xFFDDE3EE),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),  // ✅ reduced from 20

              // ── Header row ────────────────────────────────────────────
              // FIX: Use Row with Expanded to prevent overflow.
              // Delete icon is fixed-width; title takes remaining space.
              Row(
                children: [
                  Expanded(                // ✅ Expanded instead of Flexible — fills remaining width
                    child: Text(
                      _isEditing ? 'Update Expense' : 'Add Expense',
                      style: theme.textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,         // ✅ clamps to single line
                    ),
                  ),
                  if (_isEditing) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _confirmDelete,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),  // ✅ reduced from 20

              // ── Title ─────────────────────────────────────────────────
              Text('Title',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontSize: 14)),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                style: theme.textTheme.bodyLarge,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                    hintText: 'e.g. Lunch, Uber...'),
              ),
              const SizedBox(height: 12),  // ✅ reduced from 14

              // ── Amount ────────────────────────────────────────────────
              Text('Amount (PKR)',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontSize: 14)),
              const SizedBox(height: 8),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true),
                style: theme.textTheme.bodyLarge,
                decoration: const InputDecoration(hintText: '0'),
              ),
              const SizedBox(height: 12),  // ✅ reduced from 14

              // ── Category ──────────────────────────────────────────────
              Text('Category',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontSize: 14)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.darkCardAlt
                      : const Color(0xFFF0F4FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? Colors.transparent
                        : const Color(0xFFDDE3EE),
                  ),
                ),
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  dropdownColor: isDark
                      ? AppTheme.darkSurface
                      : Colors.white,
                  underline: const SizedBox(),
                  style: theme.textTheme.bodyLarge,
                  items: expenseCategories.map((cat) {
                    final color = categoryColors[cat] ??
                        const Color(0xFF9B59B6);
                    return DropdownMenuItem(
                      value: cat,
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 8),
                          Text(cat),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedCategory = val);
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),  // ✅ reduced from 14

              // ── Date ──────────────────────────────────────────────────
              Text('Date',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontSize: 14)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppTheme.darkCardAlt
                        : const Color(0xFFF0F4FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? Colors.transparent
                          : const Color(0xFFDDE3EE),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_selectedDate.day.toString().padLeft(2, '0')}/'
                            '${_selectedDate.month.toString().padLeft(2, '0')}/'
                            '${_selectedDate.year}',
                        style: theme.textTheme.bodyLarge,
                      ),
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 18,
                        color: isDark
                            ? AppTheme.darkTextSecondary
                            : AppTheme.lightTextSecondary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),  // ✅ reduced from 24

              // ── Save Button ───────────────────────────────────────────
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
                    : Text(_isEditing
                    ? 'Update Expense'
                    : 'Add Expense'),
              ),
            ],
          ),
        );
      },
    );
  }
}