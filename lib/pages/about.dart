import 'package:flutter/material.dart';
import 'package:smart_budget/util/button-widget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smart_budget/util/appBar.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          SizedBox(height: 40,),
          _titleSection()
        ],
      )
    );
  }

  Container _titleSection() {
    return Container(
          height: 300,
          color: Color(0xffF5F5F5),
          child: Center(
            child: Text(
              'Smart Budget',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w600,
              )
            )
          )
        );
  }
}


