import 'package:flutter/material.dart';
import 'package:noodle/visual/pages/blank.dart';
import 'package:noodle/visual/pages/welcome.dart';
import 'package:noodle/visual/route_generator.dart';
void main() {
  runApp(NoodleMain());
}

class NoodleMain extends StatefulWidget {

  NoodleMain({super.key});

  @override
  State<NoodleMain> createState() => _NoodleMainState();
}

class _NoodleMainState extends State<NoodleMain> {
  final navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          WelcomePage.routeName,
          ModalRoute.withName('/'),
          // widget.initialSessionData != null
          //     ? MainPage.routeName
          //     : WelcomePage.routeName,
        );

        // PushNotifications.init(_handleOpenedMessage);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Noodle',
      navigatorKey: navigatorKey,
      initialRoute: BlankPage.routeName,
      onGenerateRoute: NoodleRouteGenerator(
        navigatorKey: navigatorKey,
      ).onGenerateRoute,
    );
  }
}
