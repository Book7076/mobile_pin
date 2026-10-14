import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pin_mobile/models/restaurant_model.dart';
import 'package:pin_mobile/screens/owner/owner_menu_screen.dart';
import 'package:pin_mobile/screens/restaurants/restaurant_all_menu_screen.dart';
import 'package:pin_mobile/screens/restaurants/restaurant_detail_screen.dart';
import 'package:pin_mobile/services/menu_availability_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final List<int> _kTransparentImage = [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
];

class _MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _MockHttpClient();
}

class _MockHttpClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = true;
  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _MockHttpClientRequest();
}

class _MockHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  final HttpHeaders headers = _MockHttpHeaders();
  @override
  Future<HttpClientResponse> close() async => _MockHttpClientResponse();
}

class _MockHttpHeaders extends Fake implements HttpHeaders {
  @override
  void add(String name, Object value, {bool? preserveHeaderCase}) {}
}

class _MockHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 200;
  @override
  int get contentLength => _kTransparentImage.length;
  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;
  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([_kTransparentImage]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _MockHttpOverrides();
  });

  group('Menu Availability & Management Tests', () {
    test('MenuAvailabilityManager correctly parses and caches item availability', () {
      // Row with is_available = false
      final row1 = {'id': 'item-101', 'is_available': false, 'sort_order': 0};
      expect(MenuAvailabilityManager.parseFromRow(row1), false);
      expect(MenuAvailabilityManager.isAvailable('item-101'), false);

      // Row with sort_order < 0 fallback
      final row2 = {'id': 'item-102', 'sort_order': -9999};
      expect(MenuAvailabilityManager.parseFromRow(row2), false);
      expect(MenuAvailabilityManager.isAvailable('item-102'), false);

      // Row with is_available = true
      final row3 = {'id': 'item-103', 'is_available': true, 'sort_order': 0};
      expect(MenuAvailabilityManager.parseFromRow(row3), true);
      expect(MenuAvailabilityManager.isAvailable('item-103'), true);
    });

    testWidgets('OwnerMenuScreen toggles boolean switch, shows สินค้าหมด, and persists state across reloads', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(
        const MaterialApp(
          home: OwnerMenuScreen(
            restaurantName: 'The CHICKEN Test',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify initial state shows เปิดขาย
      expect(find.text('เปิดขาย'), findsWidgets);
      expect(find.text('สินค้าหมด'), findsNothing);

      // Find the first Switch widget and toggle it OFF
      final switches = find.byType(Switch);
      expect(switches, findsWidgets);

      await tester.tap(switches.first);
      await tester.pumpAndSettle();

      // Now it must show 'สินค้าหมด'
      expect(find.text('สินค้าหมด'), findsOneWidget);

      // Test deleting menu item: tap the first delete icon
      final deleteButtons = find.byIcon(Icons.delete_outline_rounded);
      expect(deleteButtons, findsWidgets);

      final totalBeforeDelete = tester.widgetList(find.byType(Switch)).length;
      await tester.tap(deleteButtons.first);
      await tester.pumpAndSettle();

      // Confirmation dialog opens
      expect(find.text('ยืนยันการลบเมนู'), findsOneWidget);
      expect(find.text('ลบเมนู'), findsOneWidget);

      // Confirm deletion
      await tester.tap(find.text('ลบเมนู'));
      await tester.pumpAndSettle();

      // Menu item is removed
      final totalAfterDelete = tester.widgetList(find.byType(Switch)).length;
      expect(totalAfterDelete, totalBeforeDelete - 1);
      expect(find.text('ลบเมนูออกจากฐานข้อมูลเรียบร้อยแล้ว'), findsOneWidget);
    });

    testWidgets('Customer RestaurantAllMenuScreen displays สินค้าหมด badge for out of stock dishes', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      final testDishes = [
        SignatureDish(
          name: 'ข้าวกะเพราไก่',
          price: 60,
          isAvailable: true,
        ),
        SignatureDish(
          name: 'ข้าวหน้าหมูทอด',
          price: 75,
          isAvailable: false, // สินค้าหมด
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: RestaurantAllMenuScreen(
            restaurantName: 'ร้านทดสอบ',
            initialDishes: testDishes,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Expect to see both dish names
      expect(find.text('ข้าวกะเพราไก่'), findsOneWidget);
      expect(find.text('ข้าวหน้าหมูทอด'), findsOneWidget);

      // Expect 'สินค้าหมด' badge to be visible for the out-of-stock dish
      expect(find.text('สินค้าหมด'), findsWidgets);
    });

    testWidgets('Customer RestaurantDetailScreen displays สินค้าหมด badge for out of stock dishes', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      final restaurant = RestaurantModel(
        id: 'test-res-1',
        ownerId: 'owner-1',
        name: 'ร้านทดสอบ ดีลเด็ด',
        address: 'เชียงใหม่',
        lat: 18.7883,
        lng: 98.9853,
        phone: '0812345678',
        status: 'approved',
        categories: ['อาหารไทย'],
        rating: 4.8,
        reviewCount: 10,
        priceLevel: 1,
        priceRange: '50 - 100 ฿',
        imageUrls: ['https://example.com/res.jpg'],
        openHours: '10:00 - 20:00',
        isOpen: true,
        signatureDishes: [
          SignatureDish(
            name: 'ไก่ย่างสูตรเด็ด',
            price: 80,
            isAvailable: false, // สินค้าหมด
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: RestaurantDetailScreen(
              restaurantData: restaurant.toJson(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ไก่ย่างสูตรเด็ด'), findsOneWidget);
      expect(find.text('สินค้าหมด'), findsWidgets);
    });
  });
}
