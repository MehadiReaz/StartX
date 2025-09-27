// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_project_generator/main.dart';

void main() {
  testWidgets('Flutter Project Generator loads correctly', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FlutterProjectGeneratorApp());

    // Verify that the app title is displayed.
    expect(find.text('Flutter Project Generator'), findsOneWidget);

    // Verify that project name field exists.
    expect(find.text('Project Name'), findsOneWidget);

    // Verify that generate project button exists.
    expect(find.text('Generate Project'), findsOneWidget);
  });
}
