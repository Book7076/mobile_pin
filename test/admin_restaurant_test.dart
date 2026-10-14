import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_mobile/models/restaurant_admin_model.dart';
import 'package:pin_mobile/services/admin_restaurant_service.dart';
import 'package:pin_mobile/screens/admin/admin_dashboard.dart';
import 'package:pin_mobile/screens/admin/restaurant_detail_screen.dart';

void main() {
  group('Admin Flowchart & Model Unit Tests', () {
    test('Thai date formatting test', () {
      final restaurant = RestaurantAdminModel(
        id: 'res-test',
        ownerId: 'owner-1',
        name: 'Kohatsu Matcha',
        address: 'Sukhumvit',
        phone: '0812345678',
        status: 'pending',
        createdAt: DateTime(2026, 8, 2),
      );

      // วันที่ 2 ส.ค. 2569 (2026 + 543 = 2569)
      expect(restaurant.formattedThaiDate, '2 ส.ค. 2569');
      expect(restaurant.statusThaiLabel, 'รออนุมัติ');
    });

    test('Flowchart status transition: Pending -> Approve', () async {
      final notifier = AdminRestaurantNotifier();
      final target = notifier.state.firstWhere((r) => r.status == 'pending');

      expect(target.status, 'pending');

      final success = await notifier.approveRestaurant(target.id);
      expect(success, true);

      final updated = notifier.state.firstWhere((r) => r.id == target.id);
      expect(updated.status, 'approved');
      expect(updated.rejectionReason, isNull);
    });

    test('Flowchart status transition: Pending -> Reject with Reason', () async {
      final notifier = AdminRestaurantNotifier();
      final target = notifier.state.firstWhere((r) => r.status == 'pending');

      const reason = 'เอกสารใบอนุญาตประกอบกิจการไม่สมบูรณ์';
      final success = await notifier.rejectRestaurant(target.id, reason);
      expect(success, true);

      final updated = notifier.state.firstWhere((r) => r.id == target.id);
      expect(updated.status, 'rejected');
      expect(updated.rejectionReason, reason);
    });

    test('Flowchart status transition: Approved -> Cancel Approval with Reason', () async {
      final notifier = AdminRestaurantNotifier();
      final target = notifier.state.firstWhere((r) => r.status == 'approved');

      const cancelReason = 'ตรวจพบการร้องเรียนเรื่องสุขอนามัย';
      final success = await notifier.cancelApproval(target.id, cancelReason);
      expect(success, true);

      final updated = notifier.state.firstWhere((r) => r.id == target.id);
      expect(updated.status, 'rejected');
      expect(updated.rejectionReason, cancelReason);
    });
  });

  group('Restaurant Management UI (Image 2) Widget Tests', () {
    testWidgets('Renders Header, Tabs, SearchBar, and Cards correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AdminDashboard(initialTabIndex: 1),
          ),
        ),
      );

      // ตรวจสอบ Header
      expect(find.text('จัดการร้านอาหาร'), findsOneWidget);

      // ตรวจสอบ TabBar 3 สถานะตามรูปที่ 2
      expect(find.text('รออนุมัติ'), findsOneWidget);
      expect(find.text('อนุมัติ'), findsOneWidget);
      expect(find.text('ไม่อนุมัติ'), findsOneWidget);

      // ตรวจสอบ Search Bar Placeholder
      expect(find.text('ค้นหาร้านค้า'), findsOneWidget);

      // ตรวจสอบชื่อร้านเด่น 3 ร้านในรูปที่ 2
      expect(find.text('Kohatsu Matcha'), findsWidgets);
      expect(find.text('ข้าวบ้านก๋ง'), findsWidgets);
      expect(find.text('Potto Hot Pot'), findsWidgets);

      // ตรวจสอบป้ายกำกับ "วันที่สมัคร"
      expect(find.text('วันที่สมัคร'), findsWidgets);

      // ตรวจสอบวันที่ พ.ศ. ไทย
      expect(find.text('2 ส.ค. 2569'), findsOneWidget);
      expect(find.text('1 ส.ค. 2569'), findsNWidgets(2)); // ข้าวบ้านก๋ง และ Potto Hot Pot

      // ตรวจสอบปุ่ม "รายละเอียด"
      expect(find.text('รายละเอียด'), findsWidgets);
    });

    testWidgets('Search bar filters restaurant list dynamically', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AdminDashboard(initialTabIndex: 1),
          ),
        ),
      );

      // ก่อนค้นหาพบทั้ง 3 ร้าน
      expect(find.text('Kohatsu Matcha'), findsWidgets);
      expect(find.text('ข้าวบ้านก๋ง'), findsWidgets);

      // กรอกคำค้นหา "Kohatsu"
      await tester.enterText(find.byType(TextField), 'Kohatsu');
      await tester.pumpAndSettle();

      // ควรเหลือเฉพาะ Kohatsu Matcha และไม่พบ ข้าวบ้านก๋ง
      expect(find.text('Kohatsu Matcha'), findsWidgets);
      expect(find.text('ข้าวบ้านก๋ง'), findsNothing);
    });

    testWidgets('Tab switching changes status list to Approved and Rejected', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AdminDashboard(initialTabIndex: 1),
          ),
        ),
      );

      // กดแท็บ "อนุมัติ"
      await tester.tap(find.text('อนุมัติ'));
      await tester.pumpAndSettle();

      // ต้องพบร้านที่อนุมัติแล้ว
      expect(find.text('Haru Sushi Bar'), findsWidgets);
      expect(find.text('ส้มตำเจ๊นก ครกยักษ์'), findsWidgets);

      // กดแท็บ "ไม่อนุมัติ"
      await tester.tap(find.text('ไม่อนุมัติ'));
      await tester.pumpAndSettle();

      // ต้องพบร้านที่ถูกปฏิเสธ
      expect(find.text('กาแฟโบราณลุงสม'), findsWidgets);
    });

    testWidgets('Restaurant Detail Screen (Image 1) renders all sections correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RestaurantDetailScreen(restaurantId: 'res-01'),
          ),
        ),
      );

      // Header & Back Button
      expect(find.text('รายละเอียดร้านอาหาร'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);

      // ข้อมูลร้านค้า (Header)
      expect(find.text('Kohatsu Matcha'), findsWidgets);
      expect(find.text('ประเภทร้านอาหาร : เครื่องดื่ม/คาเฟ่'), findsOneWidget);
      expect(find.text('รหัสร้าน : 111U1103'), findsOneWidget);

      // ส่วนที่อยู่ ช่องทางติดต่อ
      expect(find.text('ที่อยู่ ช่องทางติดต่อ'), findsOneWidget);
      expect(find.text('เทศบาลเชียงใหม่ อำเภอเมือง จังหวัดเชียงใหม่ ประเทศไทย'), findsOneWidget);
      expect(find.text('www.googlemap.com'), findsOneWidget);
      expect(find.text('083-666-7777'), findsOneWidget);

      // ส่วนเวลาเปิด-ปิด
      expect(find.text('เวลาเปิด-ปิด'), findsOneWidget);
      expect(find.text('อาทิตย์'), findsOneWidget);
      expect(find.text('จันทร์'), findsOneWidget);

      // ส่วนสิ่งอำนวยความสะดวก
      expect(find.text('สิ่งอำนวยความสะดวก'), findsOneWidget);
      expect(find.text('รถจักรยานยนต์'), findsOneWidget);
      expect(find.text('มีอินเทอร์เน็ต'), findsOneWidget);

      // ส่วนเมนูอาหาร
      expect(find.text('เมนูอาหาร'), findsOneWidget);
      expect(find.text('Earl Grey Matcha Foam'), findsOneWidget);
      expect(find.text('฿99'), findsOneWidget);
      expect(find.text('Matcha Ocean'), findsOneWidget);
      expect(find.text('฿89'), findsOneWidget);
      expect(find.text('Matcha Foam Latte'), findsOneWidget);
      expect(find.text('฿75'), findsOneWidget);

      // ปุ่มการทำงานด้านล่าง
      expect(find.text('อนุมัติ'), findsOneWidget);
      expect(find.text('ไม่อนุมัติ'), findsOneWidget);
    });

    testWidgets('Reject Confirmation and Reason Dialogs flow accurately', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RestaurantDetailScreen(restaurantId: 'res-01'),
          ),
        ),
      );

      // 1. กดปุ่ม "ไม่อนุมัติ" ที่แถบด้านล่าง
      await tester.tap(find.text('ไม่อนุมัติ'));
      await tester.pumpAndSettle();

      // ตรวจสอบหัวข้อ Dialog 1: "ยืนยันการไม่อนุมัติ"
      expect(find.text('ยืนยันการไม่อนุมัติ'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      expect(find.text('คุณต้องการไม่อนุมัติตร้านนี้หรือไม่'), findsOneWidget);

      // 2. กดปุ่ม "ยืนยัน" ใน Dialog 1 -> นำไปสู่ Dialog 2: "ไม่อนุมัติร้าน"
      await tester.tap(find.text('ยืนยัน'));
      await tester.pumpAndSettle();

      // ตรวจสอบองค์ประกอบของ Dialog 2: "ไม่อนุมัติร้าน" (ตรงตามภาพใหม่)
      expect(find.text('ไม่อนุมัติร้าน'), findsOneWidget);
      expect(find.text('เลือกเหตุผล'), findsOneWidget);
      expect(find.text('รายละเอียดเพิ่มเติม (ถ้ามี)'), findsOneWidget);

      // 3. ทดสอบการเปิด Dropdown เลือกเหตุผล
      await tester.tap(find.text('เลือกเหตุผล'), warnIfMissed: false);
      await tester.pumpAndSettle();

      // ตรวจสอบตัวเลือกใน Dropdown
      expect(find.text('ร้านค้าไม่มีอยู่จริง'), findsWidgets);
      expect(find.text('ไม่พบที่ตั้ง'), findsOneWidget);
      expect(find.text('อื่นๆ'), findsOneWidget);

      // เลือก "ร้านค้าไม่มีอยู่จริง"
      await tester.tap(find.text('ร้านค้าไม่มีอยู่จริง').last);
      await tester.pumpAndSettle();

      // 4. กรอกรายละเอียดเพิ่มเติม
      await tester.enterText(find.byType(TextField), 'ตรวจสอบแล้วไม่พบบริเวณดังกล่าว');
      await tester.pumpAndSettle();

      // 5. กดยืนยันใน Dialog 2
      await tester.tap(find.text('ยืนยัน'));
      await tester.pumpAndSettle();

      // ตรวจสอบว่าปิด Dialog และแสดงหน้า "ไม่อนุมัติสำเร็จ" (ตรงตามภาพใหม่ที่ 1)
      expect(find.text('ไม่อนุมัติสำเร็จ'), findsOneWidget);
      expect(find.text('คำขอของคุณเรียบร้อยแล้ว'), findsOneWidget);
      expect(find.text('กลับหน้าจัดการร้านอาหาร'), findsOneWidget);

      // 6. กดปุ่ม "กลับหน้าจัดการร้านอาหาร"
      await tester.tap(find.text('กลับหน้าจัดการร้านอาหาร'));
      await tester.pumpAndSettle();

      // ตรวจสอบหน้าจอจัดการร้านอาหาร (ตรงตามภาพใหม่ที่ 2)
      expect(find.text('จัดการร้านอาหาร'), findsOneWidget);
      expect(find.text('รออนุมัติ'), findsOneWidget);

      // ร้าน "Kohatsu Matcha" ที่ไม่อนุมัติแล้ว ต้องหายไปจากแท็บรออนุมัติ!
      expect(find.text('Kohatsu Matcha'), findsNothing);

      // คงเหลือเฉพาะร้านที่ยังรอการตรวจสอบ: ข้าวบ้านก๋ง และ Potto Hot Pot
      expect(find.text('ข้าวบ้านก๋ง'), findsWidgets);
      expect(find.text('Potto Hot Pot'), findsWidgets);
    });

    testWidgets('User Problem Reports Screen renders reports, filters, and detail modal with status update', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AdminDashboard(initialTabIndex: 2), // แท็บที่ 3: รายงานปัญหาจากผู้ใช้งาน
          ),
        ),
      );

      // Header & Icon
      expect(find.text('รายงานปัญหาจากผู้ใช้งาน'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);

      // ทดสอบแตะที่กระดิ่งแจ้งเตือน เปิด Notification Sheet
      await tester.tap(find.byKey(const Key('admin_bell_button')));
      await tester.pumpAndSettle();
      expect(find.text('การแจ้งเตือนรายงานปัญหา'), findsOneWidget);
      expect(find.text('กรองเฉพาะรายการรอดำเนินการ'), findsOneWidget);
      // ปิด Notification Sheet
      await tester.tap(find.byKey(const Key('close_notifications_sheet_button')));
      await tester.pumpAndSettle();
      expect(find.text('การแจ้งเตือนรายงานปัญหา'), findsNothing);

      // ตรวจสอบว่าไม่มีแท็กความสำคัญ 'เร่งด่วน' หรือ 'สูง' บนการ์ด
      expect(find.text('เร่งด่วน'), findsNothing);
      expect(find.text('สูง'), findsNothing);

      // ตรวจสอบว่าไม่มีรหัสรายงานแสดงบนหน้าจอ
      expect(find.textContaining('REP-2026-'), findsNothing);

      // ตรวจสอบ Filter Chips
      expect(find.text('ทั้งหมด'), findsOneWidget);
      expect(find.text('รอดำเนินการ'), findsWidgets);
      expect(find.text('กำลังตรวจสอบ'), findsWidgets);
      expect(find.text('แก้ไขแล้ว'), findsWidgets);

      // ตรวจสอบชื่อผู้แจ้งปัญหา
      expect(find.text('Kodomo'), findsOneWidget);
      expect(find.text('Harry Potter'), findsOneWidget);
      expect(find.text('Deku Kung'), findsOneWidget);
      expect(find.text('Levi S. Kennedy'), findsOneWidget);

      // ตรวจสอบหมวดหมู่ปัญหา
      expect(find.text('ข้อมูลร้านค้าไม่ถูกต้อง'), findsWidgets);
      expect(find.text('ร้านค้าปิดหรือไม่พบร้าน'), findsWidgets);
      expect(find.text('ปัญหาการใช้งานแอปพลิเคชัน'), findsWidgets);

      // ทดสอบกดที่การ์ด Kodomo เพื่อดูรายละเอียดและอัปเดตสถานะ
      await tester.tap(find.text('Kodomo'));
      await tester.pumpAndSettle();

      // ตรวจสอบ BottomSheet ที่เปิดขึ้นมา
      expect(find.text('รายละเอียดรายงานปัญหา'), findsOneWidget);
      expect(find.text('ข้อมูลผู้แจ้ง'), findsOneWidget);
      expect(find.text('รายละเอียดปัญหาที่พบ'), findsOneWidget);
      expect(find.text('อัปเดตสถานะการดำเนินการ'), findsOneWidget);
      expect(find.text('บันทึกการเปลี่ยนแปลง'), findsOneWidget);

      // ตรวจสอบว่าในหน้ารายละเอียดไม่มีคำว่าความเร่งด่วน
      expect(find.textContaining('ความเร่งด่วน'), findsNothing);

      // ทดสอบเปลี่ยนสถานะเป็น "แก้ไขแล้ว" และกดบันทึก
      await tester.tap(find.text('แก้ไขแล้ว').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('บันทึกการเปลี่ยนแปลง'));
      await tester.pumpAndSettle();

      // BottomSheet ปิดลง และสถานะของการ์ด Kodomo อัปเดตเรียบร้อย
      expect(find.text('รายละเอียดรายงานปัญหา'), findsNothing);
    });

    testWidgets('Settings Screen (Image 2) renders admin profile and logout button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AdminDashboard(initialTabIndex: 3), // แท็บที่ 4: ตั้งค่า
          ),
        ),
      );

      // Header & Icon
      expect(find.text('การตั้งค่า'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);

      // ตรวจสอบโปรไฟล์ Admin
      expect(find.text('A'), findsOneWidget);
      expect(find.text('Admin'), findsOneWidget);
      expect(find.text('mealmate001@gmail.com'), findsOneWidget);

      // ตรวจสอบปุ่มออกจากระบบ
      expect(find.text('ออกจากระบบ'), findsOneWidget);
      expect(find.byIcon(Icons.logout_rounded), findsOneWidget);

      // ทดสอบกดปุ่มออกจากระบบ -> เปิด Confirm Dialog
      await tester.tap(find.text('ออกจากระบบ'));
      await tester.pumpAndSettle();

      expect(find.text('ยืนยันการออกจากระบบ'), findsOneWidget);
      expect(find.text('คุณต้องการออกจากระบบผู้ดูแลระบบ Meaimate ใช่หรือไม่?'), findsOneWidget);
    });
  });

  group('6-Screen Cancel Rejection Flow Tests (Images 1, 2, 3)', () {
    test('Unit Test: cancelRejection moves restaurant from rejected to approved', () async {
      final notifier = AdminRestaurantNotifier();
      // ค้นหาร้านเตาอุ่นที่มีสถานะ rejected
      final target = notifier.state.firstWhere((r) => r.id == 'res-rejected-01');
      expect(target.name, 'เตาอุ่น');
      expect(target.status, 'rejected');
      expect(target.rejectionReason, 'ที่อยู่ไม่ถูกต้อง');

      final success = await notifier.cancelRejection(target.id);
      expect(success, true);

      final updated = notifier.state.firstWhere((r) => r.id == target.id);
      expect(updated.status, 'approved');
      expect(updated.rejectionReason, isNull);
      expect(updated.reviewerName, isNull);
    });

    testWidgets('Full 6-Screen Flow: Rejected List -> Detail -> Check -> Dialog -> Success -> Back',
        (WidgetTester tester) async {
      // หน้าที่ 1: เปิดหน้าจัดการร้านอาหาร แท็บ "ไม่อนุมัติ" (initialSubTabIndex: 2)
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AdminDashboard(initialTabIndex: 1, initialSubTabIndex: 2),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // ตรวจสอบหน้าที่ 1 (ภาพที่ 1 ซ้าย):
      expect(find.text('จัดการร้านอาหาร'), findsOneWidget);
      expect(find.text('ไม่อนุมัติ'), findsOneWidget);

      // พบร้านอาหารทั้ง 3 ร้านในแท็บไม่อนุมัติ
      expect(find.text('เตาอุ่น'), findsWidgets);
      expect(find.text('KAME KAFE'), findsWidgets);
      expect(find.text('สุกี้ช้างเผือก'), findsWidgets);
      expect(find.text('09.00 น.'), findsWidgets);

      // หน้าที่ 2 (ภาพที่ 1 ขวา): กดเข้าไปในร้าน "เตาอุ่น"
      await tester.tap(find.text('เตาอุ่น').last, warnIfMissed: false);
      await tester.pumpAndSettle();

      // ตรวจสอบหน้าที่ 2: รายละเอียดร้านอาหาร
      expect(find.text('รายละเอียดร้านอาหาร'), findsOneWidget);
      expect(find.text('ประเภทร้านอาหาร : ขนมหวาน/เบเกอรี่'), findsOneWidget);
      expect(find.text('รหัสร้าน : 111U1101'), findsOneWidget);
      expect(find.text('091234567'), findsOneWidget);
      expect(find.text('ที่จอดรถยนต์'), findsOneWidget);
      expect(find.text('เครื่องปรับอากาศ'), findsOneWidget);
      expect(find.text('ชีสเค้ก'), findsOneWidget);
      expect(find.text('ชิโอะปัง'), findsOneWidget);
      expect(find.text('ทาร์ตไข่'), findsOneWidget);
      expect(find.text('สาเหตุที่ไม่อนุมัติ'), findsOneWidget);
      expect(find.text('ที่อยู่ไม่ถูกต้อง'), findsOneWidget);
      expect(find.text('ผู้รับผิดชอบ: ปนัสยา'), findsOneWidget);

      // ตรวจสอบปุ่ม "ยกเลิกการไม่อนุมัติ" (ปุ่มลอยสีแดงเบอร์กันดี)
      expect(find.text('ยกเลิกการไม่อนุมัติ'), findsOneWidget);

      // หน้าที่ 3 (ภาพที่ 2 ซ้าย): กดปุ่ม "ยกเลิกการไม่อนุมัติ"
      await tester.tap(find.text('ยกเลิกการไม่อนุมัติ'));
      await tester.pumpAndSettle();

      // ตรวจสอบหน้าที่ 3: ตรวจสอบข้อมูลก่อนยกเลิก
      expect(find.text('ยืนยันการยกเลิกไม่อนุมัติ'), findsOneWidget);
      expect(find.text('คุณกำลังจะยกเลิกการไม่อนุมัติร้านนี้\nกรุณาตรวจสอบข้อมูลให้ถูกต้องก่อนดำเนินการ'), findsOneWidget);
      expect(find.text('ข้อมูลร้าน'), findsOneWidget);
      expect(find.text('เตาอุ่น'), findsWidgets);
      expect(find.text('111U1101'), findsOneWidget);
      expect(find.text('3 ส.ค. 2569'), findsOneWidget);

      // ตรวจสอบปุ่ม "ยืนยันยกเลิกการไม่อนุมัติ"
      expect(find.text('ยืนยันยกเลิกการไม่อนุมัติ'), findsOneWidget);

      // หน้าที่ 4 (ภาพที่ 2 ขวา): กดปุ่ม "ยืนยันยกเลิกการไม่อนุมัติ" เพื่อเปิด Dialog Popup
      await tester.tap(find.text('ยืนยันยกเลิกการไม่อนุมัติ'));
      await tester.pumpAndSettle();

      // ตรวจสอบ Dialog:
      expect(find.text('คุณต้องการยกเลิกไม่อนุมัติร้านนี้หรือไม่'), findsOneWidget);
      expect(find.text('ยกเลิก'), findsOneWidget);
      expect(find.text('ยืนยัน'), findsOneWidget);

      // หน้าที่ 5 (ภาพที่ 3 ซ้าย): กดปุ่ม "ยืนยัน" ใน Dialog
      await tester.tap(find.text('ยืนยัน'));
      await tester.pumpAndSettle();

      // ตรวจสอบหน้าที่ 5: หน้าสำเร็จ
      expect(find.text('ยกเลิกการไม่อนุมัติสำเร็จ'), findsOneWidget);
      expect(find.text('คำขอของคุณได้ถูกยกเลิกการไม่อนุมัติเรียบร้อยแล้ว'), findsOneWidget);
      expect(find.text('กลับหน้าจัดการร้านอาหาร'), findsOneWidget);

      // หน้าที่ 6 (ภาพที่ 3 ขวา): กดปุ่ม "กลับหน้าจัดการร้านอาหาร"
      await tester.tap(find.text('กลับหน้าจัดการร้านอาหาร'));
      await tester.pumpAndSettle();

      // ตรวจสอบหน้าที่ 6: กลับสู่หน้าจัดการร้านอาหาร แท็บไม่อนุมัติ
      expect(find.text('จัดการร้านอาหาร'), findsOneWidget);
      expect(find.text('ไม่อนุมัติ'), findsOneWidget);

      // ร้าน "เตาอุ่น" ต้องหายไปจากแท็บไม่อนุมัติแล้ว!
      expect(find.text('เตาอุ่น'), findsNothing);

      // ยังคงมีร้าน KAME KAFE และ สุกี้ช้างเผือก อยู่ในแท็บไม่อนุมัติ
      expect(find.text('KAME KAFE'), findsWidgets);
      expect(find.text('สุกี้ช้างเผือก'), findsWidgets);

      // สลับไปที่แท็บ "อนุมัติ" และต้องแสดงร้าน "เตาอุ่น" ด้วยเหมือนร้านอื่นๆ
      await tester.tap(find.text('อนุมัติ'));
      await tester.pumpAndSettle();
      expect(find.text('เตาอุ่น'), findsOneWidget);
    });

  });
}
