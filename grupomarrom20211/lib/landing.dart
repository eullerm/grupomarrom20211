import 'package:flutter/material.dart';
import 'package:grupomarrom20211/widgets/background.dart';
import 'package:grupomarrom20211/widgets/button.dart';
import 'package:grupomarrom20211/widgets/title.dart';

//Tela inicial
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
                // Título
                Container(
                  height: MediaQuery.of(context).size.height / 3,
                  child: TextTitle(title: "GEOCARD"),
                ),
                //Botões
                Container(
                  height: MediaQuery.of(context).size.height / 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Button(title: "Jogar", screen: "/").withShadow(context),
                      Button(title: "Como jogar", screen: "/")
                          .withShadow(context),
                      Button(title: "Cartas", screen: "/Countries")
                          .withShadow(context),
                      Button(title: "Créditos", screen: "/Credits")
                          .withShadow(context),
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