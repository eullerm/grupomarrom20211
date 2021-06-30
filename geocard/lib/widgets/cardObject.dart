import 'dart:math';
import 'package:flutter/material.dart';

class CardObject extends StatefulWidget {
  final String urlFront;
  final String urlBack;

  const CardObject({
    required this.urlFront,
    required this.urlBack,
    Key? key,
  }) : super(key: key);

  @override
  _CardObjectState createState() => _CardObjectState();
}

class _CardObjectState extends State<CardObject> with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;
  bool isFront = true;
  double horizontalDrag = 0;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      panEnabled: false,
      clipBehavior: Clip.none,
      maxScale: 1.5,
      boundaryMargin: EdgeInsets.all(double.infinity),
      child: GestureDetector(
        onHorizontalDragStart: (details) {
          controller.reset();

          setState(() {
            isFront = true;
            horizontalDrag = 0;
          });
        },
        onHorizontalDragUpdate: (details) {
          setState(() {
            horizontalDrag += details.delta.dx;
            horizontalDrag %= 360;

            setImageSide();
          });
        },
        onHorizontalDragEnd: (details) {
          final double end = 360 - horizontalDrag >= 180 ? 0 : 360;

          animation =
              Tween<double>(begin: horizontalDrag, end: end).animate(controller)
                ..addListener(() {
                  setState(() {
                    horizontalDrag = animation.value;

                    setImageSide();
                  });
                });
          controller.forward();
        },
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(horizontalDrag / 180 * pi),
          child: isFront
              ? Image.asset(widget.urlFront)
              : Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(pi),
                  child: Image.asset(widget.urlBack),
                ),
        ),
      ),
    );
  }

  void setImageSide() {
    if (horizontalDrag <= 90 || horizontalDrag >= 270) {
      isFront = true;
    } else {
      isFront = false;
    }
  }
}
