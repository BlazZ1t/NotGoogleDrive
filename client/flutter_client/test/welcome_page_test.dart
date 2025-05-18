import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noodle/visual/widgets/button.dart';
import 'package:noodle/visual/pages/welcome.dart';

void main() {
  group('WelcomePage Widget Tests', () {
    testWidgets('displays correct widgets', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: WelcomePage(
            login: () {},
            signUp: () {},
          ),
        ),
      );

      expect(find.text("Keep your files organized with Noodle"), findsOneWidget);
      expect(find.text("Sign up"), findsOneWidget);
      expect(find.text("Log in"), findsOneWidget);
      expect(find.byType(Button), findsNWidgets(2));
    });

    testWidgets('calls login and signUp when buttons are pressed',
        (WidgetTester tester) async {
      bool isLoginPressed = false;
      bool isSignUpPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: WelcomePage(
            login: () => isLoginPressed = true,
            signUp: () => isSignUpPressed = true,
          ),
        ),
      );

      await tester.tap(find.text("Sign up"));
      await tester.pump();
      expect(isSignUpPressed, true);

      await tester.tap(find.text("Log in"));
      await tester.pump();
      expect(isLoginPressed, true);
    });

    testWidgets('text has correct styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: WelcomePage(
            login: () {},
            signUp: () {},
          ),
        ),
      );

      final textWidget = tester
          .widget<Text>(find.text("Keep your files organized with Noodle"));

      expect(textWidget.style?.color, Colors.white);
      expect(textWidget.style?.fontFamily, "Geologica");
      expect(textWidget.style?.fontSize, 24);
      expect(textWidget.style?.fontWeight, FontWeight.w700);
    });

    testWidgets('has correct spacing', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: WelcomePage(
            login: () {},
            signUp: () {},
          ),
        ),
      );

      final columnWidget = tester.widget<Column>(find.byType(Column));
      final children = columnWidget.children;

      expect(children[1], isA<SizedBox>());
      expect((children[1] as SizedBox).height, 41);
    });

    testWidgets('has correct background color', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: WelcomePage(
            login: () {},
            signUp: () {},
          ),
        ),
      );

      final scaffoldWidget = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffoldWidget.backgroundColor, const Color(0xFF484135));
    });
  });
}