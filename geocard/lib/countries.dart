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
              Divider(
                color: AppColorScheme.appText,
                height: 0,
                thickness: 0.5,
              ),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      _cards(),
                      _cards(),
                      _cards(),
                      _cards(),
                      _cards(),
                      _cards(),
                      _cards(),
                      _cards(),
                      _cards(),
                    ],
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
