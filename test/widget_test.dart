import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_simplify/main.dart';

void main() {
  testWidgets('App loads and shows Simplify', (WidgetTester tester) async {
    await tester.pumpWidget(const SimplifyApp());
    await tester.pump();
    expect(find.text('Simplify'), findsOneWidget);
  });
}
