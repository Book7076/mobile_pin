import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pin_mobile/models/filter_criteria_model.dart';
import 'package:pin_mobile/models/restaurant_model.dart';
import 'package:pin_mobile/providers/restaurant_provider.dart';
import 'package:pin_mobile/screens/flow/food_swipe_screen.dart';

// 1x1 transparent PNG for mock network images
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
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}
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
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
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

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  group('Dynamic Category Badge Tests (ป้ายประเภทอาหารเปลี่ยนตามที่ผู้ใช้เลือก)', () {
    final restaurantA = RestaurantModel(
      id: 'rest_a',
      ownerId: 'owner_a',
      name: 'ร้าน A ก๋วยเตี๋ยวและอาหารเหนือ',
      address: 'สุเทพ เชียงใหม่',
      lat: 18.79,
      lng: 98.96,
      phone: '0812345678',
      status: 'approved',
      categories: ['noodles', 'northern_thai', 'thai'],
    );

    test('1. formatRestaurantCategory switches dynamically based on selectedCategories', () {
      // User selected "ก๋วยเตี๋ยว" (noodles) -> shows "ก๋วยเตี๋ยว"
      final labelWhenNoodles = formatRestaurantCategory(
        restaurantA,
        selectedCategories: ['noodles'],
      );
      expect(labelWhenNoodles, 'ก๋วยเตี๋ยว');

      // User selected "ก๋วยเตี๋ยว" using Thai text directly -> shows "ก๋วยเตี๋ยว"
      final labelWhenNoodlesThai = formatRestaurantCategory(
        restaurantA,
        selectedCategories: ['ก๋วยเตี๋ยว'],
      );
      expect(labelWhenNoodlesThai, 'ก๋วยเตี๋ยว');

      // User selected "อาหารเหนือ" (northern_thai) -> shows "อาหารเหนือ"
      final labelWhenNorthern = formatRestaurantCategory(
        restaurantA,
        selectedCategories: ['northern_thai'],
      );
      expect(labelWhenNorthern, 'อาหารเหนือ');

      // User selected "อาหารเหนือ" using Thai text directly -> shows "อาหารเหนือ"
      final labelWhenNorthernThai = formatRestaurantCategory(
        restaurantA,
        selectedCategories: ['อาหารเหนือ'],
      );
      expect(labelWhenNorthernThai, 'อาหารเหนือ');

      // User selected "อาหารไทย" (thai) -> shows "อาหารไทย"
      final labelWhenThai = formatRestaurantCategory(
        restaurantA,
        selectedCategories: ['thai'],
      );
      expect(labelWhenThai, 'อาหารไทย');

      // User selected both "ก๋วยเตี๋ยว" and "อาหารเหนือ" -> shows "ก๋วยเตี๋ยว/อาหารเหนือ"
      final labelWhenBoth = formatRestaurantCategory(
        restaurantA,
        selectedCategories: ['noodles', 'northern_thai'],
      );
      expect(labelWhenBoth, 'ก๋วยเตี๋ยว/อาหารเหนือ');

      // User selected unrelated category or no selection -> falls back cleanly to restaurant primary category
      final labelDefault = formatRestaurantCategory(
        restaurantA,
        selectedCategories: [],
      );
      expect(labelDefault, 'ก๋วยเตี๋ยว');
    });

    test('2. Multi-category restaurant with dessert_bakery and cafe_beverage (e.g. Toast n Cups)', () {
      final cafeBakery = RestaurantModel(
        id: 'rest_toast_cups',
        ownerId: 'owner_toast',
        name: 'Toast n\' Cups',
        address: 'นิมมาน',
        lat: 18.79,
        lng: 98.96,
        phone: '0812345678',
        status: 'approved',
        categories: ['dessert_bakery', 'cafe_beverage'],
      );

      // Selected bakery -> shows "ของหวาน" (DB cuisine_types name)
      expect(
        formatRestaurantCategory(cafeBakery, selectedCategories: ['dessert_bakery']),
        'ของหวาน',
      );

      // Selected cafe -> shows "คาเฟ่" (DB cuisine_types name)
      expect(
        formatRestaurantCategory(cafeBakery, selectedCategories: ['cafe_beverage']),
        'คาเฟ่',
      );
    });

    testWidgets('3. FoodSwipeScreen displays "ก๋วยเตี๋ยว" badge when user selected noodles in filterCriteriaProvider', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = ProviderContainer(
        overrides: [
          restaurantsProvider.overrideWith((ref) => RestaurantsNotifier()..state = [restaurantA]),
          filterCriteriaProvider.overrideWith((ref) => FilterCriteriaModel(
            selectedCategories: ['noodles'],
          )),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: FoodSwipeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Restaurant name
      expect(find.text('ร้าน A ก๋วยเตี๋ยวและอาหารเหนือ'), findsOneWidget);
      // Category badge under name MUST be "ก๋วยเตี๋ยว"
      expect(find.text('ก๋วยเตี๋ยว'), findsOneWidget);
      expect(find.text('อาหารเหนือ'), findsNothing);
    });

    testWidgets('4. FoodSwipeScreen displays "อาหารเหนือ" badge when user selected northern_thai in filterCriteriaProvider', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = ProviderContainer(
        overrides: [
          restaurantsProvider.overrideWith((ref) => RestaurantsNotifier()..state = [restaurantA]),
          filterCriteriaProvider.overrideWith((ref) => FilterCriteriaModel(
            selectedCategories: ['northern_thai'],
          )),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: FoodSwipeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Restaurant name
      expect(find.text('ร้าน A ก๋วยเตี๋ยวและอาหารเหนือ'), findsOneWidget);
      // Category badge under name MUST be "อาหารเหนือ"
      expect(find.text('อาหารเหนือ'), findsOneWidget);
      expect(find.text('ก๋วยเตี๋ยว'), findsNothing);
    });
  });
}
