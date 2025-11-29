abstract class GamificationRepository {
  Future<double> getMonthlyGoal(DateTime month);
  Future<void> setMonthlyGoal(DateTime month, double goal);
  Future<double> getCurrentMonthSavings(DateTime month);
}
