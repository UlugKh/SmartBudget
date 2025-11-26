import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/payment.dart';
import '../util/appbar.dart';
import 'add_payment_page.dart';

enum TimePeriod { today, month, year }

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  TimePeriod _selectedPeriod = TimePeriod.today;
  late Box _paymentsBox;

  @override
  void initState() {
    super.initState();
    if (Hive.isBoxOpen('payments')) {
      _paymentsBox = Hive.box('payments');
    } else {
      _openBox();
    }
  }

  Future<void> _openBox() async {
    _paymentsBox = await Hive.openBox('payments');
    if (mounted) setState(() {});
  }

  bool _filterByPeriod(Payment p, DateTime now) {
    switch (_selectedPeriod) {
      case TimePeriod.today:
        return p.date.year == now.year &&
            p.date.month == now.month &&
            p.date.day == now.day;
      case TimePeriod.month:
        return p.date.year == now.year && p.date.month == now.month;
      case TimePeriod.year:
        return p.date.year == now.year;
    }
  }

  double _calculateTotal(List<Payment> payments, bool isIncome) {
    final now = DateTime.now();
    return payments
        .where((p) => _filterByPeriod(p, now) && p.isIncome == isIncome)
        .fold(0.0, (sum, p) => sum + p.amount);
  }

  @override
  Widget build(BuildContext context) {
    if (!Hive.isBoxOpen('payments')) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartBudget'),
        automaticallyImplyLeading: false,
      ),
      body: ValueListenableBuilder(
        valueListenable: _paymentsBox.listenable(),
        builder: (context, Box box, _) {
          final allPayments = box.values
              .map((e) => Payment.fromMap(Map<String, dynamic>.from(e)))
              .toList();

          // Sort by date descending
          allPayments.sort((a, b) => b.date.compareTo(a.date));

          final now = DateTime.now();
          final filteredPayments = allPayments
              .where((p) => _filterByPeriod(p, now))
              .toList();

          final totalIncome = _calculateTotal(allPayments, true);
          final totalExpense = _calculateTotal(allPayments, false);

          return Column(
            children: [
              const SizedBox(height: 20),

              // Time Period Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPeriodButton('Today', TimePeriod.today),
                  const SizedBox(width: 8),
                  _buildPeriodButton('Month', TimePeriod.month),
                  const SizedBox(width: 8),
                  _buildPeriodButton('Year', TimePeriod.year),
                ],
              ),

              const SizedBox(height: 20),

              // Summary Containers
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'Income',
                        totalIncome,
                        Colors.green,
                        Icons.arrow_downward,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSummaryCard(
                        'Expense',
                        totalExpense,
                        Colors.red,
                        Icons.arrow_upward,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // List Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Recent Transactions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // List
              Expanded(
                child: filteredPayments.isEmpty
                    ? const Center(
                        child: Text('No transactions for this period'),
                      )
                    : ListView.builder(
                        itemCount: filteredPayments.length,
                        itemBuilder: (context, index) {
                          final payment = filteredPayments[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: payment.isIncome
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              child: Icon(
                                payment.isIncome
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color: payment.isIncome
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                            title: Text(payment.category),
                            subtitle: Text(
                              payment.note.isNotEmpty
                                  ? payment.note
                                  : payment.date.toString().split(' ')[0],
                            ),
                            trailing: Text(
                              '${payment.isIncome ? "+" : "-"}\$${payment.amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: payment.isIncome
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: bottomNavBar(context),
    );
  }

  Widget _buildPeriodButton(String text, TimePeriod period) {
    final isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = period;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}
