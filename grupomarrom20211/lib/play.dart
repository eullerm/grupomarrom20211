import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:grupomarrom20211/Theme.dart';
import 'package:grupomarrom20211/widgets/background.dart';
import 'package:grupomarrom20211/widgets/button.dart';
import 'package:grupomarrom20211/widgets/genericText.dart';
import 'package:grupomarrom20211/widgets/title.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:auto_route/auto_route.dart';

class Play extends StatefulWidget {
  const Play({Key? key}) : super(key: key);

  @override
  _PlayState createState() => _PlayState();
}

class _PlayState extends State<Play> with WidgetsBindingObserver {
  TextEditingController nameController = TextEditingController();
  TextEditingController tokenController = TextEditingController();
  final database = FirebaseFirestore.instance;
  String? _deviceId;
  String _idGuest = "";
  String _nameGuest = "";
  bool waiting = false;
  bool waitingAccept = false;
  bool hasPopup = false;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription inviteListener;
  GlobalKey dialogKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    initPlatformState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused && waiting) {
      _connect("waiting");
    }
  }

  Future<void> initPlatformState() async {
    String? deviceId;

    try {
      deviceId = await PlatformDeviceId.getDeviceId;
    } on PlatformException {
      deviceId = null;
    }

    setState(() {
      _deviceId = deviceId;
    });
  }

  @override
  Widget build(BuildContext context) {
    //database.useFirestoreEmulator("localhost", 8080); //Emulador

    SystemChrome.setEnabledSystemUIOverlays([]);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          Background(background: "Background"),
          Container(
            padding: EdgeInsets.all(16.0),
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                // Título
                Flexible(
                  flex: 2,
                  child: TextTitle(
                    title: waiting ? "Procurando" : "",
                    textStyle: TextStyles.screenTitle,
                  ).withArrowBack(context, screen: "Landing"),
                ),
                // Texto
                Flexible(
                  flex: 3,
                  child: TextField(
                    maxLength: 15,
                    onChanged: (String value) {
                      setState(() {
                        nameController.text = value;
                      });
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Insira seu nome (até 15 caracteres)',
                      counterStyle: TextStyles.smallText,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                //Botões
                Flexible(
                  flex: 10,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      SizedBox(
                        height: 50,
                        width: 50,
                        child: waiting
                            ? CircularProgressIndicator(
                                color: AppColorScheme.iconColor,
                              )
                            : SizedBox(),
                      ),
                      MatchButton(
                        title: waiting ? "Cancelar" : "Procurar uma partida",
                        width: waiting ? 150 : 250,
                        function: () => _connect("waiting"),
                      ),
                      MatchButton(
                        title: "Criar sala",
                        function: () {
                          if (nameController.text.isNotEmpty && _deviceId != null) {
                            context.router.pushNamed('/PrivateRoom/${nameController.text}/${_deviceId!}/token/');
                          } else {
                            if (nameController.text.isEmpty)
                              _showSnackBar("Insira um nome antes de continuar.");
                            else
                              _showSnackBar("Houve um problema.");
                          }
                        },
                      ),
                      MatchButton(
                        title: "Entrar na sala",
                        function: () {
                          if (nameController.text.isNotEmpty && _deviceId != null) {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    backgroundColor: AppColorScheme.cardColor.withOpacity(0.2),
                                    title: GenericText(
                                      text: "Token da sala",
                                      textStyle: TextStyles.plainText,
                                    ),
                                    content: TextField(
                                      onChanged: (String value) {
                                        setState(() {
                                          tokenController.text = value;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        hintText: '42Ad5Rafd6f1Lr159PcT',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                    ),
                                    actions: <Widget>[
                                      MatchButton(
                                        title: "Entrar",
                                        function: () {
                                          context.router.pop();
                                          _connect("privateRoom");
                                        },
                                      ),
                                    ],
                                  );
                                });
                          } else {
                            if (nameController.text.isEmpty)
                              _showSnackBar("Insira um nome antes de continuar.");
                            else
                              _showSnackBar("Houve um problema.");
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Conecta os jogadores no banco
  Future _connect(String type, {bool host = false, bool invited = false}) async {
    CollectionReference collection = database.collection("${type}");
    try {
      var result = await _connectivity.checkConnectivity();
      if (result != ConnectivityResult.none && nameController.text.isNotEmpty) {
        if (waiting && !invited) {
          inviteListener.cancel();
          await collection.doc("${_deviceId}").delete();
          setState(() {
            waiting = false;
          });
        } else {
          if (_deviceId != null) {
            if (type == "waiting") {
              collection.get().then((QuerySnapshot snapshot) {
                if (snapshot.docs.isEmpty) {
                  _waitingInvite(collection);
                } else {
                  _playersInQueue(collection);
                }
              });
            } else if (type == "privateRoom") {
              if (tokenController.text.isNotEmpty) {
                int timestamp = DateTime.now().millisecondsSinceEpoch;

                // Caso tenha convidado um jogador na fila de espera é que esse set deve ser realizado.
                // Tanto o host quanto o convidado realizam ele pois pode ser que um tente acessar o documento sem que ele exista.
                if (host || invited) collection.doc("${tokenController.text}").set({"createdAt": timestamp, "startLevel": false, "count": 1});

                bool exist = false;
                DocumentSnapshot<Object?> snapshot = await collection.doc("${tokenController.text}").get();
                exist = snapshot.exists;
                if (exist) {
                  // Precisa checar se existe a sala com o token digitado
                  collection.doc("${tokenController.text}").collection("users").doc("${_deviceId}").set({
                    "name": nameController.text,
                    "isReady": host,
                    "leader": host,
                    "id": _deviceId!,
                    "loggedAt": DateTime.now().millisecondsSinceEpoch,
                    "timestamp": DateTime.now().millisecondsSinceEpoch,
                  });

                  context.router.pushNamed('/PrivateRoom/${nameController.text}/${_deviceId}/${tokenController.text}');
                } else {
                  _closeKeyboard();
                  _showSnackBar("Sala inexistente");
                }
              }
            }
          } else {
            _showSnackBar("Houve um problema");
            setState(() {
              waiting = false;
            });
          }
        }
      } else {
        if (nameController.text.isEmpty) {
          _showSnackBar("Insira um nome válido");
        } else if (result != ConnectivityResult.none) {
          _showSnackBar("Cheque sua conexão com a internet");
        }
      }
    } on PlatformException catch (e) {
      _showSnackBar(e.toString());

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

  void _closeKeyboard() {
    setState(() {
      FocusScopeNode currentFocus = FocusScope.of(context);

      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }
    });
  }

  Future<bool> _playersInQueue(CollectionReference collection) async {
    List players = [];
    collection.get().then((QuerySnapshot elements) {
      elements.docs.forEach((element) {
        players.add({"id": element.id, "name": element.get("name")});
      });
    }).whenComplete(() async {
      //Dialog para exibir os jogadores que já estão na fila.
      final shouldPop = await showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return AlertDialog(
                  key: dialogKey,
                  backgroundColor: AppColorScheme.cardColor.withOpacity(0.2),
                  title: GenericText(
                    text: waitingAccept ? "Aguardando..." : "Jogadores na fila",
                    textStyle: TextStyles.plainText,
                  ),
                  content: _players(players, collection, setState),
                  actions: <Widget>[
                    waitingAccept
                        ? Container()
                        : MatchButton(
                            title: "Aguardar",
                            function: () {
                              _waitingInvite(collection);
                              context.router.pop();
                            },
                          ),
                    MatchButton(
                      title: "Sair",
                      function: () {
                        if (waitingAccept) {
                          collection.doc("${_idGuest}").update({"invited": false, "token": "", "hostName": ""}).then((value) {
                            setState(() {
                              _idGuest = "";
                              _nameGuest = "";
                              waitingAccept = false;
                            });
                          }); //Apaga seus dados caso feche o popup
                        }
                        context.router.pop();
                      },
                    ),
                  ],
                );
              },
            );
          });
      if (waitingAccept) {
        //Apaga seus dados caso feche o popup
        collection.doc("${_idGuest}").update({"invited": false, "token": "", "hostName": ""}).then((value) {
          setState(() {
            _idGuest = "";
            _nameGuest = "";
            waitingAccept = false;
          });
          return shouldPop ?? false;
        });
      }
      return shouldPop ?? false;
    });
    return false;
  }

  // Exibe a lista de jogadores que podem ser convidados
  _players(List players, CollectionReference collection, StateSetter setState) {
    return Container(
      width: double.maxFinite,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: players.map<Widget>((player) {
          String id = player["id"];
          String name = player["name"];
          return _player(id, name, collection.doc("${id}"), setState);
        }).toList(),
      ),
    );
  }

  // Exibe o widget com o nome do jogador que pode ser convidado
  _player(String id, String name, DocumentReference doc, StateSetter setState) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: IgnorePointer(
              ignoring: waitingAccept, //Caso já tenha convidado alguém não é possível convidar outro jogador.
              child: GestureDetector(
                onTap: () {
                  //Antes de convidar verifica se alguém já convidou o jogador na fila
                  doc.get().then((DocumentSnapshot value) {
                    if (value.get("invited")) {
                      _showSnackBar("Jogador já convidado!");
                    } else {
                      setState(() {
                        waitingAccept = true;
                        _idGuest = id;
                        _nameGuest = name;
                      });
                      String token = _createToken();
                      tokenController.text = token;
                      doc.update({"invited": true, "token": token, "hostName": nameController.text});
                      //Fica de olho para saber se o jogador vai aceitar ou recusar o convite
                      inviteListener = doc.snapshots().listen((DocumentSnapshot event) {
                        if (event.get("accepted")) {
                          inviteListener.cancel();
                          setState(() {
                            waitingAccept = false;
                            _idGuest = "";
                            _nameGuest = "";
                          });
                          _connect("privateRoom", host: true);
                        } else if (!event.get("invited")) {
                          inviteListener.cancel();
                          setState(() {
                            waitingAccept = false;
                            _idGuest = "";
                            _nameGuest = "";
                            //dialogKey = GlobalKey();
                          });
                        }
                      });
                    }
                  });
                },
                child: AnimatedContainer(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColorScheme.cardColor,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Color(0xFF000000),
                        blurRadius: 10.0,
                        offset: Offset(0.0, 5.0),
                      ),
                    ],
                  ),
                  duration: Duration(milliseconds: 200),
                  child: Text(name),
                ),
              ),
            ),
          ),
          _idGuest == id
              ? IconButton(
                  iconSize: 28,
                  onPressed: () {
                    doc.update({"invited": false, "token": ""});
                    setState(() {
                      waitingAccept = false;
                      _idGuest = "";
                      _nameGuest = "";
                    });
                  },
                  icon: Icon(
                    Icons.cancel,
                    color: Colors.red,
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  _createToken() {
    const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    const length = 5;

    return String.fromCharCodes(Iterable.generate(length, (_) => _chars.codeUnitAt(Random().nextInt(_chars.length))));
  }

  // Usuário fica aguardando convite
  void _waitingInvite(CollectionReference collection) {
    collection.doc("${_deviceId}").set({"name": nameController.text, "invited": false, "accepted": false, "token": "", "hostName": ""});
    setState(() {
      waiting = true;
    });
    //Fica aguardando alguém convidar para uma partida
    inviteListener = collection.doc("${_deviceId}").snapshots().listen((DocumentSnapshot event) {
      setState(() {
        tokenController.text = event.get("token");
      });
      String hostName = event.get("hostName");
      if (event.get("invited")) {
        setState(() {
          hasPopup = true;
        });
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: AppColorScheme.cardColor.withOpacity(0.2),
                title: GenericText(
                  text: "Convidado pelo jogador: ${hostName}",
                  textStyle: TextStyles.plainText,
                ),
                actions: <Widget>[
                  MatchButton(
                    title: "Aceitar",
                    function: () {
                      setState(() {
                        waiting = false;
                      });
                      event.reference.update({"accepted": true});
                      inviteListener.cancel();
                      context.router.pop();
                      event.reference.delete();
                      _connect("privateRoom", invited: true);
                    },
                  ),
                  MatchButton(
                    title: "Recusar",
                    function: () {
                      setState(() {
                        tokenController.text = "";
                      });
                      event.reference.update({"invited": false, "token": "", "hostName": ""});
                    },
                  ),
                ],
              );
            });
      } else if (hasPopup) {
        context.router.pop();
        setState(() {
          hasPopup = false;
        });
      }
    });
  }
}
