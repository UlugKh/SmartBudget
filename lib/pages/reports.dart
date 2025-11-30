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

  /// Generic net bar values for the current chart:
  ///  - Week mode: 7 values (Mon..Sun)
  ///  - Month mode: 4 values (W1..W4)
  List<double> _netBars = [];

  /// Labels for each bar in the net chart.
  ///  - Week mode: ["Mon", "Tue", ...]
  ///  - Month mode: ["W1", "W2", "W3", "W4"]
  List<String> _netBarLabels = [];

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

    // Local accumulators
    double income = 0.0;
    double expenses = 0.0;

    // These will become the values + labels for the bar chart
    late List<double> netBuckets;
    late List<String> netLabels;

    // Expenses per category for pie chart
    final Map<String, double> catExpenses = {};

    try {
      // 1) Get ALL payments from DB
      final allPayments = await _dao.getAllPayments();

      // 2) Filter by current mode (month / week) in Dart
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
          // Compare using date only (no time)
          final d = DateTime(p.date.year, p.date.month, p.date.day);
          return !d.isBefore(start) && !d.isAfter(end);
        }).toList();
      }

      // 3) Prepare buckets for net chart
      if (_mode == ReportMode.week) {
        // 7 buckets for Mon..Sun
        netBuckets = List.filled(7, 0.0);
        netLabels = const ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
      } else {
        // EXACTLY 4 weeks in a month: W1..W4
        netBuckets = List.filled(4, 0.0);
        netLabels = const ["W1", "W2", "W3", "W4"];
      }

      // 4) Aggregate numbers from filtered payments
      for (final p in payments) {
        final delta = p.isIncome ? p.amount : -p.amount;

        // income / expense totals
        if (p.isIncome) {
          income += p.amount;
        } else {
          expenses += p.amount;
          final key = p.category.name;
          catExpenses[key] = (catExpenses[key] ?? 0) + p.amount;
        }

        // net distribution into buckets for chart
        if (_mode == ReportMode.week) {
          // By weekday (Mon..Sun)
          final dayIndex = p.date.weekday - 1; // Mon=0..Sun=6
          netBuckets[dayIndex] += delta;
        } else {
          // By week of month → clamp to last bucket so days > 28 go into W4
          int weekIndex = (p.date.day - 1) ~/ 7; // 0..4
          if (weekIndex > 3) weekIndex = 3;      // keep inside 0..3
          netBuckets[weekIndex] += delta;
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
        _totalIncome = income;
        _totalExpenses = expenses;
        _netTotal = income - expenses;

        _netBars = netBuckets;
        _netBarLabels = netLabels;
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
                // ------ LEFT SIDE: Chips ------
                ChoiceChip(
                  label: const Text('Month', style: TextStyle(fontSize: 13)),
                  selected: _mode == ReportMode.month,
                  onSelected: (_) => _switchMode(ReportMode.month),
                  materialTapTargetSize:
                  MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 6),
                ChoiceChip(
                  label: const Text('Week', style: TextStyle(fontSize: 13)),
                  selected: _mode == ReportMode.week,
                  onSelected: (_) => _switchMode(ReportMode.week),
                  materialTapTargetSize:
                  MaterialTapTargetSize.shrinkWrap,
                ),

                const Spacer(),

                // ------ RIGHT SIDE: Arrows + Stacked Label ------
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: _goToPreviousPeriod,
                      icon: const Icon(Icons.chevron_left),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),

                    // ---- STACKED LABEL (2 lines) ----
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
                  ? "Net per weekday"
                  : "Net per week (this month)",
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildNetBarChart(),

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
// NET BAR CHART
//  - week mode:   net per weekday (Mon..Sun)
//  - month mode:  net per week of month (W1..W4)
// ---------------------------------------------------------------------------
  Widget _buildNetBarChart() {
    if (_netBars.isEmpty) {
      return const Center(
        child: Text('No data for this period'),
      );
    }

    double minY = 0;
    double maxY = 0;

    for (final v in _netBars) {
      minY = min(minY, v);
      maxY = max(maxY, v);
    }

    if (minY == 0 && maxY == 0) {
      return const Center(
        child: Text('No data for this period'),
      );
    }

    final double padding = max(maxY.abs(), minY.abs()) * 0.2;
    minY -= padding;
    maxY += padding;

    // ----- choose a "nice" interval so labels don't overlap -----
    double range = maxY - minY;
    if (range <= 0) range = maxY.abs();
    if (range == 0) range = 1;

    // target ≈ 5 lines → 4 intervals
    final double rawStep = range / 4;

    double _niceStep(double step) {
      final double magnitude =
      pow(10, (log(step) / ln10).floor()).toDouble(); // 1,10,100,..
      final double residual = step / magnitude;
      double nice;
      if (residual <= 1) {
        nice = 1;
      } else if (residual <= 2) {
        nice = 2;
      } else if (residual <= 5) {
        nice = 5;
      } else {
        nice = 10;
      }
      return nice * magnitude;
    }

    final double yStep = _niceStep(rawStep);

    return SizedBox(
      height: 230,
      child: BarChart(
        BarChartData(
          minY: minY,
          maxY: maxY,
          barGroups: _netBars
              .asMap()
              .entries
              .map(
                (e) => BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value,
                  width: 18,
                  color: e.value >= 0 ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          )
              .toList(),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: yStep, // grid + labels every yStep
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 11),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= _netBarLabels.length) {
                    return const SizedBox.shrink();
                  }
                  return Text(_netBarLabels[i]);
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
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
