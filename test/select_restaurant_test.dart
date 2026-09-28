import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_mobile/screens/owner/select_restaurant_screen.dart';
import 'package:pin_mobile/screens/owner/owner_dashboard_screen.dart';
import 'package:pin_mobile/screens/restaurants/open_restaurant_intro_screen.dart';
import 'package:pin_mobile/screens/home/home_screen.dart';
import 'package:pin_mobile/core/mock_data.dart';
import 'package:pin_mobile/providers/auth_provider.dart';

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
  void add(String name, Object value, {bool? preserveHeaderCase}) {}
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

  setUp(() {
    OwnerRestaurantManager.resetToDefault();
  });

  Widget createTestWidget(Widget child, {List<Override> overrides = const []}) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        home: child,
      ),
    );
  }

  testWidgets('SelectRestaurantScreen renders header branding and initial restaurants', (tester) async {
    await tester.pumpWidget(createTestWidget(const SelectRestaurantScreen()));
    await tester.pumpAndSettle();

    // Check header branding
    expect(find.text('MealMate'), findsOneWidget);
    expect(find.text('เลือกร้านของคุณ'), findsOneWidget);

    // Check initial restaurant cards
    expect(find.text('THE CHICKEN'), findsOneWidget);
    expect(find.text('ร้านฟาสต์ฟู้ด'), findsOneWidget);
    expect(find.text('WANJOI'), findsOneWidget);
    expect(find.text('เบเกอรี่&เครื่องดื่ม'), findsOneWidget);

    // Check add restaurant card
    expect(find.text('เพิ่มร้านใหม่'), findsOneWidget);
  });

  testWidgets('Tapping THE CHICKEN navigates to OwnerDashboardScreen with THE CHICKEN', (tester) async {
    await tester.pumpWidget(createTestWidget(const SelectRestaurantScreen()));
    await tester.pumpAndSettle();

    // Tap THE CHICKEN card
    await tester.tap(find.text('THE CHICKEN'));
    await tester.pumpAndSettle();

    // Verify it entered OwnerDashboardScreen for THE CHICKEN
    expect(find.byType(OwnerDashboardScreen), findsOneWidget);
    expect(find.text('THE CHICKEN'), findsWidgets);
    expect(find.text('สถิติ'), findsOneWidget);
    expect(find.text('เมนูอาหาร'), findsOneWidget);
    expect(find.text('ข้อมูลร้าน'), findsOneWidget);

    // Verify back navigation returns to SelectRestaurantScreen
    final backButton = find.byIcon(Icons.chevron_left_rounded);
    expect(backButton, findsOneWidget);
    await tester.tap(backButton);
    await tester.pumpAndSettle();

    expect(find.byType(SelectRestaurantScreen), findsOneWidget);
  });

  testWidgets('Tapping WANJOI navigates to OwnerDashboardScreen with WANJOI', (tester) async {
    await tester.pumpWidget(createTestWidget(const SelectRestaurantScreen()));
    await tester.pumpAndSettle();

    // Tap WANJOI card
    await tester.tap(find.text('WANJOI'));
    await tester.pumpAndSettle();

    // Verify it entered OwnerDashboardScreen for WANJOI
    expect(find.byType(OwnerDashboardScreen), findsOneWidget);
    expect(find.text('WANJOI'), findsWidgets);
    expect(find.text('เบเกอรี่&เครื่องดื่ม'), findsOneWidget);
  });

  testWidgets('Tapping เพิ่มร้านใหม่ navigates to restaurant registration (OpenRestaurantIntroScreen)', (tester) async {
    await tester.pumpWidget(createTestWidget(const SelectRestaurantScreen()));
    await tester.pumpAndSettle();

    // Tap "เพิ่มร้านใหม่"
    await tester.tap(find.text('เพิ่มร้านใหม่'));
    await tester.pumpAndSettle();

    // Verify it entered OpenRestaurantIntroScreen
    expect(find.byType(OpenRestaurantIntroScreen), findsOneWidget);
    expect(find.text('เปิดร้านอาหารกับ MealMate'), findsOneWidget);
    expect(find.text('เริ่มลงทะเบียนร้าน'), findsOneWidget);

    // Verify back button returns to SelectRestaurantScreen
    final backButton = find.byIcon(Icons.chevron_left_rounded);
    await tester.tap(backButton);
    await tester.pumpAndSettle();

    expect(find.byType(SelectRestaurantScreen), findsOneWidget);
  });

  testWidgets('HomeScreen profile tab as owner navigates to SelectRestaurantScreen', (tester) async {
    final container = ProviderContainer();
    container.read(authProvider.notifier).switchDemoRole('owner');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: HomeScreen(initialIndex: 2),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Find "แดชบอร์ดเจ้าของร้าน"
    final ownerDashboardTile = find.text('แดชบอร์ดเจ้าของร้าน');
    expect(ownerDashboardTile, findsOneWidget);

    // Tap it
    await tester.tap(ownerDashboardTile);
    await tester.pumpAndSettle();

    // Should open SelectRestaurantScreen
    expect(find.byType(SelectRestaurantScreen), findsOneWidget);
    expect(find.text('เลือกร้านของคุณ'), findsOneWidget);
  });
}
