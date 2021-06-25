import 'package:auto_route/auto_route.dart';
import 'package:geocard/landing.dart';

@MaterialAutoRouter(
  replaceInRouteName: 'Page,Route',
  routes: <AutoRoute>[
    AutoRoute(page: Landing, initial: true),
  ],
)
class $AppRouter {}
