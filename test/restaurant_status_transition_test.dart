import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pin_mobile/screens/admin/admin_dashboard.dart';
import 'package:pin_mobile/screens/admin/approval_action_success_screen.dart';
import 'package:pin_mobile/screens/admin/cancel_rejection_screen.dart';
import 'package:pin_mobile/screens/admin/cancel_rejection_success_screen.dart';
import 'package:pin_mobile/screens/admin/confirm_revoke_screen.dart';
import 'package:pin_mobile/screens/admin/reject_success_screen.dart';
import 'package:pin_mobile/screens/admin/restaurant_approval_detail_screen.dart';
import 'package:pin_mobile/screens/admin/restaurant_detail_screen.dart' as admin_detail;
import 'package:pin_mobile/screens/admin/revoke_reason_screen.dart';
import 'package:pin_mobile/screens/admin/revoke_success_screen.dart';
import 'package:pin_mobile/screens/admin/widgets/scalloped_check_badge.dart';
import 'package:pin_mobile/services/admin_restaurant_service.dart';
import 'package:pin_mobile/providers/restaurant_approval_provider.dart';

void main() {
  group('Unified Success Screens Checkmark Badge Tests', () {
    testWidgets('All 4 Admin success screens use ScallopedCheckBadge', (WidgetTester tester) async {
      // 1. ApprovalActionSuccessScreen (isApproved: true)
      await tester.pumpWidget(
        const MaterialApp(home: ApprovalActionSuccessScreen(isApproved: true)),
      );
      expect(find.byType(ScallopedCheckBadge), findsOneWidget);
      expect(find.text('อนุมัติสำเร็จ'), findsOneWidget);

      // 2. ApprovalActionSuccessScreen (isApproved: false)
      await tester.pumpWidget(
        const MaterialApp(home: ApprovalActionSuccessScreen(isApproved: false)),
      );
      expect(find.byType(ScallopedCheckBadge), findsOneWidget);
      expect(find.text('ไม่อนุมัติสำเร็จ'), findsOneWidget);

      // 3. RejectSuccessScreen
      await tester.pumpWidget(
        const MaterialApp(home: RejectSuccessScreen()),
      );
      expect(find.byType(ScallopedCheckBadge), findsOneWidget);
      expect(find.text('ไม่อนุมัติสำเร็จ'), findsOneWidget);

      // 4. CancelRejectionSuccessScreen
      await tester.pumpWidget(
        const MaterialApp(home: CancelRejectionSuccessScreen()),
      );
      expect(find.byType(ScallopedCheckBadge), findsOneWidget);
      expect(find.text('ยกเลิกการไม่อนุมัติสำเร็จ'), findsOneWidget);
    });
  });

  group('Full Restaurant Status Transition & Single Section Constraint Tests', () {
    testWidgets('Move rejected restaurant to approved via ยกเลิกไม่อนุมัติ and appears in approved tab',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AdminDashboard(initialTabIndex: 1, initialSubTabIndex: 2), // Tab ไม่อนุมัติ
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Verify "เตาอุ่น" is in "ไม่อนุมัติ"
      expect(find.text('เตาอุ่น'), findsWidgets);

      // 2. Tap on "เตาอุ่น"
      await tester.tap(find.text('เตาอุ่น').last);
      await tester.pumpAndSettle();

      // 3. Verify in detail page with button "ยกเลิกการไม่อนุมัติ"
      expect(find.text('ยกเลิกการไม่อนุมัติ'), findsOneWidget);
      await tester.tap(find.text('ยกเลิกการไม่อนุมัติ'));
      await tester.pumpAndSettle();

      // 4. In CancelRejectionScreen, tap "ยืนยันยกเลิกการไม่อนุมัติ"
      expect(find.byType(CancelRejectionScreen), findsOneWidget);
      await tester.tap(find.text('ยืนยันยกเลิกการไม่อนุมัติ'));
      await tester.pumpAndSettle();

      // 5. In dialog, tap "ยืนยัน"
      await tester.tap(find.text('ยืนยัน'));
      await tester.pumpAndSettle();

      // 6. In CancelRejectionSuccessScreen, verify unified checkmark badge
      expect(find.byType(CancelRejectionSuccessScreen), findsOneWidget);
      expect(find.byType(ScallopedCheckBadge), findsOneWidget);
      await tester.tap(find.text('กลับหน้าจัดการร้านอาหาร'));
      await tester.pumpAndSettle();

      // 7. Verify "เตาอุ่น" is REMOVED from "ไม่อนุมัติ"
      expect(find.byType(AdminDashboard), findsOneWidget);
      expect(find.text('เตาอุ่น'), findsNothing);

      // 8. Switch to "อนุมัติ" tab -> "เตาอุ่น" MUST appear in "อนุมัติ" now!
      await tester.tap(find.text('อนุมัติ'));
      await tester.pumpAndSettle();
      expect(find.text('เตาอุ่น'), findsOneWidget);

      // 9. Switch to "รออนุมัติ" tab -> "เตาอุ่น" MUST NOT be in "รออนุมัติ"
      await tester.tap(find.text('รออนุมัติ'));
      await tester.pumpAndSettle();
      expect(find.text('เตาอุ่น'), findsNothing);

      // 10. Switch back to "อนุมัติ" tab and tap "เตาอุ่น" to verify it now has "ยกเลิกการอนุมัติ"
      await tester.tap(find.text('อนุมัติ'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('เตาอุ่น'));
      await tester.pumpAndSettle();

      expect(find.text('ยกเลิกการอนุมัติ'), findsOneWidget);
    });
  });
}
