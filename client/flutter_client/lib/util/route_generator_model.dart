import 'package:flutter/material.dart';

typedef RouteGenFunc = Route<dynamic> Function(RouteSettings);

class RouteGenerator {
  final Map<String, RouteGenFunc> routes;
  final RouteGenFunc generateNotFoundRoute;
  final Route<dynamic> Function(RouteSettings, AssertionError)
      generateErrorRoute;

  const RouteGenerator({
    required this.routes,
    required this.generateNotFoundRoute,
    required this.generateErrorRoute,
  });

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final gen = routes[settings.name];
    if (gen == null) return generateNotFoundRoute(settings);
    try {
      return gen(settings);
    } on AssertionError catch (e) {
      return generateErrorRoute(settings, e);
    }
  }
}
