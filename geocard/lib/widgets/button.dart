import 'package:flutter/material.dart';
import 'package:geocard/Theme.dart';

class Button extends StatelessWidget {
  final String title;

  Button({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      child: ButtonTheme(
        child: ElevatedButton(
          onPressed: () {},
          child: _text(this.title),
          style: ElevatedButton.styleFrom(
            elevation: 4,
            shadowColor: Colors.black,
            primary: C.buttonColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
          ),
        ),
      ),
    );
  }

  _text(String title) {
    return Text(
      title,
      style: TextStyles.buttonTitle,
    );
  }
}
