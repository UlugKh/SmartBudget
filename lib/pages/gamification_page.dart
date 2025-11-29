import 'package:flutter/material.dart' hide Badge;
import '../models/badge.dart';
import '../models/monthly_goal.dart';
import '../logic/badge_logic.dart';
import '../models/payment.dart';
import '../data/local/payment_dao.dart';


class GamificationPage extends StatefulWidget {
  const GamificationPage({super.key});

  @override
  State<GamificationPage> createState() => _GamificationPageState();
}

class _GamificationPageState extends State<GamificationPage> {
  MonthlyGoal _monthlyGoal =
  const MonthlyGoal(targetAmount: 500.0, currentSavings: 350.0);

  late final List<Badge> _badgeDefinitions;
  List<Badge> _badges = [];

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initBadges();
    _loadGamificationData();
  }

  void _initBadges() {
    _badgeDefinitions = [
      const Badge(
        id: 1,
        name: 'Stone',
        description: 'Start your journey: Save \$50',
        iconPath: 'assets/icons/stone.png',
        targetValue: 50.0,
        isUnlocked: false,
        progress: 0.0,
      ),
      const Badge(
        id: 2,
        name: 'Silver',
        description: 'Getting serious: Save \$100',
        iconPath: 'assets/icons/silver.png',
        targetValue: 100.0,
        isUnlocked: false,
        progress: 0.0,
      ),
      const Badge(
        id: 3,
        name: 'Gold',
        description: 'Big steps: Save \$500',
        iconPath: 'assets/icons/gold.png',
        targetValue: 500.0,
        isUnlocked: false,
        progress: 0.0,
      ),
      const Badge(
        id: 4,
        name: 'Diamond',
        description: 'Expert saver: Save \$1,000',
        iconPath: 'assets/icons/diamond.png',
        targetValue: 1000.0,
        isUnlocked: false,
        progress: 0.0,
      ),
      const Badge(
        id: 5,
        name: 'Platinum',
        description: 'Elite status: Save \$5,000',
        iconPath: 'assets/icons/platinum.png',
        targetValue: 5000.0,
        isUnlocked: false,
        progress: 0.0,
      ),
      const Badge(
        id: 6,
        name: 'Master',
        description: 'Legendary: Save \$10,000',
        iconPath: 'assets/icons/master.png',
        targetValue: 10000.0,
        isUnlocked: false,
        progress: 0.0,
      ),
    ];
  }

  Future<void> _loadGamificationData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final now = DateTime.now();
      final yearMonth =
          '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}';

      final dao = PaymentDao();
      final List<Payment> payments =
      await dao.getPaymentsByMonth(yearMonth);

      double savings = 0;

      for (final p in payments) {
        if (p.isIncome) {
          savings += p.amount;
        } else {
          savings -= p.amount;
        }
      }

      final updatedGoal = MonthlyGoal(
        targetAmount: _monthlyGoal.targetAmount,
        currentSavings: savings,
      );

      final evaluatedBadges = evaluateBadges(
        currentSavings: savings,
        definitions: _badgeDefinitions,
      );

      setState(() {
        _monthlyGoal = updatedGoal;
        _badges = evaluatedBadges;
        _isLoading = false;
      });
    } catch (e, stack) {
      print('Gamification error: $e');
      print(stack);
      setState(() {
      _error = e.toString();
      _isLoading = false;
      });
    }
  }




  void _showEditGoalDialog() {
    final controller = TextEditingController(
      text: _monthlyGoal.targetAmount.toStringAsFixed(0),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set Monthly Goal'),
          content: TextField(
            controller: controller,
            keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
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
                    _monthlyGoal = MonthlyGoal(
                      targetAmount: newGoal,
                      currentSavings: _monthlyGoal.currentSavings,
                    );
                    _badges = evaluateBadges(
                      currentSavings: _monthlyGoal.currentSavings,
                      definitions: _badgeDefinitions,
                    );
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
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text(
          'Achievements',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SavingsGoalCard(
                targetAmount: _monthlyGoal.targetAmount,
                currentAmount: _monthlyGoal.currentSavings,
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
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics:
                const NeverScrollableScrollPhysics(),
                gridDelegate:
                const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0,
                ),
                itemCount: _badges.length,
                itemBuilder: (context, index) {
                  return BadgeTile(badge: _badges[index]);
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
            color: Colors.blue.withOpacity(0.1),
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
                  color: Colors.black54,
                ),
              ),
              IconButton(
                iconSize: 30,
                icon: const Icon(Icons.edit, color: Colors.blueGrey),
                onPressed: onEditPressed,
              )
            ],
          ),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 260,
                height: 260,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 25,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.blue.shade50,
                  ),
                ),
              ),
              SizedBox(
                width: 260,
                height: 260,
                child: CircularProgressIndicator(
                  value: progressPercent,
                  strokeWidth: 25,
                  strokeCap: StrokeCap.round,
                  valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.blue),
                  backgroundColor: Colors.transparent,
                ),
              ),
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
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'of \$${targetAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
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
            color: Colors.blue.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
                  const Icon(Icons.star,
                      size: 60, color: Colors.amber),
                )
                    : Opacity(
                  opacity: 0.3,
                  child: Image.asset(
                    badge.iconPath,
                    fit: BoxFit.contain,
                    errorBuilder: (ctx, err, stack) =>
                    const Icon(Icons.lock,
                        size: 60, color: Colors.grey),
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
