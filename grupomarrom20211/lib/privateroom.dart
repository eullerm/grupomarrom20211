import 'dart:math';

import 'package:auto_route/annotations.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
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

class _PrivateRoomState extends State<PrivateRoom> {
  late bool isToken;
  late String token;
  TextEditingController messageController = TextEditingController();
  final Connectivity _connectivity = Connectivity();
  final database = FirebaseDatabase.instance;

  void _typing() {
    setState(() {
      FocusScopeNode currentFocus = FocusScope.of(context);

      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }
    });
  }

  @override
  void initState() {
    print(this.widget.token.toString());
    //Caso o token seja a palavra token é porque a sala acabou de ser criada.
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
          Background(background: "./assets/images/Background.png"),
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
                                var db = await database.reference().child("privateRoom/${token}/${this.widget.id}").get();

                                if (db!.value["leader"]) {
                                  //Se o líder sair da sala ela é deletada.
                                  database.reference().child("privateRoom/${token}").remove();
                                } else {
                                  database.reference().child("privateRoom/${token}/${this.widget.id}").remove();
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
            children: [
              isToken
                  ? FirebaseAnimatedList(
                      shrinkWrap: true,
                      query: database.reference().child("privateRoom/${token}"),
                      itemBuilder: (BuildContext context, DataSnapshot snapshot, Animation<double> animation, int index) {
                        if (snapshot.key != "message") {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GenericText(text: snapshot.value['name'], textStyle: TextStyles.plainText),
                              IgnorePointer(
                                ignoring: snapshot.value["id"] != this.widget.id,
                                child: MatchButton(
                                  title: snapshot.value["leader"] ? "Começar" : "Pronto",
                                  function: () => start(snapshot.value["leader"]),
                                ),
                              )
                            ],
                          );
                        } else {
                          return SizedBox();
                        }
                      })
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GenericText(text: this.widget.player, textStyle: TextStyles.plainText),
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
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Row(
              children: <Widget>[
                Flexible(
                  child: TextField(
                    onTap: () => _typing(),
                    onChanged: (String value) {
                      setState(() {
                        messageController.text = value;
                      });
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
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
            )
          ],
        ),
      ),
    );
  }

  Future _createPrivateRoom() async {
    DatabaseReference reference = database.reference();
    try {
      var result = await _connectivity.checkConnectivity();
      if (result != ConnectivityResult.none) {
        reference
            .child("privateRoom/${token}/${this.widget.id}")
            .set({"name": this.widget.player, "isReady": true, "leader": true, "id": this.widget.id});
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

  sendMessage() {}

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
            Icon(
              Icons.report_problem,
              size: 20.0,
            ),
            SizedBox(width: 5),
            GenericText(text: title, textStyle: TextStyles.plainText),
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

      isToken = true;
    });
    _createPrivateRoom();
    if (!isToken) {
      setState(() {
        token = "";
      });
    }
  }
}
