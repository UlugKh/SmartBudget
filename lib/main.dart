import 'package:flutter/material.dart';
import 'package:smart_budget/app_shell.dart';
import 'package:smart_budget/pages/about.dart';
import 'package:smart_budget/pages/add_payment_page.dart';
import 'package:smart_budget/pages/dashboard_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: AppShell(),
      ),
    );
  }
}
