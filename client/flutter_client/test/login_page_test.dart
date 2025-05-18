import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noodle/visual/widgets/button.dart';
import 'package:noodle/visual/widgets/text_input.dart';
import 'package:noodle/visual/pages/login.dart';

void main() {
  group('LoginPage Tests', () {
    testWidgets('should display all UI elements correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginPage(
            login: (_, __, ___) {},
          ),
        ),
      );

      // Проверка наличия основных элементов
      expect(find.byType(TextInput), findsNWidgets(2));
      expect(find.byType(Checkbox), findsOneWidget);
      expect(find.text('Remember me'), findsOneWidget);
      expect(find.byType(Button), findsOneWidget);
    });

    testWidgets('should handle text input correctly', (WidgetTester tester) async {
      String? enteredName;
      String? enteredPassword;
      bool? rememberMeValue;

      await tester.pumpWidget(
        MaterialApp(
          home: LoginPage(
            login: (name, password, rememberMe) {
              enteredName = name;
              enteredPassword = password;
              rememberMeValue = rememberMe;
            },
          ),
        ),
      );

      final usernameInput = find.byType(TextInput).first;
      await tester.enterText(usernameInput, 'testuser');
      
      final passwordInput = find.byType(TextInput).at(1);
      await tester.enterText(passwordInput, 'secretpass');

      final loginButton = find.byType(Button);
      await tester.tap(loginButton);
      await tester.pump();

      expect(enteredName, 'testuser');
      expect(enteredPassword, 'secretpass');
      expect(rememberMeValue, false);
    });

    testWidgets('should toggle remember me checkbox', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginPage(
            login: (_, __, ___) {},
          ),
        ),
      );

      var checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, false);

      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, true);

      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, false);
    });
  });
}