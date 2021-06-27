import 'package:flutter/material.dart';
import 'package:geocard/Theme.dart';
import 'package:auto_route/auto_route.dart';

class CardInfo extends StatelessWidget {
  final bool isDetailPage;
  const CardInfo({Key? key, this.isDetailPage = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _card(context, this.isDetailPage);
  }
}

_cardFlag(bool isDetailPage) {
  return Container(
    alignment:
        isDetailPage ? FractionalOffset(0.5, 0) : FractionalOffset(0.0, 0.5),
    margin: isDetailPage ? EdgeInsets.all(0) : EdgeInsets.only(left: 24.0),
    child: Hero(
      tag: 'planet-icon-0',
      child: ClipOval(
        child: Image(
          image: AssetImage("./assets/images/Background.png"),
          height: Dimens.flagHeight,
          width: Dimens.flagWidth,
        ),
      ),
    ),
  );
}

_cardInfo(bool isDetailPage) {
  return Container(
    margin: isDetailPage
        ? EdgeInsets.all(0)
        : EdgeInsets.only(left: 72.0, right: 24.0),
    decoration: BoxDecoration(
      color: AppColorScheme.cardColor,
      borderRadius: BorderRadius.circular(8.0),
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: Color(0xFF000000),
          blurRadius: 10.0,
          offset: Offset(0.0, 10.0),
        ),
      ],
    ),
    child: Container(
      margin: EdgeInsets.only(top: 16.0, left: 72.0),
      constraints: BoxConstraints.expand(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Contry.name", style: TextStyles.contryTitle),
          Text("Contry.location", style: TextStyles.contryLocation),
          Container(
            color: Color(0xFF000000),
            width: 24.0,
            height: 1.0,
            margin: EdgeInsets.symmetric(vertical: 8.0),
          ),
          Row(
            children: <Widget>[
              Icon(Icons.straighten,
                  size: 14.0, color: AppColorScheme.iconColor),
              Text("Contry.size", style: TextStyles.contrySize),
              Container(width: 24.0),
              Icon(Icons.people, size: 14.0, color: AppColorScheme.iconColor),
              Text("Country.population", style: TextStyles.countryPopulation),
            ],
          ),
        ],
      ),
    ),
  );
}

_card(BuildContext context, bool isDetailPage) {
  return GestureDetector(
    onTap: () {
      if (!isDetailPage) {
        context.router.pushNamed('/country-detail');
      }
    },
    child: Container(
      height: isDetailPage ? 200.0 : 120.0,
      padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Stack(
        children: <Widget>[
          _cardInfo(isDetailPage),
          _cardFlag(isDetailPage),
        ],
      ),
    ),
  );
}
