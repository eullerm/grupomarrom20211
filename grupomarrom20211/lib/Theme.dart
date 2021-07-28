import 'package:flutter/material.dart';

//Local onde será armazenado o estilo dos widgets do projeto.
class AppColorScheme {
  const AppColorScheme();

  static const Color appBarTitle = const Color(0xFFFFFFFF);
  static const Color appBarIconColor = const Color(0xFFFFFFFF);
  static const Color appBarDetailBackground = const Color(0x00FFFFFF);
  static const Color buttonColor = const Color(0xAAF1FAEE);
  static const Color buttonText = const Color(0xFF000000);
  static const Color appText = const Color(0xFFC0C0C0);
  static const Color iconColor = const Color(0xFFC0C0C0);
  static const Color cardColor = const Color(0xFFC0C0C0);
  static const Color snackBarColor = const Color(0xAAF1FAEE);
}

class Dimens {
  const Dimens();

  static const flagWidth = 100.0;
  static const flagHeight = 100.0;
}

class TextStyles {
  const TextStyles();

  static const TextStyle countryTitle = const TextStyle(
    //color: Colors.planetTitle,
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w600,
    fontSize: 24.0,
  );

  static const TextStyle countryLocation = const TextStyle(
    //color: Colors.planetLocation,
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w300,
    fontSize: 14.0,
  );

  static const TextStyle countrySize = const TextStyle(
    //color: Colors.planetDistance,
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w300,
    fontSize: 12.0,
  );

  static const TextStyle countryPopulation = const TextStyle(
    //color: Colors.planetDistance,
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w300,
    fontSize: 12.0,
  );

  static const TextStyle appTitle = const TextStyle(
    color: AppColorScheme.appText,
    fontFamily: 'ElanITCStdBook',
    fontSize: 50.0,
    shadows: <Shadow>[
      Shadow(
        offset: Offset(2.0, 2.0),
        blurRadius: 3.0,
        color: Color(0xFF000000),
      ),
    ],
  );

  static const TextStyle screenTitle = const TextStyle(
    color: AppColorScheme.appText,
    fontFamily: 'ElanITCStdBook',
    fontSize: 40.0,
    shadows: <Shadow>[
      Shadow(
        offset: Offset(2.0, 2.0),
        blurRadius: 3.0,
        color: Color(0xFF000000),
      ),
    ],
  );

  static const TextStyle buttonTitle = const TextStyle(
    color: AppColorScheme.buttonText,
    fontFamily: 'ElanITCStdBook',
    fontSize: 20.0,
  );

  static const TextStyle smallText = const TextStyle(
    color: AppColorScheme.appText,
    fontFamily: 'ElanITCStdBook',
    fontSize: 12.0,
  );

  static const TextStyle plainText = const TextStyle(
    color: AppColorScheme.appText,
    fontFamily: 'ElanITCStdBook',
    fontSize: 20.0,
    shadows: <Shadow>[
      Shadow(
        offset: Offset(2.0, 2.0),
        blurRadius: 3.0,
        color: Color(0xFF000000),
      ),
    ],
  );
}
