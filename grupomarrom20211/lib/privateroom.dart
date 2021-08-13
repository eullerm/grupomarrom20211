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

  void _typing() {
    setState(() {
      FocusScopeNode currentFocus = FocusScope.of(context);
      isTyping = !isTyping;
      print(isTyping.toString());
      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }
    });
  }

  @override
  void initState() {
    print(this.widget.token.toString());
    // Caso o token seja a palavra token é porque a sala acabou de ser criada.
    if (this.widget.token != "token") {
      token = this.widget.token;
      isToken = true;
    } else {
      isToken = false;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Background(background: "Background"),
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        IconButton(
                          onPressed: () async {
                            if (isToken) {
                              try {
                                // Recebe os valores do usuário no banco.
                                CollectionReference collection = database.collection("privateRoom");
                                DocumentReference<Object?> room = collection.doc("${token}");
                                DocumentSnapshot<Object?> user = await room.collection("users").doc("${this.widget.id}").get();

                                await collection.doc("${token}").collection("users").doc("${this.widget.id}").delete();
                                // Verifica se é o líder.
                                if (user.get("leader")) {
                                  QuerySnapshot users = await collection.doc("${token}").collection("users").get();

                                  if (users.docs.isNotEmpty) {
                                    users.docs.first.reference.update({"leader": true}); //Transforma o proximo da fila em lider
                                  } else {
                                    room.collection("messages").snapshots().forEach((QuerySnapshot element) {
                                      for (DocumentSnapshot ds in element.docs) {
                                        ds.reference.delete();
                                      }
                                    });
                                    room.delete();
                                  }

                                  //doc("${this.widget.id}").delete();
                                }
                              } catch (e) {}
                            }
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
          )
        ],
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
                      stream: database.collection("privateRoom").doc("${token}").collection("users").orderBy("timestamp").snapshots(),
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot>? snapshot) {
                        if (snapshot!.hasData) {
                          return Column(
                            children: snapshot.data!.docs.map<Widget>((DocumentSnapshot doc) {
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
                                      title: doc.get("leader") ? "Começar" : "Pronto",
                                      function: () => start(doc.get("leader")),
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
                        MatchButton(
                          title: "Começar",
                          function: () => start(true),
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  start(bool isLeader) {
    print("Nicolas Cagezin");
  }

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

  Future _createPrivateRoom() async {
    CollectionReference collection = await database.collection("privateRoom");

    int timestamp = DateTime.now().millisecondsSinceEpoch;
    try {
      var result = await _connectivity.checkConnectivity();
      if (result != ConnectivityResult.none) {
        collection.doc("${token}").set({"createdAt": timestamp});
        collection.doc("${token}").collection("users").doc("${this.widget.id}").set({
          "name": this.widget.player,
          "isReady": true,
          "leader": true,
          "id": this.widget.id,
          "timestamp": timestamp,
        });
      } else {
        _showSnackBar("Cheque sua conexão com a internet");
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
        _showSnackBar("Cheque sua conexão com a internet");
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
            child: MatchButton(title: "Gerar token", function: () => createToken()),
          )
        ],
      ),
    );
  }

  createToken() {
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
            onPressed: () => sendMessage(),
          ),
        ),
      ],
    );
  }
}
