import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pin_mobile/models/user_model.dart';
import 'package:pin_mobile/providers/auth_provider.dart';
import 'package:pin_mobile/screens/profile/user_profile_screen.dart';
import 'package:pin_mobile/screens/profile/edit_user_profile_screen.dart';
import 'package:pin_mobile/screens/profile/settings_screen.dart';
import 'package:pin_mobile/screens/profile/report_problem_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('User Profile & Edit Flow Tests (Database & UI Aligned)', () {
    testWidgets('UserProfileScreen (รูปที่ 1) renders avatar without camera badge, and displays "ชื่อผู้ใช้"', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      final testUser = UserModel(
        id: 'test_user_id',
        email: 'audrey.reed@gmail.com',
        name: 'Audrey Reed',
        phone: '0859821528',
        role: 'user',
        username: 'audrey_reed',
        avatarUrl: 'https://images.unsplash.com/test-profile.jpg',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith((ref) => AuthStateNotifier()..setUserFromMap(testUser.toJson())),
          ],
          child: const MaterialApp(
            home: UserProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Top title
      expect(find.text('โปรไฟล์'), findsOneWidget);

      // Verify NO camera badge icon exists on UserProfileScreen
      expect(find.byIcon(Icons.camera_alt_outlined), findsNothing);
      expect(find.byIcon(Icons.camera_alt_rounded), findsNothing);

      // Section Title
      expect(find.text('ข้อมูลผู้ใช้งาน'), findsOneWidget);

      // Verify "ชื่อผู้ใช้" is present and connected to username
      expect(find.text('ชื่อผู้ใช้'), findsOneWidget);
      expect(find.text('audrey_reed'), findsOneWidget);

      // Verify other profile fields
      expect(find.text('ชื่อ - นามสกุล'), findsOneWidget);
      expect(find.text('Audrey Reed'), findsOneWidget);
      expect(find.text('อีเมล'), findsOneWidget);
      expect(find.text('audrey.reed@gmail.com'), findsOneWidget);
      expect(find.text('เบอร์โทรศัพท์'), findsOneWidget);
      expect(find.text('085-982-1528'), findsOneWidget);
      expect(find.text('รหัสผ่าน'), findsOneWidget);

      // Verify action buttons on Profile Screen: "แก้ไขข้อมูล" is present, "ลบบัญชี" has been REMOVED (moved to Settings)
      expect(find.text('แก้ไขข้อมูล'), findsOneWidget);
      expect(find.text('ลบบัญชี'), findsNothing);
    });

    testWidgets('EditUserProfileScreen (รูปที่ 2) renders avatar with camera badge (รูปที่ 3), username field, and Save button at top right', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: EditUserProfileScreen(
              initialUsername: 'audrey_reed',
              initialName: 'Audrey Reed',
              initialEmail: 'audrey.reed@gmail.com',
              initialPhone: '085-982-1528',
              initialImageUrl: 'https://images.unsplash.com/test-profile.jpg',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Title in AppBar
      expect(find.text('แก้ไขข้อมูลผู้ใช้งาน'), findsOneWidget);

      // Save button at top right
      expect(find.text('บันทึก'), findsOneWidget);

      // Bottom buttons "บันทึกข้อมูล" and "ยกเลิก" are REMOVED
      expect(find.text('บันทึกข้อมูล'), findsNothing);
      expect(find.text('ยกเลิก'), findsNothing);

      // Top avatar has camera badge (รูปที่ 3)
      expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);

      // Form fields exist: ชื่อผู้ใช้, ชื่อ - นามสกุล, อีเมล, เบอร์โทรศัพท์, รหัสผ่าน
      expect(find.text('ชื่อผู้ใช้'), findsOneWidget);
      expect(find.text('ชื่อ - นามสกุล'), findsOneWidget);
      expect(find.text('อีเมล'), findsOneWidget);
      expect(find.text('เบอร์โทรศัพท์'), findsOneWidget);
      expect(find.text('รหัสผ่าน'), findsOneWidget);
      expect(find.text('ลืมรหัสผ่าน'), findsOneWidget);

      // Text controllers have initial values
      expect(find.widgetWithText(TextField, 'audrey_reed'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Audrey Reed'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'audrey.reed@gmail.com'), findsOneWidget);
      expect(find.widgetWithText(TextField, '085-982-1528'), findsOneWidget);
    });

    testWidgets('EditUserProfileScreen tapping back button pops without saving and retains original data', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      final testUser = UserModel(
        id: 'test_user_id',
        email: 'audrey.reed@gmail.com',
        name: 'Audrey Reed',
        phone: '0859821528',
        role: 'user',
        username: 'audrey_reed',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith((ref) => AuthStateNotifier()..setUserFromMap(testUser.toJson())),
          ],
          child: const MaterialApp(
            home: UserProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open Edit Screen
      await tester.tap(find.text('แก้ไขข้อมูล'));
      await tester.pumpAndSettle();

      expect(find.text('แก้ไขข้อมูลผู้ใช้งาน'), findsOneWidget);

      // Change username and name in text fields
      await tester.enterText(find.widgetWithText(TextField, 'audrey_reed'), 'new_username_not_saved');
      await tester.enterText(find.widgetWithText(TextField, 'Audrey Reed'), 'New Name Not Saved');
      await tester.pumpAndSettle();

      // Tap back button (chevron left)
      final backButton = find.byIcon(Icons.chevron_left_rounded);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Returned to UserProfileScreen with ORIGINAL data intact
      expect(find.text('โปรไฟล์'), findsOneWidget);
      expect(find.text('audrey_reed'), findsOneWidget);
      expect(find.text('Audrey Reed'), findsOneWidget);
      expect(find.text('new_username_not_saved'), findsNothing);
      expect(find.text('New Name Not Saved'), findsNothing);
    });

    testWidgets('Tapping avatar in EditUserProfileScreen shows photo options with delete confirmation', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: EditUserProfileScreen(
              initialUsername: 'audrey_reed',
              initialName: 'Audrey Reed',
              initialEmail: 'audrey.reed@gmail.com',
              initialPhone: '085-982-1528',
              initialImageUrl: 'https://images.unsplash.com/test-profile.jpg',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap camera icon badge
      await tester.tap(find.byIcon(Icons.camera_alt_outlined));
      await tester.pumpAndSettle();

      // Verify bottom sheet options
      expect(find.text('รูปภาพโปรไฟล์'), findsOneWidget);
      expect(find.text('ถ่ายรูปภาพ'), findsOneWidget);
      expect(find.text('เลือกจากคลังรูปภาพ'), findsOneWidget);
      expect(find.text('ลบรูปภาพ'), findsOneWidget);

      // Tap "ลบรูปภาพ"
      await tester.tap(find.text('ลบรูปภาพ'));
      await tester.pumpAndSettle();

      // Verify confirmation dialog
      expect(find.text('ยืนยันลบรูปภาพ'), findsOneWidget);
      expect(find.text('คุณต้องการลบรูปภาพโปรไฟล์นี้ใช่หรือไม่?'), findsOneWidget);
      expect(find.text('ยกเลิก'), findsOneWidget);

      // Confirm delete
      final deleteConfirmButton = find.widgetWithText(ElevatedButton, 'ลบรูปภาพ');
      await tester.tap(deleteConfirmButton);
      await tester.pumpAndSettle();

      // SnackBar feedback
      expect(find.text('ลบรูปภาพเรียบร้อยแล้ว'), findsOneWidget);
    });

    testWidgets('SettingsScreen (รูปที่ 1) displays "ลบบัญชี" button and tapping it shows confirmation dialog with "ยกเลิก" and "ยืนยัน"', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SettingsScreen(
              email: 'Emma.carter@gmail.com',
              phone: '099-888-7777',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Top title
      expect(find.text('การตั้งค่า'), findsOneWidget);

      // Section titles
      expect(find.text('ความเป็นส่วนตัว'), findsOneWidget);
      expect(find.text('ความปลอดภัยของบัญชี'), findsOneWidget);
      expect(find.text('เกี่ยวกับแอป'), findsOneWidget);

      // Scroll to bottom to ensure "ลบบัญชี" is visible
      final deleteBtnFinder = find.byKey(const Key('settings_delete_account_button'));
      expect(deleteBtnFinder, findsOneWidget);
      await tester.ensureVisible(deleteBtnFinder);
      await tester.pumpAndSettle();

      expect(find.text('ลบบัญชี'), findsOneWidget);

      // Tap "ลบบัญชี" button
      await tester.tap(deleteBtnFinder);
      await tester.pumpAndSettle();

      // Verify confirmation dialog appears
      expect(find.text('ต้องการลบบัญชีใช่หรือไม่'), findsOneWidget);
      expect(find.text('ยกเลิก'), findsOneWidget);
      expect(find.text('ยืนยัน'), findsOneWidget);

      // Tap "ยกเลิก" to dismiss dialog
      final cancelBtnFinder = find.byKey(const Key('cancel_delete_account_btn'));
      expect(cancelBtnFinder, findsOneWidget);
      await tester.tap(cancelBtnFinder);
      await tester.pumpAndSettle();

      // Dialog is dismissed
      expect(find.text('ต้องการลบบัญชีใช่หรือไม่'), findsNothing);
    });

    test('UserModel maps image_url field to and from users table schema (รูปที่ 2)', () {
      final jsonFromDb = {
        'id': 'user_uuid_123',
        'email': 'audrey.reed@gmail.com',
        'first_name': 'Audrey',
        'last_name': 'Reed',
        'username': 'audreyre',
        'phone': '0859821528',
        'role': 'user',
        'user_type': 'customer',
        'image_url': 'https://storage.supabase.co/restaurant-images/user_avatar_123.png',
      };

      final user = UserModel.fromJson(jsonFromDb);
      expect(user.username, equals('audreyre'));
      expect(user.avatarUrl, equals('https://storage.supabase.co/restaurant-images/user_avatar_123.png'));

      final jsonToDb = user.toJson();
      expect(jsonToDb['image_url'], equals('https://storage.supabase.co/restaurant-images/user_avatar_123.png'));
      expect(jsonToDb['username'], equals('audreyre'));
    });

    testWidgets('ReportProblemScreen removes quick chips under dropdown and removes contact email field', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(
        const MaterialApp(
          home: ReportProblemScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Top title
      expect(find.text('รายงานปัญหา'), findsOneWidget);

      // Category section exists
      expect(find.text('ประเภทปัญหา'), findsOneWidget);
      expect(find.text('ข้อมูลร้านค้าไม่ถูกต้อง'), findsOneWidget);

      // Verify the 3 quick chips under dropdown are REMOVED
      expect(find.text('ข้อมูลร้านค้า'), findsNothing);
      expect(find.text('ร้านปิด/ไม่พบร้าน'), findsNothing);
      expect(find.text('ปัญหาแอป'), findsNothing);

      // Other fields exist
      expect(find.text('ร้านค้าที่เกี่ยวข้อง(ถ้ามี)'), findsOneWidget);
      expect(find.text('รายละเอียด'), findsOneWidget);

      // Verify "อีเมลติดต่อกลับ" is REMOVED
      expect(find.text('อีเมลติดต่อกลับ'), findsNothing);
      expect(find.text('อีเมล@gmail.com'), findsNothing);

      // Submit button exists
      expect(find.text('ส่งรายงาน'), findsOneWidget);

      // Search and autocomplete test for "ร้านค้าที่เกี่ยวข้อง(ถ้ามี)"
      final restaurantInputFinder = find.byKey(const Key('report_restaurant_input'));
      expect(restaurantInputFinder, findsOneWidget);

      // Type "ชาบู" to trigger search from database (e.g. "ชาบูหมูอู๊ด")
      await tester.enterText(restaurantInputFinder, 'ชาบู');
      await tester.pumpAndSettle();

      // Dropdown appears with matching restaurant name from database
      expect(find.byKey(const Key('restaurant_search_dropdown')), findsOneWidget);
      expect(find.text('ชาบูหมูอู๊ด'), findsOneWidget);

      // Tap suggestion to select
      await tester.tap(find.text('ชาบูหมูอู๊ด'));
      await tester.pumpAndSettle();

      // Dropdown closes and input text is set to selected restaurant
      expect(find.byKey(const Key('restaurant_search_dropdown')), findsNothing);
      expect(find.widgetWithText(TextField, 'ชาบูหมูอู๊ด'), findsOneWidget);
    });
  });
}
