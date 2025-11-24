import 'package:flutter/material.dart';
import '../models/expense.dart';

class ExpenseProvider with ChangeNotifier {
  final List<Expense> _expenses = [
    // Dummy data
    Expense(
      title: 'Groceries',
      amount: 50.0,
      date: DateTime.now(),
      category: Category.food,
    ),
    Expense(
      title: 'Uber',
      amount: 15.0,
      date: DateTime.now().subtract(const Duration(days: 1)),
      category: Category.transport,
    ),
  ];

  List<Expense> get expenses => _expenses;

  void addExpense(Expense expense) {
    _expenses.add(expense);
    notifyListeners();
  }

  double get totalExpenses {
    return _expenses.fold(0.0, (sum, item) => sum + item.amount);
  }

  Map<Category, double> get categoryTotals {
    Map<Category, double> totals = {};
    for (var expense in _expenses) {
      if (totals.containsKey(expense.category)) {
        totals[expense.category] = totals[expense.category]! + expense.amount;
      } else {
        totals[expense.category] = expense.amount;
      }
    }
    return totals;
  }
}
