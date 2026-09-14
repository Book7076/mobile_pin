import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pin_mobile/screens/admin/admin_dashboard.dart';
import 'package:pin_mobile/screens/admin/restaurant_approval_detail_screen.dart';
import 'package:pin_mobile/screens/admin/confirm_revoke_screen.dart';
import 'package:pin_mobile/screens/admin/revoke_reason_screen.dart';
import 'package:pin_mobile/screens/admin/revoke_success_screen.dart';

void main() {
  testWidgets('Full Admin Restaurant Revocation Flow Test', (WidgetTester tester) async {
    // Set a phone-like screen size
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    // 1. Launch AdminDashboard on Store Management tab (initialTabIndex: 1)
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: AdminDashboard(initialTabIndex: 1),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Tab 1 "จัดการร้านอาหาร" and "อนุมัติ" tab
    expect(find.text('จัดการร้านอาหาร'), findsOneWidget);
    expect(find.text('อนุมัติ'), findsOneWidget);
    expect(find.text('ดำเนินสะดวก'), findsOneWidget);
    expect(find.text('The Volcano'), findsOneWidget);
    expect(find.text('เจียวดาวหลังมอ(เจ้าแรก)'), findsOneWidget);

    // 2. Tap on "ดำเนินสะดวก" to open details
    await tester.tap(find.text('ดำเนินสะดวก'));
    await tester.pumpAndSettle();

    // Verify RestaurantApprovalDetailScreen
    expect(find.byType(RestaurantApprovalDetailScreen), findsOneWidget);
    expect(find.text('รายละเอียดร้านอาหาร'), findsOneWidget);
    expect(find.text('รหัสร้าน : 111U1102'), findsOneWidget);
    expect(find.text('ยกเลิกการอนุมัติ'), findsOneWidget);

    // 3. Tap "ยกเลิกการอนุมัติ"
    await tester.tap(find.text('ยกเลิกการอนุมัติ'));
    await tester.pumpAndSettle();

    // Verify ConfirmRevokeScreen
    expect(find.byType(ConfirmRevokeScreen), findsOneWidget);
    expect(find.text('ยืนยันการยกเลิกอนุมัติ'), findsOneWidget);
    expect(find.text('ยืนยันยกเลิกการอนุมัติ'), findsOneWidget);

    // 4. Tap "ยืนยันยกเลิกการอนุมัติ"
    await tester.tap(find.text('ยืนยันยกเลิกการอนุมัติ'));
    await tester.pumpAndSettle();

    // Verify RevokeReasonScreen
    expect(find.byType(RevokeReasonScreen), findsOneWidget);
    expect(find.text('กรุณาระบุเหตุผล'), findsOneWidget);

    // Enter revocation reason
    await tester.enterText(find.byType(TextField), 'ร้านไม่ผ่านเกณฑ์มาตรฐานความสะอาด');
    await tester.pumpAndSettle();

    // Tap "ส่งเหตุผล"
    await tester.tap(find.text('ส่งเหตุผล'));
    await tester.pumpAndSettle();

    // 5. Verify RevokeSuccessScreen
    expect(find.byType(RevokeSuccessScreen), findsOneWidget);
    expect(find.text('ยกเลิกการอนุมัติสำเร็จ'), findsOneWidget);
    expect(find.text('คำขอของคุณได้ถูกยกเลิกการอนุมัติเรียบร้อยแล้ว'), findsOneWidget);
    expect(find.text('กลับหน้าจัดการร้านอาหาร'), findsOneWidget);

    // 6. Tap "กลับหน้าจัดการร้านอาหาร"
    await tester.tap(find.text('กลับหน้าจัดการร้านอาหาร'));
    await tester.pumpAndSettle();

    // Verify returned to AdminDashboard
    expect(find.byType(AdminDashboard), findsOneWidget);

    // Verify that "ดำเนินสะดวก" is REMOVED from the "อนุมัติ" list!
    expect(find.text('ดำเนินสะดวก'), findsNothing);
    // Other approved restaurants still remain
    expect(find.text('The Volcano'), findsOneWidget);
    expect(find.text('เจียวดาวหลังมอ(เจ้าแรก)'), findsOneWidget);

    // 7. Switch to "ไม่อนุมัติ" tab
    await tester.tap(find.text('ไม่อนุมัติ'));
    await tester.pumpAndSettle();

    // Verify "ดำเนินสะดวก" is now in "ไม่อนุมัติ" with the recorded reason!
    expect(find.text('ดำเนินสะดวก'), findsOneWidget);
    expect(find.textContaining('เหตุผล: ร้านไม่ผ่านเกณฑ์มาตรฐานความสะอาด'), findsOneWidget);
  });
}
