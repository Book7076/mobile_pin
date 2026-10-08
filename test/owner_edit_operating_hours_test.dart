import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pin_mobile/screens/owner/owner_edit_operating_hours_screen.dart';
import 'package:pin_mobile/screens/owner/owner_restaurant_info_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OwnerEditOperatingHoursScreen Widget & Flow Tests', () {
    testWidgets('Renders layout matching Image 2 correctly', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(
        const MaterialApp(
          home: OwnerEditOperatingHoursScreen(
            restaurantId: 'test-rest-123',
            initialHours: [
              OperatingHourEntry(
                dayOfWeek: 1,
                dayName: 'จันทร์',
                openTime: '00:00',
                closeTime: '00:30',
              ),
              OperatingHourEntry(
                dayOfWeek: 1,
                dayName: 'จันทร์',
                openTime: '08:00',
                closeTime: '17:00',
              ),
              OperatingHourEntry(
                dayOfWeek: 4,
                dayName: 'พฤหัสบดี',
                openTime: '08:00',
                closeTime: '17:00',
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Header AppBar with #860E33 and white text
      expect(find.text('เวลาเปิด-ปิด'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
      expect(find.text('บันทึก'), findsOneWidget);

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, const Color(0xFF860E33));

      // Form inputs
      expect(find.text('เลือกวัน'), findsOneWidget);
      expect(find.text('เวลาเปิด'), findsOneWidget);
      expect(find.text('เวลาปิด'), findsOneWidget);
      expect(find.text('เพิ่ม'), findsOneWidget);

      // Initial list matching Image 2
      expect(find.text('00:00 - 00:30'), findsOneWidget);
      expect(find.text('08:00 - 17:00'), findsNWidgets(2));
      expect(find.text('จันทร์'), findsNWidgets(2));
      expect(find.text('พฤหัสบดี'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsNWidgets(3));
    });

    testWidgets('Tapping เลือกวัน opens ActionSheet matching Image 3 and selects day',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(
        const MaterialApp(
          home: OwnerEditOperatingHoursScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap "เลือกวัน"
      await tester.tap(find.text('เลือกวัน'));
      await tester.pumpAndSettle();

      // Check Image 3 options
      expect(find.text('ทุกวัน'), findsOneWidget);
      expect(find.text('จันทร์ - ศุกร์'), findsOneWidget);
      expect(find.text('เสาร์ - อาทิตย์'), findsOneWidget);
      expect(find.text('อาทิตย์'), findsOneWidget);
      expect(find.text('จันทร์'), findsWidgets);
      expect(find.text('อังคาร'), findsOneWidget);
      expect(find.text('พุธ'), findsOneWidget);
      expect(find.text('พฤหัสบดี'), findsWidgets);
      expect(find.text('ศุกร์'), findsOneWidget);
      expect(find.text('เสาร์'), findsOneWidget);
      expect(find.text('ยกเลิก'), findsOneWidget);

      // Tap "จันทร์ - ศุกร์"
      await tester.tap(find.text('จันทร์ - ศุกร์'));
      await tester.pumpAndSettle();

      // The field now shows "จันทร์ - ศุกร์"
      expect(find.text('จันทร์ - ศุกร์'), findsOneWidget);
    });

    testWidgets('Tapping เวลาเปิด and เวลาปิด opens 30-min time list matching Image 4',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(
        const MaterialApp(
          home: OwnerEditOperatingHoursScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Tap "เวลาเปิด"
      await tester.tap(find.text('เวลาเปิด'));
      await tester.pumpAndSettle();

      // Modal header and times from 00:00 to 23:30
      expect(find.text('00:00'), findsWidgets);
      expect(find.text('00:30'), findsWidgets);
      expect(find.text('01:00'), findsOneWidget);
      expect(find.text('01:30'), findsOneWidget);
      expect(find.text('ยกเลิก'), findsOneWidget);

      // Select 08:00 (need to scroll or pick visible or tap 01:00)
      await tester.tap(find.text('01:00'));
      await tester.pumpAndSettle();

      expect(find.text('01:00'), findsOneWidget);

      // 2. Tap "เวลาปิด"
      await tester.tap(find.text('เวลาปิด'));
      await tester.pumpAndSettle();

      expect(find.text('02:00'), findsOneWidget);
      await tester.tap(find.text('02:00'));
      await tester.pumpAndSettle();

      expect(find.text('02:00'), findsOneWidget);
    });

    testWidgets('Adding new hours and deleting works dynamically', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(
        const MaterialApp(
          home: OwnerEditOperatingHoursScreen(
            initialHours: [
              OperatingHourEntry(
                dayOfWeek: 1,
                dayName: 'จันทร์',
                openTime: '08:00',
                closeTime: '17:00',
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('จันทร์'), findsOneWidget);
      expect(find.text('08:00 - 17:00'), findsOneWidget);

      // Pick "อังคาร"
      await tester.tap(find.text('เลือกวัน'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('อังคาร'));
      await tester.pumpAndSettle();

      // Pick "เวลาเปิด" = 00:30
      await tester.tap(find.text('เวลาเปิด'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('00:30'));
      await tester.pumpAndSettle();

      // Pick "เวลาปิด" = 01:30
      await tester.tap(find.text('เวลาปิด'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('01:30'));
      await tester.pumpAndSettle();

      // Tap "เพิ่ม"
      await tester.tap(find.text('เพิ่ม'));
      await tester.pumpAndSettle();

      // Verify "อังคาร" and "00:30 - 01:30" added to the list
      expect(find.text('อังคาร'), findsOneWidget);
      expect(find.text('00:30 - 01:30'), findsOneWidget);

      // Delete the first item
      final deleteButtons = find.byIcon(Icons.close_rounded);
      expect(deleteButtons, findsNWidgets(2));
      await tester.tap(deleteButtons.first);
      await tester.pumpAndSettle();

      // Now only 1 item remains
      expect(find.byIcon(Icons.close_rounded), findsNWidgets(1));
    });

    testWidgets('OwnerRestaurantInfoScreen can navigate to OwnerEditOperatingHoursScreen',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(
        const MaterialApp(
          home: OwnerRestaurantInfoScreen(
            restaurantName: 'Gindon KinDang',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find 'เวลาเปิด - ปิดร้าน' section
      expect(find.text('เวลาเปิด - ปิดร้าน'), findsOneWidget);

      // Find the 'แก้ไข' button inside the operating hours section
      // In OwnerRestaurantInfoScreen, there are multiple 'แก้ไข' buttons
      final editButtons = find.text('แก้ไข');
      expect(editButtons, findsWidgets);

      // Operating hours is section 3 (after avatar edit, address edit)
      // Let's tap the one next to 'เวลาเปิด - ปิดร้าน'
      final hoursHeader = find.text('เวลาเปิด - ปิดร้าน');
      expect(hoursHeader, findsOneWidget);

      // Tap edit corresponding to operating hours
      await tester.tap(editButtons.at(2));
      await tester.pumpAndSettle();

      // Verify we arrived at OwnerEditOperatingHoursScreen
      expect(find.text('เวลาเปิด-ปิด'), findsOneWidget);
      expect(find.text('เลือกวัน'), findsOneWidget);
      expect(find.text('เพิ่ม'), findsOneWidget);
    });
  });
}
