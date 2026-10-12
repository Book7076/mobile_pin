import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

typedef OwnerStatsQuery = ({String restaurantId, int days});

class OwnerReviewPoint {
  final String label;
  final int count;

  const OwnerReviewPoint({required this.label, required this.count});
}

class OwnerSwipePoint {
  final String label;
  final int likes;
  final int dislikes;

  const OwnerSwipePoint({
    required this.label,
    required this.likes,
    required this.dislikes,
  });
}

class OwnerReviewStats {
  final int totalReviews;
  final double averageRating;
  final int fiveStarReviews;
  final Map<int, int> ratingCounts;
  final List<OwnerReviewPoint> trend;
  final List<OwnerSwipePoint> swipeTrend;
  final int totalLikes;
  final int totalDislikes;

  const OwnerReviewStats({
    required this.totalReviews,
    required this.averageRating,
    required this.fiveStarReviews,
    required this.ratingCounts,
    this.trend = const [],
    this.swipeTrend = const [],
    this.totalLikes = 0,
    this.totalDislikes = 0,
  });
}

class OwnerStatsService {
  final SupabaseClient _client;

  const OwnerStatsService(this._client);

  Future<OwnerReviewStats> fetchReviewStats({
    required String restaurantId,
    required int days,
  }) async {
    if (restaurantId.trim().isEmpty) {
      throw ArgumentError.value(restaurantId, 'restaurantId');
    }

    final now = DateTime.now();
    final start = days == 1
        ? DateTime(now.year, now.month, now.day)
        : DateTime(
            now.year,
            now.month,
            now.day,
          ).subtract(Duration(days: days - 1));

    // Resolve restaurant ID if not a UUID
    var effectiveRestaurantId = restaurantId;
    if (!effectiveRestaurantId.contains('-')) {
      try {
        final res = await _client
            .from('restaurants')
            .select('id')
            .ilike('name', '%$restaurantId%')
            .limit(1)
            .maybeSingle();
        if (res != null && res['id'] != null) {
          effectiveRestaurantId = res['id'].toString();
        }
      } catch (_) {}
    }

    // 1. Fetch Review Rows
    final rows = await _fetchRows(
      restaurantId: effectiveRestaurantId,
      start: start.toUtc(),
    );

    final ratingCounts = <int, int>{
      for (var star = 1; star <= 5; star++) star: 0,
    };
    var ratingSum = 0.0;
    final dates = <DateTime>[];

    for (final row in rows) {
      final rating = (row['rating'] as num?)?.toDouble();
      if (rating == null) continue;

      final roundedRating = rating.round().clamp(1, 5);
      ratingCounts[roundedRating] = ratingCounts[roundedRating]! + 1;
      ratingSum += rating;

      final rawDate = row['created_at'] ?? row['create_at'];
      final parsedDate = DateTime.tryParse(rawDate?.toString() ?? '');
      if (parsedDate != null) dates.add(parsedDate.toLocal());
    }

    // 2. Fetch Swipe Rows (Likes vs Dislikes from Supabase `swipes` table)
    final swipeRows = await _fetchSwipeRows(
      restaurantId: effectiveRestaurantId,
      start: start.toUtc(),
    );

    final swipeItems = <({DateTime date, String direction})>[];
    for (final sRow in swipeRows) {
      final dir = sRow['direction']?.toString().toLowerCase() ?? 'right';
      final rawDate = sRow['created_at'];
      final parsedDate = DateTime.tryParse(rawDate?.toString() ?? '');
      if (parsedDate != null) {
        swipeItems.add((date: parsedDate.toLocal(), direction: dir));
      }
    }

    final totalLikes = swipeItems.where((s) => s.direction == 'right').length;
    final totalDislikes = swipeItems.where((s) => s.direction == 'left').length;

    final total = ratingCounts.values.fold<int>(0, (sum, value) => sum + value);
    return OwnerReviewStats(
      totalReviews: total,
      averageRating: total == 0 ? 0 : ratingSum / total,
      fiveStarReviews: ratingCounts[5]!,
      ratingCounts: Map.unmodifiable(ratingCounts),
      trend: List.unmodifiable(_buildTrend(dates, start, days)),
      swipeTrend: List.unmodifiable(_buildSwipeTrend(swipeItems, start, days)),
      totalLikes: totalLikes,
      totalDislikes: totalDislikes,
    );
  }

