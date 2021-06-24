import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocard/landing.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    return MaterialApp(
      title: 'Flutter Demo',
      home: Landing(),
    );
  }
}
