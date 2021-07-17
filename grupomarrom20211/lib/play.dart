import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:grupomarrom20211/widgets/background.dart';
import 'package:grupomarrom20211/widgets/button.dart';
import 'package:grupomarrom20211/widgets/title.dart';

class Play extends StatefulWidget {
  const Play({Key? key}) : super(key: key);

  @override
  _PlayState createState() => _PlayState();
}

class _PlayState extends State<Play> {
  TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(context),
    );
  }

  Widget _body(context) {
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
                Flexible(
                  flex: 2,
                  child: TextTitle(title: "").withArrowBack(context, screen: "Landing"),
                ),
                // Texto
                Flexible(
                  flex: 2,
                  child: TextField(
                    onChanged: (String value) {
                      setState(() {
                        nameController.text = value;
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
                //Botões
                Flexible(
                  flex: 10,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Button(
                        title: "Procurar uma partida",
                        screen: "/",
                        width: 250,
                      ).withShadow(context),

                      //Botão para teste
                      ElevatedButton(
                          onPressed: () {
                            print(nameController.text);
                          },
                          child: Text("Teste"))
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
