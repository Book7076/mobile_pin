import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/swipe_session_model.dart';

/// Database service for interacting with all 4 swipe flow tables:
/// 1. `swipe_sessions` (Image 4)
/// 2. `swipes` (Image 1)
/// 3. `user_food_preferences` (Image 2)
/// 4. `selected_restaurants` (Image 3)
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

  /// 1. Creates a new session record in `swipe_sessions` (Image 4) with fallback cuisine_type_id,
  /// then immediately inserts all selected cuisine types into `swipe_session_cuisines`.
  /// If the second step fails, rolls back the created session from `swipe_sessions`.
  /// Before creating session, validates that at least 1 cuisine type is selected.
  static Future<String> createSession({
    int? cuisineTypeId,
    List<int>? cuisineTypeIds,
    double? priceMin,
    double? priceMax,
    int targetRestaurantCount = 5,
    String? explicitUserId,
  }) async {
    // Resolve all selected cuisine type IDs
    final effectiveCuisineIds = <int>[
      if (cuisineTypeIds != null && cuisineTypeIds.isNotEmpty)
        ...cuisineTypeIds
      else if (cuisineTypeId != null)
        cuisineTypeId,
    ];

    // Check that at least 1 cuisine type is selected
    if (effectiveCuisineIds.isEmpty) {
      throw ArgumentError('กรุณาเลือกประเภทอาหารอย่างน้อย 1 ประเภทก่อนเริ่มปัด');
    }

    final generatedId = generateClientUuidV4();
    final fallbackFirstCuisineId = effectiveCuisineIds.first;
    String? createdSessionId;

    try {
      final client = Supabase.instance.client;
      final userId = explicitUserId ?? await getCurrentUserId();

      // Step 1: Create swipe_sessions row with fallback cuisine_type_id
      final payload = <String, dynamic>{
        'id': generatedId,
        'cuisine_type_id': fallbackFirstCuisineId,
        'price_min': priceMin ?? 50.0,
        'price_max': priceMax,
        'target_restaurant_count': targetRestaurantCount,
        'swiped_count': 0,
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

      createdSessionId = (res != null && res['id'] != null)
          ? res['id'].toString()
          : generatedId;

      debugPrint('Step 1: Created swipe_sessions row $createdSessionId with fallback cuisine $fallbackFirstCuisineId');

      // Step 2: Insert into swipe_session_cuisines for all selected categories in a single batch
      final cuisinesBatch = effectiveCuisineIds.map((cid) => {
        'session_id': createdSessionId,
        'cuisine_type_id': cid,
      }).toList();

      try {
        await client.from('swipe_session_cuisines').insert(cuisinesBatch);
        debugPrint('Step 2: Successfully saved ${cuisinesBatch.length} cuisines to swipe_session_cuisines for session $createdSessionId');
      } catch (cuisineError) {
        debugPrint('Step 2 FAILED (swipe_session_cuisines insert error): $cuisineError');
        // Rollback: delete the session that was just created to prevent orphan sessions
        try {
          await client.from('swipe_sessions').delete().eq('id', createdSessionId);
          debugPrint('Rollback successful: Deleted orphan swipe_sessions $createdSessionId');
        } catch (deleteError) {
          debugPrint('Rollback error deleting session $createdSessionId: $deleteError');
        }
        rethrow;
      }

      return createdSessionId;
    } catch (e) {
      if (createdSessionId != null) {
        // Step 2 failed after Step 1 was successfully created -> rethrow to notify UI
        rethrow;
      }
      debugPrint('Error creating swipe session in Supabase (fallback to local id): $e');
    }

    return generatedId;
  }

  /// Fetches all cuisine_type_ids for a given session from `swipe_session_cuisines`
  static Future<List<int>> fetchSessionCuisines(String? sessionId) async {
    if (sessionId == null || sessionId.isEmpty) return [];

    try {
      final client = Supabase.instance.client;
      final res = await client
          .from('swipe_session_cuisines')
          .select('cuisine_type_id')
          .eq('session_id', sessionId);

      if (res is List) {
        final ids = res
            .map((row) => (row['cuisine_type_id'] as num?)?.toInt())
            .whereType<int>()
            .toList();
        debugPrint('Fetched ${ids.length} cuisines from swipe_session_cuisines for session $sessionId: $ids');
        return ids;
      }
    } catch (e) {
      debugPrint('Note: Error fetching session cuisines from Supabase: $e');
    }

    return [];
  }

  /// 2. Records an individual swipe in `swipes` (Image 1),
  /// increments `swiped_count` in `swipe_sessions` (Image 4),
  /// and if direction is 'right', records the restaurant in `selected_restaurants` (Image 3)
  static Future<void> recordSwipe({
    required String? sessionId,
    required String restaurantId,
    required String direction, // 'left' or 'right'
    int? currentSwipedCount,
    int? newSwipedCount,
    String? explicitUserId,
  }) async {
    if (sessionId == null || sessionId.isEmpty) return;

    final resolvedSwipedCount =
        newSwipedCount ?? ((currentSwipedCount ?? 0) + 1);

    try {
      final client = Supabase.instance.client;
      final userId = explicitUserId ?? await getCurrentUserId();

      // 2a. Insert row into `swipes` table (Image 1)
      final swipePayload = <String, dynamic>{
        'id': generateClientUuidV4(),
        'session_id': sessionId,
        'restaurant_id': restaurantId,
        'direction': direction,
        'created_at': DateTime.now().toIso8601String(),
      };
      if (userId != null) {
        swipePayload['user_id'] = userId;
      }

      await client.from('swipes').insert(swipePayload);
      debugPrint('Recorded swipe $direction for restaurant $restaurantId in session $sessionId');

      // 2b. Increment `swiped_count` in `swipe_sessions` (Image 4)
      await client.from('swipe_sessions').update({
        'swiped_count': resolvedSwipedCount,
      }).eq('id', sessionId);
      debugPrint('Updated swipe_sessions $sessionId: swiped_count=$resolvedSwipedCount');

      // 2c. If liked (direction == 'right'), insert into `selected_restaurants` (Image 3)
      if (direction == SwipeDirection.right) {
        await client.from('selected_restaurants').insert({
          'id': generateClientUuidV4(),
          'session_id': sessionId,
          'restaurant_id': restaurantId,
          'is_final_choice': false,
        });
        debugPrint('Added $restaurantId to selected_restaurants for session $sessionId');
      }
    } catch (e) {
      debugPrint('Error recording swipe in Supabase: $e');
    }
  }

  /// 3. Marks the chosen restaurant as `is_final_choice = true` in `selected_restaurants` (Image 3)
  /// and updates session `status` to completed ('เสร็จสิ้น') in `swipe_sessions` (Image 4)
  static Future<void> markFinalChoice({
    required String? sessionId,
    required String restaurantId,
  }) async {
    if (sessionId == null || sessionId.isEmpty) return;

    try {
      final client = Supabase.instance.client;

      // 3a. Update `selected_restaurants`: set is_final_choice = true
      await client.from('selected_restaurants').update({
        'is_final_choice': true,
      }).eq('session_id', sessionId).eq('restaurant_id', restaurantId);

      // 3b. Update `swipe_sessions`: status = 'เสร็จสิ้น'
      await client.from('swipe_sessions').update({
        'status': SwipeSessionModel.statusCompleted,
      }).eq('id', sessionId);

      debugPrint('Marked restaurant $restaurantId as final choice and completed session $sessionId');
    } catch (e) {
      debugPrint('Error marking final choice in Supabase: $e');
    }
  }

  /// 4. Updates progress for an active swipe session
  static Future<void> updateSession({
    required String? sessionId,
    required int targetRestaurantCount,
    required String status,
    int? swipedCount,
  }) async {
    if (sessionId == null || sessionId.isEmpty) return;

    try {
      final client = Supabase.instance.client;
      final payload = <String, dynamic>{
        'target_restaurant_count': targetRestaurantCount,
        'status': status,
      };
      if (swipedCount != null) {
        payload['swiped_count'] = swipedCount;
      }

      await client.from('swipe_sessions').update(payload).eq('id', sessionId);
      debugPrint('Swipe session $sessionId updated: count=$targetRestaurantCount, status=$status');
    } catch (e) {
      debugPrint('Error updating swipe session in Supabase: $e');
    }
  }

  /// Completes a swipe session ('เสร็จสิ้น')
  static Future<void> completeSession({
    required String? sessionId,
    required int targetRestaurantCount,
    int? swipedCount,
  }) async {
    await updateSession(
      sessionId: sessionId,
      targetRestaurantCount: targetRestaurantCount,
      swipedCount: swipedCount,
      status: SwipeSessionModel.statusCompleted,
    );
  }

  /// 5. Fetches long-term preferences from `user_food_preferences` (Image 2)
  static Future<List<UserFoodPreferenceModel>> fetchUserFoodPreferences(
      String? userId) async {
    if (userId == null || userId.isEmpty) return [];

    try {
      final client = Supabase.instance.client;
      final res = await client
          .from('user_food_preferences')
          .select()
          .eq('user_id', userId);

      if (res is List) {
        return res
            .map((item) => UserFoodPreferenceModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Note: Error loading user_food_preferences: $e');
    }

    return [];
  }

  /// 6. Saves long-term preference to `user_food_preferences` (Image 2)
  static Future<void> saveUserFoodPreference({
    required String userId,
    required int foodTagId,
    required String prefType, // 'like' or 'dislike'
  }) async {
    try {
      final client = Supabase.instance.client;
      await client.from('user_food_preferences').upsert({
        'id': generateClientUuidV4(),
        'user_id': userId,
        'food_tag_id': foodTagId,
        'pref_type': prefType,
      });
      debugPrint('Saved user food preference: tag=$foodTagId, type=$prefType for user $userId');
    } catch (e) {
      debugPrint('Error saving user food preference in Supabase: $e');
    }
  }
}
