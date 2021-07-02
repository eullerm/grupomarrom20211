import 'package:flutter/material.dart';
import 'package:grupomarrom20211/Theme.dart';
import 'package:auto_route/auto_route.dart';
import 'package:grupomarrom20211/widgets/genericText.dart';

//Widget que exibe um card com algumas informações dos países
class CardInfo extends StatelessWidget {
  final bool isDetailPage;
  final Map card;
  const CardInfo({Key? key, this.isDetailPage = false, required this.card})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _card(context, this.isDetailPage, this.card);
  }
}

_card(BuildContext context, bool isDetailPage, Map card) {
  return GestureDetector(
    onTap: () {
      if (!isDetailPage) {
        context.router.pushNamed(
          "/CountryDetail/${card['id']}",
        );
      }
    },
    child: Container(
      height: isDetailPage ? 220.0 : 120.0,
      padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Stack(
        children: <Widget>[
          _cardInfo(isDetailPage, card["name"], card["location"], card["area"],
              card["population"], context),
          _cardFlag(isDetailPage, card["name"]),
        ],
      ),
    ),
  );
}

_cardFlag(bool isDetailPage, String name) {
  return Container(
    alignment:
        isDetailPage ? FractionalOffset(0.5, 0) : FractionalOffset(0.0, 0.5),
    margin: isDetailPage ? EdgeInsets.all(0) : EdgeInsets.only(left: 20.0),
    child: Hero(
      tag: 'country-icon-$name',
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
    String population, context) {
  return Stack(
    children: <Widget>[
      _cardBackground('card-$name', isDetailPage),
      // Informações exibidas
      Container(
        margin: isDetailPage
            ? EdgeInsets.only(top: 50.0)
            : EdgeInsets.only(left: 65.0, right: 24.0),
        decoration: BoxDecoration(
          color: Color(0x00FFFFFF),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Container(
          margin: isDetailPage
              ? EdgeInsets.only(top: 50.0, left: 16.0, right: 16, bottom: 16)
              : EdgeInsets.only(top: 16.0, left: 60.0),
          constraints: BoxConstraints.expand(),
          child: Column(
            mainAxisAlignment: isDetailPage
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            crossAxisAlignment: isDetailPage
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: <Widget>[
              GenericText(text: "$name", textStyle: TextStyles.countryTitle)
                  .withAnimation(context, 'country-name-$name'),
              GenericText(
                      text: "$location", textStyle: TextStyles.countryLocation)
                  .withAnimation(context, 'country-location-$name'),
              Hero(
                tag: '$name',
                child: Container(
                  color: Color(0xFF000000),
                  width: 24.0,
                  height: 1.0,
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                ),
              ),
              Row(
                mainAxisAlignment: isDetailPage
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: Row(
                      children: <Widget>[
                        Hero(
                          tag: '$area',
                          child: Icon(Icons.straighten,
                              size: 14.0, color: AppColorScheme.iconColor),
                        ),
                        SizedBox(width: 6),
                        GenericText(
                                text: "$area",
                                textStyle: TextStyles.countrySize)
                            .withAnimation(context, 'country-size-$name'),
                      ],
                    ),
                  ),
                  Container(width: 16),
                  Container(
                    child: Row(
                      children: <Widget>[
                        Hero(
                          tag: '$population',
                          child: Icon(Icons.people,
                              size: 14.0, color: AppColorScheme.iconColor),
                        ),
                        SizedBox(width: 6),
                        GenericText(
                                text: "$population",
                                textStyle: TextStyles.countryPopulation)
                            .withAnimation(context, 'country-population-$name'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

_cardBackground(String tag, bool isDetailPage) {
  return Hero(
    tag: tag,
    child: Container(
      margin: isDetailPage
          ? EdgeInsets.only(top: 50.0)
          : EdgeInsets.only(left: 65.0, right: 24.0),
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
    ),
  );
}
