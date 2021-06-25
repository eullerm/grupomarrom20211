import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:geocard/Theme.dart';
import 'package:geocard/credits.dart';

class Button extends StatelessWidget {
  final String title;
  //final Widget widgetPage;
  final String screen;
  Button({required this.title, required this.screen});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      child: ButtonTheme(
        child: ElevatedButton(
          onPressed: () async {
            context.router.pushNamed('/$screen');
            //Navigator.push(
            //  context, MaterialPageRoute(builder: (context) => widgetPage));
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
