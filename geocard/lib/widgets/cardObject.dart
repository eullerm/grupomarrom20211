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
  double maxScale = 1.5;
  TransformationController _transformationController =
      TransformationController();
  var initialControllerValue;
  Animation<Matrix4>? _animationReset;
  late final AnimationController _controllerReset;

  @override
  void initState() {
    super.initState();

    _controllerReset = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  void _onAnimateReset() {
    _transformationController.value = _animationReset!.value;
    if (!_controllerReset.isAnimating) {
      _animationReset?.removeListener(_onAnimateReset);
      _animationReset = null;
      _controllerReset.reset();
    }
  }

  void _animateResetInitialize() {
    _controllerReset.reset();
    _animationReset = Matrix4Tween(
      begin: _transformationController.value,
      end: Matrix4.identity(),
    ).animate(_controllerReset);
    _animationReset!.addListener(_onAnimateReset);
    _controllerReset.forward();
  }

  void _animateResetStop() {
    _controllerReset.stop();
    _animationReset?.removeListener(_onAnimateReset);
    _animationReset = null;
    _controllerReset.reset();
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      panEnabled: false,
      clipBehavior: Clip.none,
      maxScale: maxScale,
      minScale: 1.0,
      boundaryMargin: EdgeInsets.all(double.infinity),
      transformationController: _transformationController,
      onInteractionStart: (ScaleStartDetails details) {
        if (_controllerReset.status == AnimationStatus.forward) {
          _animateResetStop();
        }
      },
      onInteractionEnd: (ScaleEndDetails details) {
        _animateResetInitialize();
      },
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
