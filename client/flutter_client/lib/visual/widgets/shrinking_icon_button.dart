import 'package:flutter/material.dart';

class ShrinkingIconButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Color? hoverColor;
  final Color? color;
  final double? size;
  final IconData icon;

  const ShrinkingIconButton({
    Key? key,
    this.onPressed,
    this.hoverColor,
    this.color,
    this.size,
    required this.icon,
  }) : super(key: key);

  @override
  State<ShrinkingIconButton> createState() => _ShrinkingIconButtonState();
}

class _ShrinkingIconButtonState extends State<ShrinkingIconButton> {
  bool _isPressed = false;

  late Color _iconColor;

  @override
  void initState() {
    super.initState();
    _iconColor = widget.color ?? Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (details) {
        setState(() {
          _iconColor = widget.hoverColor ?? _iconColor;
        });
      },
      onExit: (details) {
        setState(() {
          _iconColor = widget.color ?? Colors.black;
        });
      },
      child: GestureDetector(
        onTapDown: (details) {
          setState(() {
            _isPressed = true;
          });
        },
        onTapCancel: () {
          setState(() {
            _isPressed = false;
          });
        },
        onTapUp: (details) {
          setState(() {
            _isPressed = false;
          });

          // Call the onPressed function if provided
          if (widget.onPressed != null) {
            widget.onPressed!();
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Transform.scale(
            scale: _isPressed ? 0.9 : 1.0,
            child: Icon(
              widget.icon,
              size: widget.size,
              color: _iconColor,
            ),
          ),
        ),
      ),
    );
  }
}
