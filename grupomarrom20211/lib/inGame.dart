import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grupomarrom20211/Theme.dart';
import 'package:grupomarrom20211/widgets/background.dart';
import 'package:grupomarrom20211/widgets/cardInfo.dart';
import 'package:grupomarrom20211/widgets/cardObject.dart';
import 'package:grupomarrom20211/widgets/genericText.dart';
import 'package:grupomarrom20211/widgets/title.dart';
import 'const/cards.dart';

class inGame extends StatefulWidget {
  final String id;
  final String token;

  const inGame({@PathParam('id') required this.id, @PathParam('token') required this.token, Key? key}) : super(key: key);

  @override
  _inGameState createState() => _inGameState();
}

class _inGameState extends State<inGame> {
  TextEditingController nameController = TextEditingController();
  ScrollController scrollControllerOverview = ScrollController();
  ScrollController scrollControllerCardInfo = ScrollController();
  double invisibleContainerHeight = 150;
  var country = InfoCountry().cards.first;
  final database = FirebaseFirestore.instance;

  //Map country = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Background(background: "Background"),
          Stack(
            children: <Widget>[_card2(), _card2()],
          ),
        ],
      ),
    );
  }

  _text() {
    return Container(
      padding: EdgeInsets.all(8),
      child: Flexible(
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
    );
  }

  _body() {
    return Container(child: Text("Hoo", textScaleFactor: 3));
  }

  _cards() {
    return Column(
      children: InfoCountry().cards.map((e) => Text(e.name)).toList(),
    );
  }

  _card2() {
    return Container(
      height: 500,
      width: 500,
      child: CardObject(
        urlFront: 'assets/images/cards/${this.country['name']}.png',
        urlBack: 'assets/images/Cardback.png',
      ),
    );
  }
}
