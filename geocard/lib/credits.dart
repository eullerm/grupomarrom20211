import 'package:flutter/material.dart';
import 'package:geocard/Theme.dart';
import 'package:geocard/widgets/button.dart';
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
                // Título
                Container(
                  height: MediaQuery.of(context).size.height / 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Créditos",
                        style: TextStyles.screenTitle,
                      ),
                    ],
                  ),
                ),
                //Nomes
                Container(
                  height: MediaQuery.of(context).size.height / 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                      Button(title: "Voltar", screen: "/", pop: true)
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
