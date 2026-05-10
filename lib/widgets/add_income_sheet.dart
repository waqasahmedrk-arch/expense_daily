import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/income_model.dart';
import '../theme/app_theme.dart';

class AddIncomeSheet extends StatefulWidget {
  final IncomeModel? income;

  const AddIncomeSheet({super.key, this.income});

  @override
  State<AddIncomeSheet> createState() => _AddIncomeSheetState();
}

class _AddIncomeSheetState extends State<AddIncomeSheet> {
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late String _selectedSource;
  late DateTime _selectedDate;
  bool _isSaving = false;

  bool get _isEditing => widget.income != null;

  static const _incomeGreen = Color(0xFF2ECC71);

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.income?.title ?? '');
    _amountController = TextEditingController(
        text: widget.income != null
            ? widget.income!.amount.toStringAsFixed(0)
            : '');
    _selectedSource = widget.income?.source ?? 'Salary';
    _selectedDate = widget.income?.date ?? DateTime.now();
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
              primary: _incomeGreen,
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
          'Delete Income',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to delete "${widget.income!.title}"?\nThis action cannot be undone.',
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
            .deleteIncome(widget.income!.id);
        if (!context.mounted) return;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Income deleted successfully'),
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
      final updatedIncome = IncomeModel(
        id: _isEditing
            ? widget.income!.id
            : DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        amount: amount,
        source: _selectedSource,
        date: _selectedDate,
      );

      if (_isEditing) {
        await context
            .read<AppProvider>()
            .updateIncome(updatedIncome);
      } else {
        await context.read<AppProvider>().addIncome(updatedIncome);
      }

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing
              ? 'Income updated successfully!'
              : 'Income added successfully!'),
          backgroundColor: _incomeGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save income: $e'),
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
      initialChildSize: 0.88,
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
              left: 20,                   // ✅ reduced from 24
              right: 20,                  // ✅ reduced from 24
              top: 16,                    // ✅ reduced from 24
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
              const SizedBox(height: 16),

              // ── Header row ────────────────────────────────────────────
              // FIX: Icon + title + optional delete — all in one Row.
              // Icon and delete are fixed-width; title takes remaining space via Expanded.
              Row(
                children: [
                  // Fixed-size icon badge
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _incomeGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _isEditing
                          ? Icons.edit_outlined
                          : Icons.arrow_downward,
                      color: _incomeGreen,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),

                  // ✅ Expanded absorbs all remaining width — prevents right overflow
                  Expanded(
                    child: Text(
                      _isEditing ? 'Update Income' : 'Add Income',
                      style: theme.textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),

                  // Delete icon only visible in edit mode
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
              const SizedBox(height: 16),

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
                    hintText: 'e.g. Monthly Salary...'),
              ),
              const SizedBox(height: 12),

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
              const SizedBox(height: 12),

              // ── Source ────────────────────────────────────────────────
              Text('Source',
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
                  value: _selectedSource,
                  isExpanded: true,
                  dropdownColor: isDark
                      ? AppTheme.darkSurface
                      : Colors.white,
                  underline: const SizedBox(),
                  style: theme.textTheme.bodyLarge,
                  items: incomeSources.map((source) {
                    return DropdownMenuItem(
                      value: source,
                      child: Row(
                        children: [
                          const Icon(Icons.circle,
                              color: _incomeGreen, size: 10),
                          const SizedBox(width: 8),
                          Text(source),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedSource = val);
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),

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
              const SizedBox(height: 20),

              // ── Save Button ───────────────────────────────────────────
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _incomeGreen,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _isSaving
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
                    : Text(
                  _isEditing ? 'Update Income' : 'Add Income',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}