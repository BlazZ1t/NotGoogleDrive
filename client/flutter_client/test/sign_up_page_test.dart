import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noodle/visual/widgets/button.dart';
import 'package:noodle/visual/widgets/text_input.dart';
import 'package:noodle/visual/pages/sign_up.dart';

void main() {
  group('SignUpPage Tests', () {
    testWidgets('should display all UI elements correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SignUpPage(
            signUp: (_, __, ___) {},
          ),
        ),
      );

      // Проверка наличия основных элементов (единственное отличие - текст кнопки)
      expect(find.byType(TextInput), findsNWidgets(2));
      expect(find.byType(Checkbox), findsOneWidget);
      expect(find.text('Remember me'), findsOneWidget);
      expect(find.text('Sign up'), findsOneWidget);  // ← Здесь меняем 'Log in' на 'Sign up'
      expect(find.byType(Button), findsOneWidget);
    });

    testWidgets('should handle text input correctly', (WidgetTester tester) async {
      String? signedUpName;
      String? signedUpPassword;
      bool? signedUpRememberMe;

      await tester.pumpWidget(
        MaterialApp(
          home: SignUpPage(
            signUp: (name, password, rememberMe) {  // ← Параметры те же, но callback называется signUp
              signedUpName = name;
              signedUpPassword = password;
              signedUpRememberMe = rememberMe;
            },
          ),
        ),
      );

      final usernameInput = find.byType(TextInput).first;
      await tester.enterText(usernameInput, 'testuser');
      
      final passwordInput = find.byType(TextInput).at(1);
      await tester.enterText(passwordInput, 'secretpass');

      final signUpButton = find.text('Sign up');  // ← Меняем только здесь
      await tester.tap(signUpButton);
      await tester.pump();

      expect(signedUpName, 'testuser');
      expect(signedUpPassword, 'secretpass');
      expect(signedUpRememberMe, false);
    });

    testWidgets('should toggle remember me checkbox', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SignUpPage(
            signUp: (_, __, ___) {},  // ← callback называется signUp, но логика та же
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

    // Дополнительный тест на стили, если они отличаются от LoginPage
    testWidgets('should have correct background color', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SignUpPage(
            signUp: (_, __, ___) {},
          ),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFF484135));
    });
  });
}