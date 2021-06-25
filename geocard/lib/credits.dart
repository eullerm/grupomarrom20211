import 'package:flutter/material.dart';
import 'package:geocard/Theme.dart';
import 'package:geocard/widgets/time.dart';
import 'package:geocard/widgets/background.dart';

class Credits extends StatefulWidget {
  Credits();

  @override
  _CreditsState createState() => _CreditsState();
}

class _CreditsState extends State<Credits> {
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
            padding: EdgeInsets.all(10.0),
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(
                  "Créditos",
                  style: TextStyles.screenTitle,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Text(
                      "Arthur Zampirolli",
                      style: TextStyles.plainText,
                    ),
                    Text(
                      "Euller Macena",
                      style: TextStyles.plainText,
                    ),
                    Text(
                      "Hiaggo Machado",
                      style: TextStyles.plainText,
                    ),
                    Text(
                      "João Matheus",
                      style: TextStyles.plainText,
                    ),
                    Text(
                      "Malkai Oliveira",
                      style: TextStyles.plainText,
                    ),
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
