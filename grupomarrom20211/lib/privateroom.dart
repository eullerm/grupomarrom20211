/* 
  Este .dart representa a sala onde os jogadores esperam antes de entrar na partida,
  nela temos o chat entre os usuários e os botões para começar a partida em si. O host
  espera os outros jogadores clicarem nos seus botões "Pronto", para então poder clicar em "Começar",
  iniciando a partida e levando todos os jogadores para a tela seguinte, definida em "inGame.dart".
  Assim como na inGame.dart, usamos o método checkConnection para tratar os valores do banco, caso 
  o jogador perca a conexão com o app.
*/

import 'dart:async';
import 'dart:math';
import 'package:auto_route/annotations.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grupomarrom20211/Theme.dart';
import 'package:grupomarrom20211/widgets/background.dart';
import 'package:grupomarrom20211/widgets/button.dart';
import 'package:grupomarrom20211/widgets/genericText.dart';
import 'package:auto_route/auto_route.dart';

class PrivateRoom extends StatefulWidget {
  final String player;
  final String id;
  final String token;

  const PrivateRoom({@PathParam('player') required this.player, @PathParam('id') required this.id, @PathParam('token') required this.token, Key? key})
      : super(key: key);

  @override
  _PrivateRoomState createState() => _PrivateRoomState();
}

class _PrivateRoomState extends State<PrivateRoom> with WidgetsBindingObserver {
  late bool isToken;
  bool isTyping = false;
  late String token;
  TextEditingController messageController = TextEditingController();
  final Connectivity _connectivity = Connectivity();
  final database = FirebaseFirestore.instance;
  ScrollController scrollController = ScrollController();

  // listener usado pelos outros usuários (que não são o host) para saber quando trocar para a tela da partida
  late StreamSubscription listenWaitingAdm;
  late Timer _send;
  late Timer _check;

  bool toStart = false;

