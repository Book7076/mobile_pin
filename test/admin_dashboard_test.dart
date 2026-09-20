import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_mobile/screens/admin/admin_dashboard.dart';
import 'package:pin_mobile/screens/restaurants/restaurant_detail_screen.dart';

void main() {
  testWidgets('AdminDashboard renders stats, popular restaurants list, and bottom navigation', (WidgetTester tester) async {
    // Set a large enough surface size so all items fit
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: AdminDashboard(),
        ),
      ),
    );

    // Verify Screen Title
    expect(find.text('ภาพรวมสถิติ'), findsOneWidget);

    // Verify 4 Metric Cards
    expect(find.text('อัตราการปัดขวา'), findsOneWidget);
    expect(find.text('จำนวนผู้ใช้งานขณะนี้'), findsOneWidget);
    expect(find.text('จำนวนการปัดทั้งหมด'), findsOneWidget);
    expect(find.text('จำนวนที่จับคู่สำเร็จ'), findsOneWidget);

    // Verify Values and Units
    expect(find.text('คน'), findsOneWidget);
    expect(find.text('ครั้ง'), findsNWidgets(2));

    // Verify Popular Section Title
    expect(find.text('รายการยอดฮิต'), findsOneWidget);

    // Verify Top Restaurants are listed
    expect(find.text('RawTruckr'), findsOneWidget);
    expect(find.text('ครัวปันเจียง'), findsOneWidget);
    expect(find.text('ก๋วยเตี๋ยวเรือขั้นเทพ'), findsOneWidget);

    // Verify Floating Bottom Navigation Bar has 4 icons
    expect(find.byIcon(Icons.grid_view_rounded), findsOneWidget);
    expect(find.byIcon(Icons.storefront_outlined), findsOneWidget);
    expect(find.byIcon(Icons.people_outline_rounded), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);

    // Tap on RawTruckr and verify navigation to RestaurantDetailScreen
    await tester.tap(find.text('RawTruckr'));
    await tester.pumpAndSettle();

    expect(find.byType(RestaurantDetailScreen), findsOneWidget);
    expect(find.text('รายละเอียดร้านค้า'), findsOneWidget);
    expect(find.text('อันดับที่ 1'), findsOneWidget);
  });
}
