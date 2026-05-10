import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/expense_model.dart';
import '../models/income_model.dart';
import '../theme/app_theme.dart';
import 'settings_screen.dart';
import '../widgets/pie_chart_widget.dart';
import '../widgets/add_expense_sheet.dart';
import '../widgets/add_income_sheet.dart';
import 'package:intl/intl.dart';

// ─── Constants ────────────────────────────────────────────────────────────────

const _kGreen = Color(0xFF2ECC71);
const _kRed = Color(0xFFFF6B6B);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String _selectedFilter = 'All';
  String _selectedCategory = 'All Categories';

  final List<String> _filters = [
    'All', 'Daily', 'Weekly', 'Monthly', 'Yearly'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ─── Greeting helpers ──────────────────────────────────────────────────────

  String _getGreeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getGreetingEmoji() {
    final h = DateTime.now().hour;
    if (h < 12) return '☀️';
    if (h < 17) return '👋';
    return '🌙';
  }

  String _getMotivationalLine(int count) {
    if (count == 0) return 'Start tracking your expenses today!';
    if (count < 5) return 'Great start! Keep tracking.';
    if (count < 20) return 'You\'re building good habits!';
    return 'You\'re on top of your finances!';
  }

  String _formatAmount(double amount) {
    if (amount >= 1000) {
      final f = NumberFormat('#,###', 'en_US');
      return f.format(amount);
    }
    return amount.toStringAsFixed(0);
  }

  // ─── Bottom sheets ─────────────────────────────────────────────────────────

  void _showAddExpense() => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const AddExpenseSheet(),
  );

  void _showAddIncome() => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const AddIncomeSheet(),
  );

  // ─── Edit sheets ───────────────────────────────────────────────────────────

  void _showEditExpense(ExpenseModel expense) =>
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => AddExpenseSheet(expense: expense),
      );

  void _showEditIncome(IncomeModel income) =>
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => AddIncomeSheet(income: income),
      );

  // ─── Delete confirmations ──────────────────────────────────────────────────

  Future<void> _confirmDeleteExpense(
      BuildContext context, ExpenseModel expense) async {
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
          'Are you sure you want to delete "${expense.title}"?\nThis action cannot be undone.',
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
            .deleteExpense(expense.id);
        if (!context.mounted) return;
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

  Future<void> _confirmDeleteIncome(
      BuildContext context, IncomeModel income) async {
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
          'Are you sure you want to delete "${income.title}"?\nThis action cannot be undone.',
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
            .deleteIncome(income.id);
        if (!context.mounted) return;
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

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = context.watch<AppProvider>();
    final user = provider.currentUser;

    final isExpenseTab = _tabController.index == 0;

    final filteredExpenses =
    provider.getFilteredExpenses(_selectedFilter);
    final filteredIncomes =
    provider.getFilteredIncomes(_selectedFilter);

    final displayedExpenses = _selectedCategory == 'All Categories'
        ? filteredExpenses
        : filteredExpenses
        .where((e) => e.category == _selectedCategory)
        .toList();

    return Scaffold(
      backgroundColor:
      isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [

            // ── Header Card ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isExpenseTab
                        ? [
                      const Color(0xFF3B5BDB),
                      const Color(0xFF4C6EF5),
                    ]
                        : [
                      const Color(0xFF1A8B4B),
                      const Color(0xFF2ECC71),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (isExpenseTab
                          ? AppTheme.primaryBlue
                          : _kGreen)
                          .withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Greeting + settings ───────────────────────────────
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '${_getGreeting()}, ',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    _getGreetingEmoji(),
                                    style: const TextStyle(
                                        fontSize: 13),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                user?.name ?? 'User',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.2,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _getMotivationalLine(
                                    provider.transactionCount),
                                style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) =>
                                const SettingsScreen()),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color:
                              Colors.white.withOpacity(0.15),
                              borderRadius:
                              BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.settings,
                                color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── Net Balance ───────────────────────────────────────
                    const Text(
                      'Net Balance',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Rs. ${_formatAmount(provider.netBalance.abs())}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (provider.netBalance < 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _kRed.withOpacity(0.25),
                              borderRadius:
                              BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Deficit',
                              style: TextStyle(
                                color: _kRed,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          )
                        else if (provider.netBalance > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _kGreen.withOpacity(0.25),
                              borderRadius:
                              BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Surplus',
                              style: TextStyle(
                                color: _kGreen,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Stat Cards ────────────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.arrow_downward_rounded,
                            label: 'Income',
                            value:
                            'Rs. ${_formatAmount(provider.totalIncome)}',
                            color: _kGreen,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.arrow_upward_rounded,
                            label: 'Expenses',
                            value:
                            'Rs. ${_formatAmount(provider.totalExpenses)}',
                            color: _kRed,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.receipt_long,
                            label: 'Transactions',
                            value: '${provider.transactionCount}',
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Pie Chart ─────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                margin:
                const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.darkSurface
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(isDark ? 0.2 : 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Expenses by Category',
                        style: theme.textTheme.titleMedium),
                    const SizedBox(height: 16),
                    ExpensePieChart(
                      expensesByCategory:
                      provider.expensesByCategory,
                    ),
                  ],
                ),
              ),
            ),

            // ── Tab Bar ───────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding:
                const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppTheme.darkSurface
                        : const Color(0xFFF0F4FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: isExpenseTab
                          ? AppTheme.primaryBlue
                          : _kGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: Colors.white,
                    unselectedLabelColor: isDark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.lightTextSecondary,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                    tabs: const [
                      Tab(text: '💸  Expenses'),
                      Tab(text: '💰  Income'),
                    ],
                  ),
                ),
              ),
            ),

            // ── Filter Chips ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filters.map((filter) {
                      final isSelected =
                          _selectedFilter == filter;
                      final activeColor = isExpenseTab
                          ? AppTheme.primaryBlue
                          : _kGreen;
                      return GestureDetector(
                        onTap: () => setState(
                                () => _selectedFilter = filter),
                        child: AnimatedContainer(
                          duration:
                          const Duration(milliseconds: 200),
                          margin:
                          const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 9),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? activeColor
                                : (isDark
                                ? AppTheme.darkSurface
                                : Colors.white),
                            borderRadius:
                            BorderRadius.circular(20),
                            boxShadow: isSelected
                                ? [
                              BoxShadow(
                                color: activeColor
                                    .withOpacity(0.4),
                                blurRadius: 8,
                              )
                            ]
                                : null,
                          ),
                          child: Text(
                            filter,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : (isDark
                                  ? AppTheme.darkTextSecondary
                                  : AppTheme
                                  .lightTextSecondary),
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

            // ── List Header ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isExpenseTab
                          ? 'Recent Expenses'
                          : 'Recent Income',
                      style: theme.textTheme.titleMedium,
                    ),
                    if (isExpenseTab)
                      _CategoryFilter(
                        selected: _selectedCategory,
                        onChanged: (val) => setState(
                                () => _selectedCategory = val),
                      ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(
                child: SizedBox(height: 12)),

            // ── Expense List ──────────────────────────────────────────────
            if (isExpenseTab) ...[
              if (displayedExpenses.isEmpty)
                SliverToBoxAdapter(
                  child: _EmptyState(
                    icon: Icons.receipt_long_outlined,
                    message: 'No expenses yet',
                    hint: 'Tap + to add your first expense',
                    isDark: isDark,
                    theme: theme,
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final expense = displayedExpenses[index];
                      return _TransactionTile(
                        expense: expense,
                        isDark: isDark,
                        onEdit: () => _showEditExpense(expense),
                        onDelete: () => _confirmDeleteExpense(
                            context, expense),
                      );
                    },
                    childCount: displayedExpenses.length,
                  ),
                ),
            ],

            // ── Income List ───────────────────────────────────────────────
            if (!isExpenseTab) ...[
              if (filteredIncomes.isEmpty)
                SliverToBoxAdapter(
                  child: _EmptyState(
                    icon: Icons.savings_outlined,
                    message: 'No income recorded',
                    hint: 'Tap + to add your first income',
                    isDark: isDark,
                    theme: theme,
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final income = filteredIncomes[index];
                      return _IncomeTile(
                        income: income,
                        isDark: isDark,
                        onEdit: () => _showEditIncome(income),
                        onDelete: () => _confirmDeleteIncome(
                            context, income),
                      );
                    },
                    childCount: filteredIncomes.length,
                  ),
                ),
            ],

            const SliverToBoxAdapter(
                child: SizedBox(height: 100)),
          ],
        ),
      ),

      // ── Single FAB — tab-aware ────────────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        heroTag: 'primary_fab',
        onPressed:
        isExpenseTab ? _showAddExpense : _showAddIncome,
        backgroundColor:
        isExpenseTab ? AppTheme.primaryBlue : _kGreen,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String hint;
  final bool isDark;
  final ThemeData theme;

  const _EmptyState({
    required this.icon,
    required this.message,
    required this.hint,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            Icon(icon,
                size: 48,
                color: isDark
                    ? AppTheme.darkTextSecondary
                    : AppTheme.lightTextSecondary),
            const SizedBox(height: 12),
            Text(message, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 6),
            Text(hint,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

// ─── Stat Card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  color: Colors.white60, fontSize: 10)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

// ─── Transaction Tile (Expense) ───────────────────────────────────────────────

class _TransactionTile extends StatelessWidget {
  final ExpenseModel expense;
  final bool isDark;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TransactionTile({
    required this.expense,
    required this.isDark,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = DateFormat('MMM dd, yyyy');

    return GestureDetector(
      onTap: onEdit,
      child: Container(
        margin: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 5),
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withOpacity(isDark ? 0.15 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: expense.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  expense.title.isNotEmpty
                      ? expense.title[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: expense.color,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Title + category + date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(expense.title,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontSize: 15)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color:
                          expense.color.withOpacity(0.15),
                          borderRadius:
                          BorderRadius.circular(6),
                        ),
                        child: Text(
                          expense.category,
                          style: TextStyle(
                            color: expense.color,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formatter.format(expense.date),
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Amount
            Text(
              'Rs. ${expense.amount.toStringAsFixed(0)}',
              style: theme.textTheme.titleMedium?.copyWith(
                  color: _kRed, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 8),

            // Edit + Delete icons
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: onEdit,
                  child: Icon(
                    Icons.edit_outlined,
                    color: isDark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.lightTextSecondary,
                    size: 18,
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: onDelete,
                  child: Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent.withOpacity(0.7),
                    size: 18,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Income Tile ──────────────────────────────────────────────────────────────

class _IncomeTile extends StatelessWidget {
  final IncomeModel income;
  final bool isDark;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _IncomeTile({
    required this.income,
    required this.isDark,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = DateFormat('MMM dd, yyyy');

    return GestureDetector(
      onTap: onEdit,
      child: Container(
        margin: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 5),
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withOpacity(isDark ? 0.15 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _kGreen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  income.title.isNotEmpty
                      ? income.title[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: _kGreen,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Title + source + date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(income.title,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontSize: 15)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _kGreen.withOpacity(0.15),
                          borderRadius:
                          BorderRadius.circular(6),
                        ),
                        child: Text(
                          income.source,
                          style: const TextStyle(
                            color: _kGreen,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formatter.format(income.date),
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Amount
            Text(
              'Rs. ${income.amount.toStringAsFixed(0)}',
              style: theme.textTheme.titleMedium?.copyWith(
                  color: _kGreen, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 8),

            // Edit + Delete icons
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: onEdit,
                  child: Icon(
                    Icons.edit_outlined,
                    color: isDark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.lightTextSecondary,
                    size: 18,
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: onDelete,
                  child: Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent.withOpacity(0.7),
                    size: 18,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Category Filter ──────────────────────────────────────────────────────────

class _CategoryFilter extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _CategoryFilter(
      {required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = ['All Categories', ...expenseCategories];

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor:
          isDark ? AppTheme.darkSurface : Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: categories.map((cat) {
              return ListTile(
                title: Text(cat,
                    style:
                    Theme.of(context).textTheme.bodyLarge),
                trailing: selected == cat
                    ? const Icon(Icons.check,
                    color: AppTheme.primaryBlue)
                    : null,
                onTap: () {
                  onChanged(cat);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark
                ? AppTheme.darkCardAlt
                : const Color(0xFFDDE3EE),
          ),
        ),
        child: Row(
          children: [
            Text(
              selected,
              style: TextStyle(
                color: isDark
                    ? AppTheme.darkTextSecondary
                    : AppTheme.lightTextSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.filter_list,
              size: 14,
              color: isDark
                  ? AppTheme.darkTextSecondary
                  : AppTheme.lightTextSecondary,
            ),
          ],
        ),
      ),
    );
  }
}