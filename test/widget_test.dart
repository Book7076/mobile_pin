import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pin_mobile/main.dart';

void main() {
  testWidgets('App smoke test loads MaterialApp', (WidgetTester tester) async {
    // Avoid real HTTP network calls during test
    HttpOverrides.global = null;

    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);

    // Drain splash screen timer
    await tester.pump(const Duration(seconds: 3));
  });
}
