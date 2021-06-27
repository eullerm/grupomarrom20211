import 'package:flutter/material.dart';
import 'package:geocard/Theme.dart';
import 'package:geocard/widgets/background.dart';
import 'package:geocard/widgets/button.dart';
import 'package:geocard/widgets/cardInfo.dart';
import 'package:geocard/widgets/title.dart';

class CountryDetail extends StatefulWidget {
  CountryDetail();

  @override
  _CountryDetailState createState() => _CountryDetailState();
}

class _CountryDetailState extends State<CountryDetail> {
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
                    child: Container(
                      height: MediaQuery.of(context).size.height + 70,
                      //alignment: FractionalOffset(0.0, 0.3),
                      //color: Colors.black,
                      child: Column(
                        children: <Widget>[
                          SizedBox(height: 150),
                          CardInfo(isDetailPage: true),
                          SizedBox(height: 20),
                          Flexible(
                            child: SingleChildScrollView(
                              child: Text(
                                  "datadatadatadatadata\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\ndatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadatadata"),
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
