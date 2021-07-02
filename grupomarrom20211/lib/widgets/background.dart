import 'package:flutter/material.dart';

//Widget que exibe o background das telas.
class Background extends StatelessWidget {
  final String background;
  Background({
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(this.background),
          fit: BoxFit.cover,
        ),
      ),
      padding: EdgeInsets.only(top: 50.0),
    );
  }
}
