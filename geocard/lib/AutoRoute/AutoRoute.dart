import 'package:auto_route/auto_route.dart';
import 'package:geocard/countries.dart';
import 'package:geocard/landing.dart';
import 'package:geocard/credits.dart';
import 'package:geocard/countryDetail.dart';

@MaterialAutoRouter(
  replaceInRouteName: 'Page,Route',
  routes: <AutoRoute>[
    AutoRoute(page: Landing, initial: true),
    AutoRoute(page: Credits),
    AutoRoute(page: Countries),
    AutoRoute(path: '/CountryDetail/:id', page: CountryDetail),
  ],
)
class $AppRouter {}
