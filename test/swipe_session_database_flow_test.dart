import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pin_mobile/models/filter_criteria_model.dart';
import 'package:pin_mobile/models/restaurant_model.dart';
import 'package:pin_mobile/models/swipe_session_model.dart';
import 'package:pin_mobile/providers/restaurant_provider.dart';
import 'package:pin_mobile/screens/flow/budget_selection_screen.dart';
import 'package:pin_mobile/screens/flow/category_selection_screen.dart';
import 'package:pin_mobile/screens/flow/finish_transition_screen.dart';
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
      expect(session.targetRestaurantCount, 0);
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

    testWidgets('6. FoodSwipeScreen (Image 3) allows proceeding with 1 liked restaurant and updates status to ปัดเสร็จแล้ว', (tester) async {
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
      expect(sessionAfterLike.targetRestaurantCount, 1);
      expect(sessionAfterLike.status, 'กำลังใช้');

      // Now tap "ถัดไป >"
      final nextBtn = find.byKey(const ValueKey('swipe_next_button'));
      await tester.tap(nextBtn, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Navigated to FinishTransitionScreen and status completed
      expect(find.text('จบแล้วจ้า'), findsOneWidget);
      final sessionAfterFinish = container.read(swipeSessionProvider);
      expect(sessionAfterFinish.isSessionFinished, true);
      expect(sessionAfterFinish.status, 'ปัดเสร็จแล้ว');
      expect(sessionAfterFinish.targetRestaurantCount, 1);
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
      expect(session.targetRestaurantCount, 5);
      expect(session.status, 'ปัดเสร็จแล้ว');
      expect(session.isSessionFinished, true);
    });
  });
}
