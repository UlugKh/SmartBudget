class Badge {
  final int id;
  final String name;
  final String description;
  final String iconPath;
  final double targetValue;
  final bool isUnlocked;
  final double progress;

  const Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    required this.targetValue,
    required this.isUnlocked,
    required this.progress,
  });

  Badge copyWith({
    bool? isUnlocked,
    double? progress,
  }) {
    return Badge(
      id: id,
      name: name,
      description: description,
      iconPath: iconPath,
      targetValue: targetValue,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      progress: progress ?? this.progress,
    );
  }
}
