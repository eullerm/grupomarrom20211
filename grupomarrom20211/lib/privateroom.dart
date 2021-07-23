import 'package:flutter/material.dart';
import 'package:grupomarrom20211/Theme.dart';
import 'package:grupomarrom20211/widgets/background.dart';
import 'package:grupomarrom20211/widgets/button.dart';
import 'package:grupomarrom20211/widgets/genericText.dart';

class PrivateRoom extends StatefulWidget {
  const PrivateRoom({Key? key}) : super(key: key);

  @override
  _PrivateRoomState createState() => _PrivateRoomState();
}

class _PrivateRoomState extends State<PrivateRoom> {
  bool isToken = false;
  late String token;
  TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Background(background: "./assets/images/Background.png"),
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    GenericText(
                      text: isToken ? token : "Token não gerado",
                      textStyle: TextStyles.plainText,
                    ),
                  ],
                ),
                MatchButton(title: "Gerar código de partida", function: () => createToken()),
                users(),
                chat(),
              ],
            ),
          )
        ],
      ),
    );
  }

  users() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
        ),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GenericText(text: "Usuário", textStyle: TextStyles.plainText),
          MatchButton(
            title: "Pronto",
            function: () => start(),
          ),
        ],
      ),
    );
  }

  start() {
    print("Nicolas Cagezin");
  }

  chat() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
        ),
        borderRadius: BorderRadius.circular(10.0),
      ),
      height: MediaQuery.of(context).size.height / 3,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Row(
            children: <Widget>[
              Flexible(
                child: TextField(
                  onChanged: (String value) {
                    setState(() {
                      messageController.text = value;
                    });
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Insira seu nome',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              MatchButton(title: "Enviar", function: () => sendMessage())
            ],
          )
        ],
      ),
    );
  }

  createToken() {
    setState(() {
      token = "zarabatana";
      isToken = true;
    });
  }

  sendMessage() {}
}
