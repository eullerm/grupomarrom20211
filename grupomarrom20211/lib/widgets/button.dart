import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:grupomarrom20211/Theme.dart';

class Button extends StatelessWidget {
  final String title;
  //final Widget widgetPage;
  final String screen;
  final bool pop;
  Button({required this.title, required this.screen, this.pop = false});

  @override
  Widget build(BuildContext context) {
    return _button(this.title, this.screen, this.pop, context);
  }

  Widget withShadow(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0xFF000000).withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 16.0,
            offset: Offset(0, 0.75),
          ),
        ],
      ),
      child: _button(this.title, this.screen, this.pop, context),
    );
  }
}

_button(String title, String screen, bool pop, BuildContext context) {
  return Container(
    width: 150,
    child: ButtonTheme(
      child: ElevatedButton(
        onPressed: () async {
          if (pop)
            context.router.popUntilRouteWithName('$screen');
          else
            context.router.pushNamed('$screen');
          //Navigator.push(
          //  context, MaterialPageRoute(builder: (context) => widgetPage));
        },
        child: _text(title),
        style: ElevatedButton.styleFrom(
          elevation: 10,
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
