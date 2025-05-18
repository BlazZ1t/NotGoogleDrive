import 'package:flutter/material.dart';

import 'package:noodle/visual/widgets/button.dart';
import 'package:noodle/visual/widgets/text_input.dart';

class SignUpPage extends StatefulWidget{
  static const routeName = 'sign';
  final Function(String, String, bool) signUp;

  SignUpPage({
    super.key,
    required this.signUp
  });

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
String name = "";
  String password = "";
  bool rememberMe = false;

  void updateName(String s){
    setState((){
      name = s;
      debugPrint("Name: ${name}");
    });
  }

  void updatePassword(String s){
    setState((){
      password = s;
      debugPrint("Password: ${password}");
    });
  }

  void toggleRememberMe(bool? value) {
    setState(() {
      rememberMe = value ?? false;
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


            Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 10),
              child: SizedBox(
                width: 340,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 22,
                      width: 20,
                      child: Checkbox(
                        value: rememberMe,
                        onChanged: toggleRememberMe,
                        checkColor: const Color(0xFF484135), // цвет галочки
                        fillColor: WidgetStateProperty.resolveWith<Color>(
                          (Set<WidgetState> states) {
                            if (states.contains(WidgetState.selected)) {
                              return const Color(0xFFE7B35F); // цвет когда выбран
                            }
                            return const Color(0xFFCBBF7A); // цвет когда не выбран
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 1),
                    SizedBox(
                      height: 20,
                      child: const Text(
                        "Remember me",
                        style: TextStyle(
                          color: Color(0xFFE7E7E7),
                          fontSize: 16,
                          fontFamily: "Geological",
                          fontWeight: FontWeight.w200
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Button.ochre(
              "Sign up",
              onPressed: () => widget.signUp(name, password, rememberMe),
            ),
          ],
        ),
      )
    );
  }
}