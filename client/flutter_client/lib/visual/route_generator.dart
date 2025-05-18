import 'package:flutter/material.dart';
import 'package:noodle/util/route_generator_model.dart';

import 'package:noodle/visual/pages/blank.dart';
import 'package:noodle/visual/pages/welcome.dart';
import 'package:noodle/visual/pages/login.dart';
import 'package:noodle/visual/pages/sign_up.dart';
import 'package:noodle/visual/pages/main.dart';

import 'package:noodle/services/api.dart';


class NoodleRouteGenerator extends RouteGenerator {
  final GlobalKey<NavigatorState> navigatorKey;

  final ApiService apiService;

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
    required this.apiService,
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
                builder: (_) => WelcomePage(
                  login: () => navigatorKey.currentState?.pushNamed(LoginPage.routeName),
                  signUp: () => navigatorKey.currentState?.pushNamed(SignUpPage.routeName),
                ),
              );
            },

            LoginPage.routeName: (settings) {
              return MaterialPageRoute(
                settings: settings,
                allowSnapshotting: false,
                builder: (_) => LoginPage(
                  login: (n,p,b) async{
                    if (await apiService.login(n,p,b)){
                      navigatorKey.currentState?.pushNamed(MainPage.routeName);
                    }
                  }
                ),
              );
            },

            SignUpPage.routeName: (settings) {
              return MaterialPageRoute(
                settings: settings,
                allowSnapshotting: false,
                builder: (_) => SignUpPage(
                  signUp: (n,p,b)async {
                    if (await apiService.register(n,p,b)){
                      navigatorKey.currentState?.pushNamed(MainPage.routeName);
                    }
                  }
                ),
              );
            },

            MainPage.routeName: (settings) {
              return MaterialPageRoute(
                settings: settings,
                allowSnapshotting: false,
                builder: (_) => MainPage(
                  uploadFile: (f, name) async {
                    await apiService.uploadInMemory(f, name);
                  },
                  downloadFile: (p) async {
                    await apiService.downloadFileToDownloads(filePath: p);
                  },
                  deleteFile: (p) async {
                    await apiService.deleteFile(filePath: p);
                  },
                  deleteFolder: (p) async {
                    await apiService.deleteFolder(folderPath: p);
                  },
                  rename: (path, name) async {
                    await apiService.renameFile(currentPath: path, newName: name);
                  },
                  toList: (s) async {
                    return await apiService.listFiles(path: s);
                  } ,
                  createFolder: (p) async {
                    return await apiService.createFolder(p);
                  },
                  logout: () async {
                    
                    navigatorKey.currentState?.pushNamedAndRemoveUntil(WelcomePage.routeName,
                      (route) => false,
                    );
                    await apiService.logout();

                  },

                ),
              );
            },
          }
        );

}