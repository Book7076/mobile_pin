import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_mobile/screens/admin/admin_dashboard.dart';
import 'package:pin_mobile/screens/admin/approval_action_success_screen.dart';
import 'package:pin_mobile/screens/admin/restaurant_approval_detail_screen.dart';

void main() {
  Widget createTestWidget() {
    return const ProviderScope(
      child: MaterialApp(
        home: AdminDashboard(initialTabIndex: 1),
      ),
    );
  }

  testWidgets('Pending Tab displays Kohatsu Matcha, ข้าวบ้านก๋ง, and Potto Hot Pot', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Verify Title & Tabs
    expect(find.text('จัดการร้านอาหาร'), findsOneWidget);
    expect(find.text('รออนุมัติ'), findsOneWidget);
    expect(find.text('อนุมัติ'), findsOneWidget);
    expect(find.text('ไม่อนุมัติ'), findsOneWidget);

    // Verify 3 pending restaurants
    expect(find.text('Kohatsu Matcha'), findsOneWidget);
    expect(find.text('ข้าวบ้านก๋ง'), findsOneWidget);
    expect(find.text('Potto Hot Pot'), findsOneWidget);

    // Verify "วันที่สมัคร"
    expect(find.text('วันที่สมัคร'), findsNWidgets(3));
    expect(find.text('2 ส.ค. 2569'), findsOneWidget);
    expect(find.text('1 ส.ค. 2569'), findsNWidgets(2));
  });

  testWidgets('Complete Approval Flow: pending -> detail -> confirm -> success -> approved tab', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // 1. Tap on Kohatsu Matcha
    await tester.tap(find.text('Kohatsu Matcha'));
    await tester.pumpAndSettle();

    // 2. Verify RestaurantApprovalDetailScreen contents
    expect(find.byType(RestaurantApprovalDetailScreen), findsOneWidget);
    expect(find.text('รหัสร้าน : 111U1103'), findsOneWidget);
    expect(find.text('ที่อยู่ ช่องทางติดต่อ'), findsOneWidget);
    expect(find.text('เวลาเปิด-ปิด'), findsOneWidget);
    expect(find.text('สิ่งอำนวยความสะดวก'), findsOneWidget);
    expect(find.text('เมนูอาหาร'), findsOneWidget);
    expect(find.text('Earl Grey Matcha Foam'), findsOneWidget);
    expect(find.text('฿99'), findsOneWidget);

    // Verify Action Buttons
    expect(find.widgetWithText(ElevatedButton, 'อนุมัติ'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'ไม่อนุมัติ'), findsOneWidget);

    // 3. Tap "อนุมัติ"
    await tester.tap(find.widgetWithText(ElevatedButton, 'อนุมัติ'));
    await tester.pumpAndSettle();

    // Verify Approval Confirmation Dialog
    expect(find.text('ยืนยันการอนุมัติ'), findsOneWidget);
    expect(find.text('คุณต้องการอนุมัติร้านนี้หรือไม่'), findsOneWidget);

    // 4. Tap "ยืนยัน" in Dialog
    await tester.tap(find.widgetWithText(ElevatedButton, 'ยืนยัน'));
    await tester.pumpAndSettle();

    // 5. Verify Success Screen
    expect(find.byType(ApprovalActionSuccessScreen), findsOneWidget);
    expect(find.text('อนุมัติสำเร็จ'), findsOneWidget);
    expect(find.text('คำขอของคุณเรียบร้อยแล้ว'), findsOneWidget);

    // 6. Tap "กลับหน้าจัดการร้านอาหาร"
    await tester.tap(find.widgetWithText(ElevatedButton, 'กลับหน้าจัดการร้านอาหาร'));
    await tester.pumpAndSettle();

    // 7. Verify Kohatsu Matcha is NO LONGER in "รออนุมัติ"
    expect(find.byType(AdminDashboard), findsOneWidget);
    expect(find.text('Kohatsu Matcha'), findsNothing);
    expect(find.text('ข้าวบ้านก๋ง'), findsOneWidget);
    expect(find.text('Potto Hot Pot'), findsOneWidget);

    // Switch to "อนุมัติ" tab
    await tester.tap(find.text('อนุมัติ'));
    await tester.pumpAndSettle();

    // Verify Kohatsu Matcha is now in "อนุมัติ"
    expect(find.text('Kohatsu Matcha'), findsOneWidget);
  });

  testWidgets('Complete Rejection Flow: pending -> detail -> confirm -> reason dialog -> success -> rejected tab', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // 1. Tap on ข้าวบ้านก๋ง
    await tester.tap(find.text('ข้าวบ้านก๋ง'));
    await tester.pumpAndSettle();

    expect(find.byType(RestaurantApprovalDetailScreen), findsOneWidget);

    // 2. Tap "ไม่อนุมัติ"
    await tester.tap(find.widgetWithText(ElevatedButton, 'ไม่อนุมัติ'));
    await tester.pumpAndSettle();

    // Verify Rejection Confirmation Dialog
    expect(find.text('ยืนยันการไม่อนุมัติ'), findsOneWidget);
    expect(find.text('คุณต้องการไม่อนุมัติร้านนี้หรือไม่'), findsOneWidget);

    // 3. Tap "ยืนยัน" in Confirmation Dialog
    await tester.tap(find.widgetWithText(ElevatedButton, 'ยืนยัน'));
    await tester.pumpAndSettle();

    // Verify Rejection Reason Dialog
    expect(find.text('ไม่อนุมัติร้าน'), findsOneWidget);
    expect(find.text('เลือกเหตุผล'), findsOneWidget);
    expect(find.text('รายละเอียดเพิ่มเติม (ถ้ามี)'), findsOneWidget);

    // 4. Select Reason from Dropdown
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();

    expect(find.text('ร้านค้าไม่มีอยู่จริง'), findsWidgets);
    await tester.tap(find.text('ร้านค้าไม่มีอยู่จริง').last);
    await tester.pumpAndSettle();

    // Enter optional details
    await tester.enterText(find.byType(TextField).last, 'ตรวจสอบแล้วไม่พบหน้าร้านจริง');
    await tester.pumpAndSettle();

    // 5. Tap "ยืนยัน"
    await tester.tap(find.widgetWithText(ElevatedButton, 'ยืนยัน'));
    await tester.pumpAndSettle();

    // Verify Rejection Success Screen
    expect(find.byType(ApprovalActionSuccessScreen), findsOneWidget);
    expect(find.text('ไม่อนุมัติสำเร็จ'), findsOneWidget);
    expect(find.text('คำขอของคุณเรียบร้อยแล้ว'), findsOneWidget);

    // 6. Tap "กลับหน้าจัดการร้านอาหาร"
    await tester.tap(find.widgetWithText(ElevatedButton, 'กลับหน้าจัดการร้านอาหาร'));
    await tester.pumpAndSettle();

    // 7. Verify ข้าวบ้านก๋ง is removed from "รออนุมัติ"
    expect(find.byType(AdminDashboard), findsOneWidget);
    expect(find.text('ข้าวบ้านก๋ง'), findsNothing);

    // Switch to "ไม่อนุมัติ" tab
    await tester.tap(find.text('ไม่อนุมัติ'));
    await tester.pumpAndSettle();

    // Verify ข้าวบ้านก๋ง is in "ไม่อนุมัติ" with reason
    expect(find.text('ข้าวบ้านก๋ง'), findsOneWidget);
    expect(find.text('เหตุผล: ร้านค้าไม่มีอยู่จริง'), findsOneWidget);
  });
}
