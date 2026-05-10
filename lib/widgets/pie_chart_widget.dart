import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/expense_model.dart';
import '../theme/app_theme.dart';

class ExpensePieChart extends StatefulWidget {
  final Map<String, double> expensesByCategory;

  const ExpensePieChart({super.key, required this.expensesByCategory});

  @override
  State<ExpensePieChart> createState() => _ExpensePieChartState();
}

class _ExpensePieChartState extends State<ExpensePieChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.expensesByCategory.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pie_chart_outline,
                  size: 48, color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary),
              const SizedBox(height: 8),
              Text('No expense data',
                  style: TextStyle(
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary)),
            ],
          ),
        ),
      );
    }

    final total = widget.expensesByCategory.values.fold(0.0, (a, b) => a + b);
    final sections = <PieChartSectionData>[];
    int i = 0;

    widget.expensesByCategory.forEach((category, amount) {
      final pct = amount / total * 100;
      final isTouched = i == _touchedIndex;
      final color = categoryColors[category] ?? const Color(0xFF9B59B6);

      sections.add(PieChartSectionData(
        value: amount,
        color: color,
        radius: isTouched ? 80 : 65,
        title: isTouched ? '' : (pct >= 10 ? '${pct.toStringAsFixed(0)}%' : ''),
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
        badgeWidget: isTouched
            ? _BadgeWidget(category: category, amount: amount)
            : null,
        badgePositionPercentageOffset: 1.3,
      ));
      i++;
    });

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: Row(
            children: [
              Expanded(
                child: PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        if (event is FlTapUpEvent || event is FlLongPressEnd) {
                          setState(() {
                            if (response?.touchedSection != null) {
                              final idx = response!.touchedSection!.touchedSectionIndex;
                              _touchedIndex = _touchedIndex == idx ? null : idx;
                            } else {
                              _touchedIndex = null;
                            }
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.expensesByCategory.entries.map((entry) {
                  final color = categoryColors[entry.key] ?? const Color(0xFF9B59B6);
                  final pct = entry.value / total * 100;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${entry.key} ${pct.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BadgeWidget extends StatelessWidget {
  final String category;
  final double amount;

  const _BadgeWidget({required this.category, required this.amount});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Text(
        '$category : Rs. ${amount.toStringAsFixed(0)}',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : AppTheme.lightTextPrimary,
        ),
      ),
    );
  }
}