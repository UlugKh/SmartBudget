import '../models/badge.dart';

List<Badge> evaluateBadges({
  required double currentSavings,
  required List<Badge> definitions,
}) {
  return definitions.map((badge) {
    final progress =
    currentSavings.clamp(0, badge.targetValue).toDouble();
    final unlocked = currentSavings >= badge.targetValue;
    return badge.copyWith(
      isUnlocked: unlocked,
      progress: progress,
    );
  }).toList();
}
