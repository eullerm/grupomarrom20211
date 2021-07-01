// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

import 'package:auto_route/auto_route.dart' as _i1;
import 'package:flutter/material.dart' as _i2;

import '../countries.dart' as _i5;
import '../countryDetail.dart' as _i6;
import '../credits.dart' as _i4;
import '../landing.dart' as _i3;

class AppRouter extends _i1.RootStackRouter {
  AppRouter([_i2.GlobalKey<_i2.NavigatorState>? navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, _i1.PageFactory> pagesMap = {
    Landing.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return _i3.Landing();
        }),
    Credits.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return _i4.Credits();
        }),
    Countries.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return _i5.Countries();
        }),
    CountryDetail.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (data) {
          final pathParams = data.pathParams;
          final args = data.argsAs<CountryDetailArgs>(
              orElse: () => CountryDetailArgs(id: pathParams.getInt('id')));
          return _i6.CountryDetail(id: args.id);
        })
  };

  @override
  List<_i1.RouteConfig> get routes => [
        _i1.RouteConfig(Landing.name, path: '/'),
        _i1.RouteConfig(Credits.name, path: '/Credits'),
        _i1.RouteConfig(Countries.name, path: '/Countries'),
        _i1.RouteConfig(CountryDetail.name, path: '/CountryDetail/:id')
      ];
}

class Landing extends _i1.PageRouteInfo {
  const Landing() : super(name, path: '/');

  static const String name = 'Landing';
}

class Credits extends _i1.PageRouteInfo {
  const Credits() : super(name, path: '/Credits');

  static const String name = 'Credits';
}

class Countries extends _i1.PageRouteInfo {
  const Countries() : super(name, path: '/Countries');

  static const String name = 'Countries';
}

class CountryDetail extends _i1.PageRouteInfo<CountryDetailArgs> {
  CountryDetail({required int id})
      : super(name,
            path: '/CountryDetail/:id',
            args: CountryDetailArgs(id: id),
            rawPathParams: {'id': id});

  static const String name = 'CountryDetail';
}

class CountryDetailArgs {
  const CountryDetailArgs({required this.id});

  final int id;
}
