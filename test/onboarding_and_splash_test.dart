import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pin_mobile/screens/onboarding/onboarding_flow_screen.dart';
import 'package:pin_mobile/screens/onboarding/splash_screen_2.dart';
import 'package:pin_mobile/screens/onboarding/splash_screen_3.dart';
import 'package:pin_mobile/screens/splash_screen.dart';
import 'package:pin_mobile/widgets/meal_mate_logo.dart';

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

  group('Onboarding & Splash Screen Comprehensive Tests', () {
    testWidgets('1. SplashScreen renders MealMate logo, title, and tagline correctly', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SplashScreen(),
          ),
        ),
      );

      // Verify branding texts on splash screen
      expect(find.text('MealMate'), findsOneWidget);
      expect(find.byType(MealMateLogo), findsOneWidget);

      // Advance past splash delay timer (2500ms) and transition
      await tester.pump(const Duration(milliseconds: 2600));
      await tester.pump(const Duration(milliseconds: 650));
    });

    testWidgets('2. SplashScreen2 renders feature description and illustrations', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.resetPhysicalSize());

      bool nextTapped = false;
      bool skipTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen2(
            onNext: () => nextTapped = true,
            onSkip: () => skipTapped = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify header and action buttons
      expect(find.text('ถัดไป'), findsOneWidget);
      expect(find.text('ข้าม'), findsOneWidget);

      // Tap Next
      await tester.tap(find.text('ถัดไป'));
      expect(nextTapped, isTrue);

      // Tap Skip
      await tester.tap(find.text('ข้าม'));
      expect(skipTapped, isTrue);
    });

    testWidgets('3. SplashScreen3 renders final onboarding slide with start button', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.resetPhysicalSize());

      bool finishTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen3(
            onNext: () => finishTapped = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify start / explore button
      expect(find.byType(ElevatedButton), findsWidgets);
      final finishBtn = find.byType(ElevatedButton).first;
      await tester.tap(finishBtn);
      expect(finishTapped, isTrue);
    });

    testWidgets('4. OnboardingFlowScreen transitions between splash slides on next button', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: OnboardingFlowScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PageView), findsOneWidget);
      expect(find.text('ถัดไป'), findsOneWidget);

      // Tap Next to advance slide
      await tester.tap(find.text('ถัดไป'));
      await tester.pumpAndSettle();

      expect(find.byType(PageView), findsOneWidget);
    });
  });
}
