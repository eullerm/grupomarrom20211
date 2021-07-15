import 'package:flutter/material.dart';
import 'package:grupomarrom20211/Theme.dart';
import 'package:grupomarrom20211/widgets/background.dart';
import 'package:grupomarrom20211/widgets/cardInfo.dart';
import 'package:grupomarrom20211/widgets/searchCountry.dart';
import 'package:grupomarrom20211/widgets/title.dart';
import 'const/cards.dart';

//Tela responsável pela exibição da lista de países
class Countries extends StatefulWidget {
  Countries();

  @override
  _CountriesState createState() => _CountriesState();
}

class _CountriesState extends State<Countries> {
  bool isSearch = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void _verificaBusca() {
    setState(() {
      isSearch = !isSearch;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(context),
    );
  }

  _body(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          Background(background: "./assets/images/Background.png"),
          Container(
            padding: EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Stack(children: <Widget>[
                  // Título
                  TextTitle(
                    title: "Cartas",
                    textStyle: TextStyles.screenTitle,
                  ).withArrowBack(context, screen: "Landing"),
                  //Lupa
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        width: isSearch ? MediaQuery.of(context).size.width - 128 : 0,
                        child: TextField(
                          decoration: InputDecoration(
                              filled: true, fillColor: Colors.white, border: isSearch ? OutlineInputBorder() : null, hintText: 'Enter a search term'),
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            _verificaBusca();
                            /* showSearch(
                              context: context, delegate: SearchCountry()); */
                          },
                          icon: Icon(
                            Icons.search,
                            color: AppColorScheme.iconColor,
                          )),
                    ],
                  ),
                ]),

                // Cards
                Flexible(
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.white, Colors.white.withOpacity(0.05)],
                        stops: [0.98, 1],
                        tileMode: TileMode.mirror,
                      ).createShader(bounds);
                    },
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          SizedBox(height: 12),
                          _cards(),
                          SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _cards() {
    return Column(
      children: InfoCountry().cards.map<Widget>((value) => CardInfo(card: value)).toList(),
    );
  }
}
