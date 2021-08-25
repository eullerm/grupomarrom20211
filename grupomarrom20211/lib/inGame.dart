import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:grupomarrom20211/Theme.dart';
import 'package:grupomarrom20211/widgets/background.dart';
import 'package:grupomarrom20211/widgets/cardObject.dart';
import 'package:grupomarrom20211/widgets/genericText.dart';
import 'package:grupomarrom20211/widgets/timer.dart';
import 'package:grupomarrom20211/widgets/title.dart';
import 'const/cards.dart';
import 'dart:math';

import 'const/questions.dart';

class inGame extends StatefulWidget {
  final String id;
  final String token;

  const inGame({@PathParam('id') required this.id, @PathParam('token') required this.token, Key? key}) : super(key: key);

  @override
  _inGameState createState() => _inGameState();
}

class _inGameState extends State<inGame> {
  late double containerWidthCards;
  late double distanceCard;
  int index = -1;
  List<double> positions = [-83, -83, -83, -83, -83]; //Posição das cartas
  final database = FirebaseFirestore.instance;
  List winningPlayer = ["", 0];

  //Map country = {};
  List question = Questions().questions;
  var ids = new Set<int>();
  List<String> cards = ["Japão", "Alemanha", "Brasil", "França", "Rússia"];

  @override
  void initState() {
    var rand = new Random();

    while (ids.length != 3) {
      ids.add(rand.nextInt(4));
    }
    _sendQuestion();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    containerWidthCards = MediaQuery.of(context).size.width - 16;
    distanceCard = containerWidthCards / 5 - 16;

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Background(background: "Background"),
          _body(),
        ],
      ),
    );
  }

  _body() {
    _winner();
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          //Quem ta ganhando
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(width: 30, child: Image.asset("assets/images/medals/goldMedal.png")),
                SizedBox(width: 10),
                GenericText(text: "${winningPlayer[0]}", textStyle: TextStyles.questions)
              ],
            ),
          ),
          SizedBox(height: 10),
          //Timer
          OtpTimer(
            function: () => _savePoints(),
          ),
          SizedBox(height: 10),
          // Pergunta
          _questionText(),

          //Cartas
          Container(
            height: 394,
            width: containerWidthCards,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: _cards(),
            ),
          ),
        ],
      ),
    );
  }

  _card(String name, int index) {
    return AnimatedPositioned(
      bottom: positions[index],
      left: index * distanceCard,
      right: (4 - index) * distanceCard,
      duration: Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (positions[index] != -83) {
              positions[index] = -83;
            } else {
              positions[index] = 150;
            }
          });
        },
        child: Container(
          height: 200,
          child: CardObject(
            urlFront: 'assets/images/cards/${name}.png',
            urlBack: 'assets/images/Cardback.png',
          ),
        ),
      ),
    );
  }

  _cards() {
    return <Widget>[
      _card(cards[0], 0),
      _card(cards[1], 1),
      _card(cards[2], 2),
      _card(cards[3], 3),
      _card(cards[4], 4),
    ];
  }

  Future<void> _winner() async {
    await database.collection("inGame").doc("${this.widget.token}").collection("users").snapshots().listen((event) {
      event.docs.forEach((QueryDocumentSnapshot element) {
        if (element.get("points") > winningPlayer[1]) {
          setState(() {
            winningPlayer[0] = element.get("name");
            winningPlayer[1] = element.get("points");
          });
        }
        print(winningPlayer[1]);
        print(element.get("points"));
      });
    });
  }

  _savePoints() async {
    int point = 0;
    await database.collection("inGame").doc("${this.widget.token}").collection("users").doc("${this.widget.id}").get().then((DocumentSnapshot value) {
      point = value.get("points");
      value.reference.update({"points": point + 1});
      value.reference.update({"finished": true});
    });
  }

  _sendQuestion() {
    ids.forEach((index) async {
      await database.collection("inGame").doc("${this.widget.token}").collection("questions").doc().set(question.asMap()[index]);
    });
  }

  _questionText() {
    return StreamBuilder<QuerySnapshot>(
        stream: database.collection("inGame").doc("${this.widget.token}").collection("questions").snapshots().first.asStream(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot>? snapshot) {
          if (snapshot!.hasData) {
            return Container(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: GenericText(
                      textAlign: TextAlign.center,
                      text: snapshot.data!.docs.first.get("question"),
                      textStyle: TextStyles.questions,
                    ),
                  ),
                ],
              ),
            );
          }
          return Container();
        });
  }
}
