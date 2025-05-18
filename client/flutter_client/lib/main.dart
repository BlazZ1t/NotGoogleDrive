import 'package:flutter/material.dart';
import 'package:noodle/services/api.dart';
import 'package:noodle/visual/pages/blank.dart';
import 'package:noodle/visual/pages/welcome.dart';
import 'package:noodle/visual/pages/main.dart';
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
  late final apiService;
  late final bool isLoggedIn;

  @override
  void initState() {
    super.initState();
    apiService = ApiService();
    

    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        isLoggedIn = await apiService.tryStartSession();
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          isLoggedIn ? MainPage.routeName : WelcomePage.routeName,
          ModalRoute.withName('/'),
        );

        // PushNotifications.init(_handleOpenedMessage);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Noodle',
      navigatorKey: navigatorKey,
      initialRoute: BlankPage.routeName,
      onGenerateRoute: NoodleRouteGenerator(
        navigatorKey: navigatorKey,
        apiService: apiService
      ).onGenerateRoute,
    );
  }
}
