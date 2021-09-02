import 'dart:io';
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
  List<double> positions = []; //Posição das cartas
  List<UniqueKey> cardKey = [];
  List userAnswer = [];
  List correctAnswers = [];
  final database = FirebaseFirestore.instance;
  List winningPlayer = ["", 0, ""];
  List question = Questions().questions;
  List allCountries = InfoCountry().countryName;
  String gameQuestion = "";
  List gameCards = [];
  int numCorrectAnswer = 0;
  var ids = new Set<int>();
  GlobalKey timerKey = GlobalKey();
  late OtpTimer timer = OtpTimer(whenTimeIsOver: () => _whenTimeIsOver(), whenTimeIsPaused: () => _whenTimeIsPaused(), key: timerKey);
  int numCardInGame = 5;
  int numQuestion = 3;
  bool getQuestion = true;
  bool isGame = true;
  bool isReset = false;

  @override
  void initState() {
    var rand = new Random();

    for (int i = 0; i < numCardInGame; i++) {
      cardKey.add(UniqueKey());
      positions.add(-33);
    }
    if (this.widget.isLeader) {
      while (ids.length != numQuestion) {
        ids.add(rand.nextInt(question.length));
      }
      _sendQuestion();
    }

    _newQuestion();
    _resetTimer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // database.useFirestoreEmulator("localhost", 8080); //Emulador
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
    _winning();
    return Container(
      alignment: Alignment.topCenter,
      child: isGame ? _game() : _winner(),
    );
  }

  _game() {
    return SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height + 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            //Quem ta ganhando
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(width: 30, child: Image.asset("assets/images/medals/goldMedal.png")),
                  SizedBox(width: 10),
                  GenericText(text: "${winningPlayer[0]}", textStyle: TextStyles.plainText)
                ],
              ),
            ),
            timer,

            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
      ),
    );
  }

  _whenTimeIsPaused() {
    String seconds = timerKey.currentState!.toString();
    //print("segundos: ${seconds}");
    _savePoints(timer: int.parse(seconds), cards: _checkAnswer());
  }

  _whenTimeIsOver() {
    _savePoints(cards: _checkAnswer());
  }

  _checkAnswer() {
    int point = 0;
    if (userAnswer.isNotEmpty) {
      for (int i = 0; i < userAnswer.length; i++) {
        if (correctAnswers.contains(userAnswer[i])) {
          point += 15;
        }
      }
    }

    return point;
  }

  Future<void> _winning() async {
    if (!this.widget.isLeader) {
      database.collection("inGame").doc("${this.widget.token}").get().then((DocumentSnapshot event) {
        setState(() {
          winningPlayer = event.get("winningPlayer");
        });
      });
    }
  }

  _savePoints({int timer = 0, int cards = 0}) {
    if (userAnswer.length != numCorrectAnswer) {
      //A pontuação do timer só valerá caso o usuário selecione todas as cartas que respondem a pergunta.
      timer = 0;
    }
    int point = 0;
    database.collection("inGame").doc("${this.widget.token}").collection("users").doc("${this.widget.id}").get().then((DocumentSnapshot value) {
      point = value.get("points");
      if (!value.get("finished")) {
        value.reference.update({"points": point + timer + cards});
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
              textStyle: TextStyles.plainText,
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

  _card(String name, int index) {
    return AnimatedPositioned(
      bottom: positions[index],
      left: index * distanceCard,
      right: (4 - index) * distanceCard,
      duration: Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (positions[index] != -33) {
              positions[index] = -33;
              userAnswer.remove(name);
            } else if (userAnswer.length < numCorrectAnswer) {
              positions[index] = 150;
              userAnswer.add(name);
            }
          });
        },
        child: Container(
          height: 200,
          child: CardObject(
            urlFront: 'assets/images/cards/${name}.png',
            urlBack: 'assets/images/Cardback.png',
            isInGame: true,
            key: cardKey[index],
          ),
        ),
      ),
    );
  }

  void _resetTimer() {
    CollectionReference collection = database.collection("inGame").doc("${this.widget.token}").collection("users");
    if (this.widget.isLeader) {
      //O líder fica responsável por verificar se todos já estão pronto para a próxima partida
      collection.snapshots().listen((QuerySnapshot event) {
        int countFinished = 0;
        event.docs.forEach((QueryDocumentSnapshot element) {
          if (element.get("finished") && isGame) {
            countFinished++;
          }
          if (element.get("points") > winningPlayer[1]) {
            setState(() {
              winningPlayer[0] = element.get("name");
              winningPlayer[1] = element.get("points");
              winningPlayer[2] = element.get("id");
            });
          }
        });

        print("count ${countFinished}");
        //O líder avisa quando é para resetar o timer e qual é a questão que deve ser buscada.
        bool isResetTimer = false;
        int currentQuestion = 0;
        collection.get().then((QuerySnapshot snapshot) {
          collection.parent!.get().then((DocumentSnapshot value) {
            isResetTimer = value.get("resetTimer");
            currentQuestion = value.get("currentQuestion");
          }).whenComplete(() {
            if (!isResetTimer && countFinished == snapshot.size) {
              collection.parent!.update({"resetTimer": true, "winningPlayer": winningPlayer, "currentQuestion": currentQuestion + 1}).whenComplete(
                  () => print("question: ${currentQuestion + 1}"));
            }
          });
        });
      });
    }
    //Todos os jogadores ficam de olho no timer para saber quando resetar e buscar uma nova questão.
    collection.parent!.snapshots().listen((DocumentSnapshot event) {
      if (event.get("resetTimer")) {
        _newQuestion();

        if (this.widget.isLeader) {
          event.reference.update({"resetTimer": false});
        }
      }
    });
  }

  //Busca a questão e as respostas para aquela questão
  Future _newQuestion() async {
    DocumentReference doc = database.collection("inGame").doc("${this.widget.token}");
    doc.get().then((DocumentSnapshot value) {
      int currentQuestion = value.get("currentQuestion");
      doc.collection("questions").doc("${currentQuestion}").get().then((DocumentSnapshot value) {
        if (value.exists) {
          correctAnswers = gameCards = value.get("cards");
          numCorrectAnswer = gameCards.length;
          gameQuestion = value.get("question");
          userAnswer = [];
          cardKey = [];
          positions = [];
          for (int i = 0; i < numCardInGame; i++) {
            cardKey.add(UniqueKey());
            positions.add(-33);
          }
          var rand = Random();
          while (numCardInGame - gameCards.length > 0) {
            int randomIndex = rand.nextInt(allCountries.length);
            if (!gameCards.contains(allCountries[randomIndex])) {
              gameCards.add(allCountries[randomIndex]);
            }
          }
          gameCards.shuffle();
          doc.collection("users").doc("${this.widget.id}").get().then((value) {
            var finished = value.get("finished");
            if (finished) {
              value.reference.update({"finished": false}).whenComplete(() {
                timerKey.currentState!.didUpdateWidget(timer);
                setState(() {
                  // timer;
                  timerKey;
                });
              });
            }
          });
          setState(() {
            gameCards;
            numCorrectAnswer;
            gameQuestion;
            correctAnswers;
            userAnswer;
            cardKey;
            positions;
          });
        } else {
          setState(() {
            isGame = false;
          });
        }
      });
    });
  }

  //Responsável por dizer o número de cartas que responde aquela pergunta.
  _numberOfAnswer() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Flexible(
            child: GenericText(
              text: "Respostas: ${userAnswer.length}/${numCorrectAnswer}",
              textStyle: TextStyles.plainText,
            ),
          ),
        ],
      ),
    );
  }

  _winner() {
    GlobalKey titleKey = GlobalKey();
    return Container(
      //color: Colors.black,
      child: Column(
        children: <Widget>[
          TextTitle(
            title: "Jogadores:",
            key: titleKey,
          ),
          Flexible(
            //color: Colors.black,
            //constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height - titleKey.currentContext!.size!.height),
            child: Stack(
              children: <Widget>[
                StreamBuilder<QuerySnapshot>(
                  stream: database
                      .collection("inGame")
                      .doc("${this.widget.token}")
                      .collection("users")
                      .orderBy("points", descending: true)
                      .snapshots()
                      .asBroadcastStream(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) _snapshotError(snapshot);

                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return Center(
                          child: CircularProgressIndicator(),
                        );

                      case ConnectionState.none:
                        return _snapshotEmpty();

                      case ConnectionState.active:
                        return Center(
                          child: ListView(
                            children: _players(snapshot),
                          ),
                        );

                      default:
                        return _snapshotEmpty();
                    }
                  },
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              MatchButton(
                  title: "Tela inicial",
                  function: () {
                    print("object");
                    context.router.popUntilRouteWithName("Landing");
                    // *** Apagar documento da partida quando voltar para a página inicial ***
                  }),
            ],
          )
        ],
      ),
    );
  }

  _snapshotError(AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
    return Container(
      child: Center(
        child: GenericText(text: snapshot.error.toString(), textStyle: TextStyles.screenTitle),
      ),
    );
  }

  _players(AsyncSnapshot snapshot) {
    List<List<String>> players = [];
    snapshot.data!.docs.forEach((QueryDocumentSnapshot element) {
      players.add([element.get("name"), element.get("points").toString(), element.get("id")]);
    });
    return players.map<Widget>((List<String> player) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _medal(players.indexOf(player) + 1),
          GenericText(text: player[0], textStyle: TextStyles.appTitle),
          GenericText(text: player[1], textStyle: TextStyles.plainText),
          GenericText(text: player[2], textStyle: TextStyles.smallText),
        ],
      );
    }).toList();
  }

  _snapshotEmpty() {
    return Container(
      child: Center(
        child: GenericText(text: "Houve um problema de conexão.", textStyle: TextStyles.screenTitle),
      ),
    );
  }

  _medal(int pos) {
    if (pos == 1) {
      return Container(width: 30, child: Image.asset("assets/images/medals/goldMedal.png"));
    } else if (pos == 2) {
      return Container(width: 30, child: Image.asset("assets/images/medals/silverMedal.png"));
    } else if (pos == 3) {
      return Container(width: 30, child: Image.asset("assets/images/medals/bronzeMedal.png"));
    } else {
      return Container();
    }
  }
}
