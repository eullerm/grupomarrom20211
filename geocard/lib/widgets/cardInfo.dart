import 'package:flutter/material.dart';
import 'package:geocard/Theme.dart';
import 'package:auto_route/auto_route.dart';

class CardInfo extends StatelessWidget {
  final bool isDetailPage;
  final Map cards;
  const CardInfo({Key? key, this.isDetailPage = false, required this.cards})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _card(context, this.isDetailPage, this.cards);
  }
}

_cardFlag(bool isDetailPage, String name) {
  return Container(
    alignment:
        isDetailPage ? FractionalOffset(0.5, 0) : FractionalOffset(0.0, 0.5),
    margin: isDetailPage ? EdgeInsets.all(0) : EdgeInsets.only(left: 24.0),
    child: Hero(
      tag: 'planet-icon-$name',
      child: ClipOval(
        child: Image(
          image: AssetImage("./assets/images/flags/$name.png"),
          height: Dimens.flagHeight,
          width: Dimens.flagWidth,
        ),
      ),
    ),
  );
}

_cardInfo(bool isDetailPage, String name, String location, String area,
    String population) {
  return Container(
    margin: isDetailPage
        ? EdgeInsets.only(top: 50.0)
        : EdgeInsets.only(left: 72.0, right: 24.0),
    decoration: BoxDecoration(
      color: AppColorScheme.cardColor,
      borderRadius: BorderRadius.circular(8.0),
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: Color(0xFF000000),
          blurRadius: 10.0,
          offset: isDetailPage ? Offset(0.0, 5.0) : Offset(0.0, 10.0),
        ),
      ],
    ),
    child: Container(
      margin: isDetailPage
          ? EdgeInsets.only(top: 50.0, left: 16.0, right: 16, bottom: 16)
          : EdgeInsets.only(top: 16.0, left: 60.0),
      constraints: BoxConstraints.expand(),
      child: Column(
        mainAxisAlignment:
            isDetailPage ? MainAxisAlignment.center : MainAxisAlignment.start,
        crossAxisAlignment:
            isDetailPage ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: <Widget>[
          Text("$name", style: TextStyles.countryTitle),
          Text(
            "$location",
            style: TextStyles.countryLocation,
          ),
          Container(
            color: Color(0xFF000000),
            width: 24.0,
            height: 1.0,
            margin: EdgeInsets.symmetric(vertical: 8.0),
          ),
          Row(
            mainAxisAlignment: isDetailPage
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: <Widget>[
              Container(
                child: Row(
                  children: <Widget>[
                    Icon(Icons.straighten,
                        size: 14.0, color: AppColorScheme.iconColor),
                    SizedBox(width: 6),
                    Text('$area', style: TextStyles.countrySize),
                  ],
                ),
              ),
              Container(width: 24.0),
              Container(
                child: Row(
                  children: <Widget>[
                    Icon(Icons.people,
                        size: 14.0, color: AppColorScheme.iconColor),
                    SizedBox(width: 6),
                    Text("$population",
                        style: TextStyles.countryPopulation,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

_card(BuildContext context, bool isDetailPage, Map cards) {
  return GestureDetector(
    onTap: () {
      if (!isDetailPage) {
        context.router.pushNamed('/country-detail');
      }
    },
    child: Container(
      height: isDetailPage ? 220.0 : 120.0,
      padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Stack(
        children: <Widget>[
          _cardInfo(isDetailPage, cards["name"], cards["location"],
              cards["area"], cards["population"]),
          _cardFlag(isDetailPage, cards["name"]),
        ],
      ),
    ),
  );
}
