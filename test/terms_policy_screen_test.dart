import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_mobile/core/constants.dart';
import 'package:pin_mobile/models/user_model.dart';
import 'package:pin_mobile/screens/auth/terms_policy_screen.dart';
import 'package:pin_mobile/screens/auth/register_screen.dart';
import 'package:pin_mobile/screens/auth/social_register_screen.dart';

void main() {
  group('Terms & Privacy Policy Tests (PDPA Compliance)', () {
    test('1. UserModel correctly parses and serializes terms_accepted_at', () {
      final now = DateTime.parse('2026-10-16T12:00:00.000Z');
      final json = {
        'id': 'u1',
        'email': 'user@example.com',
        'name': 'Somchai',
        'role': 'customer',
        'terms_accepted_at': now.toIso8601String(),
      };

      final user = UserModel.fromJson(json);
      expect(user.termsAcceptedAt, equals(now));

      final serialized = user.toJson();
      expect(serialized['terms_accepted_at'], equals(now.toIso8601String()));

      final copied = user.copyWith(name: 'Updated Name');
      expect(copied.termsAcceptedAt, equals(now));

      final cleared = user.copyWith(clearTermsAcceptedAt: true);
      expect(cleared.termsAcceptedAt, isNull);
    });

    testWidgets('2. TermsPolicyScreen renders full Thai policy content with all 8 sections and effective date', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: TermsPolicyScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Effective Date
      expect(find.text('วันที่มีผลบังคับใช้: 16 ตุลาคม 2569'), findsOneWidget);

      // Section titles
      expect(find.text('1. ข้อมูลที่เราเก็บรวบรวม', skipOffstage: false), findsOneWidget);
      expect(find.text('2. วัตถุประสงค์ในการใช้ข้อมูล', skipOffstage: false), findsOneWidget);
      expect(find.text('3. การเปิดเผยข้อมูล', skipOffstage: false), findsOneWidget);
      expect(find.text('4. ระยะเวลาในการเก็บรักษาข้อมูล', skipOffstage: false), findsOneWidget);
      expect(find.text('5. การรักษาความมั่นคงปลอดภัย', skipOffstage: false), findsOneWidget);
      expect(find.text('6. สิทธิของเจ้าของข้อมูล', skipOffstage: false), findsOneWidget);
      expect(find.text('7. การเปลี่ยนแปลงนโยบาย', skipOffstage: false), findsOneWidget);
      expect(find.text('8. ช่องทางติดต่อ', skipOffstage: false), findsOneWidget);

      // Provider and Email Contact
      expect(find.text('ผู้ให้บริการ: ทีมพัฒนา MealMate', skipOffstage: false), findsOneWidget);
      expect(find.text('อีเมล: MealMate@gmail.com', skipOffstage: false), findsOneWidget);

      // Closing text
      expect(
        find.text('การใช้งานแอปและการประมวลผลข้อมูลส่วนบุคคลเป็นไปตามนโยบายฉบับนี้และกฎหมายที่เกี่ยวข้อง', skipOffstage: false),
        findsOneWidget,
      );

      // Buttons
      expect(find.byKey(const Key('terms_accept_button')), findsOneWidget);
      expect(find.byKey(const Key('terms_logout_button')), findsOneWidget);
    });

    testWidgets('3. On standard mobile viewport, "ยอมรับ" button starts disabled and enables after scrolling to bottom', (tester) async {
      // Small mobile height to force scrolling
      tester.view.physicalSize = const Size(400, 700);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: TermsPolicyScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Before scrolling to bottom: button is truly disabled (onPressed == null)
      final acceptButtonFinder = find.byKey(const Key('terms_accept_button'));
      ElevatedButton button = tester.widget<ElevatedButton>(acceptButtonFinder);
      expect(button.onPressed, isNull);

      // Hint is visible
      expect(find.text('กรุณาเลื่อนอ่านจนถึงท้ายเนื้อหาเพื่อกดยอมรับ'), findsOneWidget);

      // Scroll to the bottom
      await tester.drag(find.byKey(const Key('terms_scroll_view')), const Offset(0, -5000));
      await tester.pumpAndSettle();

      // Now button should be enabled and colored burgundyPrimary
      button = tester.widget<ElevatedButton>(acceptButtonFinder);
      expect(button.onPressed, isNotNull);
      expect(button.style?.backgroundColor?.resolve({}), equals(AppConstants.burgundyPrimary));

      // Hint is gone
      expect(find.text('กรุณาเลื่อนอ่านจนถึงท้ายเนื้อหาเพื่อกดยอมรับ'), findsNothing);
    });

    testWidgets('4. On very tall screen where content fits without scrolling, "ยอมรับ" button activates immediately', (tester) async {
      // Very tall screen height (e.g. tablet or desktop view)
      tester.view.physicalSize = const Size(1200, 6000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: TermsPolicyScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Button is immediately enabled
      final acceptButtonFinder = find.byKey(const Key('terms_accept_button'));
      final button = tester.widget<ElevatedButton>(acceptButtonFinder);
      expect(button.onPressed, isNotNull);
      expect(button.style?.backgroundColor?.resolve({}), equals(AppConstants.burgundyPrimary));
    });

    testWidgets('5. "ออกจากระบบ" button shows confirmation and can be dismissed or confirmed', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: TermsPolicyScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap "ออกจากระบบ" button
      final logoutBtn = find.byKey(const Key('terms_logout_button'));
      await tester.ensureVisible(logoutBtn);
      await tester.tap(logoutBtn);
      await tester.pumpAndSettle();

      // Dialog appears
      expect(find.text('หากคุณไม่อนุญาตและไม่กดยอมรับนโยบายความเป็นส่วนตัว คุณจะไม่สามารถเข้าใช้งานแอปได้ ต้องการออกจากระบบหรือไม่?'), findsOneWidget);
      expect(find.text('ยกเลิก'), findsOneWidget);

      // Tap cancel
      await tester.tap(find.text('ยกเลิก'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(TermsPolicyScreen), findsOneWidget);
    });

    testWidgets('6. RegisterScreen has terms checkbox and clicking link shows privacy policy dialog', (tester) async {
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
      await tester.pumpAndSettle();

      // Checkbox exists
      final checkboxFinder = find.byKey(const Key('register_terms_checkbox'));
      expect(checkboxFinder, findsOneWidget);
      expect(find.textContaining('ฉันได้อ่านและยอมรับ'), findsOneWidget);
      expect(find.text('นโยบายความเป็นส่วนตัว'), findsOneWidget);

      // Scroll to checkbox so it's in viewport
      await tester.ensureVisible(checkboxFinder);
      await tester.pumpAndSettle();

      // Tapping "นโยบายความเป็นส่วนตัว" opens dialog
      await tester.tap(find.text('นโยบายความเป็นส่วนตัว'));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsOneWidget);
      expect(find.text('วันที่มีผลบังคับใช้: 16 ตุลาคม 2569'), findsOneWidget);

      // Close dialog
      await tester.tap(find.text('ปิด'));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('7. SocialRegisterScreen has terms checkbox and clicking link shows privacy policy dialog', (tester) async {
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
      await tester.pumpAndSettle();

      // Checkbox exists
      expect(find.byKey(const Key('social_register_terms_checkbox')), findsOneWidget);
      expect(find.textContaining('ฉันได้อ่านและยอมรับ'), findsOneWidget);
      expect(find.text('นโยบายความเป็นส่วนตัว'), findsOneWidget);

      // Tapping "นโยบายความเป็นส่วนตัว" opens dialog
      await tester.tap(find.text('นโยบายความเป็นส่วนตัว'));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsOneWidget);
      expect(find.text('วันที่มีผลบังคับใช้: 16 ตุลาคม 2569'), findsOneWidget);

      // Close dialog
      await tester.tap(find.text('ปิด'));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsNothing);
    });
  });
}
