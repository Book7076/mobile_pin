import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pin_mobile/screens/owner/owner_stats_screen.dart';
import 'package:pin_mobile/screens/owner/owner_messages_screen.dart';
import 'package:pin_mobile/screens/admin/admin_overview_screen.dart';
import 'package:pin_mobile/screens/admin/admin_settings_screen.dart';
import 'package:pin_mobile/services/owner_stats_service.dart';

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

  group('Owner and Admin Management Comprehensive Tests', () {
    testWidgets('1. OwnerStatsScreen renders metrics cards and time period selector', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ownerReviewStatsProvider.overrideWith(
              (ref, query) async => const OwnerReviewStats(
                totalReviews: 8,
                averageRating: 4.5,
                fiveStarReviews: 5,
                ratingCounts: {1: 0, 2: 0, 3: 1, 4: 2, 5: 5},
                trend: [],
              ),
            ),
          ],
          child: const MaterialApp(
            home: OwnerStatsScreen(
              restaurantId: 'restaurant-1',
              restaurantName: 'The CHICKEN',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('สถิติ'), findsOneWidget);
      expect(find.text('ภาพรวมรีวิว'), findsOneWidget);
      expect(find.text('รีวิวทั้งหมด'), findsOneWidget);
      expect(find.text('คะแนนเฉลี่ย'), findsOneWidget);
    });

    testWidgets('2. OwnerMessagesScreen renders customer inquiries and opens reply sheet', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: OwnerMessagesScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('ข้อความและแชท'), findsOneWidget);
      expect(find.text('คุณสมชาย (ลูกค้าประจำ)'), findsOneWidget);
      expect(find.text('คุณวิภาวรรณ'), findsOneWidget);

      // Tap on first chat to open reply bottom sheet
      await tester.tap(find.text('คุณสมชาย (ลูกค้าประจำ)'));
      await tester.pumpAndSettle();

      expect(find.text('แชทกับ คุณสมชาย (ลูกค้าประจำ)'), findsOneWidget);
      expect(find.text('พิมพ์ข้อความตอบกลับ...'), findsOneWidget);
    });

    testWidgets('3. AdminOverviewScreen renders KPI overview and navigation header', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.resetPhysicalSize());

      bool navigatedToRestaurants = false;
      bool navigatedToUsers = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: AdminOverviewScreen(
              onNavigateToRestaurants: () => navigatedToRestaurants = true,
              onNavigateToUsers: () => navigatedToUsers = true,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('หน้าหลักแอดมิน'), findsOneWidget);
      expect(find.text('ภาพรวมระบบแอปพลิเคชัน Meaimate'), findsOneWidget);
      expect(find.byIcon(Icons.security_rounded), findsOneWidget);
    });

    testWidgets('4. AdminSettingsScreen renders settings and confirmation dialog on logout', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: AdminSettingsScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('การตั้งค่า'), findsOneWidget);

      // Find and tap "ออกจากระบบ" option
      final logoutOption = find.text('ออกจากระบบ');
      expect(logoutOption, findsOneWidget);
      await tester.tap(logoutOption);
      await tester.pumpAndSettle();

      // Verify confirmation dialog
      expect(find.text('ยืนยันการออกจากระบบ'), findsOneWidget);
      expect(find.text('คุณต้องการออกจากระบบผู้ดูแลระบบ Meaimate ใช่หรือไม่?'), findsOneWidget);
      expect(find.text('ยกเลิก'), findsOneWidget);
    });
  });
}
