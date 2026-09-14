import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_mobile/screens/auth/login_screen.dart';
import 'package:pin_mobile/widgets/meal_mate_logo.dart';
import 'package:pin_mobile/widgets/social_login_button.dart';

void main() {
  testWidgets('LoginScreen renders MealMate logo, form inputs, and buttons', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    // Verify Logo and Title
    expect(find.byType(MealMateLogo), findsOneWidget);
    expect(find.text('MealMate'), findsOneWidget);

    // Verify Thai Labels
    expect(find.text('อีเมล'), findsOneWidget);
    expect(find.text('รหัสผ่าน'), findsOneWidget);

    // Verify Hints
    expect(find.text('กรุณากรอกอีเมล'), findsOneWidget);
    expect(find.text('กรุณากรอกรหัสผ่าน'), findsOneWidget);

    // Verify Login Button
    expect(find.text('เข้าสู่ระบบ'), findsWidgets);

    // Verify Switcher to Sign Up
    expect(find.text('ยังไม่มีบัญชีใช่ไหม? '), findsOneWidget);
    expect(find.text('สมัครสมาชิก'), findsOneWidget);

    // Verify Social Login Buttons
    expect(find.byType(SocialLoginButton), findsNWidgets(2));
  });

  testWidgets('Tapping switch button toggles between Login and Sign Up modes', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    // Initially Login mode
    expect(find.text('ยังไม่มีบัญชีใช่ไหม? '), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'เข้าสู่ระบบ'), findsOneWidget);

    // Tap switch to register
    await tester.tap(find.text('สมัครสมาชิก'));
    await tester.pump();

    // Now in Register mode
    expect(find.text('มีบัญชีอยู่แล้ว? '), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'สมัครสมาชิก'), findsOneWidget);
  });
}
