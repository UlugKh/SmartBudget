import 'package:flutter/material.dart';

import 'package:smart_budget/pages/about.dart';
import 'package:smart_budget/pages/add_payment_page.dart';
import 'package:smart_budget/pages/gamification_page.dart';
import 'package:smart_budget/pages/home.dart';

import 'package:smart_budget/util/appbar.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    this.startIndex = 0,
  }); //start index at 0 = home page
  final int startIndex;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _index;

  final _pages = const [
    HomePage(),
    AddPaymentPage(),
    GamificationPage(),
    AboutPage(),
  ];

  @override
  void initState() {
    super.initState();
    _index = widget.startIndex; //start index state at 0 = home page
  }

  void _onNavTap(int i) {
    if (i == _index) return; // do nothing if same page
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //IndexedStack is a stack of all pages, but only one is shown based on the current index state
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _index,
        onTap: _onNavTap,
      ),
    );
  }
}
