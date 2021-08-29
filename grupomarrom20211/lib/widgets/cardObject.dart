import 'dart:math';
import 'package:flutter/material.dart';

//Responsável pela exibição da carta
class CardObject extends StatefulWidget {
  final String urlFront;
  final String urlBack;
  final bool isInGame;
  CardObject({
    required this.urlFront,
    required this.urlBack,
    this.isInGame = false,
    Key? key,
  }) : super(key: key);

  @override
  _CardObjectState createState() => _CardObjectState();
}

class _CardObjectState extends State<CardObject> with TickerProviderStateMixin {
  late AnimationController controller;
  late AnimationController controllerInGame;
  late Animation<double> animation;
  AnimationStatus animationStatus = AnimationStatus.dismissed;
  bool isFront = true;
  double horizontalDrag = 0;
  double maxScale = 1.5;
  TransformationController _transformationController = TransformationController();
  var initialControllerValue;
  Animation<Matrix4>? _animationReset;
  late final AnimationController _controllerReset;
  bool isToFlip = false;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _controllerReset = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    if (this.widget.isInGame) {
      isFront = false;
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          isToFlip = true;
          controllerInGame = AnimationController(
            vsync: this,
            duration: Duration(milliseconds: 400),
          );
          animation = Tween<double>(end: 1, begin: 0).animate(controllerInGame)
            ..addListener(() {
              setState(() {
                if (controllerInGame.value >= 0.5) {
                  isFront = true;
                }
              });
            })
            ..addStatusListener((status) {
              animationStatus = status;
            });
          controllerInGame.forward();
        });
      });
    }
  }

  @override
  void dispose() {
    _controllerReset.dispose();
    controller.dispose();
    super.dispose();
  }

  void _onAnimateReset() {
    _transformationController.value = _animationReset!.value;
    if (!_controllerReset.isAnimating) {
      _animationReset!.removeListener(_onAnimateReset);
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
    Widget body = Container();
    if (isToFlip) {
      body = withAutomaticFlip();
      setState(() {
        isToFlip = false;
      });
    } else {
      body = withGestureFlip();
    }
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
      child: body,
    );
  }

  void _setImageSide() {
    if (horizontalDrag <= 90 || horizontalDrag >= 270) {
      isFront = true;
    } else {
      isFront = false;
    }
  }

  Widget withAutomaticFlip() {
    return _card(
      isFront,
      -controller.value,
      this.widget.urlFront,
      this.widget.urlBack,
    );
  }

  Widget withGestureFlip() {
    return GestureDetector(
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

          _setImageSide();
        });
      },
      onHorizontalDragEnd: (details) {
        final double end = 360 - horizontalDrag >= 180 ? 0 : 360;
        animation = Tween<double>(begin: horizontalDrag, end: end).animate(controller)
          ..addListener(() {
            setState(() {
              horizontalDrag = animation.value;
              _setImageSide();
            });
          });
        controller.forward();
      },
      child: _card(
        isFront,
        -horizontalDrag / 180,
        this.widget.urlFront,
        this.widget.urlBack,
      ),
    );
  }
}

_card(bool isFront, double value, String front, String back) {
  return Transform(
    alignment: Alignment.center,
    transform: Matrix4.identity()
      ..setEntry(3, 2, 0.001)
      ..rotateY(value * pi),
    child: isFront
        ? Image.asset(front)
        : Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..rotateY(pi),
            child: Image.asset(back),
          ),
  );
}
