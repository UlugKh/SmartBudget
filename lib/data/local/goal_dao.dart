import 'package:sqflite/sqflite.dart';
import 'app_database.dart';

class GoalDao {
  Future<double> getMonthlyGoal(DateTime month) async {
    final db = await AppDatabase.instance.database;
    final result = await db.query(
      'monthly_goals',
      where: 'year = ? AND month = ?',
      whereArgs: [month.year, month.month],
      orderBy: 'id DESC',
      limit: 1,
    );

    if (result.isEmpty) {
      const defaultGoal = 500.0;
      await db.insert(
        'monthly_goals',
        {
          'year': month.year,
          'month': month.month,
          'target_amount': defaultGoal,
        },
      );
      return defaultGoal;
    }

    final row = result.first;
    return (row['target_amount'] as num).toDouble();
  }

  Future<void> setMonthlyGoal(DateTime month, double goal) async {
    final db = await AppDatabase.instance.database;


    final rowsUpdated = await db.update(
      'monthly_goals',
      {
        'target_amount': goal,
      },
      where: 'year = ? AND month = ?',
      whereArgs: [month.year, month.month],
    );

    if (rowsUpdated == 0) {
      await db.insert(
        'monthly_goals',
        {
          'year': month.year,
          'month': month.month,
          'target_amount': goal,
        },
      );
    }
  }
}


