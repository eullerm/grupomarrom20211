import 'package:flutter/material.dart';
import 'package:geocard/Theme.dart';
import 'package:geocard/credits.dart';
import 'package:geocard/widgets/background.dart';
import 'package:geocard/widgets/button.dart';
import 'package:geocard/widgets/time.dart';
import 'package:geocard/AutoRoute/AutoRoute.dart';
import 'package:geocard/AutoRoute/AutoRoute.gr.dart';

class Landing extends StatefulWidget {
  Landing();

  @override
  _LandingState createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(context),
    );
  }

  _body(context) {
    return Container(
      child: Stack(
        children: <Widget>[
          Background(background: "./assets/images/Background.png"),
          Container(
            padding: EdgeInsets.all(16.0),
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text(
                  "GEOCARD",
                  style: TextStyles.appTitle,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    // OtpTimer(),
                    Button(title: "Jogar", screen: ""),
                    Button(title: "Como jogar", screen: "Credits"),
                    Button(title: "Cartas", screen: "Credits"),
                    Button(title: "Créditos", screen: "Credits"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
