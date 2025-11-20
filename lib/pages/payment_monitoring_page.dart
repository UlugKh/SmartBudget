import 'package:flutter/material.dart';
import '../models/payment.dart';

class PaymentMonitoringPage extends StatefulWidget {
  const PaymentMonitoringPage({super.key});

  @override
  State<PaymentMonitoringPage> createState() => _PaymentMonitoringPageState();
}

class _PaymentMonitoringPageState extends State<PaymentMonitoringPage> {
  final List<Payment> _payments = [];

  @override
  void initState() {
    super.initState();
    _exampleData();
  }

  void _exampleData() {
    _payments.addAll([
      Payment(
        id: '1',
        amount: 25000,
        category: 'Mini Lavash',
        note: 'Lunch with homies',
        date: DateTime.now().subtract(const Duration(hours: 2)),
        isIncome: false,
      ),
      Payment(
        id: '2',
        amount: 1700,
        category: 'Transport',
        note: 'Bus card',
        date: DateTime.now().subtract(const Duration(days: 1)),
        isIncome: false,
      ),
      Payment(
        id: '3',
        amount: 200000,
        category: 'Allowance',
        note: 'Weekly allowance',
        date: DateTime.now().subtract(const Duration(days: 3)),
        isIncome: true,
      ),
    ]);
  }

  double get _totalThisMonth {
    final now = DateTime.now();
    return _payments
        .where((p) =>
    p.date.year == now.year &&
        p.date.month == now.month &&
        !p.isIncome)
        .fold(0, (sum, p) => sum + p.amount);
  }

  double get _totalToday {
    final now = DateTime.now();
    return _payments
        .where((p) =>
    p.date.year == now.year &&
        p.date.month == now.month &&
        p.date.day == now.day &&
        !p.isIncome)
        .fold(0, (sum, p) => sum + p.amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Monitoring'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          _buildSummaryCard(),
          const SizedBox(height: 16),
          Expanded(child: _buildPaymentList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'This month',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_totalThisMonth.toStringAsFixed(0)} UZS',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'Today',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_totalToday.toStringAsFixed(0)} UZS',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentList() {
    if (_payments.isEmpty) {
      return const Center(
        child: Text('No payments yet'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _payments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final payment = _payments[index];
        return _buildPaymentTile(payment);
      },
    );
  }

  Widget _buildPaymentTile(Payment payment) {
    final isIncome = payment.isIncome;
    final amountText =
        (isIncome ? '+ ' : '- ') + payment.amount.toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: isIncome ? Colors.greenAccent : Colors.redAccent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.category,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  payment.note,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amountText,
                style: TextStyle(
                  color: isIncome ? Colors.greenAccent : Colors.redAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatDate(payment.date),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}';
  }
}
