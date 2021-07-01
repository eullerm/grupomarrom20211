import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:grupomarrom20211/Theme.dart';
import 'package:grupomarrom20211/const/cards.dart';
import 'package:grupomarrom20211/widgets/background.dart';
import 'package:grupomarrom20211/widgets/cardInfo.dart';
import 'package:grupomarrom20211/widgets/cardObject.dart';
import 'package:grupomarrom20211/widgets/genericText.dart';
import 'package:grupomarrom20211/widgets/title.dart';

class CountryDetail extends StatefulWidget {
  final int id;

  CountryDetail({@PathParam('id') required this.id});

  @override
  _CountryDetailState createState() => _CountryDetailState();
}

class _CountryDetailState extends State<CountryDetail> {
  ScrollController scrollControllerOverview = ScrollController();
  ScrollController scrollControllerCardInfo = ScrollController();
  Map country = {};
  double invisibleContainerHeight = 150;

  @override
  void initState() {
    super.initState();
    country = CARDS[this.widget.id];
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

  _body(
    context,
  ) {
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
                              height: invisibleContainerHeight),
                          CardInfo(
                            isDetailPage: true,
                            card: this.country,
                          ),
                          SizedBox(height: 8),
                          Flexible(
                            child: SingleChildScrollView(
                              controller: scrollControllerOverview,
                              child: Column(
                                children: <Widget>[
                                  SizedBox(height: 20),
                                  _info("Capital", this.country["capital"]),
                                  _info("Idioma", this.country["language"]),
                                  _info("Moeda", this.country["coin"]),
                                  _info("Governo", this.country["government"]),
                                  _info(this.country["typeOfLeader"],
                                      this.country["leader"]),
                                  _info("PIB", this.country["pib"]),
                                  _info("PIB per capita",
                                      this.country["pibPerCapita"]),
                                  _info("Taxa de crescimento",
                                      this.country["growthRate"]),
                                  SizedBox(height: 50),
                                  CardObject(
                                      urlFront:
                                          'assets/images/cards/${this.country['name']}.png',
                                      urlBack: 'assets/images/Cardback.png'),
                                  SizedBox(
                                    height: 8,
                                  ),
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

  _info(String string1, String string2) {
    if (string2.isEmpty) {
      return Container();
    }
    return Column(
      children: <Widget>[
        Row(
          children: [
            Expanded(
              flex: 1,
              child: GenericText(
                  text: string1 + ": ", textStyle: TextStyles.plainText),
            ),
            SizedBox(width: 5),
            Expanded(
              flex: 2,
              child:
                  GenericText(text: string2, textStyle: TextStyles.plainText),
            ),
          ],
        ),
        SizedBox(height: 16),
      ],
    );
  }
}
