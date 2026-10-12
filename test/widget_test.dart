import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_mobile/main.dart';
import 'package:pin_mobile/screens/auth/login_screen.dart';
import 'package:pin_mobile/widgets/meal_mate_logo.dart';
import 'package:pin_mobile/core/constants.dart';

void main() {
  testWidgets('App initialization test with theme and branding', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    expect(find.text('MealMate'), findsOneWidget);
    expect(find.byType(MealMateLogo), findsOneWidget);
    expect(find.text('อีเมล'), findsOneWidget);
    expect(find.text('รหัสผ่าน'), findsOneWidget);
    expect(find.text('เข้าสู่ระบบ'), findsWidgets);
    expect(find.text('สมัครสมาชิก'), findsOneWidget);
  });
}

