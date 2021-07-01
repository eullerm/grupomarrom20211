import 'package:flutter/material.dart';
import 'package:geocard/Theme.dart';
import 'package:geocard/widgets/background.dart';
import 'package:geocard/widgets/cardObject.dart';
import 'package:geocard/widgets/title.dart';

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
                // Título
                TextTitle(
                  title: "Créditos",
                  textStyle: TextStyles.screenTitle,
                ).withArrowBack(context, screen: "Landing"),
                //Nomes
                Container(
                  height: MediaQuery.of(context).size.height / 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      /*Text(
                        "Arthur Zampirolli",
                        style: TextStyles.plainText,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Euller Macena",
                        style: TextStyles.plainText,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Hiaggo Machado",
                        style: TextStyles.plainText,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "João Matheus",
                        style: TextStyles.plainText,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Malkai Oliveira",
                        style: TextStyles.plainText,
                      ),*/
                      CardObject(
                          urlFront: 'assets/images/Front-test.png',
                          urlBack: 'assets/images/Cardback.png'),
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
}
