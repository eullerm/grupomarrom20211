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
    );
  }
}
