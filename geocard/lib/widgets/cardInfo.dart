import 'package:flutter/material.dart';
import 'package:geocard/Theme.dart';

class CardInfo extends StatefulWidget {
  const CardInfo({Key? key}) : super(key: key);

  @override
  _CardInfoState createState() => _CardInfoState();
}

class _CardInfoState extends State<CardInfo> {
  @override
  Widget build(BuildContext context) {
    return _card();
  }
}

_cardFlag() {
  return Container(
    alignment: FractionalOffset(0.0, 0.5),
    margin: EdgeInsets.only(left: 24.0),
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

_cardInfo() {
  return Container(
    margin: EdgeInsets.only(left: 72.0, right: 24.0),
    decoration: BoxDecoration(
      color: AppColorScheme.appText,
      shape: BoxShape.rectangle,
      borderRadius: BorderRadius.circular(8.0),
      boxShadow: <BoxShadow>[
        BoxShadow(
            color: Colors.black, blurRadius: 10.0, offset: Offset(0.0, 10.0))
      ],
    ),
    child: Container(
      margin: EdgeInsets.only(top: 16.0, left: 72.0),
      constraints: BoxConstraints.expand(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("planet.name", style: TextStyles.planetTitle),
          Text("planet.location", style: TextStyles.planetLocation),
          Container(
              color: Color(0xFF00C6FF),
              width: 24.0,
              height: 1.0,
              margin: EdgeInsets.symmetric(vertical: 8.0)),
          Row(
            children: <Widget>[
              Icon(Icons.location_on,
                  size: 14.0, color: AppColorScheme.appText),
              Text("planet.distance", style: TextStyles.planetDistance),
              Container(width: 24.0),
              Icon(Icons.flight_land,
                  size: 14.0, color: AppColorScheme.appText),
              Text("planet.gravity", style: TextStyles.planetDistance),
            ],
          )
        ],
      ),
    ),
  );
}

_card() {
  return Container(
    height: 120.0,
    padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
    child: GestureDetector(
      onTap: () {},
      child: Stack(
        children: <Widget>[
          _cardInfo(),
          _cardFlag(),
        ],
      ),
    ),
  );
}
