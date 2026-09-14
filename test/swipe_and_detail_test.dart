import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pin_mobile/core/mock_data.dart';
import 'package:pin_mobile/providers/restaurant_provider.dart';
import 'package:pin_mobile/screens/flow/food_swipe_screen.dart';
import 'package:pin_mobile/screens/flow/selected_restaurants_screen.dart';
import 'package:pin_mobile/screens/restaurants/restaurant_detail_screen.dart';

// 1x1 transparent PNG data for mocking network images
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
    return _createMockImageHttpClient();
  }
}

HttpClient _createMockImageHttpClient() {
  final client = _MockHttpClient();
  return client;
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

  testWidgets('FoodSwipeScreen renders correctly and handles actions', (tester) async {
    // Set screen size to standard mobile viewport
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(() => tester.view.resetPhysicalSize());

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

    // 1. Check Branding & Logo
    expect(find.text('MealMate'), findsOneWidget);

    // 2. Check Top Card content (ชาบูหมูอู๊ด is first)
    expect(find.text('ชาบูหมูอู๊ด'), findsOneWidget);
    expect(find.text('ชาบู/หมูกระทะ'), findsOneWidget);
    expect(find.text('4.7 (65 รีวิว)'), findsOneWidget);
    expect(find.text('249 บาท'), findsOneWidget);

    // 3. Check Control buttons
    expect(find.byIcon(Icons.close_rounded), findsWidgets);
    expect(find.text('i'), findsOneWidget);
    expect(find.byIcon(Icons.favorite_rounded), findsWidgets);
    expect(find.text('ถัดไป'), findsOneWidget);

    // 4. Test Liking with Heart button
    final heartButtonFinder = find.byKey(const ValueKey('swipe_like_button'));
    expect(heartButtonFinder, findsOneWidget);
    await tester.tap(heartButtonFinder);
    await tester.pumpAndSettle();

    // After like: session has 1 liked restaurant
    final swipeSession = container.read(swipeSessionProvider);
    expect(swipeSession.likedRestaurants.length, 1);
    expect(swipeSession.likedRestaurants.first.name, 'ชาบูหมูอู๊ด');

    // Next card should be displayed (RawTruckr)
    expect(find.text('RawTruckr'), findsOneWidget);
    expect(find.text('อาหารเกาหลี'), findsOneWidget);

    // 5. Test "ถัดไป" navigation to IncompleteResultScreen (< 5 liked)
    final nextBtn = find.byKey(const ValueKey('swipe_next_button'));
    expect(nextBtn, findsOneWidget);
    await tester.tap(nextBtn);
    await tester.pumpAndSettle();

    // In IncompleteResultScreen (liked 1 restaurant)
    expect(find.text('คุณเลือกได้ 1 ร้าน'), findsOneWidget);
    expect(find.text('จากทั้งหมดที่มี'), findsOneWidget);

    // Tap "ดูผลลัพธ์เลย" to proceed to SelectedRestaurantsScreen
    await tester.tap(find.text('ดูผลลัพธ์เลย'));
    await tester.pumpAndSettle();
    expect(find.text('ผลลัพธ์'), findsOneWidget);
    expect(find.text('ร้านไหน...ถูกใจคุณ'), findsOneWidget);
  });

  testWidgets('RestaurantDetailScreen renders mockup layout and sections accurately', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(() => tester.view.resetPhysicalSize());

    final container = ProviderContainer();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: RestaurantDetailScreen(restaurantId: 'rest_shabu_mouood'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Header
    expect(find.text('รายละเอียดร้านอาหาร'), findsOneWidget);

    // 2. Restaurant Card Header
    expect(find.text('ชาบูหมูอู๊ด'), findsOneWidget);
    expect(find.textContaining('ประเภทร้านอาหาร: ชาบู, หมูกระทะ'), findsOneWidget);

    // 3. Contact Info Section
    expect(find.text('ที่อยู่ ช่องทางติดต่อ'), findsOneWidget);
    expect(find.textContaining('83 ถนน สุเทพ ตำบลสุเทพ อำเภอเมืองเชียงใหม่'), findsOneWidget);
    expect(find.text('www.googlemap.com'), findsOneWidget);
    expect(find.text('095 446 1156'), findsOneWidget);

    // 4. Opening Hours Section
    expect(find.text('เวลาเปิด-ปิด'), findsOneWidget);
    expect(find.text('อาทิตย์'), findsOneWidget);
    expect(find.text('จันทร์'), findsOneWidget);
    expect(find.textContaining('11.00 - 23.00'), findsWidgets);

    // 5. Amenities Section
    expect(find.text('สิ่งอำนวยความสะดวก'), findsOneWidget);
    expect(find.text('เหมาะกับกลุ่ม'), findsOneWidget);
    expect(find.text('เครื่องปรับอากาศ'), findsOneWidget);
    expect(find.text('รถจักรยานยนต์'), findsOneWidget);
    expect(find.text('มีห้องน้ำ'), findsOneWidget);

    // 6. Dishes Section
    expect(find.text('เมนูอาหาร'), findsOneWidget);
    expect(find.text('บุฟเฟต์'), findsOneWidget);
    expect(find.text('฿249'), findsOneWidget);
    expect(find.text('กุ้งดอง'), findsOneWidget);

    // 7. Reviews Section
    expect(find.text('รีวิวร้านอาหาร'), findsOneWidget);
    expect(find.text('UserA'), findsOneWidget);
    expect(find.textContaining('ร้านสะอาด มีห้องน้ำที่สะอาด'), findsOneWidget);
    expect(find.text('UserB'), findsOneWidget);
    expect(find.textContaining('อาหารอร่อยแต่รออาหารค่อนข้างนาน'), findsOneWidget);
  });

  testWidgets('SelectedRestaurantsScreen renders mockup layout and random pick dialog', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(() => tester.view.resetPhysicalSize());

    final container = ProviderContainer();

    // 1. Test Default / Mockup State
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: SelectedRestaurantsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ผลลัพธ์'), findsOneWidget);
    expect(find.text('ร้านไหน...ถูกใจคุณ'), findsOneWidget);

    // 2. Add liked restaurant and verify populated state
    container.read(swipeSessionProvider.notifier).like(MockData.restaurants.first);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: SelectedRestaurantsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ชาบูหมูอู๊ด'), findsWidgets);

    // Tap Cutlery FAB to trigger random pick
    final fabFinder = find.byKey(const ValueKey('random_pick_fab'));
    expect(fabFinder, findsOneWidget);
    await tester.tap(fabFinder);
    await tester.pumpAndSettle();

    expect(find.text('ร้านที่ใช่'), findsOneWidget);
    expect(find.text('โดนใจคุณ'), findsOneWidget);
  });
}
