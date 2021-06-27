import 'package:flutter/material.dart';
import 'package:geocard/Theme.dart';
import 'package:geocard/widgets/background.dart';
import 'package:geocard/widgets/button.dart';
import 'package:geocard/widgets/cardInfo.dart';
import 'package:auto_route/auto_route.dart';
import 'package:geocard/widgets/title.dart';

class Countries extends StatefulWidget {
  Countries();

  @override
  _CountriesState createState() => _CountriesState();
}

class _CountriesState extends State<Countries> {
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
          padding: EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              // Título
              TextTitle(
                title: "Cartas",
                textStyle: TextStyles.screenTitle,
              ).withArrowBack(context, screen: "Landing"),
              // Cards
              Flexible(
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.white, Colors.white.withOpacity(0.05)],
                      stops: [0.95, 1],
                      tileMode: TileMode.mirror,
                    ).createShader(bounds);
                  },
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 12),
                        _cards(),
                        _cards(),
                        _cards(),
                        _cards(),
                        _cards(),
                        _cards(),
                        _cards(),
                        _cards(),
                        _cards(),
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
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

  /*Flexible(
    child: Container(
      child: ListView.builder(
        itemCount: 2,
        itemBuilder: (_, index) => CardInfo(),
      ),
    ),
  );*/
}
