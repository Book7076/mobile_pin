import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pin_mobile/models/restaurant_model.dart';
import 'package:pin_mobile/screens/restaurants/restaurant_all_menu_screen.dart';
import 'package:pin_mobile/screens/restaurants/restaurant_detail_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('User Restaurant All Menu Screen Tests', () {
    testWidgets('RestaurantAllMenuScreen renders header, categories, dishes and allows filtering',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(
        MaterialApp(
          home: RestaurantAllMenuScreen(
            restaurantName: 'ก๋วยเตี๋ยวเรือขั้นเทพ',
            initialDishes: [
              SignatureDish(
                name: 'ก๋วยเตี๋ยวเรือ พิเศษ',
                price: 50,
              ),
              SignatureDish(
                name: 'ก๋วยเตี๋ยวต้มยำพริกสด พิเศษ',
                price: 50,
              ),
              SignatureDish(
                name: 'กากหมู',
                price: 15,
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. App Bar Header
      expect(find.text('เมนูทั้งหมด'), findsOneWidget);
      expect(find.text('ก๋วยเตี๋ยวเรือขั้นเทพ'), findsOneWidget);

      // 2. Dynamic Categories Tabs (เมนูเส้น และ ของทอด เพราะมีรายการอาหารเหล่านี้)
      expect(find.text('ทั้งหมด'), findsOneWidget);
      expect(find.text('เมนูเส้น'), findsOneWidget);
      expect(find.text('ของทอด'), findsOneWidget);

      // หมวดที่ไม่มีรายการอาหาร ต้องไม่แสดง
      expect(find.text('เครื่องดื่ม'), findsNothing);
      expect(find.text('ของหวาน'), findsNothing);

      // 3. Dishes List
      expect(find.text('ก๋วยเตี๋ยวเรือ พิเศษ'), findsOneWidget);
      expect(find.text('฿50'), findsWidgets);
      expect(find.text('กากหมู'), findsOneWidget);
      expect(find.text('฿15'), findsOneWidget);

      // 4. Filter by Category
      await tester.tap(find.text('ของทอด'));
      await tester.pumpAndSettle();

      expect(find.text('กากหมู'), findsOneWidget);
      expect(find.text('ก๋วยเตี๋ยวเรือ พิเศษ'), findsNothing);

      // 5. Reset Filter to 'ทั้งหมด'
      await tester.tap(find.text('ทั้งหมด'));
      await tester.pumpAndSettle();

      expect(find.text('ก๋วยเตี๋ยวเรือ พิเศษ'), findsOneWidget);
      expect(find.text('กากหมู'), findsOneWidget);
    });

    testWidgets('Tapping "เมนูทั้งหมด >" in RestaurantDetailScreen navigates to RestaurantAllMenuScreen and back',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      final container = ProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: RestaurantDetailScreen(
              name: 'ก๋วยเตี๋ยวเรือขั้นเทพ',
              category: 'อาหารไทย/ก๋วยเตี๋ยว',
              signatureDishes: const ['ก๋วยเตี๋ยวเรือ พิเศษ', 'กากหมู'],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify 'เมนูอาหาร' and 'เมนูทั้งหมด' button are present
      expect(find.text('เมนูอาหาร'), findsOneWidget);
      expect(find.text('เมนูทั้งหมด'), findsOneWidget);

      // Scroll to 'เมนูทั้งหมด' and tap it
      await tester.ensureVisible(find.text('เมนูทั้งหมด'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('เมนูทั้งหมด'));
      await tester.pumpAndSettle();

      // Now on RestaurantAllMenuScreen
      expect(find.byType(RestaurantAllMenuScreen), findsOneWidget);
      expect(find.text('เมนูทั้งหมด'), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.chevron_left_rounded).first);
      await tester.pumpAndSettle();

      // Returned back to RestaurantDetailScreen
      expect(find.byType(RestaurantDetailScreen), findsOneWidget);
      expect(find.text('รายละเอียดร้านอาหาร'), findsOneWidget);
    });
  });
}
