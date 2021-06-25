import 'package:auto_route/auto_route.dart';
import 'package:geocard/landing.dart';
import 'package:geocard/credits.dart';

@MaterialAutoRouter(
  replaceInRouteName: 'Page,Route',
  routes: <AutoRoute>[
    AutoRoute(page: Landing, initial: true),
    AutoRoute(page: Credits),
  ],
)
class $AppRouter {}
