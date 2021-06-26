import 'package:flutter/material.dart';
import 'package:geocard/Theme.dart';
import 'package:geocard/widgets/background.dart';
import 'package:geocard/widgets/button.dart';
import 'package:geocard/widgets/cardInfo.dart';
import 'package:auto_route/auto_route.dart';
import 'package:geocard/widgets/title.dart';

class Contries extends StatefulWidget {
  Contries();

  @override
  _ContriesState createState() => _ContriesState();
}

class _ContriesState extends State<Contries> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(context),
    );
  }
}

_body(BuildContext context) {
  return Container(
    child: Stack(
      children: <Widget>[
        Background(background: "./assets/images/Background.png"),
        Container(
          padding: EdgeInsets.all(16.0),
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              // Título
              TextTitle(
                title: "GEOCARD",
              ).withArrowBack(context, screen: "Landing"),
              //Botões
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    _cards(),
                    _cards(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

_cards() {
  return CardInfo();
}
