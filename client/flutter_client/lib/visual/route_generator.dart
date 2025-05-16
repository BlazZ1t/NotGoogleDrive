import 'package:flutter/material.dart';
import 'package:noodle/util/route_generator_model.dart';

import 'package:noodle/visual/pages/blank.dart';
import 'package:noodle/visual/pages/welcome.dart';


class NoodleRouteGenerator extends RouteGenerator {
  final GlobalKey<NavigatorState> navigatorKey;


  static Route<dynamic> _generateNotFoundRoute(RouteSettings settings) {
    // assume for now that no invalid route can be generated and consider it a fatal error, so just throw a Exception
    throw Exception("Route \"${settings.name}\" was not found");
  }

  static Route<dynamic> _generateErrorRoute(
      RouteSettings settings, AssertionError error) {
    // too lazy to make a nice looking error page, just rethrow
    throw error;
  }

  NoodleRouteGenerator({
    required this.navigatorKey,
  }) : super(
          generateNotFoundRoute: _generateNotFoundRoute,
          generateErrorRoute: _generateErrorRoute,
          routes: {
            BlankPage.routeName: (settings) {
              return MaterialPageRoute(
                settings: settings,
                allowSnapshotting: false,
                builder: (_) => const BlankPage(),
              );
            },

            WelcomePage.routeName: (settings) {
              return MaterialPageRoute(
                settings: settings,
                allowSnapshotting: false,
                builder: (_) => WelcomePage(),
              );
            },
          }
        );

}