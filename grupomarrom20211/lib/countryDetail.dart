import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:grupomarrom20211/Theme.dart';
import 'package:grupomarrom20211/const/cards.dart';
import 'package:grupomarrom20211/widgets/background.dart';
import 'package:grupomarrom20211/widgets/cardInfo.dart';
import 'package:grupomarrom20211/widgets/cardObject.dart';
import 'package:grupomarrom20211/widgets/genericText.dart';
import 'package:grupomarrom20211/widgets/title.dart';

//Tela responsável pela exibição das informações dos países
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
    country = InfoCountry().cards[this.widget.id];
    scrollControllerOverview.addListener(() {
      setState(() {
        if (scrollControllerOverview.offset >= scrollControllerOverview.position.maxScrollExtent / 2) {
          scrollControllerCardInfo.animateTo(
            scrollControllerCardInfo.position.maxScrollExtent,
            duration: Duration(milliseconds: 200),
            curve: Curves.ease,
          );
        }
        if (scrollControllerOverview.offset == scrollControllerOverview.position.minScrollExtent) {
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
        if (scrollControllerCardInfo.offset == scrollControllerCardInfo.position.minScrollExtent) {
          //Future.dalayed adicionado antes do jump To para que não ocorra ocorra erro com o listener acima
          Future.delayed(Duration(milliseconds: 50), () {
            scrollControllerOverview.jumpTo(
              scrollControllerOverview.position.minScrollExtent,
            );
          });
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

  _body(BuildContext context) {
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
                          AnimatedContainer(duration: Duration(milliseconds: 200), height: invisibleContainerHeight),
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
                                  GenericText(text: this.country["overview"], textStyle: TextStyles.plainText),
                                  SizedBox(height: 50),
                                  CardObject(
                                    urlFront: 'assets/images/cards/${this.country['name']}.png',
                                    urlBack: 'assets/images/Cardback.png',
                                  ),
                                  SizedBox(
                                    height: 180,
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
}
