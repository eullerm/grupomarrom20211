import 'dart:ui';

import 'package:flutter/material.dart';

class Background extends StatelessWidget {
  Background();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("./assets/Background.png"),
          fit: BoxFit.cover,
        ),
      ),
      padding: EdgeInsets.only(top: 50.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 0.8, sigmaY: 0.8),
        child: Container(
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.0)),
        ),
      ),
    );
  }
}
