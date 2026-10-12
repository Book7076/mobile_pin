import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pin_mobile/screens/owner/owner_menu_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OwnerMenuScreen Dynamic Categories Tests', () {
    testWidgets(
        'Only shows tabs for categories that currently have menu items in the restaurant (hides empty categories)',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(
        const MaterialApp(
          home: OwnerMenuScreen(
            restaurantName: 'Gindon กินดัง ข้าวหน้าของย่าง',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // ตรวจสอบ Title ของ AppBar: จัดการเมนูอาหาร (ไม่มีชื่อร้านต่อท้าย) และอยู่กึ่งกลาง
      expect(find.text('จัดการเมนูอาหาร'), findsOneWidget);
      expect(find.textContaining('Gindon'), findsNothing);
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.centerTitle, isTrue);

      // มีเฉพาะเมนูข้าว -> แสดงเฉพาะ 'ทั้งหมด' และ 'ข้าว'
      expect(find.text('ทั้งหมด'), findsOneWidget);
      expect(find.text('ข้าว'), findsOneWidget);

      // หมวดหมู่อื่นที่ยังไม่มีเมนูในร้าน ต้องไม่แสดงเป็นแท็บ
      expect(find.text('ของทอด'), findsNothing);
      expect(find.text('เมนูเส้น'), findsNothing);
      expect(find.text('เครื่องดื่ม'), findsNothing);
      expect(find.text('ของหวาน'), findsNothing);

      // ตรวจสอบรายการเมนูข้าวที่มีอยู่จริง
      expect(find.text('ข้าวหน้ากุ้งย่างซีอิ๊ว'), findsOneWidget);
      expect(find.text('ข้าวหน้าหมูสามชั้นย่าง'), findsOneWidget);
      expect(find.text('ข้าวหน้าหมูสันคอย่าง'), findsOneWidget);
    });

    testWidgets(
        'Add menu dialog provides all categories from database, and adding new category reveals its tab dynamically',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(
        const MaterialApp(
          home: OwnerMenuScreen(
            restaurantName: 'Gindon กินดัง ข้าวหน้าของย่าง',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // ก่อนเพิ่ม: ยังไม่มีแท็บ 'ของทอด'
      expect(find.text('ของทอด'), findsNothing);

      // กดปุ่ม 'เพิ่มเมนู'
      await tester.tap(find.text('เพิ่มเมนู'));
      await tester.pumpAndSettle();

      expect(find.text('เพิ่มเมนูใหม่'), findsOneWidget);
      expect(find.text('ประเภทอาหาร'), findsOneWidget);

      // กรอกชื่อและราคา
      await tester.enterText(find.widgetWithText(TextField, 'ชื่อเมนูอาหาร *'), 'เกี๊ยวซ่าทอดกรอบ');
      await tester.enterText(find.widgetWithText(TextField, 'ราคา (บาท) *'), '45');

      // ตรวจสอบว่ามีตัวเลือกประเภทอาหารต่างๆ ให้เลือกครบตาม Database
      expect(find.text('ข้าว'), findsOneWidget);
      expect(find.text('ของทอด'), findsOneWidget);
      expect(find.text('เมนูเส้น'), findsOneWidget);
      expect(find.text('เครื่องดื่ม'), findsOneWidget);
      expect(find.text('ของหวาน'), findsOneWidget);

      // เลือกประเภท 'ของทอด' (ไม่มีการติ๊กเลือกค้างไว้เริ่มต้น)
      await tester.ensureVisible(find.text('ของทอด'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ของทอด'));
      await tester.pumpAndSettle();

      // กดปุ่ม 'บันทึก'
      await tester.tap(find.text('บันทึก'));
      await tester.pumpAndSettle();

      // หลังเพิ่มเมนู: แท็บ 'ของทอด' ปรากฏขึ้นมาโดยอัตโนมัติ!
      expect(find.text('ของทอด'), findsWidgets);
      expect(find.text('เกี๊ยวซ่าทอดกรอบ'), findsOneWidget);

      // กดสลับแท็บไปที่ 'ข้าว'
      await tester.tap(find.text('ข้าว').first);
      await tester.pumpAndSettle();

      expect(find.text('ข้าวหน้ากุ้งย่างซีอิ๊ว'), findsOneWidget);
      expect(find.text('เกี๊ยวซ่าทอดกรอบ'), findsNothing);

      // กดสลับแท็บไปที่ 'ของทอด'
      await tester.tap(find.text('ของทอด').first);
      await tester.pumpAndSettle();

      expect(find.text('เกี๊ยวซ่าทอดกรอบ'), findsOneWidget);
      expect(find.text('ข้าวหน้ากุ้งย่างซีอิ๊ว'), findsNothing);
    });
  });
}
