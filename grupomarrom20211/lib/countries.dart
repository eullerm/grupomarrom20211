import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grupomarrom20211/Theme.dart';
import 'package:grupomarrom20211/widgets/background.dart';
import 'package:grupomarrom20211/widgets/cardInfo.dart';
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
  TextEditingController searchController = TextEditingController();

  void _verificaBusca() {
    setState(() {
      isSearch = !isSearch;
      FocusScopeNode currentFocus = FocusScope.of(context);

      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }
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
                SizedBox(height: 16),
                Stack(
                  children: <Widget>[
                    // Título
                    TextTitle(
                      title: "Cartas",
                      textStyle: TextStyles.screenTitle,
                    ).withArrowBack(context, screen: "Landing"),
                    _searchBar(),
                  ],
                ),
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
      children: InfoCountry().cards.map<Widget>((value) {
        if (searchController.text.isNotEmpty) {
          bool contain = false;
          //Percorre as palavras chaves de cada país e verifica se o que o usuário digitou bate com elas
          value["keywords"].forEach((String value) {
            if (!contain && searchController.text.isNotEmpty) {
              contain = value.contains(searchController.text.toLowerCase());
            }
          });

          if (contain) {
            return CardInfo(card: value);
          } else {
            return SizedBox();
          }
        } else {
          return CardInfo(card: value);
        }
      }).toList(),
    );
  }

  //Lupa
  _searchBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        AnimatedContainer(
          duration: Duration(milliseconds: 300),
          width: isSearch ? MediaQuery.of(context).size.width - 128 : 0,
          child: TextField(
            onChanged: (String value) {
              setState(() {
                searchController.text = value;
              });
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'Pesquisar',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            _verificaBusca();
          },
          icon: Icon(
            Icons.search,
            color: AppColorScheme.iconColor,
          ),
        ),
      ],
    );
  }
}
