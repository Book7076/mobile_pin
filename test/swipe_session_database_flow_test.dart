import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pin_mobile/core/mock_data.dart';
import 'package:pin_mobile/models/filter_criteria_model.dart';
import 'package:pin_mobile/models/restaurant_model.dart';
import 'package:pin_mobile/models/swipe_session_model.dart';
import 'package:pin_mobile/providers/restaurant_provider.dart';
import 'package:pin_mobile/screens/flow/budget_selection_screen.dart';
import 'package:pin_mobile/screens/flow/category_selection_screen.dart';
import 'package:pin_mobile/screens/flow/finish_transition_screen.dart';
import 'package:pin_mobile/screens/flow/food_swipe_screen.dart';
import 'package:pin_mobile/services/swipe_session_service.dart';

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

  group('Swipe Sessions Database & Flow Integration Tests (รูปที่ 1, 2, 3 -> 4)', () {
    test('1. SwipeSessionModel serialization matches Image 4 database schema', () {
      final now = DateTime.now();
      final model = SwipeSessionModel(
        id: '9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d',
        userId: 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
        cuisineTypeId: 3,
        priceMin: 50.0,
        priceMax: 570.0,
        targetRestaurantCount: 3,
        status: SwipeSessionModel.statusInProgress,
        createdAt: now,
      );

      final json = model.toJson();
      expect(json['id'], '9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d');
      expect(json['user_id'], 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11');
      expect(json['cuisine_type_id'], 3);
      expect(json['price_min'], 50.0);
      expect(json['price_max'], 570.0);
      expect(json['target_restaurant_count'], 3);
      expect(json['status'], 'กำลังใช้');
      expect(json['created_at'], now.toIso8601String());

      // Deserialization
      final parsed = SwipeSessionModel.fromJson(json);
      expect(parsed.id, model.id);
      expect(parsed.userId, model.userId);
      expect(parsed.cuisineTypeId, 3);
      expect(parsed.priceMin, 50.0);
      expect(parsed.priceMax, 570.0);
      expect(parsed.targetRestaurantCount, 3);
      expect(parsed.status, 'กำลังใช้');
    });

    test('2. mapCategoryToCuisineTypeId maps all categories from Image 1 correctly', () {
      // Image 1 categories
      expect(mapCategoryToCuisineTypeId('thai'), 1);
      expect(mapCategoryToCuisineTypeId('อาหารไทย'), 1);
      expect(mapCategoryToCuisineTypeId('japanese'), 2);
      expect(mapCategoryToCuisineTypeId('อาหารญี่ปุ่น'), 2);
      expect(mapCategoryToCuisineTypeId('korean'), 3);
      expect(mapCategoryToCuisineTypeId('อาหารเกาหลี'), 3);
      expect(mapCategoryToCuisineTypeId('chinese'), 4);
      expect(mapCategoryToCuisineTypeId('อาหารจีน'), 4);
      expect(mapCategoryToCuisineTypeId('dessert_bakery'), 5);
      expect(mapCategoryToCuisineTypeId('ขนมหวาน/เบเกอรี่'), 5);
      expect(mapCategoryToCuisineTypeId('fast_food'), 7);
      expect(mapCategoryToCuisineTypeId('ฟาสต์ฟู้ด'), 7);
      expect(mapCategoryToCuisineTypeId('healthy'), 8);
      expect(mapCategoryToCuisineTypeId('อาหารสุขภาพ'), 8);
      expect(mapCategoryToCuisineTypeId('noodles'), 10);
      expect(mapCategoryToCuisineTypeId('ก๋วยเตี๋ยว'), 10);
      expect(mapCategoryToCuisineTypeId('cafe_beverage'), 11);
      expect(mapCategoryToCuisineTypeId('คาเฟ่/เครื่องดื่ม'), 11);
      expect(mapCategoryToCuisineTypeId('shabu_hotpot'), 12);
      expect(mapCategoryToCuisineTypeId('ชาบู/ฮอกพอด'), 12);
      expect(mapCategoryToCuisineTypeId('mookata'), 12);
      expect(mapCategoryToCuisineTypeId('หมูกระทะ'), 12);
      expect(mapCategoryToCuisineTypeId('a_la_carte'), 17);
      expect(mapCategoryToCuisineTypeId('อาหารตามสั่ง'), 17);
    });

    testWidgets('3. CategorySelectionScreen (Image 1) maps selected category to cuisine_type_id', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = ProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: CategorySelectionScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Korean food (อาหารเกาหลี)
      expect(find.text('อาหารเกาหลี'), findsOneWidget);
      await tester.tap(find.text('อาหารเกาหลี'));
      await tester.pumpAndSettle();

      // Tap Next button (ถัดไป)
      final nextButton = find.widgetWithText(ElevatedButton, 'ถัดไป');
      expect(nextButton, findsOneWidget);
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      final criteria = container.read(filterCriteriaProvider);
      expect(criteria.selectedCategories, contains('korean'));
      expect(criteria.cuisineTypeId, 3); // Korean = 3 in database cuisine_types
    });

    testWidgets('4. BudgetSelectionScreen (Image 2) saves price_min and price_max and initializes session', (tester) async {
      final container = ProviderContainer();

      // Set initial criteria with korean (cuisine_type_id = 3)
      container.read(filterCriteriaProvider.notifier).state = FilterCriteriaModel(
        selectedCategories: ['korean'],
        cuisineTypeId: 3,
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: BudgetSelectionScreen(selectedCategories: ['korean']),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Quick tap preset budget ฿500
      expect(find.text('฿500'), findsOneWidget);
      await tester.tap(find.text('฿500'));
      await tester.pumpAndSettle();

      // Tap "ถัดไป"
      final nextBtn = find.widgetWithText(ElevatedButton, 'ถัดไป');
      expect(nextBtn, findsOneWidget);
      await tester.tap(nextBtn);
      await tester.pumpAndSettle();

      final criteria = container.read(filterCriteriaProvider);
      expect(criteria.minBudget, 50.0);
      expect(criteria.maxBudget, 500.0);
      expect(criteria.cuisineTypeId, 3);

      final session = container.read(swipeSessionProvider);
      expect(session.cuisineTypeId, 3);
      expect(session.priceMin, 50.0);
      expect(session.priceMax, 500.0);
      expect(session.targetRestaurantCount, 5);
      expect(session.swipedCount, 0);
      expect(session.status, 'กำลังใช้');
    });

    testWidgets('5. FoodSwipeScreen (Image 3) prevents proceeding when 0 restaurants swiped right', (tester) async {
      final container = ProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: FoodSwipeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final nextBtn = find.byKey(const ValueKey('swipe_next_button'));
      expect(nextBtn, findsOneWidget);

      // Tap "ถัดไป >" with 0 liked restaurants
      await tester.tap(nextBtn, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Should show warning SnackBar and NOT navigate to FinishTransitionScreen
      expect(find.textContaining('กรุณาปัดขวาเพื่อเลือกร้านอย่างน้อย 1 ร้านก่อนไปต่อจ้า'), findsOneWidget);
      expect(find.text('จบแล้วจ้า'), findsNothing);
      expect(find.byType(FoodSwipeScreen), findsOneWidget);
    });

    testWidgets('6. FoodSwipeScreen (Image 3) allows proceeding with 1 liked restaurant and updates status to เสร็จสิ้น', (tester) async {
      final container = ProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: FoodSwipeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap like button on first restaurant
      final likeBtn = find.byKey(const ValueKey('swipe_like_button'));
      expect(likeBtn, findsOneWidget);
      await tester.tap(likeBtn);
      await tester.pumpAndSettle();

      final sessionAfterLike = container.read(swipeSessionProvider);
      expect(sessionAfterLike.likedRestaurants.length, 1);
      expect(sessionAfterLike.swipedCount, 1);
      expect(sessionAfterLike.status, 'กำลังใช้');

      // Now tap "ถัดไป >"
      final nextBtn = find.byKey(const ValueKey('swipe_next_button'));
      await tester.tap(nextBtn, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Navigated to FinishTransitionScreen and status completed
      expect(find.text('จบแล้วจ้า'), findsOneWidget);
      final sessionAfterFinish = container.read(swipeSessionProvider);
      expect(sessionAfterFinish.isSessionFinished, true);
      expect(sessionAfterFinish.isCompleted, true);
      expect(sessionAfterFinish.status, SwipeSessionModel.statusCompleted);
    });

    testWidgets('7. FoodSwipeScreen automatically navigates to result transition when 5 restaurants are liked', (tester) async {
      final container = ProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: FoodSwipeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final likeBtn = find.byKey(const ValueKey('swipe_like_button'));
      expect(likeBtn, findsOneWidget);

      // Like 5 restaurants sequentially
      for (int i = 0; i < 5; i++) {
        await tester.tap(likeBtn);
        await tester.pumpAndSettle();
      }

      // Automatically transitions to result transition screen immediately!
      expect(find.text('จบแล้วจ้า'), findsOneWidget);

      final session = container.read(swipeSessionProvider);
      expect(session.likedRestaurants.length, 5);
      expect(session.swipedCount, 5);
      expect(session.isCompleted, true);
      expect(session.status, SwipeSessionModel.statusCompleted);
      expect(session.isSessionFinished, true);
    });

    test('8. Swipes table model (Image 1) and swiped_count synchronization test', () {
      final swipeRecord = SwipeRecordModel(
        id: '123e4567-e89b-12d3-a456-426614174000',
        sessionId: 'session-uuid-1',
        userId: 'user-uuid-1',
        restaurantId: 'rest-uuid-1',
        direction: SwipeDirection.right,
        createdAt: DateTime.now(),
      );

      final json = swipeRecord.toJson();
      expect(json['session_id'], 'session-uuid-1');
      expect(json['restaurant_id'], 'rest-uuid-1');
      expect(json['direction'], 'right');

      final deserialized = SwipeRecordModel.fromJson(json);
      expect(deserialized.sessionId, 'session-uuid-1');
      expect(deserialized.direction, SwipeDirection.right);

      // Verify pass (left) increments swiped_count
      final notifier = SwipeSessionNotifier();
      expect(notifier.state.swipedCount, 0);

      final dummyRestaurant = MockData.restaurants.first;

      notifier.pass(dummyRestaurant);
      expect(notifier.state.swipedCount, 1);
      expect(notifier.state.passedRestaurants.length, 1);
      expect(notifier.state.likedRestaurants.length, 0);

      notifier.like(dummyRestaurant);
      expect(notifier.state.swipedCount, 2);
      expect(notifier.state.likedRestaurants.length, 1);
    });

    test('9. user_food_preferences table model (Image 2) serialization test', () {
      final pref = UserFoodPreferenceModel(
        id: 'pref-uuid-1',
        userId: 'user-uuid-1',
        foodTagId: 10,
        prefType: FoodPreferenceType.like,
      );

      final json = pref.toJson();
      expect(json['user_id'], 'user-uuid-1');
      expect(json['food_tag_id'], 10);
      expect(json['pref_type'], 'like');

      final parsed = UserFoodPreferenceModel.fromJson(json);
      expect(parsed.foodTagId, 10);
      expect(parsed.prefType, 'like');

      final dislikePref = UserFoodPreferenceModel(
        userId: 'user-uuid-2',
        foodTagId: 4,
        prefType: FoodPreferenceType.dislike,
      );
      expect(dislikePref.prefType, 'dislike');
    });

    test('10. selected_restaurants table model (Image 3) and winner is_final_choice test', () {
      final selected = SelectedRestaurantModel(
        sessionId: 'session-uuid-1',
        restaurantId: 'rest_winner',
        isFinalChoice: false,
      );

      final json = selected.toJson();
      expect(json['session_id'], 'session-uuid-1');
      expect(json['restaurant_id'], 'rest_winner');
      expect(json['is_final_choice'], false);

      final parsed = SelectedRestaurantModel.fromJson(json);
      expect(parsed.isFinalChoice, false);

      // Test setWinner in SwipeSessionNotifier
      final notifier = SwipeSessionNotifier();
      final winner = MockData.restaurants[1];

      notifier.setWinner(winner);
      expect(notifier.state.selectedWinner?.id, winner.id);
      expect(notifier.state.isSessionFinished, true);
      expect(notifier.state.status, SwipeSessionModel.statusCompleted);
    });

    test('11. swipe_session_cuisines table model serialization test', () {
      final cuisineModel = SwipeSessionCuisineModel(
        sessionId: 'session-uuid-test',
        cuisineTypeId: 10,
      );

      final json = cuisineModel.toJson();
      expect(json['session_id'], 'session-uuid-test');
      expect(json['cuisine_type_id'], 10);

      final parsed = SwipeSessionCuisineModel.fromJson(json);
      expect(parsed.sessionId, 'session-uuid-test');
      expect(parsed.cuisineTypeId, 10);
    });

    test('12. Point 1: Validation requires at least 1 cuisine type before creating session', () async {
      expect(
        () => SwipeSessionService.createSession(
          cuisineTypeIds: [],
          priceMin: 50,
          priceMax: 300,
        ),
        throwsArgumentError,
      );
    });

    test('13. Point 1: SwipeSessionNotifier.initSession stores multiple sessionCuisineTypeIds', () async {
      final notifier = SwipeSessionNotifier();
      await notifier.initSession(
        cuisineTypeIds: [10, 15, 1], // noodles, northern_thai, thai
        priceMin: 50,
        priceMax: 500,
      );

      expect(notifier.state.sessionCuisineTypeIds, [10, 15, 1]);
      // First category serves as fallback backup in cuisineTypeId
      expect(notifier.state.cuisineTypeId, 10);
      expect(notifier.state.priceMin, 50);
      expect(notifier.state.priceMax, 500);
      expect(notifier.state.status, SwipeSessionModel.statusInProgress);
    });

    test('14. Point 2: getMatchedCuisineLabelsForRestaurant displays only categories restaurant has AND user selected', () {
      final dualRestaurant = RestaurantModel(
        id: 'rest_dual',
        ownerId: 'owner_1',
        name: 'ร้านข้าวซอยป้าสาย (ก๋วยเตี๋ยวและอาหารเหนือ)',
        address: 'เชียงใหม่',
        lat: 18.79,
        lng: 98.96,
        phone: '0812345678',
        status: 'approved',
        categories: ['noodles', 'northern_thai', 'thai'],
      );

      final singleRestaurant = RestaurantModel(
        id: 'rest_single',
        ownerId: 'owner_2',
        name: 'ร้านก๋วยเตี๋ยวเรือคุณเทพ',
        address: 'เชียงใหม่',
        lat: 18.79,
        lng: 98.96,
        phone: '0812345678',
        status: 'approved',
        categories: ['noodles'],
      );

      // User selected noodles (10) and northern_thai (15)
      final userSelectedCuisineIds = [10, 15];

      // Dual restaurant matches BOTH: shows both badges
      final dualLabels = getMatchedCuisineLabelsForRestaurant(
        dualRestaurant,
        sessionCuisineTypeIds: userSelectedCuisineIds,
      );
      expect(dualLabels, contains('ก๋วยเตี๋ยว'));
      expect(dualLabels, contains('อาหารเหนือ'));
      expect(dualLabels.length, 2);

      // Single restaurant matches ONLY noodles: shows only noodles badge
      final singleLabels = getMatchedCuisineLabelsForRestaurant(
        singleRestaurant,
        sessionCuisineTypeIds: userSelectedCuisineIds,
      );
      expect(singleLabels, ['ก๋วยเตี๋ยว']);
      expect(singleLabels.length, 1);
    });

    testWidgets('15. Point 2 Widget: FoodSwipeScreen displays both badges when restaurant has both matched cuisines',
        (WidgetTester tester) async {
      final dualRestaurant = RestaurantModel(
        id: 'rest_dual_card',
        ownerId: 'owner_1',
        name: 'ร้านอาหารล้านนา ก๋วยเตี๋ยวและอาหารเหนือ',
        address: 'เชียงใหม่',
        lat: 18.79,
        lng: 98.96,
        phone: '0812345678',
        status: 'approved',
        categories: ['noodles', 'northern_thai'],
        imageUrls: ['https://example.com/food.jpg'],
        priceRange: '฿ 60 - 150',
        rating: 4.8,
        reviewCount: 42,
      );

      final container = ProviderContainer(
        overrides: [
          restaurantsProvider.overrideWith(
              (ref) => RestaurantsNotifier()..state = [dualRestaurant]),
          filterCriteriaProvider.overrideWith((ref) => FilterCriteriaModel(
                selectedCategories: ['noodles', 'northern_thai'],
                minBudget: 50.0,
                maxBudget: 500.0,
              )),
          swipeSessionProvider.overrideWith((ref) {
            final notifier = SwipeSessionNotifier();
            notifier.state = SwipeSessionState(
              currentSessionDbId: 'mock-session-id',
              cuisineTypeId: 10,
              sessionCuisineTypeIds: [10, 15],
              priceMin: 50,
              priceMax: 500,
            );
            return notifier;
          }),
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

      // Both badges under restaurant name must be visible in UI
      expect(find.text('ก๋วยเตี๋ยว'), findsOneWidget);
      expect(find.text('อาหารเหนือ'), findsOneWidget);
    });
  });
}
