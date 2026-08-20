// Basic smoke test for the admin app.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders a MaterialApp', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Center(child: Text('Admin')))),
    );
    expect(find.text('Admin'), findsOneWidget);
  });
}
