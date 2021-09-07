import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grupomarrom20211/Theme.dart';
import 'package:grupomarrom20211/widgets/background.dart';
import 'package:grupomarrom20211/widgets/button.dart';
import 'package:grupomarrom20211/widgets/genericText.dart';
import 'package:grupomarrom20211/widgets/title.dart';

class Winner extends StatefulWidget {
  final String player;
  final String id;
  final String token;
  const Winner({
    @PathParam('player') required this.player,
    @PathParam('id') required this.id,
    @PathParam('token') required this.token,
    Key? key,
  }) : super(key: key);

  @override
  _WinnerState createState() => _WinnerState();
}

class _WinnerState extends State<Winner> {
  final database = FirebaseFirestore.instance;
  GlobalKey titleKey = GlobalKey();
  List players = [];
  bool hasPlayer = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //database.useFirestoreEmulator("localhost", 8080);
    if (!hasPlayer) _getPlayers();
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

  _getPlayers() {
    database.collection("inGame").doc("${this.widget.token}").collection("users").orderBy("points", descending: true).get().then((value) {
      value.docs.forEach((element) {
        players.add([element.get("name"), element.get("points").toString()]);
      });
      setState(() {
        hasPlayer = true;
        players;
      });
    });
  }

  _body() {
    return Container(
      //color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          TextTitle(
            title: "Jogadores:",
            key: titleKey,
          ),
          Flexible(
            child: Container(
              height: MediaQuery.of(context).size.height / 2,
              //color: Colors.black,
              //constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height - titleKey.currentContext!.size!.height),
              child: Column(
                children: hasPlayer
                    ? _players()
                    : [
                        Center(
                          child: CircularProgressIndicator(),
                        )
                      ],
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              MatchButton(
                title: "Nova partida",
                function: () {
                  database
                      .collection("inGame")
                      .doc("${this.widget.token}")
                      .collection("questions")
                      .get()
                      .then((value) => value.docs.forEach((element) {
                            element.reference.delete();
                          }));
                  context.router.popUntilRouteWithName("PrivateRoom");
                },
                // *** Apagar documento da partida quando voltar para a página inicial ***
              ),
              SizedBox(height: 10),
              MatchButton(
                title: "Tela inicial",
                function: () async {
                  // Recebe os valores do usuário no banco.
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

                      room2.collection("questions").snapshots().forEach((QuerySnapshot element) {
                        // Exclui todas as questões, caso não existe um outro usuário
                        for (DocumentSnapshot ds in element.docs) {
                          ds.reference.delete();
                        }
                      });
                      // Exclui a sala vazia da coleção inGame
                      room2.delete();
                    }
                  }
                  context.router.popUntilRouteWithName("Landing");
                  // *** Apagar documento da partida quando voltar para a página inicial ***
                },
              ),
            ],
          )
        ],
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

  _players() {
    return players.map<Widget>((player) {
      return Row(
        children: <Widget>[
          SizedBox(width: 35),
          _medal(players.indexOf(player) + 1),
          SizedBox(width: 15),
          Flexible(
            flex: 7,
            child: FittedBox(fit: BoxFit.fitWidth, child: GenericText(text: player[0], textStyle: TextStyles.appTitle)),
          ),
          SizedBox(width: 15),
          Flexible(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FittedBox(fit: BoxFit.fitWidth, child: GenericText(text: "(${player[1]})", textStyle: TextStyles.plainText)),
              ],
            ),
          ),
          SizedBox(width: 30),
        ],
      );
    }).toList();
  }
}