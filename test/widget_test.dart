// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:autocare_pro/main.dart';

void main() {
  testWidgets('AutoCare Pro app loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AutoCareProApp());

    // Verify that the app loads without errors
    // The app should have a MaterialApp with title
    expect(tester.takeException(), isNull);

    // Test that the app can handle basic navigation
    // Since this is a complex app, we'll just verify it doesn't crash
    await tester.pumpAndSettle();

    // Verify the app is in a good state
    expect(tester.takeException(), isNull);
  });
}
