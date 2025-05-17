import 'package:flutter/material.dart';

import 'package:noodle/visual/widgets/button.dart';
import 'package:noodle/visual/widgets/text_input.dart';

class LoginPage extends StatefulWidget{
  static const routeName = 'login';
  final Function(String, String, bool) login;

  LoginPage({
    super.key,
    required this.login
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String name = "";
  String password = "";

  void updateName(String s){
    setState((){
      name = s;
      print("Name: ${name}");
    });
  }

  void updatePassword(String s){
    setState((){
      password = s;
      print("Password: ${password}");
    });
  }


  @override
  Widget build(BuildContext context) {

    return  Scaffold(
      backgroundColor: Color(0xFF484135),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 342,
              child: TextInput.yellow(
                hintText: "Username",
                onTextChanged: updateName
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 342,
              child: TextInput.yellow(
                hintText: "Password",
                onTextChanged: updatePassword
              ),
            ),

            const SizedBox(height: 20),
            Button.ochre(
              "Log in",
              onPressed: () => widget.login(name, password, true),
            ),
          ],
        ),
      )
    );
  }
}