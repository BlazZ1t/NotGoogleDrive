import 'package:noodle/visual/widgets/shrinking_icon_button.dart';
import 'package:flutter/material.dart';

// bound 64 symbols
class TextInput extends StatefulWidget {
  final String? initialText;
  final InputDecoration decoration;
  final TextStyle? textStyle;
  final Color? cursorColor;
  final Color cancelBtnColor;
  final Color cancelBtnHoverColor;
  final Function(String) onTextChanged;

  const TextInput({
    super.key,
    this.initialText,
    required this.onTextChanged,
    required this.decoration,
    this.textStyle,
    this.cursorColor,
    required this.cancelBtnColor,
    required this.cancelBtnHoverColor,
  });

  factory TextInput.yellow({
    String? hintText,
    required Function(String) onTextChanged,
  }) => TextInput(
    onTextChanged: onTextChanged, 
    decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFCBBF7A),
          contentPadding: const EdgeInsets.only(left: 12),
          hintText: hintText,
          hintStyle: TextStyle(
            color: const Color(0xFF484135).withAlpha(204),
            fontSize: 18,
            fontFamily: 'Geological',
            fontWeight: FontWeight.w200,
          ),
          counterText: "",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          errorStyle: const TextStyle(
            color: Color(0xFFE7B35F),
            fontSize: 18,
            fontFamily: 'Geological',
            fontWeight: FontWeight.w200,
          ),
        ),
        textStyle: const TextStyle(
            color: Color(0xFF484135),
            fontSize: 18,
            fontFamily: 'Geological',
            fontWeight: FontWeight.w400,
          ),
        cursorColor: Colors.black,
        cancelBtnColor: const Color.fromARGB(90, 0, 32, 51),
        cancelBtnHoverColor: const Color.fromARGB(120, 0, 32, 51),
      );
    

  factory TextInput.white({
    String? initialText,
    required Function(String) onTextChanged,
  }) =>
      TextInput(
        initialText: initialText,
        onTextChanged: onTextChanged,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(left: 12),
          hintText: 'Введите текст',
          hintStyle: const TextStyle(
            color: Color(0x59002033),
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            letterSpacing: -0.10,
          ),
          counterText: "",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              width: 1,
              color: Color(0x47004269),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              width: 1,
              color: Color(0xFF333333),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              width: 1,
              color: Color(0xFF97989E),
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              width: 1,
              color: Color.fromARGB(255, 202, 75, 75),
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              width: 1,
              color: Color(0xFFEB5757),
            ),
          ),
          errorStyle: const TextStyle(
            color: Color(0xFFEB5757),
            fontSize: 13,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            letterSpacing: -0.10,
            decoration: TextDecoration.none,
          ),
        ),
        textStyle: const TextStyle(
          color: Colors.black,
          fontSize: 14,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w400,
          letterSpacing: -0.10,
          decoration: TextDecoration.none,
        ),
        cursorColor: Colors.black,
        cancelBtnColor: const Color.fromARGB(90, 0, 32, 51),
        cancelBtnHoverColor: const Color.fromARGB(120, 0, 32, 51),
      );

  factory TextInput.black({
    String? initialText,
    required Function(String) onTextChanged,
  }) =>
      TextInput(
        initialText: initialText,
        onTextChanged: onTextChanged,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(left: 12),
          hintText: 'Введите текст',
          hintStyle: const TextStyle(
            color: Color(0xFF97989E),
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            letterSpacing: -0.10,
          ),
          counterText: "",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              width: 1,
              color: Color(0xFF97989E),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              width: 1,
              color: Colors.white,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              width: 1,
              color: Color(0xFF97989E),
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              width: 1,
              color: Color.fromARGB(255, 202, 75, 75),
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              width: 1,
              color: Color(0xFFEB5757),
            ),
          ),
          errorStyle: const TextStyle(
            color: Color(0xFFEB5757),
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            letterSpacing: -0.10,
            decoration: TextDecoration.none,
          ),
        ),
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w400,
          letterSpacing: -0.10,
          decoration: TextDecoration.none,
        ),
        cursorColor: Colors.white,
        cancelBtnColor: const Color.fromARGB(255, 191, 191, 194),
        cancelBtnHoverColor: const Color.fromARGB(255, 209, 209, 212),
      );

  @override
  State<TextInput> createState() => _TextInputState();
}

class _TextInputState extends State<TextInput> {
  late final TextEditingController _textController;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText);
    _textController.addListener(_handleTextChange);
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleTextChange() {
    // may throw an exception
    widget.onTextChanged(_textController.text);
  }

  void _handleFocusChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: TextFormField(
        maxLength: 64,
        controller: _textController,
        focusNode: _focusNode,
        cursorRadius: const Radius.circular(2),
        cursorColor: widget.cursorColor,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Field is empty';
          }
          return null;
        },
        decoration: widget.decoration.copyWith(
          suffixIcon: _textController.text.isNotEmpty
              ? ShrinkingIconButton(
                  icon: Icons.cancel,
                  color: widget.cancelBtnColor,
                  size: 24,
                  hoverColor: widget.cancelBtnHoverColor,
                  onPressed: () {
                    setState(() {
                      _textController.clear();
                      _focusNode.requestFocus();
                    });
                  },
                )
              : null,
        ),
        style: widget.textStyle,
        onChanged: (v) => setState(() {}),
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _textController.removeListener(_handleTextChange);
    _textController.dispose();
    super.dispose();
  }
}
