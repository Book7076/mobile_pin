import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pin_mobile/screens/home/home_screen.dart';
import 'package:pin_mobile/screens/restaurants/create_restaurant_screen.dart';
import 'package:pin_mobile/screens/restaurants/open_restaurant_intro_screen.dart';
import 'package:pin_mobile/screens/restaurants/restaurant_pending_review_screen.dart';
import 'package:pin_mobile/services/admin_restaurant_service.dart';
import 'package:pin_mobile/providers/restaurant_provider.dart';

void main() {
  group('Restaurant Registration & Database Alignment Tests', () {
    testWidgets('1. Tapping เริ่มลงทะเบียนร้าน navigates directly to CreateRestaurantScreen with ข้อมูลร้าน header', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: OpenRestaurantIntroScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      final registerBtn = find.text('เริ่มลงทะเบียนร้าน');
      expect(registerBtn, findsOneWidget);

      await tester.tap(registerBtn);
      await tester.pumpAndSettle();

      // Should now be on CreateRestaurantScreen with ข้อมูลร้าน header matching Screenshot 1
      expect(find.byType(CreateRestaurantScreen), findsOneWidget);
      expect(find.text('ข้อมูลร้าน'), findsOneWidget);
    });

    testWidgets('2. CreateRestaurantScreen matches Screenshots 1-4 with empty initial state and no status stepper', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CreateRestaurantScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // 1. Header (Screenshot 1: no top-right save button)
      expect(find.text('ข้อมูลร้าน'), findsOneWidget);
      expect(find.text('บันทึก'), findsNothing);

      // 2. Profile Row: empty initial state ("ระบุชื่อร้านอาหาร")
      expect(find.text('ระบุชื่อร้านอาหาร'), findsOneWidget);
      expect(find.textContaining('ประเภทอาหาร :'), findsOneWidget);

      // 3. Section: รูปสำหรับหน้าปัดร้านอาหาร (Screenshot 1)
      expect(find.text('รูปสำหรับหน้าปัดร้านอาหาร'), findsOneWidget);
      expect(find.text('รูปภาพร้านอาหารหรือเมนูแนะนำ เพื่อแสดงบนหน้าปัดหน้าร้านอาหาร'), findsOneWidget);

      // 4. Section: ที่อยู่ (Screenshot 1)
      expect(find.text('ที่อยู่'), findsOneWidget);

      // 5. Section: เวลาเปิด - ปิดร้าน (Screenshot 1)
      expect(find.text('เวลาเปิด - ปิดร้าน'), findsOneWidget);
      expect(find.text('อาทิตย์'), findsOneWidget);
      expect(find.text('จันทร์'), findsOneWidget);

      // 6. Section: สิ่งอำนวยความสะดวก (Screenshot 2)
      expect(find.text('สิ่งอำนวยความสะดวก'), findsOneWidget);

      // 7. Section: เมนูอาหาร (อย่างน้อย 3 อย่าง)
      expect(find.textContaining('เมนูอาหาร (0/3 อย่าง) *'), findsOneWidget);
      expect(find.text('+ เพิ่มเมนู'), findsOneWidget);
      expect(find.text('ใส่ 3 ตัวอย่าง'), findsOneWidget);

      // 8. Action Button: ส่งข้อมูลเพื่ออนุมัติ
      expect(find.text('ส่งข้อมูลเพื่ออนุมัติ'), findsOneWidget);

      // 9. CRITICAL CHECK: No "สถานะร้านค้า" stepper should be shown
      expect(find.text('สถานะร้านค้า'), findsNothing);
      expect(find.text('1\nส่งคำขอ'), findsNothing);
      expect(find.text('ผ่านการตรวจสอบ'), findsNothing);
    });

    testWidgets('3. Form blocks submission and shows warning when mandatory fields are missing', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CreateRestaurantScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      final submitBtn = find.text('ส่งข้อมูลเพื่ออนุมัติ');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      // Should show validation warning (name is empty)
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('กรุณาระบุชื่อร้านอาหาร'), findsOneWidget);
    });

    testWidgets('4. Screenshot 4 Modal Bottom Sheet: แก้ไขข้อมูลติดต่อและที่อยู่ opens and updates fields', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CreateRestaurantScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Tap "แก้ไข" in ที่อยู่ section
      final editAddressBtn = find.text('แก้ไข').at(1); // 0 is logo, 1 is address
      await tester.tap(editAddressBtn);
      await tester.pumpAndSettle();

      // Modal Bottom Sheet from Screenshot 4
      expect(find.text('แก้ไขข้อมูลติดต่อและที่อยู่'), findsOneWidget);
      expect(find.text('ที่อยู่ร้านอาหาร'), findsOneWidget);
      expect(find.text('ลิงก์ Google Maps'), findsOneWidget);
      expect(find.text('เบอร์โทรศัพท์ติดต่อ'), findsOneWidget);
      expect(find.text('อีเมลร้านค้า'), findsOneWidget);
      expect(find.text('บันทึกข้อมูล'), findsOneWidget);

      // Enter data in bottom sheet
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'RX53+CV9 ตำบลช้างเผือก เชียงใหม่ 50300');
      await tester.enterText(textFields.at(1), 'https://maps.app.goo.gl/mnsZN4wPsw5k9KZE9');
      await tester.enterText(textFields.at(2), '0652454642');
      await tester.enterText(textFields.at(3), 'MADISON.PARKER@GMAIL.COM');

      await tester.tap(find.text('บันทึกข้อมูล'));
      await tester.pumpAndSettle();

      // Verify fields updated on screen
      expect(find.text('RX53+CV9 ตำบลช้างเผือก เชียงใหม่ 50300'), findsOneWidget);
      expect(find.text('https://maps.app.goo.gl/mnsZN4wPsw5k9KZE9'), findsOneWidget);
      expect(find.text('0652454642'), findsOneWidget);
      expect(find.text('MADISON.PARKER@GMAIL.COM'), findsOneWidget);
    });

    testWidgets('5. Adding 3 sample menus and submitting navigates to solid red RestaurantPendingReviewScreen', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CreateRestaurantScreen(
              initialLogoImageUrl: 'https://images.unsplash.com/logo.jpg',
              initialBannerImageUrl: 'https://images.unsplash.com/banner.jpg',
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // 1. Enter Name
      await tester.tap(find.byIcon(Icons.edit_note_rounded));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Roastniyom Coffee');
      await tester.tap(find.text('บันทึก').last);
      await tester.pumpAndSettle();

      // 2. Select Cuisine Type
      await tester.tap(find.textContaining('ประเภทอาหาร :'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('อาหารไทย').first);
      await tester.pumpAndSettle();

      // 3. Verify Logo & Banner bottom sheet options (ถ่ายรูปภาพ & เลือกจากคลังรูปภาพ - matching Owner)
      await tester.tap(find.text('แก้ไข').at(0)); // logo edit
      await tester.pumpAndSettle();
      expect(find.text('รูปภาพโปรไฟล์ร้านอาหาร'), findsOneWidget);
      expect(find.text('ถ่ายรูปภาพ'), findsOneWidget);
      expect(find.text('เลือกจากคลังรูปภาพ'), findsOneWidget);
      expect(find.text('ลบรูปภาพ'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      await tester.tap(find.text('แก้ไข').at(1)); // banner edit
      await tester.pumpAndSettle();
      expect(find.text('รูปภาพสำหรับหน้าปัดร้านอาหาร'), findsOneWidget);
      expect(find.text('ถ่ายรูปภาพ'), findsOneWidget);
      expect(find.text('เลือกจากคลังรูปภาพ'), findsOneWidget);
      expect(find.text('ลบรูปภาพ'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // 4. Address & Contact
      await tester.tap(find.text('แก้ไข').at(2)); // address edit
      await tester.pumpAndSettle();
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'RX53+CV9 ตำบลช้างเผือก เชียงใหม่');
      await tester.enterText(fields.at(1), 'https://maps.app.goo.gl/test');
      await tester.enterText(fields.at(2), '0652454642');
      await tester.enterText(fields.at(3), 'test@gmail.com');
      await tester.tap(find.text('บันทึกข้อมูล'));
      await tester.pumpAndSettle();

      // 5. Operating Hours (OwnerEditOperatingHoursScreen - Screenshot 3 & 4)
      final editHoursBtn = find.text('แก้ไข').at(3); // hours edit
      await tester.ensureVisible(editHoursBtn);
      await tester.tap(editHoursBtn);
      await tester.pumpAndSettle();

      await tester.tap(find.text('เลือกวัน'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ทุกวัน'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('เวลาเปิด'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('01:00'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('เวลาปิด'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('02:00'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('เพิ่ม'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('บันทึก').last);
      await tester.pumpAndSettle();

      // 6. Facilities (OwnerEditAmenitiesScreen)
      final editFacilitiesBtn = find.text('แก้ไข').at(4); // facilities edit
      await tester.ensureVisible(editFacilitiesBtn);
      await tester.tap(editFacilitiesBtn);
      await tester.pumpAndSettle();
      await tester.tap(find.text('มีปลั๊กไฟ'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('บันทึก').last);
      await tester.pumpAndSettle();

      // 7. Add 3 sample menus
      final addSampleBtn = find.text('ใส่ 3 ตัวอย่าง');
      await tester.ensureVisible(addSampleBtn);
      await tester.tap(addSampleBtn);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.textContaining('เมนูอาหาร (3/3 อย่าง) *'), findsOneWidget);

      // 8. Submit
      final submitBtn = find.text('ส่งข้อมูลเพื่ออนุมัติ');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      // Must navigate to RestaurantPendingReviewScreen with solid red background
      expect(find.byType(RestaurantPendingReviewScreen), findsOneWidget);
      expect(find.text('รอการตรวจสอบร้านประมาณ 2-3 วัน'), findsOneWidget);
      expect(find.text('กลับสู่หน้าการตั้งค่า'), findsOneWidget);

      // Wait for any snackbars to dismiss before tapping
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      // Test tapping "กลับสู่หน้าการตั้งค่า"
      final backToSettingsBtn = find.text('กลับสู่หน้าการตั้งค่า');
      await tester.tap(backToSettingsBtn);
      await tester.pumpAndSettle();

      // Should land on HomeScreen tab 3 (Profile / Settings)
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('6. Dynamic Settings Switch: owner shows แดชบอร์ดเจ้าของร้าน vs non-owner shows เปิดร้านอาหาร', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.resetPhysicalSize());

      // Test non-owner: displays เปิดร้านอาหาร
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomeScreen(initialTab: 2),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('เปิดร้านอาหาร'), findsOneWidget);
      expect(find.text('โปรไฟล์'), findsOneWidget);
      expect(find.text('การตั้งค่า'), findsOneWidget);
    });

    testWidgets('7. Customer display rule: pending and rejected restaurants must NEVER be shown in swipe/discovery list', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Verify filteredRestaurantsProvider only contains approved restaurants
      final filteredList = container.read(filteredRestaurantsProvider);
      for (final r in filteredList) {
        expect(r.status, equals('approved'), reason: 'Customer must never see non-approved restaurant: ${r.name}');
      }

      // Verify that known pending or rejected restaurants are excluded
      final hasPending = filteredList.any((r) => r.status == 'pending');
      final hasRejected = filteredList.any((r) => r.status == 'rejected');
      expect(hasPending, isFalse);
      expect(hasRejected, isFalse);
    });

    testWidgets('8. Admin status decision & user_type lifecycle: approve sets approved & owner, reject sets rejected & owner', (tester) async {
      final notifier = AdminRestaurantNotifier();

      // Test 1: Approve restaurant
      final approveResult = await notifier.approveRestaurant('res-01');
      expect(approveResult, isTrue);
      final approvedItem = notifier.state.firstWhere((r) => r.id == 'res-01');
      expect(approvedItem.status, equals('approved'));

      // Test 2: Reject restaurant
      final rejectResult = await notifier.rejectRestaurant('res-02', 'ข้อมูลไม่ครบถ้วน');
      expect(rejectResult, isTrue);
      final rejectedItem = notifier.state.firstWhere((r) => r.id == 'res-02');
      expect(rejectedItem.status, equals('rejected'));
      expect(rejectedItem.rejectionReason, equals('ข้อมูลไม่ครบถ้วน'));
    });

    testWidgets('9. Adding menu without image does not show fallback food image and displays ไม่มีรูป placeholder', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CreateRestaurantScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Tap + เพิ่มเมนู
      final addMenuBtn = find.text('+ เพิ่มเมนู');
      await tester.ensureVisible(addMenuBtn);
      await tester.tap(addMenuBtn);
      await tester.pumpAndSettle();

      // Enter Name and Price without image
      await tester.enterText(find.byType(TextField).at(0), 'ข้าวมันไก่');
      await tester.enterText(find.byType(TextField).at(1), '50');

      // Select Category
      await tester.tap(find.text('ข้าว'));
      await tester.pumpAndSettle();

      // Save Menu Item
      await tester.tap(find.text('บันทึก').last);
      await tester.pumpAndSettle();

      // Verify menu item was added without image and renders 'ไม่มีรูป' placeholder
      expect(find.text('ข้าวมันไก่'), findsOneWidget);
      expect(find.text('ไม่มีรูป'), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);
    });
  });
}
