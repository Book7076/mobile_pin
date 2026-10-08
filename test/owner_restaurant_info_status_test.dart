import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pin_mobile/screens/owner/owner_restaurant_info_screen.dart';

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
  });
}
