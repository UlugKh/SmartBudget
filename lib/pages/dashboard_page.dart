import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';
import 'add_expense_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SmartBudget Dashboard')),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          final total = provider.totalExpenses;
          final expenses = provider.expenses;

          return Column(
            children: [
              // Summary Card
              Card(
                margin: const EdgeInsets.all(16),
                elevation: 4,
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        'Total Expenses',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '\$${total.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.displayMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                            ),
                      ),
                    ],
                  ),
                ),
              ),

              // Recent Expenses Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Recent Expenses',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),

              // Expenses List
              Expanded(
                child: expenses.isEmpty
                    ? const Center(child: Text('No expenses yet!'))
                    : ListView.builder(
                        itemCount: expenses.length,
                        itemBuilder: (context, index) {
                          // Show newest first
                          final expense = expenses[expenses.length - 1 - index];
                          return ListTile(
                            leading: CircleAvatar(
                              child: Icon(_getCategoryIcon(expense.category)),
                            ),
                            title: Text(expense.title),
                            subtitle: Text(expense.formattedDate),
                            trailing: Text(
                              '-\$${expense.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddExpensePage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  IconData _getCategoryIcon(Category category) {
    switch (category) {
      case Category.food:
        return Icons.fastfood;
      case Category.transport:
        return Icons.directions_car;
      case Category.shopping:
        return Icons.shopping_bag;
      case Category.other:
        return Icons.category;
    }
  }
}
