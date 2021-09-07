import 'dart:async';
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
import 'const/cards.dart';
import 'dart:math';
import 'const/questions.dart';

class inGame extends StatefulWidget {
  final String player;
  final String id;
  final String token;
  final bool isLeader;
  const inGame({
    @PathParam('player') required this.player,
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
  int pointsPerCard = 15;
  var ids = new Set<int>();
  GlobalKey timerKey = GlobalKey();
  late OtpTimer timer = OtpTimer(whenTimeIsOver: () => _whenTimeIsOver(), whenTimeIsPaused: () => _whenTimeIsPaused(), key: timerKey);
  int numCardInGame = 5;
  int numQuestion = 3;
  bool getQuestion = true;
  bool isGame = true;
  bool isReset = false;
  late bool leader;

  late StreamSubscription listenResetTimer;
  late StreamSubscription listenFinishedPlayers;

  @override
  void initState() {
    var rand = new Random();
    leader = this.widget.isLeader;

    if (leader) {
      //Serve para resetar a quantidade de usuários prontos na sala privada
      database.collection("privateRoom").doc("${this.widget.token}").update({"startLevel": false, "count": 1});
    } else {
      //Cada usuário reseta seu status da sala privada
      database.collection("privateRoom").doc("${this.widget.token}").collection("users").doc("${this.widget.id}").update({"isReady": false});
    }

    for (int i = 0; i < numCardInGame; i++) {
      cardKey.add(UniqueKey());
      positions.add(-33);
    }
    if (leader) {
      while (ids.length != numQuestion) {
        ids.add(rand.nextInt(question.length));
      }
      _sendQuestion();
    }

    _newQuestion();
    _resetTimer();
    super.initState();
  }

  Future<bool> _willPopScopeCall() async {
    final shouldPop = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sair do jogo'),
        content: Text('Deseja realmente sair'),
        actions: <Widget>[
          MatchButton(
            title: "Sim",
            function: () {
              _removePlayer().whenComplete(() {
                setState(() {
                  isGame = false;
                });
                context.router.popUntilRouteWithName("Landing");
              });
            },
          ),
          MatchButton(
            title: "Não",
            function: () {
              context.router.pop();
            },
          ),
        ],
      ),
    );
    return shouldPop ?? false;
  }

