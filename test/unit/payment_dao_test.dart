import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:smart_budget/data/local/payment_dao.dart';
import 'package:smart_budget/models/payment.dart';
import 'package:smart_budget/data/local/app_database.dart';

void main() {
  late PaymentDao dao;

  //helper funcs
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi; 
  });

  setUp(() async {
    await AppDatabase.instance.initForTest(inMemory: true);
    dao = PaymentDao();
  });

  tearDown(() async {
    await AppDatabase.instance.close();
  });


  //tests
  test('U1: insertPayment then getAllPayments returns it', () async {
    final p = Payment(
      id: '1',
      amount: 10,
      category: Category.food,
      note: 'Burger',
      date: DateTime(2025, 11, 1),
      isIncome: false,
      isSaving: false,
    );

    await dao.insertPayment(p);
    final all = await dao.getAllPayments();

    expect(all.length, 1);
    expect(all.first.note, 'Burger');
    expect(all.first.amount, 10);
  });

  test('U2: getTotalByMonth sums expenses vs income', () async {
    await dao.insertPayment(Payment(
      id: '1',
      amount: 50,
      category: Category.food,
      note: 'Groceries',
      date: DateTime(2025, 11, 3),
      isIncome: false,
      isSaving: false,
    ));
    await dao.insertPayment(Payment(
      id: '2',
      amount: 100,
      category: Category.other,
      note: 'Paycheck',
      date: DateTime(2025, 11, 10),
      isIncome: true,
      isSaving: false,
    ));

    final expenses = await dao.getTotalByMonth('2025-11', income: false);
    final income = await dao.getTotalByMonth('2025-11', income: true);

    expect(expenses, 50);
    expect(income, 100);
  });
}
