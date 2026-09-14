import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pin_mobile/screens/flow/finish_transition_screen.dart';
import 'package:pin_mobile/screens/flow/incomplete_result_screen.dart';
import 'package:pin_mobile/screens/flow/selected_restaurants_screen.dart';
import 'package:pin_mobile/screens/flow/food_swipe_screen.dart';

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

  group('Result Flow Unit & Widget Tests', () {
    testWidgets('FinishTransitionScreen renders "จบแล้วจ้า" pill and transitions',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: FinishTransitionScreen(),
          ),
        ),
      );

      // Verify "จบแล้วจ้า" is displayed
      expect(find.text('จบแล้วจ้า'), findsOneWidget);
      expect(find.byIcon(Icons.notifications_active_rounded), findsOneWidget);

      // Fast-forward animation & timer (1400ms auto proceed)
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pumpAndSettle();

      // Should have transitioned to SelectedRestaurantsScreen
      expect(find.text('ผลลัพธ์'), findsOneWidget);
      expect(find.text('ร้านไหน...ถูกใจคุณ'), findsOneWidget);
    });

    testWidgets(
        'SelectedRestaurantsScreen renders 5 cards, ratings, and random pick FAB',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SelectedRestaurantsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Header checks
      expect(find.text('ผลลัพธ์'), findsOneWidget);
      expect(find.text('ร้านไหน...ถูกใจคุณ'), findsOneWidget);

      // Mockup 5 restaurants check
      expect(find.text('RawTruckr'), findsOneWidget);
      expect(find.text('ครัวปินเจียง'), findsOneWidget);
      expect(find.text('ก๋วยเตี๋ยวเรือขึ้นเทพ'), findsOneWidget);
      expect(find.text('TEDS Coffee & Eatery'), findsOneWidget);
      expect(find.text('ข้าวซอยแม่สาย'), findsOneWidget);

      // 1. Test upper-right arrow (>) navigation to details
      final arrowFinder = find.byKey(const ValueKey('card_arrow_0'));
      expect(arrowFinder, findsOneWidget);
      await tester.tap(arrowFinder);
      await tester.pumpAndSettle();

      // Now on RestaurantDetailScreen
      expect(find.text('รายละเอียดร้านอาหาร'), findsOneWidget);
      expect(find.text('มีอินเทอร์เน็ต'), findsOneWidget);
      expect(find.text('เดลิเวอรี่'), findsOneWidget);
      expect(find.text('เหมาะกับเด็ก'), findsOneWidget);

      // Go back to SelectedRestaurantsScreen
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();

      // 2. Cutlery FAB check
      final fabFinder = find.byKey(const ValueKey('random_pick_fab'));
      expect(fabFinder, findsOneWidget);

      // Tap Cutlery FAB to trigger FinalWinnerScreen ("ร้านที่ใช่ โดนใจคุณ")
      await tester.tap(fabFinder);
      await tester.pumpAndSettle();

      // FinalWinnerScreen verification
      expect(find.text('ร้านที่ใช่'), findsOneWidget);
      expect(find.text('โดนใจคุณ'), findsOneWidget);
      expect(find.byKey(const ValueKey('winner_restaurant_card')), findsOneWidget);

      // Tap "X" button to return to SelectedRestaurantsScreen
      final closeBtn = find.byKey(const ValueKey('winner_close_button'));
      expect(closeBtn, findsOneWidget);
      await tester.tap(closeBtn);
      await tester.pumpAndSettle();

      expect(find.text('ผลลัพธ์'), findsOneWidget);
      expect(find.text('ร้านไหน...ถูกใจคุณ'), findsOneWidget);
    });

    testWidgets(
        'IncompleteResultScreen renders sad face, dynamic count, and action buttons',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: IncompleteResultScreen(likedCount: 4),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Texts
      expect(find.text('คุณเลือกได้ 4 ร้าน'), findsOneWidget);
      expect(find.text('จากทั้งหมดที่มี'), findsOneWidget);

      // Action buttons
      expect(find.text('ดูผลลัพธ์เลย'), findsOneWidget);
      expect(find.text('ค้นหาร้านเพิ่มเติม'), findsOneWidget);

      // Tap "ดูผลลัพธ์เลย" -> routes to SelectedRestaurantsScreen
      await tester.tap(find.text('ดูผลลัพธ์เลย'));
      await tester.pumpAndSettle();

      expect(find.text('ผลลัพธ์'), findsOneWidget);
      expect(find.text('ร้านไหน...ถูกใจคุณ'), findsOneWidget);
    });

    testWidgets(
        'FoodSwipeScreen "ถัดไป >" with < 5 restaurants navigates to IncompleteResultScreen',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: FoodSwipeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find "ถัดไป >" button
      final nextButton = find.byKey(const ValueKey('swipe_next_button'));
      expect(nextButton, findsOneWidget);

      // Tap "ถัดไป" when 0 restaurants are liked
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Navigated to IncompleteResultScreen with 0 count
      expect(find.text('คุณเลือกได้ 0 ร้าน'), findsOneWidget);
      expect(find.text('จากทั้งหมดที่มี'), findsOneWidget);
      expect(find.text('ดูผลลัพธ์เลย'), findsOneWidget);
      expect(find.text('ค้นหาร้านเพิ่มเติม'), findsOneWidget);
    });
  });
}
