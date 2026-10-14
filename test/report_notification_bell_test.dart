import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pin_mobile/screens/admin/admin_user_management_screen.dart';
import 'package:pin_mobile/services/report_service.dart';

void main() {
  setUp(() {
    ReportNotificationManager.clear();
  });

  group('Admin Problem Reports - Notification Bell Tests (Picture 1 Database Schema)', () {
    testWidgets('Bell shows badge for new pending reports, and disappears after clicking to view', (WidgetTester tester) async {
      // 1. Pump AdminUserManagementScreen (หน้ารายงานปัญหาของ admin)
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AdminUserManagementScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 2. ตรวจสอบว่ามีไอคอนกระดิ่งและมีตัวเลขแจ้งเตือนเริ่มต้น (จากรายงานใหม่ที่ยังไม่ได้กดดู)
      expect(find.byKey(const Key('admin_bell_button')), findsOneWidget);
      expect(find.byKey(const Key('admin_bell_badge')), findsOneWidget);

      // ใน Mock data มี pending report 2 รายการ (Kodomo, Somchai Dee)
      expect(find.text('2'), findsWidgets);

      // 3. แตะที่กระดิ่งเพื่อเปิดดูการแจ้งเตือน
      await tester.tap(find.byKey(const Key('admin_bell_button')));
      await tester.pumpAndSettle();

      // Modal Sheet เปิดขึ้นมา
      expect(find.text('การแจ้งเตือนรายงานปัญหา'), findsOneWidget);

      // 4. ตัวเลขจำนวนการแจ้งเตือนบนกระดิ่งต้อง "หายไป" เพราะเรากดดูแล้ว
      expect(find.byKey(const Key('admin_bell_badge')), findsNothing);

      // 5. ปิด Notification Sheet
      await tester.tap(find.byKey(const Key('close_notifications_sheet_button')));
      await tester.pumpAndSettle();

      // 6. ตรวจสอบว่าตัวเลขบนกระดิ่งยังคงหายไป (ไม่โผล่กลับมาซ้ำ)
      expect(find.byKey(const Key('admin_bell_badge')), findsNothing);
    });

    test('Unit test ReportNotificationManager correctly tracks seen report IDs', () {
      ReportNotificationManager.clear();
      expect(ReportNotificationManager.isSeen('rep-01'), isFalse);

      ReportNotificationManager.markAsSeen('rep-01');
      expect(ReportNotificationManager.isSeen('rep-01'), isTrue);
      expect(ReportNotificationManager.isSeen('rep-02'), isFalse);

      ReportNotificationManager.markAllAsSeen(['rep-02', 'rep-03']);
      expect(ReportNotificationManager.isSeen('rep-02'), isTrue);
      expect(ReportNotificationManager.isSeen('rep-03'), isTrue);

      ReportNotificationManager.clear();
      expect(ReportNotificationManager.isSeen('rep-01'), isFalse);
    });
  });
}
