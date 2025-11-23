import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smart_budget/util/button-widget.dart';

AppBar appBar() {
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
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SvgPicture.asset(
                'assets/icons/smart_budget_logo.svg',
                width: 60,   
                height: 60,
              ),
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