  Future<List<Map<String, dynamic>>> _fetchRows({
    required String restaurantId,
    required DateTime start,
  }) async {
    try {
      final response = await _client
          .from('reviews')
          .select('rating, created_at')
          .eq('restaurant_id', restaurantId)
          .gte('created_at', start.toIso8601String());
      return List<Map<String, dynamic>>.from(response);
    } catch (_) {
      try {
        final response = await _client
            .from('reviews')
            .select('rating, create_at')
            .eq('restaurant_id', restaurantId)
            .gte('create_at', start.toIso8601String());
        return List<Map<String, dynamic>>.from(response);
      } catch (e) {
        debugPrint('Note: Error querying reviews for owner stats: $e');
        return [];
      }
    }
  }

  Future<List<Map<String, dynamic>>> _fetchSwipeRows({
    required String restaurantId,
    required DateTime start,
  }) async {
    try {
      final response = await _client
          .from('swipes')
          .select('direction, created_at')
          .eq('restaurant_id', restaurantId)
          .gte('created_at', start.toIso8601String());
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Note: Error querying swipes for owner stats: $e');
      return [];
    }
  }

  List<OwnerReviewPoint> _buildTrend(
    List<DateTime> dates,
    DateTime startUtc,
    int days,
  ) {
    final start = startUtc.toLocal();
    if (days == 1) {
      const hours = [0, 4, 8, 12, 16, 20];
      return [
        for (var index = 0; index < hours.length; index++)
          OwnerReviewPoint(
            label: '${hours[index].toString().padLeft(2, '0')}:00',
            count: dates.where((date) {
              final nextHour = index + 1 < hours.length ? hours[index + 1] : 24;
              return date.hour >= hours[index] && date.hour < nextHour;
            }).length,
          ),
      ];
    }

    return [
      for (var offset = 0; offset < days; offset++)
        (() {
          final date = start.add(Duration(days: offset));
          return OwnerReviewPoint(
            label: '${date.day}/${date.month}',
            count: dates
                .where(
                  (item) =>
                      item.year == date.year &&
                      item.month == date.month &&
                      item.day == date.day,
                )
                .length,
          );
        })(),
    ];
  }

  List<OwnerSwipePoint> _buildSwipeTrend(
    List<({DateTime date, String direction})> swipeItems,
    DateTime startUtc,
    int days,
  ) {
    final start = startUtc.toLocal();
    if (days == 1) {
      const hours = [0, 4, 8, 12, 16, 20];
      return [
        for (var index = 0; index < hours.length; index++)
          (() {
            final nextHour = index + 1 < hours.length ? hours[index + 1] : 24;
            final matches = swipeItems.where((item) {
              return item.date.hour >= hours[index] && item.date.hour < nextHour;
            });
            return OwnerSwipePoint(
              label: '${hours[index].toString().padLeft(2, '0')}:00',
              likes: matches.where((item) => item.direction == 'right').length,
              dislikes: matches.where((item) => item.direction == 'left').length,
            );
          })(),
      ];
    }

    return [
      for (var offset = 0; offset < days; offset++)
        (() {
          final date = start.add(Duration(days: offset));
          final matches = swipeItems.where(
            (item) =>
                item.date.year == date.year &&
                item.date.month == date.month &&
                item.date.day == date.day,
          );
          return OwnerSwipePoint(
            label: '${date.day}/${date.month}',
            likes: matches.where((item) => item.direction == 'right').length,
            dislikes: matches.where((item) => item.direction == 'left').length,
          );
        })(),
    ];
  }
}

final ownerReviewStatsProvider = FutureProvider.autoDispose
    .family<OwnerReviewStats, OwnerStatsQuery>(
      (ref, query) => OwnerStatsService(
        Supabase.instance.client,
      ).fetchReviewStats(restaurantId: query.restaurantId, days: query.days),
    );
