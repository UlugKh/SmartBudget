import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';

import 'package:smart_budget/pages/monitoring_page.dart';
import 'package:smart_budget/providers/payment_provider.dart';
import 'package:smart_budget/models/payment.dart';

/// A light fake provider for widget tests
/// Only iuse MonitoringPage fiels
/// Others ignored through noSuchMethod
class TestPaymentProvider extends ChangeNotifier implements PaymentProvider {
  final List<Payment> _payments;
  final double _total;

  TestPaymentProvider({
    required List<Payment> payments,
    required double totalExpenses,
  })  : _payments = payments,
        _total = totalExpenses;

  @override
  List<Payment> get payments => _payments;

  @override
  double get totalExpenses => _total;

  @override
  bool get isLoading => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Navigator observer mock for checking navigation.
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  Widget buildTestApp({
    required PaymentProvider provider,
    NavigatorObserver? observer,
  }) {
    return ChangeNotifierProvider<PaymentProvider>.value(
      value: provider,
      child: MaterialApp(
        home: const MonitoringPage(),
        navigatorObservers: observer != null ? [observer] : const [],
      ),
    );
  }

  testWidgets(
    'M1: shows empty state when there are no payments',
    (tester) async {
      final provider = TestPaymentProvider(
        payments: const [],
        totalExpenses: 0.0,
      );

      await tester.pumpWidget(buildTestApp(provider: provider));

      // AppBar title
      expect(find.text('Monitoring'), findsOneWidget);

      // Empty list message
      expect(find.text('No payments yet!'), findsOneWidget);

      // Total card value should be $0.00
      expect(find.text('\$0.00'), findsOneWidget);
    },
  );

  testWidgets(
    'M2: renders recent payments list with correct signs',
    (tester) async {
      final p1 = Payment(
        id: '1',
        amount: 12.5,
        category: Category.food,
        note: 'Coffee',
        date: DateTime(2025, 11, 1),
        isIncome: false,
        isSaving: false,
      );
      final p2 = Payment(
        id: '2',
        amount: 100,
        category: Category.transport,
        note: 'Salary',
        date: DateTime(2025, 11, 2),
        isIncome: true,
        isSaving: false,
      );

      final provider = TestPaymentProvider(
        payments: [p1, p2],
        totalExpenses: 12.5,
      );

      await tester.pumpWidget(buildTestApp(provider: provider));

      // Notes appear in list
      expect(find.text('Coffee'), findsOneWidget);
      expect(find.text('Salary'), findsOneWidget);

      // Trailing amounts show correct +/- formatting
      expect(find.text('-\$12.50'), findsOneWidget);
      expect(find.text('+\$100.00'), findsOneWidget);

      // "Recent Payments" header exists
      expect(find.text('Recent Payments'), findsOneWidget);
    },
  );

    testWidgets(
    'M3: floating action button is visible with insights icon',
    (tester) async {
      final provider = TestPaymentProvider(
        payments: const [],
        totalExpenses: 0.0,
      );

      await tester.pumpWidget(buildTestApp(provider: provider));

      // FAB exists
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // And it has the right icon
      expect(find.byIcon(Icons.insights_outlined), findsOneWidget);
    },
  );
}
