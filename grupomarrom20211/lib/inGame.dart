import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:grupomarrom20211/Theme.dart';
import 'package:grupomarrom20211/widgets/background.dart';
import 'package:grupomarrom20211/widgets/button.dart';
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
  final bool isLeader;
  const inGame({
    @PathParam('id') required this.id,
    @PathParam('token') required this.token,
    @PathParam('isLeader') required this.isLeader,
    Key? key,
  }) : super(key: key);

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
  List question = Questions().questions;
  var ids = new Set<int>();
  GlobalKey timerKey = GlobalKey();
  late OtpTimer timer = OtpTimer(function: () => _savePoints(), key: timerKey);
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
    database.useFirestoreEmulator("localhost", 8080); //Emulador
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
    _resetTimer();

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
          timer,
          SizedBox(height: 10),
          MatchButton(
            title: "Enviar",
            function: () {
              print("object");
            },
          ),
          SizedBox(height: 10),
          // Pergunta e cartas
          _question(),

          /* //Cartas
          Container(
            height: 394,
            width: containerWidthCards,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: _cards(),
            ),
          ), */
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

  Future<void> _winner() async {
    if (!this.widget.isLeader) {
      await database.collection("inGame").doc("${this.widget.token}").collection("users").snapshots().listen((QuerySnapshot event) {
        event.docs.forEach((QueryDocumentSnapshot element) {
          if (element.get("points") > winningPlayer[1]) {
            setState(() {
              winningPlayer[0] = element.get("name");
              winningPlayer[1] = element.get("points");
            });
          }
        });
      });
    }
  }

  _savePoints() async {
    int point = 0;
    await database.collection("inGame").doc("${this.widget.token}").collection("users").doc("${this.widget.id}").get().then((DocumentSnapshot value) {
      point = value.get("points");
      if (!value.get("finished")) {
        value.reference.update({"points": point + 1});
        value.reference.update({"finished": true});
      }
    });
  }

  _sendQuestion() {
    ids.forEach((index) async {
      await database.collection("inGame").doc("${this.widget.token}").collection("questions").doc().set(question.asMap()[index]);
    });
  }

  _question() {
    return StreamBuilder<QuerySnapshot>(
        stream: database.collection("inGame").doc("${this.widget.token}").collection("questions").snapshots().first.asStream(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot>? snapshot) {
          if (snapshot!.hasData) {
            Map<String, dynamic> cards = snapshot.data!.docs.first.get("cards");
            List<String> countries = cards.keys.toList();
            return Column(children: <Widget>[
              Container(
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
              ),
              Container(
                height: 394,
                width: containerWidthCards,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: countries.map<Widget>((String country) => _card(country, countries.indexOf(country))).toList(),
                ),
              ),
            ]);
          }
          return Container();
        });
  }

  void _resetTimer() async {
    CollectionReference collection = database.collection("inGame").doc("${this.widget.token}").collection("users");
    if (this.widget.isLeader) {
      await collection.snapshots().listen((QuerySnapshot event) async {
        int countFinished = 0;
        event.docs.forEach((QueryDocumentSnapshot element) {
          if (element.get("finished")) {
            countFinished++;
            print("count ${countFinished}");
          }
          if (element.get("points") > winningPlayer[1]) {
            setState(() {
              winningPlayer[0] = element.get("name");
              winningPlayer[1] = element.get("points");
            });
          }
        });
        bool isNotResetTimer = true;
        QuerySnapshot snapshot = await collection.get();
        await collection.parent!.get().then((DocumentSnapshot value) => isNotResetTimer = !value.get("resetTimer"));
        if (isNotResetTimer && countFinished == snapshot.size) {
          await collection.parent!.update({"resetTimer": true, "winningPlayer": winningPlayer});
        }
      });
    }

    await collection.parent!.snapshots().listen((DocumentSnapshot event) {
      if (event.get("resetTimer")) {
        collection.doc("${this.widget.id}").update({"finished": false});
        setState(() {
          timerKey.currentState!.didUpdateWidget(timer);
        });
        if (this.widget.isLeader) {
          event.reference.update({"resetTimer": false});
        }
      }
    });
  }
}
