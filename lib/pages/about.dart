import 'package:flutter/material.dart';
import 'package:smart_budget/util/button-widget.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Container(
          alignment: Alignment.center,
          color: Colors.green,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
              GestureDetector(
                onTap:() => {},
                child: Text(
                  'Mission'
                ),
              ),
              GestureDetector(
                onTap:() => {},
                child: Text(
                  'App Info'
                ),
              ),
              GestureDetector(
                onTap:() => {},
                child: Text(
                  'Community'
                ),
              ),
              GestureDetector(
                onTap:() => {},
                child: Text(
                'Contact Us'
              )
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomButton(buttonText: 'Sign in', onPressed: () {}, ),
                    SizedBox(width: 10),
                    CustomButton(buttonText: 'Log in', onPressed: () {})   
                  ],
                ),
              )
                         
            ],
            ),
          )
        ),
        ),
      body: Center(
        child: Text('Test text'),
        
      )
    );
  }
}


