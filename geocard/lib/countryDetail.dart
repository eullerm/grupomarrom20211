import 'package:flutter/material.dart';
import 'package:geocard/Theme.dart';
import 'package:geocard/widgets/background.dart';
import 'package:geocard/widgets/cardInfo.dart';
import 'package:geocard/widgets/title.dart';

class CountryDetail extends StatefulWidget {
  final Map country = {
    "name": "Alemanha",
    "location": "Europa",
    "area": "357.386 Km²",
    "population": "83,02 M",
    "capital": "Berlim",
    "language": "Alemão",
    "coin": "Euro",
    "government": "República democrática parlamentarista",
    "leader": "Angela Merkel (desde 2005)",
    "typeOfLeader": "Chanceler",
    "division": [
      'Baden-Wurttemberg',
      'Baixa Saxônia',
      'Baviera',
      'Berlim',
      'Brandemburgo',
      'Bremen',
      'Eslésvico-Holsácia',
      'Hamburgo',
      'Hesse',
      'Mecklemburgo-Pomerânia Ocidental',
      'Renânia do Norte-Vestfália',
      'Renânia-Palatinado',
      'Sarre',
      'Saxônia',
      'Saxônia-Anhalt',
      'Turíngia'
    ],
    "typeOfDivision": "Estados",
    "pib": "3,861 trilhões USD (2019)",
    "pibPerCapita": "46.445,25 USD ‎(2019)",
    "growthRate": "0,6% mudança anual ‎(2019)",
    "publicDebt": "59,8% do PIB ‎(2019)",
  };
  CountryDetail();

  @override
  _CountryDetailState createState() => _CountryDetailState();
}

class _CountryDetailState extends State<CountryDetail> {
  ScrollController scrollControllerOverview = ScrollController();
  ScrollController scrollControllerCardInfo = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollControllerOverview.addListener(() {
      setState(() {
        if (scrollControllerOverview.offset >=
            scrollControllerOverview.position.maxScrollExtent / 2) {
          scrollControllerCardInfo.animateTo(
            scrollControllerCardInfo.position.maxScrollExtent,
            duration: Duration(milliseconds: 200),
            curve: Curves.ease,
          );
        }
        if (scrollControllerOverview.offset ==
            scrollControllerOverview.position.minScrollExtent) {
          scrollControllerCardInfo.animateTo(
            scrollControllerCardInfo.position.minScrollExtent,
            duration: Duration(milliseconds: 200),
            curve: Curves.ease,
          );
        }
      });
    });
    scrollControllerCardInfo.addListener(() {
      setState(() {
        if (scrollControllerCardInfo.offset ==
            scrollControllerCardInfo.position.minScrollExtent) {
          scrollControllerOverview.jumpTo(
            scrollControllerOverview.position.minScrollExtent,
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(context),
    );
  }

  _body(context) {
    return Container(
      child: Stack(
        children: <Widget>[
          Background(background: "./assets/images/Background.png"),
          Container(
            padding: EdgeInsets.all(16.0),
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                // Título
                TextTitle(
                  title: "",
                  textStyle: TextStyles.screenTitle,
                ).withArrowBack(context, screen: "Countries"),

                // Detalhes
                Flexible(
                  child: SingleChildScrollView(
                    controller: scrollControllerCardInfo,
                    child: Container(
                      height: MediaQuery.of(context).size.height + 70,
                      child: Column(
                        children: <Widget>[
                          AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              height: 150),
                          CardInfo(
                            isDetailPage: true,
                            cards: this.widget.country,
                          ),
                          SizedBox(height: 8),
                          Flexible(
                            child: SingleChildScrollView(
                              controller: scrollControllerOverview,
                              child: Column(
                                children: <Widget>[
                                  SizedBox(height: 20),
                                  //Exemplo de como cada campo de informação deve ser construido.
                                  Row(
                                    children: [
                                      Text("Info: "),
                                      Text("Informação sobre o campo info"),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
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
}
