/* 
  Este .dart representa a tela da partida, nela temos todo o funcionamento
  do jogo em si. Cada partida tem 3 rodadas. O jogador pode enviar a resposta 
  antes do tempo acabar ou esperar o timer chegar a zero, quando todos jogadores
  enviarem a resposta ou o timer de todos chegar a zero, uma nova rodada começa. 
  No final da terceira rodada, os jogadores são levados para a tela de final de partida,
  onde os jogadores aparecem em ordem de pontos. O método checkConnection apaga os dados 
  de um jogador no banco, caso o mesmo fique inativo por alguns segundos. A cada rodada todos "n"
  jogadores enviam um timestamp para o servidor e todos jogadores checam se o timestamp do servidor
  menos o timestamp do jogador "i" é maior que 12, caso sim, é considerado que o jogador perdeu 
  a conexão e ele é excluído do banco e da partida.
*/

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
  late Timer _check;

  late StreamSubscription listenResetTimer;
  late StreamSubscription listenFinishedPlayers;

  @override
  void initState() {
    var rand = new Random();
    leader = this.widget.isLeader;

    // Cria os jogadores no banco
    if (leader) {
      //Serve para resetar a quantidade de usuários prontos na sala privada
      database.collection("privateRoom").doc("${this.widget.token}").update({"startLevel": false, "count": 1});
    } else {
      //Cada usuário reseta seu status da sala privada
      database.collection("privateRoom").doc("${this.widget.token}").collection("users").doc("${this.widget.id}").update({"isReady": false});
    }

    // Coloca a posição de cada carta na tela
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
    _check = _checkConnection();
    super.initState();
  }

  // Pop up para sair da partida
  Future<bool> _willPopScopeCall() async {
    final shouldPop = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColorScheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Sair do jogo'),
        content: Text('Deseja realmente sair?'),
        actions: <Widget>[
          Container(
            alignment: Alignment.center,
            child: Column(
              children: [
                MatchButton(
                  title: "Sim",
                  function: () {
                    _removePlayer().whenComplete(() {
                      _check.cancel();
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

  // Tela da partida em si, com as cartas, timer e jogador que está ganhando no momento
  _game() {
    return SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height + 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            // Quem ta ganhando
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

  // Responsável por salvar os pontos quando o botão "Enviar" é clicado
  _whenTimeIsPaused() {
    String seconds = timerKey.currentState!.toString();
    _savePoints(timer: int.parse(seconds), cards: _checkAnswer());
  }

  // Responsável por salvar os pontos quando o tempo chega a zero
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

  // Retorna o jogador que está ganhando no momento
  Future<void> _winning() async {
    if (!leader && isGame) {
      database.collection("inGame").doc("${this.widget.token}").get().then((DocumentSnapshot event) {
        if (event.exists) {
          setState(() {
            winningPlayer = event.get("winningPlayer");
          });
        }
      });
    }
  }

  // Calcula o pontuação do jogador, usando o timer de acordo com a porcentagem de resposta correta.
  _savePoints({int timer = 0, int cards = 0}) {
    int correctAnswers = cards ~/ pointsPerCard;
    double correctPercent = correctAnswers / numCorrectAnswer;
    timer = (timer * correctPercent).toInt();
    int point = 0;
    database.collection("inGame").doc("${this.widget.token}").collection("users").doc("${this.widget.id}").get().then((DocumentSnapshot value) {
      point = value.get("points");
      if (!value.get("finished")) {
        value.reference.update({"points": point + timer + cards, "finished": true, "timestamp": FieldValue.serverTimestamp()});
      }
    });
  }

  // Envia as questões para o banco
  _sendQuestion() {
    int count = 0;
    ids.forEach((index) {
      database.collection("inGame").doc("${this.widget.token}").collection("questions").doc("${count}").set(question.asMap()[index]);
      count++;
    });
  }

  // Responsável por exibir as questões na tela
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

  // Responsável pela exibição das cartas
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
          int countFinished = 0; // Contador usado para garantir que todos os jogadores estão prontos antes de iniciar a partida
          event.docs.forEach((QueryDocumentSnapshot element) {
            if (element.get("finished") && isGame) {
              countFinished++;
            }

            // Se o ganhador jogador
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
                if (leader) {
                  doc.update({"resetTimer": false});
                }
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
          _check.cancel();
          context.router.pushNamed('/Winner/${this.widget.player}/${this.widget.id}/${this.widget.token}');
          if (leader) {
            listenFinishedPlayers.cancel();
          }
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

  // Método responsável por checar e tratar caso um jogador, host ou não, perca a conexão
  Timer _checkConnection() {
    return Timer.periodic(Duration(seconds: 14), (_) {
      database.collection("inGame").doc("${this.widget.token}").collection("users").get().then((usersInGame) {
        database.collection("privateRoom").doc("${this.widget.token}").collection("users").get().then((users) async {
          bool leaderDeleted = false;
          DocumentSnapshot doc = await database.collection("inGame").doc("${this.widget.token}").collection("users").doc("${this.widget.id}").get();
          try {
            Timestamp timestamp = doc.get("timestamp");

            usersInGame.docs.forEach((element) {
              var userInGame = element.data();
              Timestamp userInGameTimestamp = userInGame["timestamp"];
              if ((timestamp.seconds - userInGameTimestamp.seconds).abs() >= 12) {
                element.reference.delete();

                if (userInGame["leader"]) leaderDeleted = true;

                users.docs.forEach((userPrivateRoom) {
                  if (userPrivateRoom.id == userInGame["id"]) {
                    userPrivateRoom.reference.delete();
                  }
                });
              }
            });
          } catch (e) {
            print("${e.toString()}");
          }
          if (leaderDeleted) {
            database.collection("inGame").doc("${this.widget.token}").collection("users").get().then((value) {
              value.docs.first.reference.update({"leader": true}).whenComplete(() {
                // Verifica no banco se ele é o novo lider.
                if (value.docs.first.id == this.widget.id) {
                  setState(() {
                    leader = true;
                  });
                  // Reseta o timer
                  listenResetTimer.cancel();
                  _resetTimer();
                }
              });
            });

            database
                .collection("privateRoom")
                .doc("${this.widget.token}")
                .collection("users")
                .get()
                .then((value) => value.docs.first.reference.update({"leader": true}));
          }
        });
      });
    });
  }
}
