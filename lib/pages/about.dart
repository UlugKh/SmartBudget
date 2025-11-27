import 'package:flutter/material.dart';
import 'package:smart_budget/util/button-widget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smart_budget/util/appbar.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          SizedBox(height: 40),
          _titleSection(),
          Container(
            padding: EdgeInsets.all(40),
            child: Row(
              mainAxisAlignment:  MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Image.asset(
                    'assets/icons/budget_picture.png',
                    height: 180,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Image.asset(
                    'assets/icons/finance_tracking.png',
                    height: 180,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(currentIndex: 4, onTap:(i) => {}),
    );
  }

  Container _titleSection() {
    return Container(
      height: 300,
      color: Color(0xffF5F5F5),
      child: Center(
        child: Text(
          'Smart Budget',
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
