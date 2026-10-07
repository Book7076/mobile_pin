import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pin_mobile/models/menu_item_model.dart';
import 'package:pin_mobile/models/operating_hours_model.dart';
import 'package:pin_mobile/screens/owner/owner_dashboard_screen.dart';
import 'package:pin_mobile/screens/owner/owner_menu_screen.dart';
import 'package:pin_mobile/screens/owner/owner_restaurant_info_screen.dart';
import 'package:pin_mobile/screens/owner/owner_reviews_screen.dart';

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

  group('Option A - Store Owner Models & Logic', () {
    test('MenuItemModel serialization and toInsertMap', () {
      final item = MenuItemModel(
        id: 'item-1',
        restaurantId: 'rest-123',
        name: 'ข้าวไก่กรอบ',
        price: 79.0,
        imageUrl: 'https://example.com/item.jpg',
      );

      final insertMap = item.toInsertMap();
      expect(insertMap['restaurant_id'], 'rest-123');
      expect(insertMap['name'], 'ข้าวไก่กรอบ');
      expect(insertMap['price'], 79.0);
      expect(insertMap['image_url'], 'https://example.com/item.jpg');
      // Should NOT contain keys that don't exist in Supabase menu_items table
      expect(insertMap.containsKey('id'), false);
      expect(insertMap.containsKey('is_available'), false);
    });

    test('OperatingHoursModel formatting display', () {
      final hours = [
        const OperatingHoursModel(
          id: 'h1',
          restaurantId: 'r1',
          dayOfWeek: 1,
          openTime: '10:00:00',
          closeTime: '21:30:00',
        ),
        const OperatingHoursModel(
          id: 'h2',
          restaurantId: 'r1',
          dayOfWeek: 2,
          openTime: '10:00:00',
          closeTime: '21:30:00',
        ),
      ];

      final display = OperatingHoursModel.formatDisplay(hours);
      expect(display, contains('10:00 - 21:30 น.'));
    });
  });

  group('Option A - Store Owner Screens Widget Tests', () {
    testWidgets('OwnerDashboardScreen renders restaurant name and navigates to OwnerMenuScreen', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(
        const MaterialApp(
          home: OwnerDashboardScreen(
            restaurantId: 'test-rest-id',
            restaurantName: 'The CHICKEN Test',
            restaurantCategory: 'ไก่ทอดและอาหารเกาหลี',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('The CHICKEN Test'), findsOneWidget);
      expect(find.text('เมนูอาหาร'), findsOneWidget);
      expect(find.text('ข้อมูลร้าน'), findsOneWidget);
      expect(find.text('รีวิว'), findsOneWidget);

      // Tap 'เมนูอาหาร'
      await tester.tap(find.text('เมนูอาหาร'));
      await tester.pumpAndSettle();

      expect(find.byType(OwnerMenuScreen), findsOneWidget);
      expect(find.textContaining('จัดการเมนูอาหาร'), findsOneWidget);
    });

    testWidgets('OwnerMenuScreen renders categories, items and opens add dialog', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(
        const MaterialApp(
          home: OwnerMenuScreen(
            restaurantId: 'test-rest-id',
            restaurantName: 'The CHICKEN Test',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ทั้งหมด'), findsOneWidget);
      expect(find.text('เพิ่มเมนู'), findsOneWidget);

      // Open add menu dialog
      await tester.tap(find.text('เพิ่มเมนู'));
      await tester.pumpAndSettle();

      expect(find.text('เพิ่มเมนูใหม่'), findsOneWidget);
      expect(find.text('บันทึกเมนู'), findsOneWidget);
    });

    testWidgets('OwnerRestaurantInfoScreen renders and allows edit mode', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(
        const MaterialApp(
          home: OwnerRestaurantInfoScreen(
            restaurantId: 'test-rest-id',
            restaurantName: 'The CHICKEN Test',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ข้อมูลร้าน'), findsOneWidget);
      expect(find.text('The CHICKEN Test'), findsOneWidget);
      expect(find.text('ที่อยู่'), findsOneWidget);
      expect(find.text('เวลาเปิด - ปิดร้าน'), findsOneWidget);
      expect(find.text('สิ่งอำนวยความสะดวก'), findsOneWidget);
      expect(find.text('สถานะร้านค้า'), findsOneWidget);

      // Tap edit on ที่อยู่ (second 'แก้ไข' after avatar photo edit)
      final editButtons = find.text('แก้ไข');
      expect(editButtons, findsWidgets);
      await tester.tap(editButtons.at(1));
      await tester.pumpAndSettle();

      expect(find.text('แก้ไขข้อมูลติดต่อและที่อยู่'), findsOneWidget);
      expect(find.text('บันทึกข้อมูล'), findsOneWidget);
    });

    testWidgets('OwnerReviewsScreen renders reviews and score summary', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));

      await tester.pumpWidget(
        const MaterialApp(
          home: OwnerReviewsScreen(
            restaurantId: 'test-rest-id',
            restaurantName: 'The CHICKEN Test',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('รีวิวจากลูกค้า'), findsOneWidget);
      expect(find.byIcon(Icons.rate_review_outlined), findsOneWidget);
    });
  });
}
