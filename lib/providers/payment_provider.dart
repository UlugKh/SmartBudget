import 'package:flutter/material.dart';
import '../models/payment.dart';
import '../data/local/payment_dao.dart';

/// PaymentProvider
///
/// This is the main state manager for payments in the app.
/// It:
///  - Loads payments from SQLite on startup (through PaymentDao)
///  - Seeds dummy data into the DB the very first time (if table is empty)
///  - Exposes a list of payments to the UI
///  - Allows adding new payments (and writes them to SQLite)
///  - Calculates totals (e.g. totalExpenses, totals per category)
///
/// All widgets that use [Consumer<PaymentProvider>] will automatically
/// rebuild when [notifyListeners()] is called.
class PaymentProvider with ChangeNotifier {
  /// Data Access Object that talks directly to SQLite.
  final PaymentDao _dao = PaymentDao();

  /// In-memory cache of all loaded payments.
  /// This is what the UI reads from.
  final List<Payment> _payments = [];

  /// Indicates whether initial loading from the database is finished.
  /// While this is false, [isLoading] will be true.
  bool _initialized = false;

  /// Constructor:
  /// When the provider is created, we immediately start loading payments
  /// from SQLite in the background.
  PaymentProvider() {
    _loadPayments();
  }

  /// Load all payments from the database.
  ///
  /// - If the DB is empty on first run, we create dummy example data,
  ///   insert it into SQLite, and also keep it in memory.
  /// - If the DB has data, we just load it into the in-memory list.
  Future<void> _loadPayments() async {
    // Fetch all payments from SQLite via DAO
    final fromDb = await _dao.getAllPayments();

    if (fromDb.isEmpty) {
      // If there are no rows yet, this is probably the first time the app runs.
      // Seed DB with some dummy example payments.
      final examples = _createDummyPayments();
      for (final p in examples) {
        await _dao.insertPayment(p);
      }

      // Update in-memory list with dummy data
      _payments.addAll(examples);
    } else {
      // DB already has data → just load it into memory
      _payments.addAll(fromDb);
    }

    // ensure newest-first in memory
    _sortPayments();

    // Mark provider as initialized (not loading anymore)
    _initialized = true;

    // Notify all listeners (widgets) that data is ready / updated
    notifyListeners();
  }

  void _sortPayments() {
    // Newest first
    _payments.sort((a, b) => b.date.compareTo(a.date));
  }

  /// Public read-only view of payments.
  ///
  /// Using List.unmodifiable() so widgets cannot accidentally modify
  /// the internal list without going through the provider.
  List<Payment> get payments => List.unmodifiable(_payments);

  /// True while loading initial data from the database.
  bool get isLoading => !_initialized;

  /// Add a new payment.
  ///
  /// This:
  ///  - Inserts it into SQLite via [PaymentDao.insertPayment]
  ///  - Adds it to the in-memory list
  ///  - Notifies listeners so UI updates immediately
  Future<void> addPayment(Payment payment) async {
    // Persist to SQLite
    await _dao.insertPayment(payment);

    // Update in-memory cache
    _payments.add(payment);

    // Keep list newest-first
    _sortPayments();

    // Trigger UI rebuild
    notifyListeners();
  }

  /// Update an existing payment.
  Future<void> updatePayment(Payment payment) async {
    await _dao.updatePayment(payment);

    final index = _payments.indexWhere((p) => p.id == payment.id);
    if (index != -1) {
      _payments[index] = payment;
      _sortPayments();
      notifyListeners();
    }
  }

  /// Delete a payment by ID.
  Future<void> deletePayment(String id) async {
    await _dao.deletePayment(id);

    _payments.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  /// Total expenses (sum of amounts where isIncome == false).
  ///
  /// This is used by the Dashboard summary card and can be reused
  /// anywhere we need a "total spent" number.
  double get totalExpenses {
    return _payments
        .where((p) => !p.isIncome) // only expenses
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  /// Total spending per category (only expenses, not income).
  ///
  /// Returns a map:
  ///   Category -> total amount spent in that category
  ///
  /// Can be used for charts or breakdowns in the UI.
  Map<Category, double> get categoryTotals {
    final Map<Category, double> totals = {};
    for (var payment in _payments.where((p) => !p.isIncome)) {
      if (totals.containsKey(payment.category)) {
        totals[payment.category] = totals[payment.category]! + payment.amount;
      } else {
        totals[payment.category] = payment.amount;
      }
    }
    return totals;
  }

  /// Total expenses for the current month.
  double get totalExpensesCurrentMonth {
    final now = DateTime.now();
    return _payments
        .where(
          (p) =>
              !p.isIncome &&
              p.date.year == now.year &&
              p.date.month == now.month,
        )
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  /// Top spending category for the current month.
  MapEntry<Category, double>? get topCategoryCurrentMonth {
    final now = DateTime.now();
    final expenses = _payments.where(
      (p) =>
          !p.isIncome && p.date.year == now.year && p.date.month == now.month,
    );

    if (expenses.isEmpty) return null;

    final Map<Category, double> totals = {};
    for (var p in expenses) {
      totals[p.category] = (totals[p.category] ?? 0) + p.amount;
    }

    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first;
  }

  /// Creates some example payments for first run.
  ///
  /// These are only inserted if the payments table is empty
  /// when the app is launched.
  List<Payment> _createDummyPayments() {
    final now = DateTime.now();

    return [
      Payment(
        id: '1',
        amount: 50.0,
        category: Category.food,
        note: 'Groceries',
        date: now,
        isIncome: false,
        isSaving: false,
      ),
      Payment(
        id: '2',
        amount: 15.0,
        category: Category.transport,
        note: 'Uber',
        date: now.subtract(const Duration(days: 1)),
        isIncome: false,
        isSaving: false,
      ),
      Payment(
        id: '3',
        amount: 200.0,
        category: Category.entertainment,
        note: 'Cinema + snacks',
        date: now.subtract(const Duration(days: 3)),
        isIncome: false,
        isSaving: false,
      ),
    ];
  }
}
