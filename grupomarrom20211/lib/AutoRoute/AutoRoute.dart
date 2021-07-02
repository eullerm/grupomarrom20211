import 'package:auto_route/auto_route.dart';
import 'package:grupomarrom20211/countries.dart';
import 'package:grupomarrom20211/landing.dart';
import 'package:grupomarrom20211/credits.dart';
import 'package:grupomarrom20211/countryDetail.dart';

//Responsável por gerar as rotas das páginas.
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