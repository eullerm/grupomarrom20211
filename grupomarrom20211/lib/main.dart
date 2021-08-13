import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grupomarrom20211/AutoRoute/AutoRoute.gr.dart';

import 'package:onesignal_flutter/onesignal_flutter.dart';
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
    //Remove this method to stop OneSignal Debugging
    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

    OneSignal.shared.setAppId("6824ea51-892f-465b-a728-dc30991f1138");

    return MaterialApp.router(
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
