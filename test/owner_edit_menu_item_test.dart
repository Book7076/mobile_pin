import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pin_mobile/screens/owner/owner_edit_menu_item_screen.dart';
import 'package:pin_mobile/screens/owner/owner_menu_screen.dart';
import 'package:pin_mobile/widgets/image_crop_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OwnerEditMenuItemScreen Widget Tests (Database Aligned)', () {
    testWidgets('Renders AppBar with burgundy color 8B1E3F, title and save button at top right',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(
        const MaterialApp(
          home: OwnerEditMenuItemScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // 1. AppBar
      expect(find.text('เพิ่มเมนูใหม่'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, const Color(0xFF8B1E3F));
      expect(appBar.centerTitle, isTrue);

      // 2. Save button at top right (inside AppBar actions)
      expect(find.text('บันทึก'), findsOneWidget);

      // 3. No bottom navigation / bottom cancel/save bar
      expect(find.text('ยกเลิก'), findsNothing);

      // 4. No warning banner
      expect(find.textContaining('คำเตือน'), findsNothing);
      expect(find.textContaining('LINE MAN'), findsNothing);

      // 5. No extra toggles or language expanders
      expect(find.textContaining('เพิ่มชื่อในภาษาอื่น'), findsNothing);
      expect(find.textContaining('แยกราคาออนไลน์'), findsNothing);
      expect(find.textContaining('เมนูแนะนำ ⭐'), findsNothing);
      expect(find.textContaining('ส่งเดลิเวอรีได้'), findsNothing);
      expect(find.textContaining('คำอธิบายเมนู'), findsNothing);
      expect(find.textContaining('เพิ่มตัวเลือก'), findsNothing);
    });

    testWidgets('Renders categories strictly ordered: ข้าว, ของทอด, เมนูเส้น, เครื่องดื่ม, ของหวาน',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(
        const MaterialApp(
          home: OwnerEditMenuItemScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ประเภทอาหาร'), findsOneWidget);
      expect(find.text('เลือกได้หลายประเภท'), findsOneWidget);

      // ตรวจสอบหมวดหมู่ตาม Database
      expect(find.text('ข้าว'), findsOneWidget);
      expect(find.text('ของทอด'), findsOneWidget);
      expect(find.text('เมนูเส้น'), findsOneWidget);
      expect(find.text('เครื่องดื่ม'), findsOneWidget);
      expect(find.text('ของหวาน'), findsOneWidget);

      // ต้องไม่มีหมวดหมู่ mock เช่น อาหารเจ โปรโมชัน
      expect(find.text('อาหารเจ'), findsNothing);
      expect(find.text('โปรโมชัน'), findsNothing);

      // ตรวจสอบลำดับพิกัด Y จากบนลงล่าง
      final yKhao = tester.getTopLeft(find.text('ข้าว')).dy;
      final yThod = tester.getTopLeft(find.text('ของทอด')).dy;
      final ySen = tester.getTopLeft(find.text('เมนูเส้น')).dy;
      final yDrink = tester.getTopLeft(find.text('เครื่องดื่ม')).dy;
      final ySweet = tester.getTopLeft(find.text('ของหวาน')).dy;

      expect(yKhao < yThod, isTrue);
      expect(yThod < ySen, isTrue);
      expect(ySen < yDrink, isTrue);
      expect(yDrink < ySweet, isTrue);

      // ไม่ควรมีการติ๊กเลือกค้างไว้ในส่วนของประเภทอาหาร
      for (final checkbox in tester.widgetList<Checkbox>(find.byType(Checkbox))) {
        expect(checkbox.value, isFalse);
      }
    });

    testWidgets('Tapping image opens camera/gallery options only (no preset food and no URL input)',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(
        const MaterialApp(
          home: OwnerEditMenuItemScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('เพิ่มรูปภาพอาหาร'), findsOneWidget);
      await tester.tap(find.text('เพิ่มรูปภาพอาหาร'));
      await tester.pumpAndSettle();

      expect(find.text('เลือกรูปภาพอาหาร'), findsOneWidget);
      expect(find.text('ถ่ายรูปภาพ'), findsOneWidget);
      expect(find.text('เลือกจากคลังรูปภาพ'), findsOneWidget);

      // ต้องไม่มีรูปอาหารแนะนำ และไม่มีตัวเลือกใส่ URL
      expect(find.textContaining('เลือกจากรูปอาหารตัวอย่าง'), findsNothing);
      expect(find.textContaining('ระบุลิงก์รูปภาพโดยตรง'), findsNothing);
    });

    testWidgets('Validation: Name, price, and category must ALL be filled before saving',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(
        const MaterialApp(
          home: OwnerEditMenuItemScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // 1. กดบันทึกโดยไม่กรอกอะไรเลย -> ต้องไม่บันทึกและขึ้นเตือน
      await tester.tap(find.text('บันทึก'));
      await tester.pumpAndSettle();
      expect(find.textContaining('กรุณาระบุข้อมูลให้ครบ: ชื่ออาหาร, ราคาอาหาร, เลือกประเภทอาหารอย่างน้อย 1 ประเภท'),
          findsOneWidget);

      // 2. กรอกชื่ออาหารอย่างเดียว
      await tester.pump(const Duration(seconds: 4));
      await tester.enterText(find.widgetWithText(TextField, 'ชื่อเมนู'), 'ข้าวหมูกรอบ');
      await tester.tap(find.text('บันทึก'));
      await tester.pumpAndSettle();
      expect(find.textContaining('กรุณาระบุข้อมูลให้ครบ: ราคาอาหาร, เลือกประเภทอาหารอย่างน้อย 1 ประเภท'),
          findsOneWidget);

      // 3. กรอกราคา แต่ยังไม่เลือกประเภท
      await tester.pump(const Duration(seconds: 4));
      await tester.enterText(find.widgetWithText(TextField, 'ราคา (บาท) *'), '65');
      await tester.tap(find.text('บันทึก'));
      await tester.pumpAndSettle();
      expect(find.textContaining('กรุณาระบุข้อมูลให้ครบ: เลือกประเภทอาหารอย่างน้อย 1 ประเภท'),
          findsOneWidget);

      // 4. เลือกประเภท 'ข้าว' และ 'ของทอด' (เลือกได้หลายประเภท)
      await tester.tap(find.text('ข้าว'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ของทอด'));
      await tester.pumpAndSettle();

      // ตอนนี้ครบทุกอย่างแล้ว เมื่อกดบันทึกจะสำเร็จ
      await tester.tap(find.text('บันทึก'));
      await tester.pumpAndSettle();
      expect(find.byType(OwnerEditMenuItemScreen), findsNothing); // Popped
    });

    testWidgets('Tapping back button does NOT save anything and leaves data untouched',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      Map<String, dynamic>? returnResult = {'unchanged': true};

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () async {
                returnResult = await Navigator.push<Map<String, dynamic>>(
                  ctx,
                  MaterialPageRoute(builder: (_) => const OwnerEditMenuItemScreen()),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // กรอกข้อมูลบางส่วน
      await tester.enterText(find.widgetWithText(TextField, 'ชื่อเมนู'), 'ต้มยำกุ้งน้ำข้น');
      await tester.enterText(find.widgetWithText(TextField, 'ราคา (บาท) *'), '120');

      // กดย้อนกลับ
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();

      // ผลลัพธ์ต้องเป็น null ไม่มีการส่งข้อมูลบันทึก
      expect(returnResult, isNull);
    });

    testWidgets('Supports adding a new category with + สร้างประเภท', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(
        const MaterialApp(
          home: OwnerEditMenuItemScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('สร้างประเภท'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('สร้างประเภท'));
      await tester.pumpAndSettle();

      expect(find.text('สร้างประเภทอาหารใหม่'), findsOneWidget);
      await tester.enterText(find.widgetWithText(TextField, 'ชื่อประเภทอาหาร'), 'สลัด/อาหารคลีน');
      await tester.tap(find.widgetWithText(ElevatedButton, 'สร้างประเภท'));
      await tester.pumpAndSettle();

      expect(find.text('สลัด/อาหารคลีน'), findsOneWidget);
    });

    testWidgets('Adding menu item without image is allowed, and saves successfully with empty image_url',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      Map<String, dynamic>? savedResult;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () async {
                savedResult = await Navigator.push<Map<String, dynamic>>(
                  ctx,
                  MaterialPageRoute(builder: (_) => const OwnerEditMenuItemScreen()),
                );
              },
              child: const Text('Add Dish'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Dish'));
      await tester.pumpAndSettle();

      // กรอกชื่อ ราคา และเลือกประเภท แต่ไม่ใส่รูปภาพ
      await tester.enterText(find.widgetWithText(TextField, 'ชื่อเมนู'), 'น้ำเปล่าเย็น');
      await tester.enterText(find.widgetWithText(TextField, 'ราคา (บาท) *'), '10');
      await tester.tap(find.text('เครื่องดื่ม'));
      await tester.pumpAndSettle();

      // บันทึก
      await tester.tap(find.text('บันทึก'));
      await tester.pumpAndSettle();

      expect(savedResult, isNotNull);
      expect(savedResult!['saved'], isTrue);
      final item = savedResult!['item'] as Map<String, dynamic>;
      expect(item['name'], 'น้ำเปล่าเย็น');
      expect(item['price'], 10.0);
      expect(item['image'], '');
      expect(item['image_url'], '');
    });

    testWidgets('OwnerMenuScreen renders gray camera icon and ไม่มีรูป for items without image',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(
        const MaterialApp(
          home: OwnerMenuScreen(restaurantId: null),
        ),
      );
      await tester.pumpAndSettle();

      // Open add menu
      await tester.tap(find.text('เพิ่มเมนู'));
      await tester.pumpAndSettle();

      // เพิ่มเมนูไม่มีรูปภาพ
      await tester.enterText(find.widgetWithText(TextField, 'ชื่อเมนู'), 'ชาดำเย็น');
      await tester.enterText(find.widgetWithText(TextField, 'ราคา (บาท) *'), '25');
      await tester.tap(find.text('เครื่องดื่ม'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('บันทึก'));
      await tester.pumpAndSettle();

      // ตรวจสอบว่าในหน้ารายการเมนู แสดงไอคอนกล้องและข้อความ 'ไม่มีรูป'
      expect(find.text('ชาดำเย็น'), findsOneWidget);
      expect(find.text('ไม่มีรูป'), findsWidgets);
      expect(find.byIcon(Icons.camera_alt_outlined), findsWidgets);
    });

    testWidgets('ImageCropScreen renders correctly, supports rotation, and confirm crop',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      final testImageBytes = base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
      );

      Uint8List? croppedResult;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () async {
                croppedResult = await Navigator.push<Uint8List>(
                  ctx,
                  MaterialPageRoute(
                    builder: (_) => ImageCropScreen(imageBytes: testImageBytes),
                  ),
                );
              },
              child: const Text('Open Crop'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Crop'));
      await tester.pumpAndSettle();

      expect(find.text('ครอบตัดรูปภาพ'), findsOneWidget);
      expect(find.text('หมุนภาพ'), findsOneWidget);
      expect(find.text('รีเซ็ต'), findsOneWidget);
      expect(find.text('ครอบตัด'), findsOneWidget);

      // หมุนภาพ
      await tester.tap(find.text('หมุนภาพ'));
      await tester.pumpAndSettle();

      // กดครอบตัด
      await tester.runAsync(() async {
        await tester.tap(find.text('ครอบตัด'));
        await tester.pump();
        await Future.delayed(const Duration(milliseconds: 300));
      });
      await tester.pump();
      await tester.pumpAndSettle();

      expect(croppedResult, isNotNull);
    });

    testWidgets('Tapping image with existing image shows delete image option, and deletes image when tapped',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(
        const MaterialApp(
          home: OwnerEditMenuItemScreen(
            itemToEdit: {
              'id': 'test-1',
              'name': 'ไก่ทอด',
              'price': 50,
              'image_url': 'https://example.com/chicken.jpg',
              'category': 'ของทอด',
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // ตรวจสอบว่ามีปุ่ม 'เปลี่ยนรูป'
      expect(find.text('เปลี่ยนรูป'), findsOneWidget);

      // แตะที่รูปภาพเพื่อเปิด bottom sheet
      await tester.tap(find.text('เปลี่ยนรูป'));
      await tester.pumpAndSettle();

      // ตรวจสอบว่ามีตัวเลือก 'ลบรูปภาพ' ใน modal
      expect(find.text('ลบรูปภาพ'), findsOneWidget);
      expect(find.text('นำรูปภาพอาหารนี้ออก'), findsOneWidget);

      // แตะ 'ลบรูปภาพ' ใน modal
      await tester.tap(find.text('ลบรูปภาพ'));
      await tester.pumpAndSettle();

      // ตรวจสอบว่ามีป็อปอัพ 'ยืนยันลบรูปภาพ'
      expect(find.text('ยืนยันลบรูปภาพ'), findsOneWidget);
      expect(find.text('คุณต้องการลบรูปภาพอาหารนี้ใช่หรือไม่?'), findsOneWidget);

      // ทดสอบกรณีกดยกเลิก -> รูปภาพยังต้องอยู่เหมือนเดิม
      await tester.tap(find.text('ยกเลิก'));
      await tester.pumpAndSettle();
      expect(find.text('เปลี่ยนรูป'), findsOneWidget);

      // แตะ 'เปลี่ยนรูป' เพื่อเปิด modal อีกครั้ง แล้วเลือก 'ลบรูปภาพ'
      await tester.tap(find.text('เปลี่ยนรูป'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ลบรูปภาพ'));
      await tester.pumpAndSettle();

      // คราวนี้กดยืนยัน 'ลบรูปภาพ' ในป็อปอัพ
      await tester.tap(find.widgetWithText(ElevatedButton, 'ลบรูปภาพ'));
      await tester.pumpAndSettle();

      // ตรวจสอบว่ารูปภาพถูกลบแล้ว และเปลี่ยนกลับเป็น 'เพิ่มรูปภาพอาหาร'
      expect(find.text('ลบรูปภาพเรียบร้อยแล้ว'), findsOneWidget);
      expect(find.text('เพิ่มรูปภาพอาหาร'), findsOneWidget);
    });
  });
}
