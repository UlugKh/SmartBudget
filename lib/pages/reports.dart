import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../data/local/payment_dao.dart';
import '../models/payment.dart';

/// Report can be shown for a whole month or a specific week.
enum ReportMode {
  month,
  week,
}

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final PaymentDao _dao = PaymentDao();

  /// Current mode: monthly or weekly
  ReportMode _mode = ReportMode.month;

  /// Date that defines the current period (month or week).
  /// For month: any day in that month.
  /// For week: any day in that week.
  DateTime _anchorDate = DateTime.now();

  /// Income per bucket for the bar chart
  ///  - Week mode: 7 values (Mon..Sun)
  ///  - Month mode: 4 values (W1..W4)
  List<double> _incomeBars = [];

  /// Expenses per bucket for the bar chart (stored as positive numbers)
  List<double> _expenseBars = [];

  /// Labels for each bar.
  ///  - Week mode: ["Mon", "Tue", ...]
  ///  - Month mode: ["W1", "W2", "W3", "W4"]
  List<String> _barLabels = [];

  /// Expenses per category (for pie chart).
  Map<String, double> _categoryExpenses = {};

  /// Totals for the selected period.
  double _totalIncome = 0.0;
  double _totalExpenses = 0.0;
  double _netTotal = 0.0;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadForCurrentPeriod();
  }

  // ---------------------------------------------------------------------------
  // DATE HELPERS
  // ---------------------------------------------------------------------------

  /// Start of the week (Monday) for [_anchorDate]
  DateTime get _weekStart {
    final d = DateTime(_anchorDate.year, _anchorDate.month, _anchorDate.day);
    return d.subtract(Duration(days: d.weekday - 1)); // weekday: Mon=1..Sun=7
  }

  /// End of the week (Sunday) for [_anchorDate]
  DateTime get _weekEnd => _weekStart.add(const Duration(days: 6));

  /// Nicely formatted label for a week, e.g. "Nov 24–30, 2025"
  String _formatWeekLabel(DateTime startOfWeek) {
    final end = startOfWeek.add(const Duration(days: 6));

    final sameMonth = startOfWeek.month == end.month;
    final sameYear = startOfWeek.year == end.year;

    if (sameYear && sameMonth) {
      // Example: "Nov 24–30, 2025"
      return '${DateFormat('MMM d').format(startOfWeek)}–'
          '${DateFormat('d, y').format(end)}';
    } else if (sameYear) {
      // Example: "Nov 28 – Dec 4, 2025"
      return '${DateFormat('MMM d').format(startOfWeek)} – '
          '${DateFormat('MMM d, y').format(end)}';
    } else {
      // Cross-year week (rare but possible)
      return '${DateFormat('MMM d, y').format(startOfWeek)} – '
          '${DateFormat('MMM d, y').format(end)}';
    }
  }

  // ---------------------------------------------------------------------------
  // LOAD DATA FOR CURRENT PERIOD (MONTH / WEEK)
  // ---------------------------------------------------------------------------
  Future<void> _loadForCurrentPeriod() async {
    setState(() {
      _loading = true;
    });

    double incomeTotal = 0.0;
    double expenseTotal = 0.0;

    late List<double> incomeBuckets;
    late List<double> expenseBuckets;
    late List<String> labels;

    final Map<String, double> catExpenses = {};

    try {
      final allPayments = await _dao.getAllPayments();

      late final List<Payment> payments;
      if (_mode == ReportMode.month) {
        payments = allPayments.where((p) {
          return p.date.year == _anchorDate.year &&
              p.date.month == _anchorDate.month;
        }).toList();
      } else {
        final start = _weekStart;
        final end = _weekEnd;
        payments = allPayments.where((p) {
          final d = DateTime(p.date.year, p.date.month, p.date.day);
          return !d.isBefore(start) && !d.isAfter(end);
        }).toList();
      }

      if (_mode == ReportMode.week) {
        incomeBuckets = List.filled(7, 0.0);
        expenseBuckets = List.filled(7, 0.0);
        labels = const ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
      } else {
        incomeBuckets = List.filled(4, 0.0);
        expenseBuckets = List.filled(4, 0.0);
        labels = const ["W1", "W2", "W3", "W4"];
      }

      for (final p in payments) {
        // overall totals
        if (p.isIncome) {
          incomeTotal += p.amount;
        } else {
          expenseTotal += p.amount;
          final key = p.category.name;
          catExpenses[key] = (catExpenses[key] ?? 0) + p.amount;
        }

        // bucket index
        int idx;
        if (_mode == ReportMode.week) {
          idx = p.date.weekday - 1; // 0..6
        } else {
          idx = (p.date.day - 1) ~/ 7; // 0..?
          if (idx > 3) idx = 3; // clamp into W4
        }

        if (p.isIncome) {
          incomeBuckets[idx] += p.amount;
        } else {
          expenseBuckets[idx] += p.amount;
        }
      }
    } catch (e, st) {
      debugPrint('Error loading reports: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load reports: $e')),
        );
      }
    } finally {
      if (!mounted) return;
      setState(() {
        _totalIncome = incomeTotal;
        _totalExpenses = expenseTotal;
        _netTotal = incomeTotal - expenseTotal;

        _incomeBars = incomeBuckets;
        _expenseBars = expenseBuckets;
        _barLabels = labels;
        _categoryExpenses = catExpenses;

        _loading = false;
      });
    }
  }

  void _switchMode(ReportMode mode) {
    if (_mode == mode) return;
    setState(() {
      _mode = mode;
    });
    _loadForCurrentPeriod();
  }

  void _goToPreviousPeriod() {
    setState(() {
      if (_mode == ReportMode.month) {
        _anchorDate = DateTime(
          _anchorDate.year,
          _anchorDate.month - 1,
          _anchorDate.day,
        );
      } else {
        _anchorDate = _anchorDate.subtract(const Duration(days: 7));
      }
    });
    _loadForCurrentPeriod();
  }

  void _goToNextPeriod() {
    setState(() {
      if (_mode == ReportMode.month) {
        _anchorDate = DateTime(
          _anchorDate.year,
          _anchorDate.month + 1,
          _anchorDate.day,
        );
      } else {
        _anchorDate = _anchorDate.add(const Duration(days: 7));
      }
    });
    _loadForCurrentPeriod();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reports"),
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --------------------------------------------------
            //   MODE + PERIOD (stacked label)
            // --------------------------------------------------
            Row(
              children: [
                ChoiceChip(
                  label: const Text('Month',
                      style: TextStyle(fontSize: 13)),
                  selected: _mode == ReportMode.month,
                  onSelected: (_) => _switchMode(ReportMode.month),
                  materialTapTargetSize:
                  MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 6),
                ChoiceChip(
                  label: const Text('Week',
                      style: TextStyle(fontSize: 13)),
                  selected: _mode == ReportMode.week,
                  onSelected: (_) => _switchMode(ReportMode.week),
                  materialTapTargetSize:
                  MaterialTapTargetSize.shrinkWrap,
                ),
                const Spacer(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: _goToPreviousPeriod,
                      icon: const Icon(Icons.chevron_left),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          _mode == ReportMode.month
                              ? DateFormat('MMMM')
                              .format(_anchorDate) // "November"
                              : _formatWeekLabel(_weekStart)
                              .split(',')
                              .first, // "Nov 24–30"
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          _anchorDate.year.toString(),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: _goToNextPeriod,
                      icon: const Icon(Icons.chevron_right),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ---------------------------
            //   SUMMARY + CHARTS
            // ---------------------------
            const Text(
              "Summary",
              style:
              TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildSummaryCard(),

            const SizedBox(height: 28),
            Text(
              _mode == ReportMode.week
                  ? "Income & expenses per weekday"
                  : "Income & expenses per week",
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildIncomeExpenseChart(),

            const SizedBox(height: 28),
            const Text(
              "Spending by category",
              style:
              TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildCategoryPieChart(),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SUMMARY CARD  (Income / Expenses / Net)
  // ---------------------------------------------------------------------------
  Widget _buildSummaryCard() {
    final netColor =
    _netTotal >= 0 ? Colors.green.shade700 : Colors.red.shade700;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _mode == ReportMode.month ? "This month" : "This week",
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Income
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Income",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  Text(
                    "+\$${_totalIncome.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              // Expenses
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Expenses",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  Text(
                    "-\$${_totalExpenses.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              // Net
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    "Net",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  Text(
                    (_netTotal >= 0 ? "+\$" : "-\$") +
                        _netTotal.abs().toStringAsFixed(2),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: netColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // INCOME vs EXPENSE BAR CHART
  // ---------------------------------------------------------------------------
  Widget _buildIncomeExpenseChart() {
    if (_incomeBars.isEmpty || _expenseBars.isEmpty) {
      return const Center(child: Text('No data for this period'));
    }

    final bucketCount = _incomeBars.length;

    // Find biggest magnitude for symmetric Y axis
    double biggest = 0;
    for (var i = 0; i < bucketCount; i++) {
      biggest = max(biggest, _incomeBars[i].abs());
      biggest = max(biggest, _expenseBars[i].abs());
    }

    if (biggest == 0) {
      return const Center(child: Text('No data for this period'));
    }

    final double maxY = biggest * 1.2;
    final double minY = -maxY;

    return SizedBox(
      height: 230,
      child: BarChart(
        BarChartData(
          minY: minY,
          maxY: maxY,
          barGroups: List.generate(bucketCount, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                // Income up
                BarChartRodData(
                  toY: _incomeBars[i],
                  width: 10,
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
                // Expenses down
                BarChartRodData(
                  toY: -_expenseBars[i],
                  width: 10,
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) =>
                    Text(value.toInt().toString()),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= _barLabels.length) {
                    return const SizedBox.shrink();
                  }
                  return Text(_barLabels[i]);
                },
              ),
            ),
            topTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // CATEGORY PIE CHART (expenses only)
  // ---------------------------------------------------------------------------
  Widget _buildCategoryPieChart() {
    if (_categoryExpenses.isEmpty) {
      return const Center(child: Text('No expenses for this period'));
    }

    final total = _categoryExpenses.values.fold<double>(
      0.0,
          (sum, v) => sum + v,
    );

    return SizedBox(
      height: 260,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: _categoryExpenses.entries.map((e) {
            final percent = (e.value / total * 100).toStringAsFixed(0);
            return PieChartSectionData(
              value: e.value,
              title: '$percent%',
              radius: 70,
              showTitle: true,
            );
          }).toList(),
        ),
      ),
    );
  }
}
