import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/local/payment_dao.dart';
import '../models/payment.dart';
import 'package:intl/intl.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final PaymentDao _dao = PaymentDao();

  List<double> weeklySpending = List.filled(7, 0.0); // Mon-Sun
  Map<String, double> categorySpending = {};
  double monthlyTotal = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Current month in YYYY-MM format
    final now = DateTime.now();
    final yearMonth = DateFormat('yyyy-MM').format(now);

    // Get all payments for the month
    final payments = await _dao.getPaymentsByMonth(yearMonth);

    // Calculate monthly total
    double total = 0.0;
    for (var p in payments) {
      total += p.amount;
    }

    // Calculate weekly totals (Mon-Sun)
    List<double> weekly = List.filled(7, 0.0);
    for (var p in payments) {
      int weekdayIndex = p.date.weekday - 1; // Mon=0, Sun=6
      weekly[weekdayIndex] += p.amount;
    }

    // Calculate totals per category
    Map<String, double> categories = {};
    for (var p in payments) {
      final key = p.category.name;
      categories[key] = (categories[key] ?? 0) + p.amount;
    }

    setState(() {
      monthlyTotal = total;
      weeklySpending = weekly;
      categorySpending = categories;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reports"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Monthly Summary",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildSummaryCard(),

            const SizedBox(height: 28),
            const Text(
              "Weekly Spending",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildWeeklyBarChart(),

            const SizedBox(height: 28),
            const Text(
              "Category Breakdown",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildCategoryPieChart(),
          ],
        ),
      ),
    );
  }

  // SUMMARY CARD
  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "This Month",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              Text(
                "\$${monthlyTotal.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Icon(Icons.trending_up, size: 40, color: Colors.blue),
        ],
      ),
    );
  }

  // WEEKLY BAR CHART
  Widget _buildWeeklyBarChart() {
    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          barGroups: weeklySpending
              .asMap()
              .entries
              .map(
                (e) => BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value,
                  width: 18,
                  color: Colors.blue,
                ),
              ],
            ),
          )
              .toList(),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
                  return Text(days[value.toInt()]);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // CATEGORY PIE CHART
  Widget _buildCategoryPieChart() {
    return SizedBox(
      height: 250,
      child: PieChart(
        PieChartData(
          sections: categorySpending.entries
              .map(
                (e) => PieChartSectionData(
              value: e.value,
              title: e.key,
              radius: 60,
            ),
          )
              .toList(),
        ),
      ),
    );
  }
}
