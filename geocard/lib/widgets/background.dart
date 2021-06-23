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
          image: AssetImage("images/Background.png"),
          fit: BoxFit.cover,
        ),
      ),
      padding: EdgeInsets.only(top: 50.0),
      child: Text(
        "Cute Cats of\nEducity",
        style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 38.0,
            height: 1.4,
            fontWeight: FontWeight.w600),
        textAlign: TextAlign.center,
      ),
    );
  }
}
