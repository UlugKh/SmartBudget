import 'app_database.dart';
import 'package:smart_budget/models/payment.dart';

class PaymentDao {
  /// CREATE
  Future<int> insertPayment(Payment payment) async {
    final db = await AppDatabase.instance.database;
    return db.insert('payments', payment.toMap());
  }

  /// READ all payments (latest first)
  Future<List<Payment>> getAllPayments() async {
    final db = await AppDatabase.instance.database;
    final result = await db.query('payments', orderBy: 'date DESC');
    return result.map((map) => Payment.fromMap(map)).toList();
  }

  /// READ payments for a specific month (YYYY-MM)
  Future<List<Payment>> getPaymentsByMonth(String yearMonth) async {
    final db = await AppDatabase.instance.database;
    final result = await db.rawQuery(
      '''
      SELECT * FROM payments
      WHERE strftime('%Y-%m', date) = ?
      ORDER BY date DESC
      ''',
      [yearMonth],
    );
    return result.map((map) => Payment.fromMap(map)).toList();
  }

  /// READ payments for a specific week (ISO week number)
  Future<List<Payment>> getPaymentsByWeek(int year, int weekNumber) async {
    final db = await AppDatabase.instance.database;
    final result = await db.rawQuery(
      '''
      SELECT * FROM payments
      WHERE strftime('%Y', date) = ?
      AND strftime('%W', date) = ?
      ORDER BY date DESC
      ''',
      ['$year', '$weekNumber'],
    );
    return result.map((map) => Payment.fromMap(map)).toList();
  }

  /// UPDATE payment
  Future<int> updatePayment(Payment payment) async {
    final db = await AppDatabase.instance.database;
    return db.update(
      'payments',
      payment.toMap(),
      where: 'id = ?',
      whereArgs: [payment.id],
    );
  }

  /// DELETE payment
  Future<int> deletePayment(String id) async {
    final db = await AppDatabase.instance.database;
    return db.delete(
      'payments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// GET totals per category for a given month
  Future<Map<String, double>> getCategoryTotalsByMonth(String yearMonth) async {
    final db = await AppDatabase.instance.database;
    final result = await db.rawQuery(
      '''
      SELECT category, SUM(amount) as total
      FROM payments
      WHERE strftime('%Y-%m', date) = ?
      GROUP BY category
      ''',
      [yearMonth],
    );

    final Map<String, double> totals = {};
    for (var row in result) {
      totals[row['category'] as String] = (row['total'] as num).toDouble();
    }
    return totals;
  }

  /// GET total spending/income for a given month
  Future<double> getTotalByMonth(String yearMonth, {bool income = false}) async {
    final db = await AppDatabase.instance.database;
    final result = await db.rawQuery(
      '''
      SELECT SUM(amount) as total
      FROM payments
      WHERE strftime('%Y-%m', date) = ?
      AND isIncome = ?
      ''',
      [yearMonth, income ? 1 : 0],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }
}
