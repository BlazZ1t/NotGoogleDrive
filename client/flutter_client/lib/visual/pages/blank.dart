import 'package:flutter/material.dart';

class BlankPage extends StatelessWidget {
  static const routeName = 'loading';

  const BlankPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
    );
  }
}
