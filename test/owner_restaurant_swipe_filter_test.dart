import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pin_mobile/core/mock_data.dart';
import 'package:pin_mobile/models/restaurant_model.dart';
import 'package:pin_mobile/models/user_model.dart';
import 'package:pin_mobile/providers/auth_provider.dart';
import 'package:pin_mobile/providers/restaurant_provider.dart';
import 'package:pin_mobile/screens/flow/food_swipe_screen.dart';

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
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockHttpClient();
  }
}

class _MockHttpClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = true;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    return _MockHttpClientRequest();
  }
}

class _MockHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  final HttpHeaders headers = _MockHttpHeaders();

  @override
  Future<HttpClientResponse> close() async {
    return _MockHttpClientResponse();
  }
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

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  group('Owner Restaurant Exclusion Filter Tests', () {
    test('isUserOwnerOfRestaurant correctly identifies owned restaurants via database owner_id == users.id', () {
      final ownerUser = UserModel(
        id: '1d52f097-0b67-40c0-8542-d790d32ee523',
        email: 'owner@test.com',
        name: 'ร้านค้าเจ้าของ',
        role: 'owner',
      );

      final normalUser = UserModel(
        id: 'c4e99999-0000-4000-8000-000000000001',
        email: 'user@test.com',
        name: 'ลูกค้าทั่วไป',
        role: 'customer',
      );

      final ownedRestaurant = RestaurantModel(
        id: 'rest-uuid-001',
        ownerId: '1d52f097-0b67-40c0-8542-d790d32ee523',
        name: 'ร้านส้มตำแซ่บ',
        address: 'กรุงเทพฯ',
        lat: 13.75,
        lng: 100.5,
        phone: '0812345678',
        status: 'approved',
      );

      final otherRestaurant = RestaurantModel(
        id: 'rest-uuid-002',
        ownerId: 'ffffffff-0b67-40c0-8542-d790d32ee999',
        name: 'ร้านก๋วยเตี๋ยวต้มยำ',
        address: 'เชียงใหม่',
        lat: 18.79,
        lng: 98.98,
        phone: '0898765432',
        status: 'approved',
      );

      // Owner testing owned restaurant -> true (MUST BE EXCLUDED)
      expect(
        isUserOwnerOfRestaurant(
          restaurant: ownedRestaurant,
          currentUser: ownerUser,
        ),
        isTrue,
      );

      // Owner testing other restaurant -> false (NOT EXCLUDED)
      expect(
        isUserOwnerOfRestaurant(
          restaurant: otherRestaurant,
          currentUser: ownerUser,
        ),
        isFalse,
      );

      // Normal customer testing owned restaurant -> false (CAN SWIPE)
      expect(
        isUserOwnerOfRestaurant(
          restaurant: ownedRestaurant,
          currentUser: normalUser,
        ),
        isFalse,
      );
    });

    test('filteredRestaurantsProvider excludes owned restaurant when logged in as owner', () {
      final container = ProviderContainer(
        overrides: [
          restaurantsProvider.overrideWith((ref) => RestaurantsNotifier()),
        ],
      );

      // Initially logged in as demoUser (id: 'user_demo_01')
      final initialFiltered = container.read(filteredRestaurantsProvider);
      // rest_01 ('ร้านส้มตำเด้อ คอนแวนต์', ownerId: 'owner_demo_01') should be visible to normal user
      final hasRest01ForUser = initialFiltered.any((r) => r.id == 'rest_01');
      expect(hasRest01ForUser, isTrue);

      // Switch to demoOwner (id: 'owner_demo_01', ownedRestaurantId: 'rest_01')
      container.read(authProvider.notifier).switchDemoRole('owner');

      final ownerFiltered = container.read(filteredRestaurantsProvider);
      // When owner is logged in, their own restaurant rest_01 MUST be filtered out
      final hasRest01ForOwner = ownerFiltered.any((r) => r.id == 'rest_01');
      expect(hasRest01ForOwner, isFalse);

      // Other restaurants should still be visible
      expect(ownerFiltered.isNotEmpty, isTrue);
      final hasShabuForOwner = ownerFiltered.any((r) => r.id == 'rest_shabu_mouood');
      expect(hasShabuForOwner, isTrue);
    });

    testWidgets('FoodSwipeScreen never displays own restaurant for an owner', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = ProviderContainer();
      // Set to owner role
      container.read(authProvider.notifier).switchDemoRole('owner');

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: FoodSwipeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Ensure the swipe screen loads
      expect(find.text('MealMate'), findsOneWidget);

      // Confirm 'ร้านส้มตำเด้อ คอนแวนต์' (which belongs to owner_demo_01) does not appear on screen
      expect(find.text('ร้านส้มตำเด้อ คอนแวนต์'), findsNothing);

      // Other restaurants (e.g. ชาบูหมูอู๊ด) can be displayed
      expect(find.text('ชาบูหมูอู๊ด'), findsOneWidget);
    });
  });
}
