import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pin_mobile/screens/flow/category_selection_screen.dart';
import 'package:pin_mobile/screens/flow/budget_selection_screen.dart';

// 1x1 transparent PNG data for mocking network images in tests
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

  testWidgets('Flow 3: CategorySelectionScreen renders categories and handles multi-select',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: CategorySelectionScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Title and Subtitle
    expect(find.text('เลือกประเภทอาหาร'), findsOneWidget);
    expect(find.text('(เลือกได้มากกว่า 1 ประเภท)'), findsOneWidget);

    // Verify prominent categories
    expect(find.text('อาหารไทย'), findsOneWidget);
    expect(find.text('อาหารญี่ปุ่น'), findsOneWidget);
    expect(find.text('ชาบู/ฮอกพอด'), findsOneWidget);
    expect(find.text('หมูกระทะ'), findsOneWidget);

    // Tap on "อาหารไทย"
    await tester.tap(find.text('อาหารไทย'));
    await tester.pumpAndSettle();

    // Verify checkmark badge appears
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);

    // Verify Next button "ถัดไป" is visible and active
    expect(find.text('ถัดไป'), findsOneWidget);

    // Tap on "อาหารญี่ปุ่น" (Multi-select)
    await tester.tap(find.text('อาหารญี่ปุ่น'));
    await tester.pumpAndSettle();

    // Both categories should have checkmarks
    expect(find.byIcon(Icons.check_rounded), findsNWidgets(2));
  });

  testWidgets('Flow 4: BudgetSelectionScreen renders tooltip bubble and handles presets',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: BudgetSelectionScreen(
            selectedCategories: ['thai', 'japanese'],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Title and Subtitles
    expect(find.text('ตั้งงบประมาณสำหรับมื้อนี้'), findsOneWidget);
    expect(find.text('เลือกช่วงราคาที่คุณต้องการ'), findsOneWidget);

    // Verify initial floating price bubble is "฿ 50" matching mockup
    expect(find.text('฿ 50'), findsWidgets);

    // Tap on preset chip "฿200"
    await tester.tap(find.text('฿200'));
    await tester.pumpAndSettle();

    // Verify price bubble updated to "฿ 200"
    expect(find.text('฿ 200'), findsOneWidget);

    // Verify Next button "ถัดไป" exists
    expect(find.text('ถัดไป'), findsOneWidget);
  });
}
