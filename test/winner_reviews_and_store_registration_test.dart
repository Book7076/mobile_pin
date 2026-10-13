import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pin_mobile/models/restaurant_model.dart';
import 'package:pin_mobile/providers/restaurant_provider.dart';
import 'package:pin_mobile/screens/flow/final_winner_screen.dart';
import 'package:pin_mobile/screens/restaurants/review_restaurant_screen.dart';
import 'package:pin_mobile/screens/restaurants/open_restaurant_intro_screen.dart';
import 'package:pin_mobile/screens/restaurants/go_to_owner_screen.dart';

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

final _testRestaurant = RestaurantModel(
  id: 'rest_rawtruckr',
  ownerId: 'owner_123',
  name: 'RawTruckr',
  address: 'ถ.นิมมานเหมินท์ ต.สุเทพ อ.เมือง จ.เชียงใหม่',
  phone: '098-765-4321',
  lat: 18.796143,
  lng: 98.968253,
  rating: 4.5,
  reviewCount: 120,
  priceRange: '150 - 350 บาท',
  imageUrls: ['https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec'],
  categories: ['korean', 'fastfood'],
  features: ['wifi', 'parking', 'delivery'],
  status: 'approved',
  createdAt: DateTime(2025, 1, 1),
);

void main() {
  setUpAll(() {
    HttpOverrides.global = _MockHttpOverrides();
  });

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  group('Winner, Reviews, and Store Registration Comprehensive Tests', () {
    testWidgets('1. FinalWinnerScreen renders winning restaurant card, details, and dismiss button', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: FinalWinnerScreen(restaurant: _testRestaurant),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Header labels
      expect(find.text('ร้านที่ใช่'), findsOneWidget);
      expect(find.text('โดนใจคุณ'), findsOneWidget);

      // Card details
      expect(find.byKey(const ValueKey('winner_restaurant_card')), findsOneWidget);
      expect(find.text('RawTruckr'), findsOneWidget);
      expect(find.text('อาหารเกาหลี'), findsOneWidget);
      expect(find.textContaining('120'), findsOneWidget);

      // Dismiss button exists
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    });

    testWidgets('2. ReviewRestaurantScreen validates empty comment and shows snackbar', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ReviewRestaurantScreen(restaurant: _testRestaurant),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('รีวิวร้านอาหาร'), findsOneWidget);
      expect(find.text('RawTruckr'), findsOneWidget);

      // Submit review with empty comment
      final submitButton = find.widgetWithText(ElevatedButton, 'ส่งรีวิวร้านอาหาร');
      expect(submitButton, findsOneWidget);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Expect validation snackbar
      expect(find.text('กรุณาเขียนข้อความรีวิวสักนิดนึงนะ'), findsOneWidget);
    });

    testWidgets('3. ReviewRestaurantScreen submits review successfully', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: ReviewRestaurantScreen(restaurant: _testRestaurant),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Type comment
      final commentField = find.byType(TextField).first;
      expect(commentField, findsOneWidget);
      await tester.enterText(commentField, 'ไก่ทอดอร่อยมาก กรอบนอกนุ่มใน!');
      await tester.pump(const Duration(milliseconds: 300));

      // Tap submit
      final submitButton = find.widgetWithText(ElevatedButton, 'ส่งรีวิวร้านอาหาร');
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Check review was added to provider
      final reviews = container.read(reviewsProvider);
      expect(reviews.any((r) => r.comment == 'ไก่ทอดอร่อยมาก กรอบนอกนุ่มใน!'), isTrue);
    });

    testWidgets('4. OpenRestaurantIntroScreen renders intro benefits and registration action', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: OpenRestaurantIntroScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('เปิดร้านอาหาร'), findsOneWidget);
      expect(find.text('เปิดร้านอาหารกับ MealMate'), findsOneWidget);
      expect(find.text('เริ่มลงทะเบียนร้าน'), findsOneWidget);
    });

    testWidgets('5. GoToOwnerScreen renders brand transition layout', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: GoToOwnerScreen(
            transitionDelay: Duration(seconds: 10), // long delay so we inspect screen without auto-push
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      // Header / brand text
      expect(find.textContaining('MealMate'), findsWidgets);
      expect(find.textContaining('ระบบกำลังเข้าสู่หน้าลงทะเบียนเจ้าของร้าน'), findsOneWidget);
    });
  });
}
