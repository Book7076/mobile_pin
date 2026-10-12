import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_mobile/screens/admin/admin_dashboard.dart';
import 'package:pin_mobile/services/admin_overview_service.dart';

void main() {
  testWidgets(
    'AdminDashboard renders Supabase overview counts and no mock content',
    (WidgetTester tester) async {
      // Set a large enough surface size so all items fit
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            adminOverviewStatsProvider.overrideWith(
              (ref) async => const AdminOverviewStats(
                approvedRestaurants: 12,
                rejectedRestaurants: 3,
                pendingRestaurants: 7,
                totalUsers: 42,
              ),
            ),
          ],
          child: const MaterialApp(home: AdminDashboard()),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Screen Title
      expect(find.text('ภาพรวมระบบ'), findsOneWidget);
      expect(find.text('ข้อมูลล่าสุดจาก Supabase'), findsOneWidget);

      // Verify 4 Metric Cards
      expect(find.text('ร้านที่อนุมัติ'), findsOneWidget);
      expect(find.text('ร้านที่ปฏิเสธ'), findsOneWidget);
      expect(find.text('ร้านรออนุมัติ'), findsOneWidget);
      expect(find.text('ผู้ใช้ทั้งหมด'), findsOneWidget);

      // Verify values returned by the data provider
      expect(find.text('12'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
      expect(find.text('ร้าน'), findsNWidgets(3));
      expect(find.text('คน'), findsOneWidget);
      expect(find.text('รายการยอดฮิต'), findsNothing);
      expect(find.text('อัตราการปัดขวา'), findsNothing);

      // Verify Floating Bottom Navigation Bar has 4 icons
      expect(find.byIcon(Icons.grid_view_rounded), findsOneWidget);
      expect(find.byIcon(Icons.storefront_outlined), findsOneWidget);
      expect(find.byIcon(Icons.people_outline_rounded), findsNWidgets(2));
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    },
  );
}
