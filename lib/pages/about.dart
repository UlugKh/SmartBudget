import 'package:flutter/material.dart';
import 'package:smart_budget/util/button-widget.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),

      body: const Center(
        child: Text('Test text'),
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      elevation: 5,
      shadowColor: Colors.black.withOpacity(0.5),
      toolbarHeight: 100,           
      titleSpacing: 0,          
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start, 
          children: [
            // LOGO ON THE LEFT
            SvgPicture.asset(
              'assets/icons/smart_budget_logo.svg',
              width: 60,   
              height: 60,  
            ),

            const SizedBox(width: 40),

            // MENU ITEMS (left side)
            GestureDetector(
              onTap: () {},
              child: const Text('Mission'),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () {},
              child: const Text('App Info'),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () {},
              child: const Text('Community'),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () {},
              child: const Text('Contact Us'),
            ),

            // BUTTONS FAR RIGHT
            const Spacer(),

            Row(
              children: [
                CustomButton(
                  buttonText: 'Sign in',
                  onPressed: () {},
                ),
                const SizedBox(width: 10),
                CustomButton(
                  buttonText: 'Log in',
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


