import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pin_mobile/models/favorite_manager.dart';
import 'package:pin_mobile/screens/home/home_screen.dart';
import 'package:pin_mobile/screens/home/discover_screen.dart';

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

  group('Home & Discovery Flow Comprehensive Tests', () {
    testWidgets('1. HomeScreen renders search bar, banner, and bottom navigation', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomeScreen(initialTab: 0),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Verify search input field exists
      expect(find.byType(TextField), findsWidgets);
      expect(find.text('ค้นหาร้านอาหาร'), findsOneWidget);

      // Verify swipe banner exists
      expect(find.text('ปัดหาร้านอาหาร'), findsOneWidget);

      // Verify floating bottom navigation bar icons exist
      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);
      expect(find.byIcon(Icons.account_circle_outlined), findsOneWidget);
    });

    testWidgets('2. HomeScreen filters restaurants by search query', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomeScreen(initialTab: 0),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Enter search text
      final searchField = find.widgetWithText(TextField, 'ค้นหาร้านอาหาร');
      expect(searchField, findsOneWidget);
      await tester.enterText(searchField, 'ข้าวซอย');
      await tester.pump(const Duration(milliseconds: 300));

      // Curated item matching query appears
      expect(find.textContaining('ข้าวซอยแม่สาย'), findsOneWidget);
    });

    testWidgets('3. HomeScreen switches to Favorites Tab and displays saved favorites', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.resetPhysicalSize());

      // Ensure at least one favorite exists
      FavoriteManager.addFavorite({
        'name': 'ร้านทดสอบโปรด',
        'category': 'ประเภท: อาหารไทย',
        'price': '฿ 50-100 บาท',
        'rating': 4.9,
        'image': 'assets/images/khao_soi.jpg',
        'isAsset': true,
        'isFavorite': true,
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomeScreen(initialTab: 1),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Verify favorite item or favorites screen header
      expect(find.text('รายการโปรด'), findsWidgets);
      expect(find.textContaining('ร้านทดสอบโปรด'), findsOneWidget);
    });

    testWidgets('4. HomeScreen switches to Profile Tab', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomeScreen(initialTab: 2),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Profile tab should display profile menu cards
      expect(find.text('โปรไฟล์'), findsWidgets);
      expect(find.text('การตั้งค่า'), findsOneWidget);
      expect(find.text('ศูนย์ช่วยเหลือ'), findsOneWidget);
      expect(find.text('รายงานปัญหา'), findsOneWidget);
    });

    testWidgets('5. DiscoverScreen renders location search and preference header inside Scaffold', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: DiscoverScreen(),
            ),
          ),
        ),
      );
      // Pump initial render
      await tester.pump(const Duration(milliseconds: 300));

      // DiscoverScreen shows distance slider and category preferences
      expect(find.byType(DiscoverScreen), findsOneWidget);
      expect(find.textContaining('ระยะทาง:'), findsOneWidget);
    });
  });
}
