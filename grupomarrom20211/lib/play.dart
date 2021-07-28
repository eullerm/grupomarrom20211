import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_database/firebase_database.dart';
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
  final database = FirebaseDatabase.instance;
  String? _deviceId;
  bool waiting = false;
  final Connectivity _connectivity = Connectivity();

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
                    onChanged: (String value) {
                      setState(() {
                        nameController.text = value;
                      });
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Insira seu nome',
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

  Future _connect(String type) async {
    DatabaseReference reference = database.reference();
    try {
      var result = await _connectivity.checkConnectivity();
      if (result != ConnectivityResult.none && nameController.text.isNotEmpty) {
        if (waiting) {
          reference.child("waiting/${_deviceId!}").remove();
          setState(() {
            waiting = false;
          });
        } else {
          if (_deviceId != null) {
            if (type == "waiting") {
              reference.child("waiting/${_deviceId!}").set({"name": nameController.text});
              setState(() {
                waiting = true;
              });
            } else if (type == "privateRoom") {
              if (true) {
                // Precisa checar se existe a sala com o token digitado
                reference.child("privateRoom/${tokenController.text}/${_deviceId!}").set({
                  "name": nameController.text,
                  "isReady": false,
                  "leader": false,
                  "id": _deviceId!,
                  "timestamp": DateTime.now().millisecondsSinceEpoch
                });

                context.router.pushNamed('/PrivateRoom/${nameController.text}/${_deviceId!}/${tokenController.text}');
              } else {
                _closeKeyboard();
                _showSnackBar("Sala inexistente");
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
}
