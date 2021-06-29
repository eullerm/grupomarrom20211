import 'package:flutter/material.dart';

class GenericText extends StatelessWidget {
  final String text;
  final TextStyle textStyle;
  const GenericText({Key? key, required this.text, required this.textStyle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _text(this.text, this.textStyle);
  }

  Widget withAnimation(BuildContext context, String tag) {
    return Hero(
        tag: '$tag',
        child: Material(
            type: MaterialType.transparency,
            child: _text(this.text, this.textStyle)));
  }
}

_text(String text, TextStyle textStyle) {
  return Text("$text", style: textStyle);
}
