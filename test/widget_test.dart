// Flutter test

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Basic widget test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('WinPoi Test'),
          ),
        ),
      ),
    );

    expect(find.text('WinPoi Test'), findsOneWidget);
  });

  test('String test', () {
    const title = 'WinPoi';
    expect(title, equals('WinPoi'));
  });
}
