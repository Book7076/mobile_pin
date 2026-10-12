import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/swipe_session_model.dart';

/// Database service for interacting with Supabase `swipe_sessions` table
class SwipeSessionService {
  /// Safely resolves the current authenticated user's ID
  static Future<String?> getCurrentUserId() async {
    try {
      final client = Supabase.instance.client;
      final authUser = client.auth.currentUser;
      if (authUser != null) {
        return authUser.id;
      }

      // Fallback: check users table if any user exists
      try {
        final userRow =
            await client.from('users').select('id').limit(1).maybeSingle();
        if (userRow != null && userRow['id'] != null) {
          return userRow['id'].toString();
        }
      } catch (_) {}
    } catch (e) {
      debugPrint('Note: Supabase not initialized or user unavailable: $e');
    }
    return null;
  }

  /// Creates a new swipe session record in `swipe_sessions`
  static Future<String> createSession({
    int? cuisineTypeId,
    double? priceMin,
    double? priceMax,
    String? explicitUserId,
  }) async {
    final generatedId = generateClientUuidV4();

    try {
      final client = Supabase.instance.client;
      final userId = explicitUserId ?? await getCurrentUserId();

      final payload = <String, dynamic>{
        'id': generatedId,
        'cuisine_type_id': cuisineTypeId,
        'price_min': priceMin,
        'price_max': priceMax,
        'target_restaurant_count': 0,
        'status': SwipeSessionModel.statusInProgress, // 'กำลังใช้'
        'created_at': DateTime.now().toIso8601String(),
      };

      if (userId != null) {
        payload['user_id'] = userId;
      }

      final res = await client
          .from('swipe_sessions')
          .insert(payload)
          .select()
          .maybeSingle();

      if (res != null && res['id'] != null) {
        debugPrint('Swipe session created in Supabase with id: ${res['id']}');
        return res['id'].toString();
      }
    } catch (e) {
      debugPrint('Error creating swipe session in Supabase (fallback to local id): $e');
    }

    return generatedId;
  }

  /// Updates progress for an active swipe session
  static Future<void> updateSession({
    required String? sessionId,
    required int targetRestaurantCount,
    required String status,
  }) async {
    if (sessionId == null || sessionId.isEmpty) return;

    try {
      final client = Supabase.instance.client;
      await client.from('swipe_sessions').update({
        'target_restaurant_count': targetRestaurantCount,
        'status': status,
      }).eq('id', sessionId);
      debugPrint('Swipe session $sessionId updated: count=$targetRestaurantCount, status=$status');
    } catch (e) {
      debugPrint('Error updating swipe session in Supabase: $e');
    }
  }

  /// Completes a swipe session ('ปัดเสร็จแล้ว')
  static Future<void> completeSession({
    required String? sessionId,
    required int targetRestaurantCount,
  }) async {
    await updateSession(
      sessionId: sessionId,
      targetRestaurantCount: targetRestaurantCount,
      status: SwipeSessionModel.statusCompleted,
    );
  }
}
