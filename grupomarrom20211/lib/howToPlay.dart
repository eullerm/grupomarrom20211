import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:grupomarrom20211/Theme.dart';
import 'package:grupomarrom20211/widgets/background.dart';
import 'package:grupomarrom20211/widgets/title.dart';

class HowToPlay extends StatefulWidget {
  HowToPlay();

  @override
  _HowToPlayState createState() => _HowToPlayState();
}

class _HowToPlayState extends State<HowToPlay> {
  List images1 = ['1', '2', '3', '4', '5', '6', '7', '8', '9'];
  List images2 = ['1', '2', '3', '4', '5', '6', '7'];
  final controller = PageController(initialPage: 0);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        index: 0,
        color: Color(0xFF03989e),
        backgroundColor: Color(0xFFe9fae8),
        height: 48,
        items: [
          Text(
            "1",
            style: TextStyles.navigation,
          ),
          Text(
            "2",
            style: TextStyles.navigation,
          ),
          Text(
            "3",
            style: TextStyles.navigation,
          ),
        ],
        onTap: (index) {
          controller.animateToPage(index, duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
        },
      ),
      body: _body(context),
    );
  }

  _body(context) {
    return Container(
      child: Stack(
        children: <Widget>[
          PageView(
            controller: controller,
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: images1.map<Widget>((e) {
                      return Image.asset("assets/images/HowToPlay-CriandoPartida/${e}.png");
                    }).toList(),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: double.infinity,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: images2.map<Widget>((e) {
                      return Image.asset("assets/images/HowToPlay-EntrandoPartida/${e}.png");
                    }).toList(),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: double.infinity,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: images2.map<Widget>((e) {
                      return Image.asset("assets/images/HowToPlay-Jogando/${e}.png");
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.all(10.0),
            width: double.infinity,
            child: Column(
              children: <Widget>[
                // Título
                Flexible(
                  flex: 2,
                  child: TextTitle(
                    title: "",
                    textStyle: TextStyles.screenTitle,
                  ).withArrowBack(context, screen: "Landing"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
