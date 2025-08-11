import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:proprint/core/providers/dashboard_provider.dart';
import 'package:proprint/features/presentation/auth/login.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Login form validation & tap test', (WidgetTester tester) async {
    // Wrap everything inside ScreenUtilInit like in your main.dart
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(
            375, 812), // Match AppConstants.screenW/H if you have them
        minTextAdapt: true,
        splitScreenMode: true,
        useInheritedMediaQuery: true,
        builder: (context, child) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => DashboardProvider()),
              // Add other providers here if needed later (e.g., UserNameProvider)
            ],
            child: MaterialApp(
              home: child,
            ),
          );
        },
        child: const Login(), // this is the screen under test
      ),
    );

    await tester
        .pumpAndSettle(); //It is a method used in Flutter widget tests to wait for all animations, transitions, and scheduled frames to complete before continuing.

    // Find widgets by key
    final emailField = find.byKey(const Key('emailField'));
    final passwordField = find.byKey(const Key('passwordField'));
    final loginButton = find.byKey(const Key('loginButton'));

    // Enter text
    await tester.enterText(emailField, 'manasfaizan@gmail.com');
    await tester.enterText(passwordField, 'anas4444');

    // Tap login
    await tester.tap(loginButton);
    await tester
        .pump(); // rebuilds the widget tree and advances the clock by a small amount of time (one frame). It’s like saying: “Render this widget”

    // expect is a function provided by the test package in Dart. It's used to assert that a value meets certain expectations during a test.
    expect(find.byType(CircularProgressIndicator),
        findsOneWidget); //find is a utility in Flutter's testing framework that helps you locate widgets in the UI.
  });
}
