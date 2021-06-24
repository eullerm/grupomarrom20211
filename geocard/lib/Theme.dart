import 'package:flutter/material.dart';

class Colors {
  const Colors();

  static const Color appBarTitle = const Color(0xFFFFFFFF);
  static const Color appBarIconColor = const Color(0xFFFFFFFF);
  static const Color appBarDetailBackground = const Color(0x00FFFFFF);
  static const Color buttonColor = const Color(0x051102);
}

class Dimens {
  const Dimens();

  static const planetWidth = 100.0;
  static const planetHeight = 100.0;
}

class TextStyles {
  const TextStyles();

  static const TextStyle appBarTitle = const TextStyle(
    //color: Colors.appBarTitle,
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w600,
    fontSize: 36.0,
  );

  static const TextStyle planetTitle = const TextStyle(
    //color: Colors.planetTitle,
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w600,
    fontSize: 24.0,
  );

  static const TextStyle planetLocation = const TextStyle(
    //color: Colors.planetLocation,
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w300,
    fontSize: 14.0,
  );

  static const TextStyle planetDistance = const TextStyle(
    //color: Colors.planetDistance,
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w300,
    fontSize: 12.0,
  );

  static const TextStyle appTitle = const TextStyle(
    fontFamily: 'ElanITCStdBook',
    fontWeight: FontWeight.w300,
    fontSize: 50.0,
  );

  static const TextStyle buttonTitle = const TextStyle(
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w300,
    fontSize: 18.0,
  );
}
