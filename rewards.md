# SmartBudget – Gamification & Monthly Goals Module

This document explains how the **Rewards/Achievements (Gamification)** page and **Monthly Goal** logic work in the SmartBudget mobile app.  
It also briefly covers:

- How savings are calculated
- How badges are unlocked
- How monthly saving goals are stored and edited
- System & hardware requirements to run the app
- How the app is made portable across devices
- What is produced at each stage of the development cycle (for this specific feature)

---

## 1. High-level overview

**Goal of this module**

The Gamification page has two main responsibilities:

1. **Monthly Goal Tracking**
    - Show how much the user has saved this month.
    - Let the user set or edit a **monthly saving goal**.
    - Visualize progress with a circular progress indicator.

2. **Badge / Achievement System**
    - Define a set of **rank badges** (Stone → Master).
    - Unlock badges based on the user’s **current month savings**.
    - Display locked/unlocked state with custom badge icons.

The module is implemented entirely in Flutter, using:

- `GamificationPage` – main screen
- `MonthlyGoal` – simple model (targetAmount, currentSavings)
- `Badge` – model representing a rank badge
- `Payment` – model representing each transaction
- `GoalDao` + `sqflite` – SQLite persistence for monthly goals
- `PaymentProvider` + `PaymentDao` – provides this month’s transactions

---

## 2. Data model & SQLite integration

### 2.1 Payment model

Each transaction is stored in the `payments` table and mapped to a `Payment` object:

```dart
class Payment {
  final String id;
  final double amount;
  final Category category;
  final String note;
  final DateTime date;
  final bool isIncome;
  final bool isSafing; // optional saving flag

  Map<String, dynamic> toMap() { ... }
  factory Payment.fromMap(Map<String, dynamic> map) { ... }
}
