import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/review_model.dart';

/// Service responsible for fetching and submitting restaurant reviews to Supabase `reviews` table
class ReviewService {
  /// Safely checks if Supabase client is initialized
  static bool get isSupabaseAvailable {
    try {
      Supabase.instance.client;
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Resolves current authenticated or database user ID
  static Future<String?> getCurrentUserId() async {
    if (!isSupabaseAvailable) return null;
    try {
      final client = Supabase.instance.client;
      final authUser = client.auth.currentUser;
      if (authUser != null) {
        return authUser.id;
      }

      // Check users table fallback for active local user
      try {
        final userRow =
            await client.from('users').select('id').limit(1).maybeSingle();
        if (userRow != null && userRow['id'] != null) {
          return userRow['id'].toString();
        }
      } catch (_) {}
    } catch (e) {
      debugPrint('Note: Error resolving current user for review: $e');
    }
    return null;
  }

  /// Fetches reviews for a given restaurant from `reviews` table
  static Future<List<ReviewModel>> fetchReviewsForRestaurant(
      String restaurantId) async {
    if (!isSupabaseAvailable) return [];

    try {
      final client = Supabase.instance.client;
      dynamic response;

      // 1. Try querying with joined user details
      try {
        response = await client
            .from('reviews')
            .select('*, users(id, first_name, last_name, email, image_url)')
            .eq('restaurant_id', restaurantId)
            .order('create_at', ascending: false);
      } catch (e) {
        debugPrint('Note: Querying reviews with joined users failed, trying plain select: $e');
        // 2. Fallback to plain select
        response = await client
            .from('reviews')
            .select('*')
            .eq('restaurant_id', restaurantId)
            .order('create_at', ascending: false);
      }

      if (response != null && response is List) {
        return response
            .map((item) =>
                ReviewModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
    } catch (e) {
      debugPrint('Note: Error fetching reviews for restaurant $restaurantId: $e');
    }
    return [];
  }

  /// Submits a new review to Supabase `reviews` table
  static Future<ReviewModel?> submitReview({
    required String restaurantId,
    required double rating,
    required String comment,
    String? photoUrl,
    String? explicitUserId,
    String? explicitUserName,
  }) async {
    final now = DateTime.now();

    // If Supabase not initialized (e.g. unit tests or offline demo), return local simulated review
    if (!isSupabaseAvailable) {
      debugPrint('Note: Supabase not initialized, creating offline simulated review.');
      return ReviewModel(
        id: 'local_rev_${now.millisecondsSinceEpoch}',
        restaurantId: restaurantId,
        userId: explicitUserId ?? 'local_user',
        userName: explicitUserName ?? 'นักชิม Mealmate',
        rating: rating,
        comment: comment,
        photoUrl: photoUrl,
        createdAt: now,
      );
    }

    try {
      final client = Supabase.instance.client;
      final userId = explicitUserId ?? await getCurrentUserId();
      if (userId == null) {
        debugPrint('Note: No user ID resolved for review submission.');
        return null;
      }

      final nowIso = now.toIso8601String();
      final payload = <String, dynamic>{
        'restaurant_id': restaurantId,
        'user_id': userId,
        'rating': rating.round().clamp(1, 5),
        'comment': comment,
        'create_at': nowIso,
      };

      if (photoUrl != null && photoUrl.trim().isNotEmpty) {
        payload['photo_url'] = photoUrl.trim();
      }

      dynamic inserted;
      try {
        inserted = await client
            .from('reviews')
            .insert(payload)
            .select('*, users(id, first_name, last_name, email, image_url)')
            .maybeSingle();
      } catch (e) {
        debugPrint('Note: Insert with users join failed, falling back to plain insert select: $e');
        inserted = await client
            .from('reviews')
            .insert(payload)
            .select('*')
            .maybeSingle();
      }

      if (inserted != null) {
        return ReviewModel.fromJson(Map<String, dynamic>.from(inserted));
      }

      // Fallback return if select didn't return payload
      return ReviewModel(
        id: 'rev_${now.millisecondsSinceEpoch}',
        restaurantId: restaurantId,
        userId: userId,
        userName: explicitUserName ?? 'นักชิม Mealmate',
        rating: rating,
        comment: comment,
        photoUrl: photoUrl,
        createdAt: now,
      );
    } catch (e) {
      debugPrint('Note: Error submitting review to Supabase: $e');
      return null;
    }
  }

  /// Calculates average rating from a list of reviews
  static double calculateAverageRating(List<ReviewModel> reviews, {double defaultRating = 4.5}) {
    if (reviews.isEmpty) return defaultRating;
    final total = reviews.fold<double>(0.0, (sum, r) => sum + r.rating);
    final avg = total / reviews.length;
    return double.parse(avg.toStringAsFixed(1));
  }
}
