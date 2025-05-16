import 'package:flutter/material.dart';

import 'package:noodle/visual/widgets/button.dart';

class WelcomePage extends StatefulWidget{
  static const routeName = 'welcome';

  WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {



  @override
  Widget build(BuildContext context) {

    return  Scaffold(
      backgroundColor: Color(0xFF484135),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 60,
              width: 342,
              child: Text(
                "Keep your files organized",
                textAlign: TextAlign.center,
                style: TextStyle(
                  
                  color: Colors.white,
                  fontFamily: "Geologica",
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                )
              ),
            ),
            const SizedBox(height: 41),
            Button.yellow(
              "Sign up",
            ),
            const SizedBox(height: 11),
            Button.yellow(
              "Log in",
            ),
          ],
        ),
      )
    );
  }
}