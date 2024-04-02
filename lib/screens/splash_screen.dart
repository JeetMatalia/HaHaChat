import 'dart:async';
import 'package:chat_app/screens/auth/login_screen.dart';
import 'package:chat_app/screens/home_screen.dart';
import 'package:flutter/material.dart';

import '../api/apis.dart';
import '../main.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Replace this timer with any logic you want for showing the splash screen
    Timer(Duration(seconds: 3), () {
      // Navigate to the next screen after 3 seconds

      if (APIs.auth.currentUser != null) {
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen()));
      } else {
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // Background image
          Image.asset(
            'assets/images/img_appicon.png',
            // Replace this with your image path
            fit: BoxFit.cover,
          ),
          // Overlay for text at the bottom
          Container(
            alignment: Alignment.bottomCenter,
            padding: EdgeInsets.only(bottom: 50.0),
            child: Text(
              'Made for Fun HaHaChat',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
