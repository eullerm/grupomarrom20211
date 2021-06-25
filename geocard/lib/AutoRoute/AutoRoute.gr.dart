// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

import 'package:auto_route/auto_route.dart' as _i1;
import 'package:flutter/material.dart' as _i2;

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
        })
  };

  @override
  List<_i1.RouteConfig> get routes => [
        _i1.RouteConfig(Landing.name, path: '/'),
        _i1.RouteConfig(Credits.name, path: '/Credits')
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
