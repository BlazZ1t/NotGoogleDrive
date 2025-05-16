import 'package:flutter/material.dart';


class Button extends StatelessWidget{
  final double width;
  final double height;

  final VoidCallback? onPressed;
  final String? text;
  final TextStyle? textStyle;
  final ButtonStyle? buttonStyle;

  Button({
    this.width = 342,
    this.height = 47,
    required this.onPressed,
    this.text,
    this.textStyle,
    this.buttonStyle
  });

  factory Button.ochre(
    String text, {
    VoidCallback? onPressed,
  }) =>
      Button(
        text: text,
        buttonStyle: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return const Color(0xFF9F956C).withAlpha(100);
              }
              return const Color(0xFF9F956C);
            },
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          overlayColor: WidgetStateProperty.all(
            (const Color(0xFF9F956C)).withAlpha(20),
          ),
          elevation: const WidgetStatePropertyAll(0),
        ),
        textStyle: TextStyle(
          color: onPressed == null ? Colors.grey : Colors.white,
          fontSize: 18,
          fontFamily: 'Geologica',
          fontWeight: FontWeight.w400,
        ),
        onPressed: onPressed,
      );

  factory Button.yellow(
    String text, {
    VoidCallback? onPressed,
  }) =>
      Button(
        text: text,
        buttonStyle: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) {
                return const Color(0xFFCBBF7A).withAlpha(100);
              }
              return const Color(0xFFCBBF7A);
            },
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          overlayColor: WidgetStateProperty.all(
            (const Color(0xFFCBBF7A)).withAlpha(20),
          ),
          elevation: const WidgetStatePropertyAll(0),
        ),
        textStyle: TextStyle(
          color: onPressed == null ? Colors.grey : Colors.white,
          fontSize: 18,
          fontFamily: 'Geologica',
          fontWeight: FontWeight.w400,
        ),
        onPressed: onPressed,
      );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: buttonStyle,
        child: Text(
          text ?? '',
          style:textStyle
        ),
      ),
    );
  }

}