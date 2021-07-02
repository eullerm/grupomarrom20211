import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:grupomarrom20211/Theme.dart';
import 'package:auto_route/auto_route.dart';

//Widget responsável pela exibição dos títulos do app
class TextTitle extends StatelessWidget {
  final String title;
  final TextStyle textStyle;
  const TextTitle(
      {Key? key, required this.title, this.textStyle = TextStyles.appTitle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _appTitle(this.title, this.textStyle);
  }

  Widget withArrowBack(BuildContext context, {required String screen}) {
    return Container(
      width: double.infinity,
      child: Stack(
        children: [
          IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: AppColorScheme.appText,
              ),
              onPressed: () async {
                context.router.popUntilRouteWithName('$screen');
              }),
          _appTitle(this.title, this.textStyle),
        ],
      ),
    );
  }
}

_appTitle(String title, TextStyle textStyle) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      Text(
        title,
        style: textStyle,
      ),
    ],
  );
}
