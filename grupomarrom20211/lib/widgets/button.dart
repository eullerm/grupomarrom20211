import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:grupomarrom20211/Theme.dart';

//Widget responsável por exibir os botões
class Button extends StatelessWidget {
  final String title;
  final String screen;
  final bool pop;
  final double width;
  Button({required this.title, this.screen = "", this.pop = false, this.width = 150});

  @override
  Widget build(BuildContext context) {
    return _button(this.title, this.screen, this.pop, context, this.width);
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
      child: _button(this.title, this.screen, this.pop, context, this.width),
    );
  }
}

_button(String title, String screen, bool pop, BuildContext context, double width) {
  return Container(
    width: width,
    child: ButtonTheme(
      child: ElevatedButton(
        onPressed: () async {
          if (pop)
            context.router.popUntilRouteWithName('$screen');
          else
            context.router.pushNamed('$screen');
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

class MatchButton extends StatelessWidget {
  final String title;
  final double width;
  final Function function;
  final bool isReady;
  const MatchButton({required this.title, this.width = 150, required this.function, this.isReady = false, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      child: _matchButton(this.title, context, this.width, this.function, this.isReady),
    );
  }
}

_matchButton(String title, BuildContext context, double width, Function function, bool isReady) {
  return Container(
    width: width,
    child: ButtonTheme(
      child: ElevatedButton(
        onPressed: () => function(),
        child: _text(title),
        style: ElevatedButton.styleFrom(
          elevation: 10,
          shadowColor: Colors.black,
          primary: AppColorScheme.buttonColor,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: isReady ? Color(0xFF197419) : Color(4278190080),
              width: isReady ? 2 : 0,
            ),
            borderRadius: BorderRadius.circular(32),
          ),
        ),
      ),
    ),
  );
}
