import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_mobile/screens/auth/login_screen.dart';
import 'package:pin_mobile/screens/auth/register_screen.dart';
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

    // Verify removed header subtitles and admin portal button
    expect(find.text('โปรดลงชื่อเข้าใช้บัญชีที่มีอยู่'), findsNothing);
    expect(find.text('เข้าสู่ระบบสำหรับแอดมิน (Admin Portal)'), findsNothing);
  });

  testWidgets('Tapping สมัครสมาชิก opens RegisterScreen with all 6 fields and back button', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    // Initially on LoginScreen
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('ยังไม่มีบัญชีใช่ไหม? '), findsOneWidget);

    // Tap "สมัครสมาชิก"
    await tester.tap(find.text('สมัครสมาชิก'));
    await tester.pumpAndSettle();

    // Now on RegisterScreen
    expect(find.byType(RegisterScreen), findsOneWidget);

    // Verify Header Texts
    expect(find.text('สมัครสมาชิก'), findsNWidgets(2)); // Title and submit button
    expect(find.text('สมัครสมาชิกเพื่อเริ่มต้นใช้งาน'), findsOneWidget);

    // Verify Back Button "<"
    expect(find.byKey(const Key('register_back_button')), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);

    // Verify Input Labels and Hints
    expect(find.text('ชื่อ'), findsOneWidget);
    expect(find.text('ชื่อจริง'), findsOneWidget);
    expect(find.text('นามสกุล'), findsNWidgets(2)); // Label and hint are both 'นามสกุล'
    expect(find.text('ชื่อผู้ใช้'), findsOneWidget);
    expect(find.text('กรุณากรอกชื่อผู้ใช้'), findsOneWidget);
    expect(find.text('เลขบัตรประชาชน'), findsNothing);
    expect(find.text('กรุณากรอกเลขบัตรประชาชน'), findsNothing);
    expect(find.text('เบอร์โทรศัพท์'), findsOneWidget);
    expect(find.text('กรุณากรอกเบอร์โทรศัพท์'), findsOneWidget);
    expect(find.text('อีเมล'), findsOneWidget);
    expect(find.text('กรุณากรอกอีเมล'), findsOneWidget);
    expect(find.text('รหัสผ่าน'), findsOneWidget);
    expect(find.text('กรุณากรอกรหัสผ่าน'), findsOneWidget);
    expect(find.text('ยืนยันรหัสผ่าน'), findsOneWidget);
    expect(find.text('กรุณากรอกเพื่อยืนยันรหัสผ่าน'), findsOneWidget);

    // Verify Tapping "<" returns back to LoginScreen
    await tester.tap(find.byKey(const Key('register_back_button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verified returned to LoginScreen
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(RegisterScreen), findsNothing);
  });

  testWidgets('Submitting registration returns to LoginScreen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    // Tap "สมัครสมาชิก" to open RegisterScreen
    await tester.tap(find.text('สมัครสมาชิก'));
    await tester.pumpAndSettle();
    expect(find.byType(RegisterScreen), findsOneWidget);

    // Fill all form fields
    await tester.enterText(find.descendant(of: find.byKey(const Key('first_name_field')), matching: find.byType(TextField)), 'สมชาย');
    await tester.enterText(find.descendant(of: find.byKey(const Key('last_name_field')), matching: find.byType(TextField)), 'ใจดี');
    await tester.enterText(find.descendant(of: find.byKey(const Key('username_field')), matching: find.byType(TextField)), 'somchai123');
    await tester.enterText(find.descendant(of: find.byKey(const Key('phone_field')), matching: find.byType(TextField)), '0812345678');
    await tester.enterText(find.descendant(of: find.byKey(const Key('email_field')), matching: find.byType(TextField)), 'test@test.com');
    await tester.enterText(find.descendant(of: find.byKey(const Key('password_field')), matching: find.byType(TextField)), '123456');
    await tester.enterText(find.descendant(of: find.byKey(const Key('confirm_password_field')), matching: find.byType(TextField)), '123456');
    await tester.pump();

    // Ensure terms checkbox is checked
    final termsCheckbox = find.byKey(const Key('register_terms_checkbox'));
    await tester.ensureVisible(termsCheckbox);
    await tester.tap(termsCheckbox);
    await tester.pump();

    // Ensure submit button is visible before tapping
    await tester.ensureVisible(find.byKey(const Key('register_submit_button')));
    await tester.pump();

    // Tap submit button
    await tester.tap(find.byKey(const Key('register_submit_button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Successfully returned to LoginScreen
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(RegisterScreen), findsNothing);
  });
}
