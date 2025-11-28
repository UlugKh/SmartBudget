import 'package:flutter/material.dart' hide Badge;
import '../models/badge.dart';

class GamificationPage extends StatefulWidget {
  const GamificationPage({super.key});

  @override
  State<GamificationPage> createState() => _GamificationPageState();
}

class _GamificationPageState extends State<GamificationPage> {
  // Goal state
  double monthlyGoal = 500.00;
  final double currentSavings = 350.00;

  // LOGIC: Defined tiers for each badge
  final List<Badge> badges = [
    Badge(
      id: 1,
      name: 'Stone',
      description: 'Start your journey: Save \$50',
      iconPath: 'assets/icons/stone.png',
      isUnlocked: true,
      targetValue: 50.0,
      progress: 50.0,
    ),
    Badge(
      id: 2,
      name: 'Silver',
      description: 'Getting serious: Save \$100',
      iconPath: 'assets/icons/silver.png',
      isUnlocked: true,
      targetValue: 100.0,
      progress: 100.0,
    ),
    Badge(
      id: 3,
      name: 'Gold',
      description: 'Big steps: Save \$500',
      iconPath: 'assets/icons/gold.png',
      isUnlocked: false,
      targetValue: 500.0,
      progress: 350.0,
    ),
    Badge(
      id: 4,
      name: 'Diamond',
      description: 'Expert saver: Save \$1,000',
      iconPath: 'assets/icons/diamond.png',
      isUnlocked: false,
      targetValue: 1000.0,
      progress: 350.0,
    ),
    Badge(
      id: 5,
      name: 'Platinum',
      description: 'Elite status: Save \$5,000',
      iconPath: 'assets/icons/platinum.png',
      isUnlocked: false,
      targetValue: 5000.0,
      progress: 350.0,
    ),
    Badge(
      id: 6,
      name: 'Master',
      description: 'Legendary: Save \$10,000',
      iconPath: 'assets/icons/master.png',
      isUnlocked: false,
      targetValue: 10000.0,
      progress: 350.0,
    ),
  ];

  void _showEditGoalDialog() {
    TextEditingController controller =
    TextEditingController(text: monthlyGoal.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set Monthly Goal'),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Target Amount (\$)',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final newGoal = double.tryParse(controller.text);
                if (newGoal != null && newGoal > 0) {
                  setState(() {
                    monthlyGoal = newGoal;
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // THEME UPDATE: Blue background kept
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text(
          'Achievements',
          // REVERTED: Default black text style
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        // REVERTED: Default icon theme
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Circular Tracker
              SavingsGoalCard(
                targetAmount: monthlyGoal,
                currentAmount: currentSavings,
                onEditPressed: _showEditGoalDialog,
              ),
              const SizedBox(height: 30),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Rank Badges',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    // REVERTED: Black text
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Grid of Badges
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                // Keeps the layout responsive and square
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0,
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
  final VoidCallback onEditPressed;

  const SavingsGoalCard({
    super.key,
    required this.targetAmount,
    required this.currentAmount,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    final double progressPercent = targetAmount > 0
        ? (currentAmount / targetAmount).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1), // THEME UPDATE: Blue shadow kept
            spreadRadius: 4,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Monthly Goal',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    // REVERTED: Black54 color
                    color: Colors.black54
                ),
              ),
              IconButton(
                iconSize: 30,
                // REVERTED: BlueGrey icon
                icon: const Icon(Icons.edit, color: Colors.blueGrey),
                onPressed: onEditPressed,
              )
            ],
          ),
          const SizedBox(height: 20),

          // --- CIRCULAR TRACKER ---
          Stack(
            alignment: Alignment.center,
            children: [
              // 1. Background Circle
              SizedBox(
                width: 260,
                height: 260,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 25,
                  // THEME UPDATE: Blue tint background
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade50),
                ),
              ),
              // 2. Progress Circle (Blue)
              SizedBox(
                width: 260,
                height: 260,
                child: CircularProgressIndicator(
                  value: progressPercent,
                  strokeWidth: 25,
                  strokeCap: StrokeCap.round,
                  // THEME UPDATE: Blue Progress kept
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                  backgroundColor: Colors.transparent,
                ),
              ),
              // 3. Text in the Middle
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Saved",
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${currentAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      // REVERTED: Black87 text
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'of \$${targetAmount.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BadgeTile extends StatelessWidget {
  final Badge badge;

  const BadgeTile({super.key, required this.badge});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.05), // Light blue shadow
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        // THEME UPDATE: Blue border if unlocked
        border: badge.isUnlocked
            ? Border.all(color: Colors.blue.withOpacity(0.3), width: 1.5)
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: badge.isUnlocked
                    ? Image.asset(
                  badge.iconPath,
                  fit: BoxFit.contain,
                  errorBuilder: (ctx, err, stack) =>
                  const Icon(Icons.star, size: 60, color: Colors.amber),
                )
                    : Opacity(
                  opacity: 0.3,
                  child: Image.asset(
                    badge.iconPath,
                    fit: BoxFit.contain,
                    errorBuilder: (ctx, err, stack) =>
                    const Icon(Icons.lock, size: 60, color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              badge.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                // REVERTED: Black87/Grey
                color: badge.isUnlocked ? Colors.black87 : Colors.grey,
              ),
            ),
            Text(
              badge.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
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