  @override
  void dispose() {
    timerKey.currentState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //database.useFirestoreEmulator("localhost", 8080); //Emulador
    containerWidthCards = MediaQuery.of(context).size.width - 16;
    distanceCard = containerWidthCards / 5 - 16;

    return WillPopScope(
      onWillPop: _willPopScopeCall,
      child: Scaffold(
        body: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Background(background: "Background"),
            _body(),
          ],
        ),
      ),
    );
  }

  _body() {
    _winning();
    return Container(
      alignment: Alignment.topCenter,
      child: _game(),
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
            Stack(
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: AppColorScheme.iconColor,
                  ),
                  onPressed: _willPopScopeCall,
                ),
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
              ],
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
          point += pointsPerCard;
        }
      }
    }

    return point;
  }

  Future<void> _winning() async {
    if (!leader && isGame) {
      database.collection("inGame").doc("${this.widget.token}").get().then((DocumentSnapshot event) {
        setState(() {
          winningPlayer = event.get("winningPlayer");
        });
      });
    }
  }

  _savePoints({int timer = 0, int cards = 0}) {
    // Calcula o pontuação do timer de acordo com a porcentagem de resposta correta.
    int correctAnswers = cards ~/ pointsPerCard;
    double correctPercent = correctAnswers / numCorrectAnswer;
    timer = (timer * correctPercent).toInt();
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
    try {
      CollectionReference collection = database.collection("inGame").doc("${this.widget.token}").collection("users");
      if (leader) {
        //O líder fica responsável por verificar se todos já estão pronto para a próxima partida
        listenFinishedPlayers = collection.snapshots().listen((QuerySnapshot event) {
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

          //O líder avisa quando é para resetar o timer e qual é a questão que deve ser buscada.
          bool isResetTimer = false;
          int currentQuestion = 0;
          collection.get().then((QuerySnapshot snapshot) {
            collection.parent!.get().then((DocumentSnapshot value) {
              isResetTimer = value.get("resetTimer");
              currentQuestion = value.get("currentQuestion");
            }).whenComplete(() {
              if (!isResetTimer && countFinished == snapshot.size) {
                collection.parent!.update({"resetTimer": true, "winningPlayer": winningPlayer, "currentQuestion": currentQuestion + 1}).catchError(
                    (object) => print("error: ${object.toString()}"));
              }
            });
          });
        });
      }
      //Todos os jogadores ficam de olho no timer para saber quando resetar e buscar uma nova questão.
      listenResetTimer = collection.parent!.snapshots().listen((DocumentSnapshot event) {
        if (event.get("resetTimer")) {
          _newQuestion();

          if (leader) {
            event.reference.update({"resetTimer": false});
          }
        }
      });
    } catch (e) {
      print("Error: ${e.toString()}");
    }
  }

  //Busca a questão e as respostas para aquela questão
  Future _newQuestion() async {
    DocumentReference doc = database.collection("inGame").doc("${this.widget.token}");
    doc.get().then((DocumentSnapshot value) {
      int currentQuestion = value.get("currentQuestion");
      doc.collection("questions").doc("${currentQuestion}").get().then((DocumentSnapshot value) {
        if (value.exists) {
          correctAnswers = value.get("cards");
          gameCards = value.get("cards");
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
          doc.collection("users").doc("${this.widget.id}").get().then((DocumentSnapshot value) {
            var finished = value.get("finished");
            if (finished) {
              value.reference.update({"finished": false}).whenComplete(() {
                timerKey.currentState!.didUpdateWidget(timer);
                setState(() {
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
          listenResetTimer.cancel();
          if (leader) listenFinishedPlayers.cancel();
          context.router.pushNamed('/Winner/${this.widget.player}/${this.widget.id}/${this.widget.token}');
        }
      });
    });
  }

  // Responsável por dizer o número de cartas que responde aquela pergunta.
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

  Future<void> _removePlayer() async {
    // Recebe os valores do usuário no banco.
    listenResetTimer.cancel();
    if (leader) listenFinishedPlayers.cancel();
    CollectionReference collection = database.collection("privateRoom");
    DocumentReference room = collection.doc("${this.widget.token}");
    DocumentReference room2 = database.collection("inGame").doc("${this.widget.token}");
    DocumentSnapshot user = await room.collection("users").doc("${this.widget.id}").get();
    DocumentSnapshot user2 = await room2.collection("users").doc("${this.widget.id}").get();
    await collection.doc("${this.widget.token}").collection("users").doc("${this.widget.id}").delete();
    user2.reference.delete();
    // Verifica se é o líder.
    if (user.get("leader")) {
      QuerySnapshot users = await collection.doc("${this.widget.token}").collection("users").get();

      if (users.docs.isNotEmpty) {
        users.docs.first.reference.update({"leader": true}); // Transforma o proximo da fila em lider
      } else {
        room.collection("messages").snapshots().forEach((QuerySnapshot element) {
          // Exclui todas as mensagens da sala caso não exista um proximo usuário
          for (DocumentSnapshot ds in element.docs) {
            ds.reference.delete();
          }
        });
        // Exclui a sala vazia da coleção privateRoom

        room.delete();

        room2.collection("questions").snapshots().forEach((element) {
          // Exclui todas as questões, caso não existe um outro usuário
          for (DocumentSnapshot ds in element.docs) {
            ds.reference.delete();
          }
        });
        // Exclui a sala vazia da coleção inGame
        room2.delete();
      }
    }
  }
}
