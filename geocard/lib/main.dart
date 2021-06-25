import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocard/credits.dart';
import 'package:geocard/landing.dart';
import 'package:geocard/AutoRoute/AutoRoute.dart';
import 'package:geocard/AutoRoute/AutoRoute.gr.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final _appRouter = AppRouter();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    return MaterialApp.router(
      title: 'Flutter Demo',
      routerDelegate: _appRouter.delegate(),
      routeInformationParser: _appRouter.defaultRouteParser(),
    );
  }
}
