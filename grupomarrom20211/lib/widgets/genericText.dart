import 'package:flutter/material.dart';

//Widget que exibe textos com possibilidade de animação.
class GenericText extends StatelessWidget {
  final String text;
  final TextStyle textStyle;
  final TextAlign textAlign;
  const GenericText({Key? key, required this.text, required this.textStyle, this.textAlign = TextAlign.start}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _text(this.text, this.textStyle, this.textAlign);
  }

  Widget withAnimation(BuildContext context, String tag) {
    return Hero(tag: '$tag', child: Material(type: MaterialType.transparency, child: _text(this.text, this.textStyle, this.textAlign)));
  }
}

_text(String text, TextStyle textStyle, TextAlign textAlign) {
  return Text(
    text,
    textAlign: textAlign,
    style: textStyle,
  );
}
