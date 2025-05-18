import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BubleButtons extends StatefulWidget{
  final VoidCallback f1;
  final VoidCallback f2;
  final VoidCallback f3;

  final VoidCallback? ret;

  const BubleButtons({
    required this.f1,
    required this.f2,
    required this.f3,
    this.ret
  });

  @override
  State<BubleButtons> createState() => _BubleButtonsState();
}

class _BubleButtonsState extends State<BubleButtons> with SingleTickerProviderStateMixin {
    late AnimationController _controller;
  bool _isExpanded = false;
  final Color _buttonColor = const Color(0xFFE7B35F);
  final double _buttonSize = 80.0;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
              children: [
                Spacer(),
                Center(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [

                    const SizedBox(
                        height: 250,
                        width: 300,
                      ),
                    (_isExpanded)?
                    SizedBox(
                        height: 250,
                        width: 300,
                        child: GestureDetector(onTap: _toggleExpansion),
                    ): const SizedBox(
                        height: 250,
                        width: 300,
                    ),
                    
                    // Верхняя левая кнопка
                    if (true)
                      Positioned(
                        bottom: 46 +(_buttonSize + 5) * 0.6 * _controller.value + _buttonSize * 0.25 * (1 - _controller.value),
                        left:  (size.width+20)/2 - _buttonSize -(_buttonSize + 5) * 0.9 * _controller.value,
                        child: GestureDetector(
                          onTap: widget.f1,
                          child: Container(
                            width: _buttonSize * (0.5 +  0.5 * _controller.value),
                            height: _buttonSize * (0.5 +  0.5 * _controller.value),
                            decoration: BoxDecoration(
                              color: _buttonColor,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: SizedBox(
                                height: 48 * (0.5 +  0.5 * _controller.value),
                                width: 48 * (0.5 +  0.5 * _controller.value),
                                child: SvgPicture.asset("assets/images/Img_box.svg")
                              ),
                            )
                          ),
                        ),
                      ),
                    
                    // Верхняя центральная кнопка
                    if (true)
                      Positioned(
                        bottom: 46 + (_buttonSize + 10) * _controller.value + _buttonSize * 0.25 * (1 - _controller.value),
                        child: GestureDetector(
                          onTap: widget.f2,
                          child: Container(
                            width: _buttonSize * (0.5 +  0.5 * _controller.value),
                            height: _buttonSize * (0.5 +  0.5 * _controller.value),
                            decoration: BoxDecoration(
                              color: _buttonColor,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: SizedBox(
                                height: 48 * (0.5 +  0.5 * _controller.value),
                                width: 48 * (0.5 +  0.5 * _controller.value),
                                child: SvgPicture.asset("assets/images/File.svg")
                              ),
                            )
                          ),
                        ),
                      ),
                    
                    // Верхняя правая кнопка
                    if (true)
                      Positioned(
                        bottom: 46 +(_buttonSize + 5) * 0.6 * _controller.value + _buttonSize * 0.25 * (1 - _controller.value),
                        right:  (size.width+20)/2 - _buttonSize -(_buttonSize + 5) * 0.9 * _controller.value,
                        child: GestureDetector(
                          onTap: widget.f3,
                          child: Container(
                            width: _buttonSize * (0.5 +  0.5 * _controller.value),
                            height: _buttonSize * (0.5 +  0.5 * _controller.value),
                            decoration: BoxDecoration(
                              color: _buttonColor,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: SizedBox(
                                height: 48 * (0.5 +  0.5 * _controller.value),
                                width: 48 * (0.5 +  0.5 * _controller.value),
                                child: SvgPicture.asset("assets/images/folder.svg")
                              ),
                            )
                          ),
                        ),
                      ),


                      // Главная кнопка (центр)
                    Positioned(
                      bottom: 46 + _buttonSize * 0.25 * _controller.value,
                       // Полностью исчезает
                      child: GestureDetector(
                        onTap: _toggleExpansion,
                        child: Container(
                          width: _buttonSize * (1 - 0.5 *_controller.value),
                          height: _buttonSize * (1 - 0.5 *_controller.value),
                          decoration: BoxDecoration(
                            color: _buttonColor,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: SizedBox(
                              height: 48 * (1 - 0.5 *_controller.value),
                              width: 48 * (1 - 0.5 *_controller.value),
                              child: SvgPicture.asset("assets/images/Plus.svg")
                            ),
                          )
                          // child: (_isExpanded) ?SizedBox(
                          //   height: 48 * (1 - _controller.value),
                          //   width: 48 * (1 - _controller.value),
                          //   child: SvgPicture.asset("assets/images/plus.svg")
                          // ) : child: (_isExpanded) ?SizedBox(
                          //   height: 48 * (1 - _controller.value),
                          //   width: 48 * (1 - _controller.value),
                          //   child: SvgPicture.asset("assets/images/plus.svg")
                          // )
                        ),
                      ),
                    ),

                    if(widget.ret != null) 
                      Positioned(
                        bottom: 35,
                        left: 50,
                        // Полностью исчезает
                        child: GestureDetector(
                          onTap: widget.ret,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Color(0xFFF4E87C),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: SizedBox(
                                height: 32,
                                width: 32,
                                child: SvgPicture.asset("assets/images/Back.svg")
                              ),
                            )
                            // child: (_isExpanded) ?SizedBox(
                            //   height: 48 * (1 - _controller.value),
                            //   width: 48 * (1 - _controller.value),
                            //   child: SvgPicture.asset("assets/images/plus.svg")
                            // ) : child: (_isExpanded) ?SizedBox(
                            //   height: 48 * (1 - _controller.value),
                            //   width: 48 * (1 - _controller.value),
                            //   child: SvgPicture.asset("assets/images/plus.svg")
                            // )
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          )
        ],
      );
  }
}