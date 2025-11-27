import 'package:flutter/material.dart' hide Badge;
import '../models/badge.dart';

class GamificationPage extends StatefulWidget {
  const GamificationPage({super.key});

  @override
  State<GamificationPage> createState() => _GamificationPageState();
}

class _GamificationPageState extends State<GamificationPage> {
  final double monthlyGoal = 500.00;
  final double currentSavings = 350.00;

  final List<Badge> badges = [
    Badge(
      id: 1,
      name: 'Novice Saver',
      description: 'Save your first \$50',
      iconPath: 'assets/badges/novice.png',
      isUnlocked: true,
      targetValue: 50.0,
      progress: 50.0,
    ),
    Badge(
      id: 2,
      name: 'Halfway Hero',
      description: 'Reach 50% of monthly goal',
      iconPath: 'assets/badges/halfway.png',
      isUnlocked: true,
      targetValue: 250.0,
      progress: 350.0,
    ),
    Badge(
      id: 3,
      name: 'Goal Crusher',
      description: 'Hit your monthly goal',
      iconPath: 'assets/badges/winner.png',
      isUnlocked: false,
      targetValue: 500.0,
      progress: 350.0,
    ),
    Badge(
      id: 4,
      name: 'Streak Master',
      description: 'Save for 3 months in a row',
      iconPath: 'assets/badges/streak.png',
      isUnlocked: false,
      targetValue: 3.0,
      progress: 1.0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SavingsGoalCard(
                targetAmount: monthlyGoal,
                currentAmount: currentSavings,
              ),
              const SizedBox(height: 24),
              const Text(
                'Your Badges',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: badges.length,
                itemBuilder: (context, index) {
                  return BadgeTile(badge: badges[index]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SavingsGoalCard extends StatelessWidget {
  final double targetAmount;
  final double currentAmount;

  const SavingsGoalCard({
    super.key,
    required this.targetAmount,
    required this.currentAmount,
  });

  @override
  Widget build(BuildContext context) {
    final double progressPercent = (currentAmount / targetAmount).clamp(0.0, 1.0);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Monthly Savings Goal',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progressPercent,
              minHeight: 12,
              backgroundColor: Colors.grey[300],
              color: Colors.green,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${currentAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Text(
                  'Goal: \$${targetAmount.toStringAsFixed(0)}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BadgeTile extends StatelessWidget {
  final Badge badge;

  const BadgeTile({super.key, required this.badge});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: badge.isUnlocked ? Colors.white : Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              badge.isUnlocked ? Icons.emoji_events : Icons.lock,
              size: 48,
              color: badge.isUnlocked ? Colors.amber : Colors.grey,
            ),
            const SizedBox(height: 12),
            Text(
              badge.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: badge.isUnlocked ? Colors.black : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              badge.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}