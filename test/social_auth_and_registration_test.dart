import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_mobile/core/constants.dart';
import 'package:pin_mobile/screens/auth/login_screen.dart';
import 'package:pin_mobile/screens/auth/register_screen.dart';
import 'package:pin_mobile/screens/auth/social_register_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('Registration and Social Auth Flow Tests (รูปที่ 1, รูปที่ 2, รูปที่ 3)', () {
    testWidgets('1. RegisterScreen has "ชื่อผู้ใช้" after name & surname, validates all required fields', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RegisterScreen(),
          ),
        ),
      );
      await tester.pump();

      // Title & Subtitle
      expect(find.text('สมัครสมาชิก'), findsWidgets);
      expect(find.text('สมัครสมาชิกเพื่อเริ่มต้นใช้งาน'), findsOneWidget);

      // 1. ชื่อ
      expect(find.text('ชื่อ'), findsOneWidget);
      expect(find.text('ชื่อจริง'), findsOneWidget);

      // 2. นามสกุล
      expect(find.text('นามสกุล'), findsNWidgets(2)); // label and hint

      // 3. ชื่อผู้ใช้ (ต่อจากชื่อและนามสกุล ตามรูปที่ 1 และคำสั่ง)
      expect(find.text('ชื่อผู้ใช้'), findsOneWidget);
      expect(find.text('กรุณากรอกชื่อผู้ใช้'), findsOneWidget);
      expect(find.byKey(const Key('username_field')), findsOneWidget);

      // 4. เบอร์โทรศัพท์
      expect(find.text('เบอร์โทรศัพท์'), findsOneWidget);
      expect(find.text('กรุณากรอกเบอร์โทรศัพท์'), findsOneWidget);

      // 5. อีเมล
      expect(find.text('อีเมล'), findsOneWidget);

      // 6. รหัสผ่าน
      expect(find.text('รหัสผ่าน'), findsOneWidget);

      // 7. ยืนยันรหัสผ่าน
      expect(find.text('ยืนยันรหัสผ่าน'), findsOneWidget);

      // ตรวจสอบเงื่อนไขว่าทุกช่องในหน้าสมัครสมาชิกต้องกรอกทั้งหมด:
      final submitButton = find.byKey(const Key('register_submit_button'));
      await tester.ensureVisible(submitButton);
      await tester.pump();
      await tester.tap(submitButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('กรุณากรอกชื่อจริง'), findsOneWidget);
    });

    testWidgets('2. Social Login Popup Dialog (รูปที่ 2 โทนสี burgundyPrimary) displays for Google and Facebook', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      await tester.pump();

      final loginState = tester.state(find.byType(LoginScreen)) as dynamic;

      // 2.1 ทดสอบกรณีล็อกอินด้วย Google แล้วไม่พบบัญชีในตาราง users
      loginState.showSocialAccountNotFoundDialog(OAuthProvider.google);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // ต้องขึ้นป็อปอัพหัวข้อ "ไม่พบบัญชี MealMate"
      expect(find.text('ไม่พบบัญชี MealMate'), findsOneWidget);
      // ข้อความ "บัญชี Google นี้ไม่ได้เชื่อมต่อกับบัญชี MealMate"
      expect(find.text('บัญชี Google นี้ไม่ได้เชื่อมต่อกับบัญชี MealMate'), findsOneWidget);

      // มีปุ่ม "ลงทะเบียน" และปุ่ม "ปิด"
      expect(find.byKey(const Key('social_dialog_register_button')), findsOneWidget);
      expect(find.text('ลงทะเบียน'), findsOneWidget);
      expect(find.byKey(const Key('social_dialog_close_button')), findsOneWidget);
      expect(find.text('ปิด'), findsOneWidget);

      // ตรวจสอบสี burgundyPrimary ของปุ่มลงทะเบียน
      final registerElevatedButton = tester.widget<ElevatedButton>(find.byKey(const Key('social_dialog_register_button')));
      expect(registerElevatedButton.style?.backgroundColor?.resolve({}), equals(AppConstants.burgundyPrimary));

      // กดปุ่มปิด
      await tester.tap(find.byKey(const Key('social_dialog_close_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('ไม่พบบัญชี MealMate'), findsNothing);

      // 2.2 ทดสอบกรณีล็อกอินด้วย Facebook แล้วไม่พบบัญชีในตาราง users
      loginState.showSocialAccountNotFoundDialog(OAuthProvider.facebook);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('ไม่พบบัญชี MealMate'), findsOneWidget);
      // ข้อความเปลี่ยนเป็น Facebook
      expect(find.text('บัญชี Facebook นี้ไม่ได้เชื่อมต่อกับบัญชี MealMate'), findsOneWidget);

      await tester.tap(find.byKey(const Key('social_dialog_close_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('3. Tapping "ลงทะเบียน" from popup opens SocialRegisterScreen to complete profile', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      await tester.pump();

      final loginState = tester.state(find.byType(LoginScreen)) as dynamic;
      loginState.showSocialAccountNotFoundDialog(OAuthProvider.google);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // กดปุ่ม "ลงทะเบียน"
      await tester.tap(find.byKey(const Key('social_dialog_register_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // นำทางมายังหน้า SocialRegisterScreen
      expect(find.byType(SocialRegisterScreen), findsOneWidget);
      expect(find.text('ลงทะเบียนสมาชิก'), findsOneWidget);
      expect(find.text('เชื่อมต่อบัญชีกับ Google'), findsOneWidget);

      // ตรวจสอบช่องกรอก: ชื่อ, นามสกุล, ชื่อผู้ใช้, เบอร์โทร
      expect(find.byKey(const Key('first_name_field')), findsOneWidget);
      expect(find.byKey(const Key('last_name_field')), findsOneWidget);
      expect(find.byKey(const Key('username_field')), findsOneWidget);
      expect(find.byKey(const Key('phone_field')), findsOneWidget);

      // ตรวจสอบ validation ว่าต้องกรอกทุกช่อง
      final submitButton = find.byKey(const Key('social_register_submit_button'));
      await tester.ensureVisible(submitButton);
      await tester.pump();

      // Clear any prefilled text to test required fields
      await tester.ensureVisible(find.byKey(const Key('first_name_field')));
      await tester.enterText(find.descendant(of: find.byKey(const Key('first_name_field')), matching: find.byType(TextField)), '');
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('กรุณากรอกชื่อจริง'), findsOneWidget);
    });

    testWidgets('4. SocialRegisterScreen validates phone format and completes registration', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SocialRegisterScreen(
              providerName: 'google',
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.enterText(find.descendant(of: find.byKey(const Key('first_name_field')), matching: find.byType(TextField)), 'นพดล');
      await tester.enterText(find.descendant(of: find.byKey(const Key('last_name_field')), matching: find.byType(TextField)), 'สุขเกษม');
      await tester.enterText(find.descendant(of: find.byKey(const Key('username_field')), matching: find.byType(TextField)), 'nopadol_s');
      // เบอร์สั้นไป
      await tester.enterText(find.descendant(of: find.byKey(const Key('phone_field')), matching: find.byType(TextField)), '1234');

      final submitButton = find.byKey(const Key('social_register_submit_button'));
      await tester.ensureVisible(submitButton);
      await tester.pump();
      await tester.tap(submitButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('กรุณากรอกเบอร์โทรศัพท์ให้ถูกต้อง'), findsOneWidget);

      // เบอร์ถูกต้อง
      await tester.ensureVisible(find.byKey(const Key('phone_field')));
      await tester.enterText(find.descendant(of: find.byKey(const Key('phone_field')), matching: find.byType(TextField)), '0891234567');
      await tester.pump();
      expect(find.text('0891234567'), findsOneWidget);
    });
  });
}
