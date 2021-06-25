import 'package:flutter/material.dart';
import 'package:geocard/Theme.dart';
import 'package:geocard/credits.dart';

class Button extends StatelessWidget {
  final String title;
  final Widget widgetPage;

  Button({required this.title, required this.widgetPage});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      child: ButtonTheme(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => widgetPage));
          },
          child: _text(this.title),
          style: ElevatedButton.styleFrom(
            elevation: 4,
            shadowColor: Colors.black,
            primary: AppColorScheme.buttonColor,
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
