import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pin_mobile/screens/owner/owner_stats_screen.dart';
import 'package:pin_mobile/services/owner_stats_service.dart';

void main() {
  testWidgets(
    'OwnerStatsScreen shows real review metrics without popular menu mock',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ownerReviewStatsProvider.overrideWith(
              (ref, query) async => const OwnerReviewStats(
                totalReviews: 8,
                averageRating: 4.5,
                fiveStarReviews: 5,
                ratingCounts: {1: 0, 2: 0, 3: 1, 4: 2, 5: 5},
                trend: [
                  OwnerReviewPoint(label: '1/10', count: 1),
                  OwnerReviewPoint(label: '2/10', count: 2),
                  OwnerReviewPoint(label: '3/10', count: 0),
                  OwnerReviewPoint(label: '4/10', count: 3),
                  OwnerReviewPoint(label: '5/10', count: 2),
                ],
              ),
            ),
          ],
          child: const MaterialApp(
            home: OwnerStatsScreen(
              restaurantId: 'restaurant-1',
              restaurantName: 'ร้านทดสอบ',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ภาพรวมรีวิว'), findsOneWidget);
      expect(find.text('รีวิวทั้งหมด'), findsOneWidget);
      expect(find.text('คะแนนเฉลี่ย'), findsOneWidget);
      expect(find.text('รีวิว 5 ดาว'), findsOneWidget);
      expect(find.text('เรทรีวิว'), findsOneWidget);
      expect(find.text('จาก 8 รีวิว'), findsOneWidget);
      expect(find.text('การถูกใจไม่ถูกใจ'), findsOneWidget);
      expect(find.text('แนวโน้มจำนวนรีวิว'), findsNothing);
      expect(find.text('เมนูยอดนิยม'), findsNothing);
      expect(find.text('ผู้เข้าชม'), findsNothing);

      final reviewCardSize = tester.getSize(
        find.byKey(const Key('owner_review_rating_card')),
      );
      expect(reviewCardSize.width, greaterThan(480));
    },
  );

  testWidgets(
    'OwnerStatsScreen displays swipe trend with likes and dislikes line chart',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ownerReviewStatsProvider.overrideWith(
              (ref, query) async => const OwnerReviewStats(
                totalReviews: 12,
                averageRating: 4.8,
                fiveStarReviews: 10,
                ratingCounts: {1: 0, 2: 0, 3: 0, 4: 2, 5: 10},
                totalLikes: 25,
                totalDislikes: 4,
                swipeTrend: [
                  OwnerSwipePoint(label: '1/10', likes: 5, dislikes: 1),
                  OwnerSwipePoint(label: '2/10', likes: 8, dislikes: 0),
                  OwnerSwipePoint(label: '3/10', likes: 12, dislikes: 3),
                ],
              ),
            ),
          ],
          child: const MaterialApp(
            home: OwnerStatsScreen(
              restaurantId: 'restaurant-1',
              restaurantName: 'ร้านทดสอบ',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('การถูกใจไม่ถูกใจ'), findsOneWidget);
      expect(find.text('ถูกใจ 25'), findsOneWidget);
      expect(find.text('ไม่ถูกใจ 4'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    },
  );
}
