import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grupomarrom20211/widgets/background.dart';
import 'package:grupomarrom20211/widgets/button.dart';
import 'package:grupomarrom20211/widgets/timer.dart';
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
    SystemChrome.setEnabledSystemUIOverlays([]);
    return Scaffold(
      body: _body(context),
    );
  }

  _body(context) {
    return Container(
      child: Stack(
        children: <Widget>[
          BackgroundVideo(background: "assets/videos/BackgroundAnimated.mp4"),
          Container(
            padding: EdgeInsets.all(16.0),
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                // Título
                Flexible(
                  flex: 2,
                  child: TextTitle(title: "GEOCARD"),
                ),
                //Botões
                Flexible(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      //OtpTimer(),
                      Button(title: "Jogar", screen: "/Play").withShadow(context),
                      Button(title: "Como jogar", screen: "Landing").withShadow(context),
                      Button(title: "Cartas", screen: "/Countries").withShadow(context),
                      Button(title: "Créditos", screen: "/Credits").withShadow(context),
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
