class MonthlyGoal {
  final double targetAmount;
  final double currentSavings;

  const MonthlyGoal({
    required this.targetAmount,
    required this.currentSavings,
  });

  double get progressPercent {
    if (targetAmount <= 0) return 0;
    final value = currentSavings / targetAmount;
    return value.clamp(0.0, 1.0);
  }
}
