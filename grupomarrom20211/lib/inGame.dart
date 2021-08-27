import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:grupomarrom20211/AutoRoute/AutoRoute.gr.dart';
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
  List allCountries = InfoCountry().countryName;
  String gameQuestion = "";
  List gameCards = [];
  int numCorrectAnswer = 0;
  var ids = new Set<int>();
  GlobalKey timerKey = GlobalKey();
  late OtpTimer timer = OtpTimer(function: () => _savePoints(), key: timerKey);
  int numCardInGame = 5;
  int numQuestion = 3;
  bool getQuestion = true;

  @override
  void initState() {
    var rand = new Random();

    while (ids.length != numQuestion) {
      ids.add(rand.nextInt(question.length));
    }
    _sendQuestion();
    _newQuestion();
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
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              //Numero de perguntas corretas na partida
              _numberOfAnswer(),
              // Pergunta
              _question(),
              //Cartas
              _cards(),
            ],
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

  Future<void> _winner() async {
    if (!this.widget.isLeader) {
      await database.collection("inGame").doc("${this.widget.token}").snapshots().listen((DocumentSnapshot event) {
        setState(() {
          winningPlayer[0] = event.get("name");
          winningPlayer[1] = event.get("points");
        });
      });
    }
  }

  _savePoints() {
    int point = 0;
    database.collection("inGame").doc("${this.widget.token}").collection("users").doc("${this.widget.id}").get().then((DocumentSnapshot value) {
      point = value.get("points");
      if (!value.get("finished")) {
        value.reference.update({"points": point + 1});
        value.reference.update({"finished": true});
      }
    });
  }

  _sendQuestion() {
    int count = 0;
    ids.forEach((index) {
      database.collection("inGame").doc("${this.widget.token}").collection("questions").doc("${count}").set(question.asMap()[index]);
      count++;
    });
  }

  _question() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Flexible(
            child: GenericText(
              textAlign: TextAlign.center,
              text: gameQuestion,
              textStyle: TextStyles.questions,
            ),
          ),
        ],
      ),
    );
  }

  _cards() {
    return Container(
      height: 355,
      width: containerWidthCards,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: gameCards.map<Widget>((country) => _card(country, gameCards.indexOf(country))).toList(),
      ),
    );
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
        bool isToResetTimer = false;
        int currentQuestion = 0;
        QuerySnapshot snapshot = await collection.get();
        await collection.parent!.get().then((DocumentSnapshot value) {
          isToResetTimer = !value.get("resetTimer");
          currentQuestion = value.get("currentQuestion");
        });
        if (isToResetTimer && countFinished == snapshot.size) {
          await collection.parent!.update({"resetTimer": true, "winningPlayer": winningPlayer, "currentQuestion": currentQuestion + 1});
        }
      });
    }

    await collection.parent!.snapshots().listen((DocumentSnapshot event) {
      if (event.get("resetTimer")) {
        _newQuestion();
        collection.doc("${this.widget.id}").update({"finished": false});

        if (this.widget.isLeader) {
          event.reference.update({"resetTimer": false});
        }
        setState(() {
          timerKey.currentState!.didUpdateWidget(timer);
        });
      }
    });
  }

  void _newQuestion() {
    DocumentReference doc = database.collection("inGame").doc("${this.widget.token}");
    doc.get().then((DocumentSnapshot value) {
      int currentQuestion = value.get("currentQuestion");
      doc.collection("questions").doc("${currentQuestion}").get().then((value) {
        if (value.exists) {
          gameCards = value.get("cards");
          numCorrectAnswer = gameCards.length;
          gameQuestion = value.get("question");
          var rand = Random();
          while (numCardInGame - gameCards.length > 0) {
            int randomIndex = rand.nextInt(allCountries.length);
            if (!gameCards.contains(allCountries[randomIndex])) {
              gameCards.add(allCountries[randomIndex]);
            }
          }
          gameCards.shuffle();
          setState(() {
            gameCards;
            numCorrectAnswer;
            gameQuestion;
          });
        } else {
          print("Fim de jogo");
        }
      });
    });
  }

  _numberOfAnswer() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Flexible(
            child: GenericText(
              text: "Respostas: x/${numCorrectAnswer}",
              textStyle: TextStyles.questions,
            ),
          ),
        ],
      ),
    );
  }
}
