import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:electromart/main.dart'; // ✅ your correct project name

void main() {
  testWidgets('App boots to Login and navigates to Shell', (WidgetTester tester) async {
    // Launch the app
    await tester.pumpWidget(const ElectroMartApp());

    // --- Login screen ---
    expect(find.text('Welcome to ElectroMart'), findsOneWidget);
    expect(find.text('Log in to continue'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Log In'), findsOneWidget);

    // Tap Log In
    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();

    // --- Shell (BottomNavigationBar) ---
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Products'), findsOneWidget);
    expect(find.text('Cart'), findsOneWidget);
    expect(find.text('About'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    // Home page should show ElectroMart title
    expect(find.text('ElectroMart'), findsOneWidget);
  });

  testWidgets('Products page shows product tiles', (WidgetTester tester) async {
    await tester.pumpWidget(const ElectroMartApp());

    // Go to shell
    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();

    // Tap Products tab
    await tester.tap(find.text('Products'));
    await tester.pumpAndSettle();

    // Expect products to show
    expect(find.text('Add to Cart'), findsWidgets);
  });
}
