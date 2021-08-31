// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

import 'package:auto_route/auto_route.dart' as _i1;
import 'package:flutter/foundation.dart' as _i11;
import 'package:flutter/material.dart' as _i2;

import '../countries.dart' as _i6;
import '../countryDetail.dart' as _i7;
import '../credits.dart' as _i5;
import '../howToPlay.dart' as _i4;
import '../inGame.dart' as _i9;
import '../landing.dart' as _i3;
import '../play.dart' as _i8;
import '../privateroom.dart' as _i10;

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
    HowToPlay.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return _i4.HowToPlay();
        }),
    Credits.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return _i5.Credits();
        }),
    Countries.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return _i6.Countries();
        }),
    CountryDetail.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (data) {
          final pathParams = data.pathParams;
          final args = data.argsAs<CountryDetailArgs>(
              orElse: () => CountryDetailArgs(id: pathParams.getInt('id')));
          return _i7.CountryDetail(id: args.id);
        }),
    Play.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (_) {
          return const _i8.Play();
        }),
    InGame.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (data) {
          final pathParams = data.pathParams;
          final args = data.argsAs<InGameArgs>(
              orElse: () => InGameArgs(
                  id: pathParams.getString('id'),
                  token: pathParams.getString('token'),
                  isLeader: pathParams.getBool('isLeader')));
          return _i9.inGame(
              id: args.id,
              token: args.token,
              isLeader: args.isLeader,
              key: args.key);
        }),
    PrivateRoom.name: (routeData) => _i1.MaterialPageX<dynamic>(
        routeData: routeData,
        builder: (data) {
          final pathParams = data.pathParams;
          final args = data.argsAs<PrivateRoomArgs>(
              orElse: () => PrivateRoomArgs(
                  player: pathParams.getString('player'),
                  id: pathParams.getString('id'),
                  token: pathParams.getString('token')));
          return _i10.PrivateRoom(
              player: args.player,
              id: args.id,
              token: args.token,
              key: args.key);
        })
  };

  @override
  List<_i1.RouteConfig> get routes => [
        _i1.RouteConfig(Landing.name, path: '/'),
        _i1.RouteConfig(HowToPlay.name, path: '/how-to-play'),
        _i1.RouteConfig(Credits.name, path: '/Credits'),
        _i1.RouteConfig(Countries.name, path: '/Countries'),
        _i1.RouteConfig(CountryDetail.name, path: '/CountryDetail/:id'),
        _i1.RouteConfig(Play.name, path: '/Play'),
        _i1.RouteConfig(InGame.name, path: '/inGame/:id/:token/:isLeader'),
        _i1.RouteConfig(PrivateRoom.name,
            path: '/PrivateRoom/:player/:id/:token')
      ];
}

class Landing extends _i1.PageRouteInfo {
  const Landing() : super(name, path: '/');

  static const String name = 'Landing';
}

class HowToPlay extends _i1.PageRouteInfo {
  const HowToPlay() : super(name, path: '/how-to-play');

  static const String name = 'HowToPlay';
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

class Play extends _i1.PageRouteInfo {
  const Play() : super(name, path: '/Play');

  static const String name = 'Play';
}

class InGame extends _i1.PageRouteInfo<InGameArgs> {
  InGame(
      {required String id,
      required String token,
      required bool isLeader,
      _i11.Key? key})
      : super(name,
            path: '/inGame/:id/:token/:isLeader',
            args:
                InGameArgs(id: id, token: token, isLeader: isLeader, key: key),
            rawPathParams: {'id': id, 'token': token, 'isLeader': isLeader});

  static const String name = 'InGame';
}

class InGameArgs {
  const InGameArgs(
      {required this.id,
      required this.token,
      required this.isLeader,
      this.key});

  final String id;

  final String token;

  final bool isLeader;

  final _i11.Key? key;
}

class PrivateRoom extends _i1.PageRouteInfo<PrivateRoomArgs> {
  PrivateRoom(
      {required String player,
      required String id,
      required String token,
      _i11.Key? key})
      : super(name,
            path: '/PrivateRoom/:player/:id/:token',
            args:
                PrivateRoomArgs(player: player, id: id, token: token, key: key),
            rawPathParams: {'player': player, 'id': id, 'token': token});

  static const String name = 'PrivateRoom';
}

class PrivateRoomArgs {
  const PrivateRoomArgs(
      {required this.player, required this.id, required this.token, this.key});

  final String player;

  final String id;

  final String token;

  final _i11.Key? key;
}
