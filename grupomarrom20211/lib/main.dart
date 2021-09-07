import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grupomarrom20211/AutoRoute/AutoRoute.gr.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final _appRouter = AppRouter();
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      builder: (BuildContext context, Widget? child) {
        return SafeArea(
          child: child!,
        );
      },
      title: 'Flutter Demo',
      routerDelegate: _appRouter.delegate(),
      routeInformationParser: _appRouter.defaultRouteParser(),
    );
  }
}
