import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:geocard/Theme.dart';
import 'package:geocard/const/cards.dart';
import 'package:geocard/widgets/background.dart';
import 'package:geocard/widgets/cardInfo.dart';
import 'package:geocard/widgets/title.dart';

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
                            card: this.country,
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