  void _typing() {
    setState(() {
      FocusScopeNode currentFocus = FocusScope.of(context);
      isTyping = !isTyping;
      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }
    });
  }

  @override
  void initState() {
    // Caso o token seja a palavra token é porque a sala acabou de ser criada.
    if (this.widget.token != "token") {
      token = this.widget.token;
      isToken = true;
    } else {
      isToken = false;
    }

    _send = _sendTimestamp();
    _check = _checkConnection();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    return WillPopScope(
      onWillPop: _removePlayer,
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            Background(background: "Background"),
            _body(),
          ],
        ),
      ),
    );
  }

  users() {
    return Expanded(
      flex: 3,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              isToken
                  ? StreamBuilder<QuerySnapshot>(
                      stream: database
                          .collection("privateRoom")
                          .doc("${token}")
                          .collection("users")
                          .orderBy("leader", descending: true)
                          .orderBy("loggedAt")
                          .snapshots(),
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot>? snapshot) {
                        if (snapshot!.hasData) {
                          return Column(
                            children: snapshot.data!.docs.map<Widget>((DocumentSnapshot doc) {
                              bool leader = doc.get("leader");
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: GenericText(text: doc.get('name'), textStyle: TextStyles.plainText),
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  IgnorePointer(
                                    ignoring: doc.get("id") != this.widget.id,
                                    child: MatchButton(
                                      title: leader ? "Começar" : "Pronto",
                                      function: () async {
                                        int count = await countUsers();
                                        if (count >= 1 && leader) {
                                          setState(() {
                                            toStart = true;
                                          });
                                          start();
                                        } else if (!leader) {
                                          waitingAdm();
                                        } else {
                                          _showSnackBar("Necessário mais de 1 jogador.");
                                        }
                                      },
                                      isReady: leader ? false : doc.get("isReady"), // Botão de lider fica sem o highlight
                                    ),
                                  )
                                ],
                              );
                            }).toList(),
                          );
                        }
                        return Container();
                      })
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 5,
                          child: GenericText(text: this.widget.player, textStyle: TextStyles.plainText),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        MatchButton(title: "Começar", function: () => _showSnackBar("Necessário criar a sala.")),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  //Retorna a quantidade de usuarios na sala.
  Future<int> countUsers() async {
    CollectionReference collection = await database.collection("privateRoom");
    var count = 1;
    try {
      var result = await _connectivity.checkConnectivity();
      if (result != ConnectivityResult.none) {
        var aux = await collection.doc("${token}").collection("users");
        var snapshot = await aux.get();
        count = snapshot.size;
      }
    } on PlatformException catch (e) {
      _showSnackBar(e.toString());
    }
    return count;
  }

  //Função responsável por settar usuário como pronto e aguardar pelo admin para começar a partida.
  void waitingAdm() async {
    CollectionReference collection = await database.collection("privateRoom");
    try {
      var result = await _connectivity.checkConnectivity();
      if (result != ConnectivityResult.none) {
        DocumentSnapshot doc = await collection.doc("${token}").get();

        bool isReady = false;
        await doc.reference.collection("users").doc("${this.widget.id}").get().then((DocumentSnapshot value) {
          // Quando o usuário clica no botão de "Pronto", ele inverte o seu status
          isReady = !value.get("isReady");
        });
        isReady ? doc.reference.update({"count": doc.get("count") + 1}) : doc.reference.update({"count": doc.get("count") - 1});
        doc.reference.collection("users").doc("${this.widget.id}").update({"isReady": isReady});
        listenWaitingAdm = doc.reference.snapshots().listen((DocumentSnapshot event) {
          // Quando o host define o campo startLevel como true, a partida começa e os outros usuários são direcionados para a tela da partida
          if (event.get('startLevel')) {
            setState(() {
              toStart = false;
            });
            listenWaitingAdm.cancel();
            _send.cancel();
            _check.cancel();
            context.router.pushNamed('/inGame/${this.widget.player}/${this.widget.id}/${token}/${false}').whenComplete(() {
              _check = _checkConnection();
              _send = _sendTimestamp();
            });
          }
        });
      }
    } on PlatformException catch (e) {
      _showSnackBar(e.toString());
    }
  }

  //Função responsável pelo inicio da partida.
  start() async {
    CollectionReference collection = database.collection("privateRoom");

    try {
      var result = _connectivity.checkConnectivity();
      if (result != ConnectivityResult.none) {
        int total = await countUsers();
        collection.doc("${token}").get().then((DocumentSnapshot doc) {
          if (total == doc.get("count")) {
            _changingRoom();
          } else {
            setState(() {
              toStart = false;
            });
            _showSnackBar("Nem todos jogadores estão prontos.");
          }
        });
      } else {
        setState(() {
          toStart = false;
        });
        _showSnackBar("Cheque sua conexão.");
      }
    } on PlatformException catch (e) {
      _showSnackBar(e.toString());
    }
  }

  //Chat da sala privada.
  chat() {
    return Flexible(
      flex: 5,
      child: Container(
        width: MediaQuery.of(context).size.width - 16,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Flexible(
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: isToken
                      ? Column(
                          children: [
                            StreamBuilder<QuerySnapshot>(
                                stream: database.collection("privateRoom").doc("${token}").collection("messages").snapshots(),
                                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot>? snapshot) {
                                  if (snapshot!.hasData) {
                                    return Column(
                                      children: snapshot.data!.docs.map<Widget>((DocumentSnapshot doc) {
                                        return Column(
                                          children: [
                                            Row(
                                              children: [
                                                GenericText(text: doc.get('name') + ":", textStyle: TextStyles.plainText),
                                                SizedBox(width: 6),
                                                Expanded(
                                                  flex: 8,
                                                  child: Container(
                                                    padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                                                    child: GenericText(text: doc.get('text'), textStyle: TextStyles.plainText),
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(5.0),
                                                      color: Colors.black26,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 5),
                                          ],
                                        );
                                      }).toList(),
                                    );
                                  }
                                  return Container();
                                }),
                          ],
                        )
                      : SizedBox(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //Responsável por criar a sala privada no banco ao gerar um token
  Future _createPrivateRoom() async {
    CollectionReference collection = await database.collection("privateRoom");

    FieldValue timestamp = FieldValue.serverTimestamp();
    try {
      var result = await _connectivity.checkConnectivity();
      if (result != ConnectivityResult.none) {
        collection.doc("${token}").set({"createdAt": timestamp, "startLevel": false, "count": 1});
        collection.doc("${token}").collection("users").doc("${this.widget.id}").set({
          "name": this.widget.player,
          "isReady": true,
          "leader": true,
          "id": this.widget.id,
          "loggedAt": timestamp,
          "timestamp": timestamp,
        });
      } else {
        _showSnackBar("Cheque sua conexão com a internet.");
        setState(() {
          isToken = false;
        });
      }
    } on PlatformException catch (e) {
      _showSnackBar(e.toString());
      setState(() {
        isToken = false;
        token = "";
      });
    }
  }

  // Responsável pelo envio das mensagens para serem exibidas no chat da sala
  sendMessage() async {
    CollectionReference collection = await database.collection("privateRoom");
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    try {
      var result = await _connectivity.checkConnectivity();
      if (result != ConnectivityResult.none) {
        collection.doc("${token}").collection("messages").doc("${timestamp}").set({"name": this.widget.player, "text": messageController.text});
        setState(() {
          messageController.clear();
        });
      } else {
        _showSnackBar("Cheque sua conexão com a internet.");
        setState(() {
          isToken = false;
        });
      }
    } on PlatformException catch (e) {
      _showSnackBar(e.toString());
      setState(() {
        isToken = false;
      });

      return;
    }
  }

  // Responsável pelos snack bars de avisos do sistema
  _showSnackBar(String title) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        backgroundColor: AppColorScheme.snackBarColor.withOpacity(0.5),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Icon(
                Icons.report_problem,
                size: 20.0,
              ),
            ),
            SizedBox(width: 5),
            Expanded(
              flex: 7,
              child: GenericText(text: title, textStyle: TextStyles.plainText),
            ),
          ],
        ),
      ),
    );
  }

  generateToken() {
    return Flexible(
      flex: 1,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SelectableText(
                isToken ? token : "Token não gerado",
                style: TextStyles.plainText,
              ),
            ],
          ),
          IgnorePointer(
            ignoring: isToken,
            child: MatchButton(title: "Gerar token", function: () => _createToken()),
          )
        ],
      ),
    );
  }

  // Gera o token usado para identificar a sala privada e a da partida
  _createToken() {
    const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    const length = 5;

    setState(() {
      token = String.fromCharCodes(Iterable.generate(length, (_) => _chars.codeUnitAt(Random().nextInt(_chars.length))));
      Clipboard.setData(ClipboardData(text: token)).then((value) {
        _showSnackBar("Token copiado!");
      });
      isToken = true;
    });
    _createPrivateRoom();
  }

  textField() {
    return Row(
      children: <Widget>[
        Flexible(
          child: TextField(
            onTap: () => _typing(),
            controller: messageController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white70,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        SizedBox(width: 6),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: IconButton(
            icon: Icon(Icons.send),
            color: AppColorScheme.iconColor,
            onPressed: () {
              if (messageController.text != '' && isToken) {
                sendMessage();
              }
            },
          ),
        ),
      ],
    );
  }

  _body() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Stack(
            children: <Widget>[
              Row(
                children: <Widget>[
                  IconButton(
                    onPressed: () {
                      //_removePlayer();
                      context.router.pop();
                    },
                    icon: Icon(Icons.arrow_back),
                    color: AppColorScheme.iconColor,
                  )
                ],
              ),
              Row(
                children: <Widget>[
                  generateToken(),
                ],
              )
            ],
          ),
          SizedBox(height: 16),
          users(),
          SizedBox(height: 16),
          chat(),
          SizedBox(height: 8),
          textField(),
        ],
      ),
    );
  }

  //Leva os usuários para a sala de jogo
  void _changingRoom() {
    DocumentReference doc = database.collection("inGame").doc("${token}");
    doc.set({
      "createdAt": DateTime.now().millisecondsSinceEpoch,
      "resetTimer": false,
      "currentQuestion": 0,
      "winningPlayer": ["", 0, ""], //[Nome do jogador, número de pontos, id do device]
    });
    // O líder fica responsavel por gerar a sala de jogo e levar todos os usuários.
    // Pega a sala
    database.collection("privateRoom").doc("${token}").get().then((DocumentSnapshot snapshot) {
      // Percorre todos os usuários
      snapshot.reference.collection("users").snapshots().forEach((QuerySnapshot element) {
        // Envia para outra sala
        element.docs.forEach((QueryDocumentSnapshot user) {
          if (toStart) {
            doc.collection("users").doc(user.id).set({
              "name": user.get("name"),
              "points": 0,
              "finished": false, // Se o jogador terminou a jogada
              "leader": user.get("leader"),
              "id": user.get("id"),
              "loggedAt": user.get("loggedAt"),
              "timestamp": user.get("timestamp"),
            });
          }
        });
      });
    }).whenComplete(() {
      //Troca o usuário de sala.
      database.collection("privateRoom").doc("${token}").update({"startLevel": true}).whenComplete(() {
        setState(() {
          toStart = false;
        });
        _check.cancel();
        _send.cancel();
        context.router.pushNamed('/inGame/${this.widget.player}/${this.widget.id}/${token}/${true}').whenComplete(() {
          _check = _checkConnection();
          _send = _sendTimestamp();
        });
      });
    });
  }

  Future<bool> _removePlayer() async {
    if (isToken) {
      try {
        // Recebe os valores do usuário no banco.
        CollectionReference collection = database.collection("privateRoom");
        DocumentReference room = collection.doc("${token}");
        DocumentSnapshot user = await room.collection("users").doc("${this.widget.id}").get();
        // Deleta ele na privateRoom
        await collection.doc("${token}").collection("users").doc("${this.widget.id}").delete();

        CollectionReference collectionInGame = database.collection("inGame");
        DocumentSnapshot roomInGame = await collectionInGame.doc("${token}").get();
        // Deleta ele na inGame caso exista.
        if (roomInGame.exists) await roomInGame.reference.collection("users").doc("${this.widget.id}").delete();

        QuerySnapshot users = await collection.doc("${token}").collection("users").get();
        if (users.docs.isNotEmpty) {
          room.collection("users").get().then((value) {
            value.docs.forEach((element) {
              element.reference.update({"isReady": false});
            });
          }).whenComplete(() {
            room.update({"count": 1});

            // Verifica se é o líder.
            if (user.get("leader")) {
              database.collection("privateRoom").doc("${token}").collection("users").get().then((value) {
                value.docs.first.reference.update({"leader": true, "isReady": true}); // Transforma o proximo da fila em lider
              });
            }
          });
        } else {
          if (roomInGame.exists) await roomInGame.reference.delete();

          room.collection("messages").snapshots().forEach((QuerySnapshot element) {
            //Exclui todas as mensagens da sala caso não exista um proximo usuário
            for (DocumentSnapshot ds in element.docs) {
              ds.reference.delete();
            }
          });
          room.delete();
        }

        _check.cancel();
        _send.cancel();
      } catch (e) {}
    }
    return true;
  }

  // Responsável por verificar a conexão dos jogadores e fazer as operações de exclusão e a de passar o líder para outro jogador,
  // caso quem desconectou tenha sido o líder
  Timer _checkConnection() {
    return Timer.periodic(Duration(seconds: 10), (_) {
      if (isToken) {
        try {
          database.collection("privateRoom").doc("${token}").collection("users").get().then((usersInPrivateRoom) async {
            bool leaderDeleted = false;
            bool playerDeleted = false;
            DocumentSnapshot doc = await database.collection("privateRoom").doc("${token}").collection("users").doc("${this.widget.id}").get();
            CollectionReference doc2 = database.collection("inGame").doc("${token}").collection("users");
            if (doc.exists) {
              try {
                Timestamp timestamp = doc.get("timestamp");
                usersInPrivateRoom.docs.forEach((element) {
                  var userInPrivateRoom = element.data();
                  Timestamp userInPrivateRoomTimestamp = userInPrivateRoom["timestamp"];

                  // Se o timestamp do usuário for 12 segundos maior que o do usuário testado, o usuário testado é deletado da sala
                  if ((timestamp.seconds - userInPrivateRoomTimestamp.seconds) >= 12) {
                    element.reference.delete();

                    playerDeleted = true;

                    doc2.doc("${userInPrivateRoom['id']}").get().then((value) {
                      if (value.exists) {
                        value.reference.delete();
                      }
                    });

                    if (userInPrivateRoom["leader"]) {
                      leaderDeleted = true;
                    }
                  }
                });

                if (playerDeleted) {
                  doc.reference.parent
                      .get()
                      .then((value) => value.docs.forEach((element) {
                            // O estado dos botões de "Pronto" dos jogadores são resetados
                            element.reference.update({"isReady": false});
                          }))
                      .whenComplete(() {
                    // O número de jogadores "prontos" é resetado
                    doc.reference.parent.parent?.update({"count": 1});
                    if (leaderDeleted) {
                      listenWaitingAdm.cancel().catchError((onError) => print("${onError.toString()}"));

                      database.collection("privateRoom").doc("${token}").collection("users").get().then((value) {
                        value.docs.first.reference.update({"leader": true, "isReady": true});
                      });
                    }
                  });
                }
              } catch (e) {}
            }
          });
        } catch (e) {
          print("${e.toString()}");
        }
      }
    });
  }

  // Responsável por mandar o timestamp dos jogadores, mostrando que eles estão conectados no app
  Timer _sendTimestamp() {
    return Timer.periodic(Duration(seconds: 8), (_) {
      if (isToken) {
        try {
          database.collection("privateRoom").doc("${token}").collection("users").doc("${this.widget.id}").get().then((value) {
            if (value.exists) {
              value.reference.update({"timestamp": FieldValue.serverTimestamp()}).catchError((onError) {});
            } else {
              _check.cancel();
              _send.cancel();
            }
          });
        } catch (e) {
          database.collection("privateRoom").doc("${token}").get().then((value) {
            if (!value.exists) {
              _check.cancel();
              _send.cancel();
            }
          });
        }
      }
    });
  }
}
