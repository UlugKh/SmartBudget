import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smart_budget/app_shell.dart';
import 'package:smart_budget/providers/payment_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // This creates a single PaymentProvider instance for the whole app
      create: (_) => PaymentProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const AppShell(), // no need for extra Scaffold here
      ),
    );
  }
}
