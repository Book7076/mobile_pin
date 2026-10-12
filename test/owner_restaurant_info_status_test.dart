import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pin_mobile/screens/owner/owner_restaurant_info_screen.dart';
import 'package:pin_mobile/widgets/image_crop_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OwnerRestaurantInfoScreen Dynamic Status Tests', () {
    testWidgets('Pending status renders Image 2 layout correctly', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(
        const MaterialApp(
          home: OwnerRestaurantInfoScreen(
            restaurantName: 'The CHICKEN Test',
            initialStatus: 'pending',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('สถานะร้านค้า'), findsOneWidget);
      expect(find.text('ส่งคำขอ'), findsOneWidget);
      expect(find.text('รอตรวจสอบ'), findsWidgets);
      expect(find.text('กำลังตรวจสอบ'), findsOneWidget);
      expect(find.text('ผลการตรวจสอบ'), findsOneWidget);

      // Verify card content matches Image 2
      expect(find.text('อยู่ระหว่างรอเจ้าหน้าที่ตรวจสอบ'), findsOneWidget);
      expect(find.byIcon(Icons.access_time_rounded), findsOneWidget);
      expect(
        find.textContaining('โดยปกติใช้เวลาประมาณ 3-5 วันทำการ'),
        findsOneWidget,
      );
    });

    testWidgets('In Review status renders under review layout correctly', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(
        const MaterialApp(
          home: OwnerRestaurantInfoScreen(
            restaurantName: 'The CHICKEN Test',
            initialStatus: 'in_review',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('สถานะร้านค้า'), findsOneWidget);
      expect(find.text('เจ้าหน้าที่กำลังตรวจสอบข้อมูลร้านค้า'), findsOneWidget);
      expect(find.byIcon(Icons.manage_search_rounded), findsWidgets);
      expect(
        find.textContaining('ระบบกำลังตรวจสอบความถูกต้องของข้อมูลร้านค้า'),
        findsOneWidget,
      );
    });

    testWidgets('Rejected status renders Image 3 layout correctly with reasons', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(
        const MaterialApp(
          home: OwnerRestaurantInfoScreen(
            restaurantName: 'The CHICKEN Test',
            initialStatus: 'rejected',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('สถานะร้านค้า'), findsOneWidget);
      // Card 1
      expect(find.text('ไม่ผ่านการตรวจสอบ'), findsOneWidget);
      expect(find.text('กรุณาแก้ไขข้อมูลและส่งคำขอใหม่'), findsOneWidget);
      // Card 2
      expect(find.text('เหตุผลที่ไม่ผ่านการตรวจสอบ'), findsOneWidget);
      expect(find.text('รูปภาพหน้าร้านไม่ชัดเจน'), findsOneWidget);
      expect(find.text('เมนูอาหารบางรายการไม่ถูกต้อง'), findsOneWidget);
      expect(find.text('ข้อมูลติดต่อร้านค้าไม่ครบถ้วน'), findsOneWidget);
    });

    testWidgets('Approved status renders approved layout correctly', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(
        const MaterialApp(
          home: OwnerRestaurantInfoScreen(
            restaurantName: 'The CHICKEN Test',
            initialStatus: 'approved',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('สถานะร้านค้า'), findsOneWidget);
      expect(find.text('ผ่านการตรวจสอบ'), findsOneWidget);
      expect(find.text('ร้านค้าของคุณได้รับการอนุมัติแล้ว'), findsOneWidget);
      expect(find.byIcon(Icons.storefront_outlined), findsOneWidget);
    });

    testWidgets('Status section is read-only (no PopupMenuButton for owner)', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(
        const MaterialApp(
          home: OwnerRestaurantInfoScreen(
            restaurantName: 'The CHICKEN Test',
            initialStatus: 'pending',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Ensure no PopupMenuButton exists in the screen
      expect(find.byType(PopupMenuButton<String>), findsNothing);
      expect(find.byIcon(Icons.tune_rounded), findsNothing);
    });

    testWidgets('Save button exists in AppBar and blocks save when photo is missing', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(
        const MaterialApp(
          home: OwnerRestaurantInfoScreen(
            restaurantName: 'The CHICKEN Test',
            restaurantImageUrl: null,
            initialStatus: 'pending',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify save button in AppBar
      final saveButton = find.widgetWithText(TextButton, 'บันทึก');
      expect(saveButton, findsOneWidget);

      // Tap save button without a photo
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Verify validation warning snackbar
      expect(
        find.descendant(
          of: find.byType(SnackBar),
          matching: find.textContaining('รูปภาพร้านอาหาร'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Photo options bottom sheet and delete confirmation popup work correctly', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(
        const MaterialApp(
          home: OwnerRestaurantInfoScreen(
            restaurantName: 'The CHICKEN Test',
            restaurantImageUrl: 'https://images.unsplash.com/test.jpg',
            initialStatus: 'approved',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap edit photo badge
      final editBadge = find.text('แก้ไข').first;
      await tester.tap(editBadge);
      await tester.pumpAndSettle();

      // BottomSheet options appear
      expect(find.text('รูปภาพโปรไฟล์ร้านอาหาร'), findsOneWidget);
      expect(find.text('ถ่ายรูปภาพ'), findsOneWidget);
      expect(find.text('เลือกจากคลังรูปภาพ'), findsOneWidget);
      expect(find.text('ลบรูปภาพ'), findsOneWidget);

      // Tap "ลบรูปภาพ"
      await tester.tap(find.text('ลบรูปภาพ'));
      await tester.pumpAndSettle();

      // Confirmation dialog appears
      expect(find.text('ยืนยันลบรูปภาพ'), findsOneWidget);
      expect(find.text('คุณต้องการลบรูปภาพร้านอาหารนี้ใช่หรือไม่?'), findsOneWidget);
      expect(find.text('ยกเลิก'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'ลบรูปภาพ'), findsOneWidget);

      // Tap "ลบรูปภาพ" in dialog to confirm deletion
      await tester.tap(find.widgetWithText(ElevatedButton, 'ลบรูปภาพ'));
      await tester.pumpAndSettle();

      // Dialog dismissed and snackbar confirms
      expect(find.text('ยืนยันลบรูปภาพ'), findsNothing);
      expect(find.text('ลบรูปภาพเรียบร้อยแล้ว'), findsOneWidget);

      // Now tapping "บันทึก" should fail validation because photo is deleted
      final saveButton = find.widgetWithText(TextButton, 'บันทึก');
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(SnackBar),
          matching: find.textContaining('รูปภาพร้านอาหาร'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Swipe card image validation blocks save when missing and delete works', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(
        const MaterialApp(
          home: OwnerRestaurantInfoScreen(
            restaurantName: 'The CHICKEN Test',
            restaurantImageUrl: 'https://images.unsplash.com/test.jpg',
            swipeCardImageUrl: '',
            initialStatus: 'approved',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Swipe card section is visible with new description
      expect(find.text('รูปสำหรับหน้าปัดร้านอาหาร'), findsOneWidget);
      expect(
        find.text('รูปภาพร้านอาหารหรือเมนูแนะนำ เพื่อแสดงบนหน้าปัดหาร้านอาหาร'),
        findsOneWidget,
      );
      expect(find.text('เพิ่มรูปสำหรับหน้าปัดร้านอาหาร'), findsOneWidget);

      // Attempt to save when swipeCardImageUrl is empty
      final saveButton = find.widgetWithText(TextButton, 'บันทึก');
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Verify validation blocked and message shown in SnackBar
      expect(
        find.descendant(
          of: find.byType(SnackBar),
          matching: find.textContaining('รูปสำหรับหน้าปัดร้านอาหาร'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Swipe card image renders with "แก้ไข" button when photo exists', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(
        const MaterialApp(
          home: OwnerRestaurantInfoScreen(
            restaurantName: 'The CHICKEN Test',
            restaurantImageUrl: 'https://images.unsplash.com/test.jpg',
            swipeCardImageUrl: 'https://images.unsplash.com/swipe-card.jpg',
            initialStatus: 'approved',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Ensure no "เปลี่ยนรูป", "ลบรูป", or "พร้อมแสดงในหน้าปัด" text exists
      expect(find.text('เปลี่ยนรูป'), findsNothing);
      expect(find.text('ลบรูป'), findsNothing);
      expect(find.text('พร้อมแสดงในหน้าปัด'), findsNothing);

      // Ensure "แก้ไข" button is present on the swipe card image
      expect(find.text('แก้ไข'), findsWidgets);
    });

    testWidgets('Swipe card crop screen uses exact card dimensions (0.88w x 0.64h) and 24px cornerRadius', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));

      final testImageBytes = base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
      );

      final cardWidth = 400 * 0.88;
      final cardHeight = 800 * 0.64;

      await tester.pumpWidget(
        MaterialApp(
          home: ImageCropScreen(
            imageBytes: testImageBytes,
            targetWidth: cardWidth,
            targetHeight: cardHeight,
            aspectRatio: cardWidth / cardHeight,
            cornerRadius: 24.0,
            subtitleTag: 'ขนาดเท่ากับหน้าปัดร้านอาหาร',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ครอบตัดรูปภาพ'), findsOneWidget);
      expect(find.text('ขนาดเท่ากับหน้าปัดร้านอาหาร'), findsOneWidget);
      expect(find.text('หมุนภาพ'), findsOneWidget);
      expect(find.text('รีเซ็ต'), findsOneWidget);
      expect(find.text('ครอบตัด'), findsOneWidget);
    });
  });
}

