import 'package:flutter/material.dart';
import 'package:frontend/sign_up.dart';
import 'dart:async';

class FlashScreen extends StatefulWidget {
  const FlashScreen({super.key});

  @override
  FlashScreenState createState() => FlashScreenState();
}

class FlashScreenState extends State<FlashScreen> {
  @override
  void initState() {
    super.initState();
    // timer for flash screen
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignUp()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF363D7D),
      // Color(0xFF4B4E87), purple
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // SizedBox(height: 10),
                Image.asset('assets/images/GhinaLogo_white.png', width: 180),
                SizedBox(height: 200),
              ],
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 250,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(100),
                  topRight: Radius.circular(100),
                ),
              ),
              alignment: Alignment.center,
              child: const Text(
                "ادخر اليوم , ازدهر غداً",
                style: TextStyle(
                  fontSize: 35,
                  color: Color(0xFF4B4E87),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
