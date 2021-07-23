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

class Play extends StatefulWidget {
  const Play({Key? key}) : super(key: key);

  @override
  _PlayState createState() => _PlayState();
}

class _PlayState extends State<Play> {
  TextEditingController nameController = TextEditingController();
  final database = FirebaseDatabase.instance;
  String? _deviceId;
  bool waiting = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
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

  Widget _body(context) {
    final reference = database.reference();
    return Container(
      child: Stack(
        children: <Widget>[
          Background(background: "./assets/images/Background.png"),
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
                      MatchButton(
                        title: waiting ? "Cancelar" : "Procurar uma partida",
                        width: waiting ? 150 : 250,
                        function: () => _connect(reference),
                      ),
                      Button(
                        title: "Criar sala",
                        screen: "/",
                      ).withShadow(context),
                      SizedBox(
                        height: 50,
                        width: 50,
                        child: waiting
                            ? CircularProgressIndicator(
                                color: AppColorScheme.iconColor,
                              )
                            : SizedBox(),
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

  Future _connect(DatabaseReference reference) async {
    if (waiting) {
      reference.child("waiting/${_deviceId!}").remove();
      setState(() {
        waiting = false;
      });
    } else {
      if (_deviceId != null) {
        reference.child("waiting/${_deviceId!}").set({"name": nameController.text});
        // print((await reference.child("waiting").get())!.value.length);
        setState(() {
          waiting = true;
        });
      } else {
        setState(() {
          waiting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
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
                GenericText(text: "Dado deletado!", textStyle: TextStyles.plainText),
              ],
            ),
          ),
        );
      }
    }
  }
}
