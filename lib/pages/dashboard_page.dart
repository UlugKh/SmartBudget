import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/payment_provider.dart';
import '../models/payment.dart';
import 'reports.dart';

/// DashboardPage
///
/// It shows:
///  - Total expenses (sum of all non-income payments)
///  - A list of all recent payments
///  - A floating button to quickly open the Reports screen
///
/// The data comes from **PaymentProvider**, which loads from SQLite.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SmartBudget Dashboard')),

      /// Consumer listens to PaymentProvider.
      /// Whenever payments are loaded from SQLite or updated,
      /// this widget rebuilds automatically.
      body: Consumer<PaymentProvider>(
        builder: (context, provider, child) {
          final total = provider.totalExpenses; // total spent (expenses only)
          final payments = provider.payments;   // all payments from database

          return Column(
            children: [
              // ---------------------------
              //   SUMMARY CARD
              // ---------------------------
              Card(
                margin: const EdgeInsets.all(16),
                elevation: 4,
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Title label
                      Text(
                        'Total Spent',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),

                      // Total spent value
                      Text(
                        '\$${total.toStringAsFixed(2)}',
                        style: Theme.of(context)
                            .textTheme
                            .displayMedium
                            ?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ---------------------------
              //    SECTION HEADER
              // ---------------------------
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Recent Payments',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),

              // ---------------------------
              //    PAYMENT LIST
              // ---------------------------
              Expanded(
                child: payments.isEmpty
                    ? const Center(child: Text('No payments yet!'))

                /// Show newest-first list of payments
                    : ListView.builder(
                  itemCount: payments.length,
                  itemBuilder: (context, index) {
                    final payment = payments[index];

                    return ListTile(
                      leading: CircleAvatar(
                        child: Icon(
                          _getCategoryIcon(payment.category),
                        ),
                      ),

                      // Main text: note or description
                      title: Text(payment.note),

                      // Date of the payment
                      subtitle: Text(
                        DateFormat.yMd().format(payment.date),
                      ),

                      // Amount (expense red, income green)
                      trailing: Text(
                        payment.isIncome
                            ? '+\$${payment.amount.toStringAsFixed(2)}'
                            : '-\$${payment.amount.toStringAsFixed(2)}',
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

      // ---------------------------
      //   FLOATING ACTION BUTTON
      //   (opens Reports screen)
      // ---------------------------
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          /// Opens ReportsScreen as a new route.
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ReportsScreen(),
            ),
          );
        },
        child: const Icon(Icons.insights_outlined),
      ),
    );
  }

  /// Returns an icon for a given payment category.
  IconData _getCategoryIcon(Category category) {
    switch (category) {
      case Category.food:
        return Icons.fastfood;
      case Category.transport:
        return Icons.directions_car;
      case Category.shopping:
        return Icons.shopping_bag;
      case Category.entertainment:
        return Icons.movie;
      case Category.other:
        return Icons.category;
    }
  }
}
