import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// In-memory manager and Supabase synchronizer for favorite restaurants
class FavoriteManager {
  /// Default in-memory favorites list (used for offline mode, previews, and tests)
  static final List<Map<String, dynamic>> favorites = [
    {
      'id': '0d22ab1d-70aa-4783-b7f7-645e9040a71d',
      'restaurant_id': '0d22ab1d-70aa-4783-b7f7-645e9040a71d',
      'name': 'RawTruckr',
      'category': 'อาหารเกาหลี',
      'price': '฿ 150-350 บาท',
      'rating': 4.4,
      'image': 'assets/images/rawtruckr.jpg',
      'isAsset': true,
      'isBookmarked': true,
      'isFavorite': true,
    },
    {
      'id': 'cc70d6f7-7e55-44a1-b808-f0c07864f7ec',
      'restaurant_id': 'cc70d6f7-7e55-44a1-b808-f0c07864f7ec',
      'name': 'ครัวปันเจียง',
      'category': 'อาหารไทย/อาหารตามสั่ง',
      'price': '฿ 60-90 บาท',
      'rating': 4.7,
      'image': 'assets/images/krua_pan_jiang.jpg',
      'isAsset': true,
      'isBookmarked': true,
      'isFavorite': true,
    },
    {
      'id': '51f4a842-0566-48fd-8db5-516adb8103fe',
      'restaurant_id': '51f4a842-0566-48fd-8db5-516adb8103fe',
      'name': 'ก๋วยเตี๋ยวเรือขั้นเทพ',
      'category': 'อาหารไทย/ก๋วยเตี๋ยว',
      'price': '฿ 50-80 บาท',
      'rating': 4.3,
      'image': 'assets/images/boat_noodles.jpg',
      'isAsset': true,
      'isBookmarked': true,
      'isFavorite': true,
    },
    {
      'id': '9dab41ac-c26d-436d-b4eb-2a38d6b4e28f',
      'restaurant_id': '9dab41ac-c26d-436d-b4eb-2a38d6b4e28f',
      'name': 'TEDS Coffee & Eatery',
      'category': 'ร้านกาแฟ/ขนมหวาน',
      'price': '฿ 60-150 บาท',
      'rating': 4.9,
      'image': 'assets/images/teds_coffee.jpg',
      'isAsset': true,
      'isBookmarked': true,
      'isFavorite': true,
    },
  ];

  static bool _hasLoadedFromSupabase = false;

  /// Check whether Supabase client is initialized and accessible
  static bool get isSupabaseAvailable {
    try {
      return Supabase.instance.client != null;
    } catch (_) {
      return false;
    }
  }

  /// Safely resolves the current user's ID
  static Future<String?> getCurrentUserId() async {
    if (!isSupabaseAvailable) return null;
    try {
      final client = Supabase.instance.client;
      final authUser = client.auth.currentUser;
      if (authUser != null) {
        return authUser.id;
      }

      // Check users table if available
      try {
        final userRow =
            await client.from('users').select('id').limit(1).maybeSingle();
        if (userRow != null && userRow['id'] != null) {
          return userRow['id'].toString();
        }
      } catch (_) {}
    } catch (e) {
      debugPrint('Note: Supabase user resolution notice: $e');
    }
    return null;
  }

  /// Fetches favorites from Supabase `favorites` table for the user
  static Future<List<Map<String, dynamic>>> fetchFavorites({
    String? userId,
    bool forceRefresh = false,
  }) async {
    if (!isSupabaseAvailable) return favorites;

    try {
      final uid = userId ?? await getCurrentUserId();
      if (uid == null) return favorites;

      final client = Supabase.instance.client;
      final response = await client
          .from('favorites')
          .select(
              'id, user_id, restaurant_id, create_at, restaurants(id, name, address, google_maps_url, phone, status, cuisine_type_id, cuisine_types(id, name), restaurant_images(image_url, is_logo, sort_order))')
          .eq('user_id', uid)
          .order('create_at', ascending: false);

      if (response is List) {
        final List<Map<String, dynamic>> loaded = [];
        for (final row in response) {
          final favMap = Map<String, dynamic>.from(row as Map);
          final restMap = favMap['restaurants'] is Map
              ? Map<String, dynamic>.from(favMap['restaurants'] as Map)
              : <String, dynamic>{};

          final restId = favMap['restaurant_id']?.toString() ??
              restMap['id']?.toString() ??
              '';
          final name = restMap['name']?.toString() ?? 'ร้านอาหาร';

          // Determine category
          String category = 'อาหารทั่วไป';
          if (restMap['cuisine_types'] is Map &&
              restMap['cuisine_types']['name'] != null) {
            category = restMap['cuisine_types']['name'].toString();
          } else if (restMap['category'] != null) {
            category = restMap['category'].toString();
          }

          // Determine images
          String imageUrl = '';
          bool isAsset = false;
          if (restMap['restaurant_images'] is List &&
              (restMap['restaurant_images'] as List).isNotEmpty) {
            final imgList =
                (restMap['restaurant_images'] as List).whereType<Map>().toList();

            // Try to find logo or food photo
            final nonLogo = imgList.where((img) {
              final isLogo = img['is_logo'];
              return isLogo == false ||
                  isLogo == 'false' ||
                  isLogo == 0 ||
                  isLogo == '0';
            }).toList();

            if (nonLogo.isNotEmpty) {
              imageUrl = nonLogo.first['image_url']?.toString() ?? '';
            } else {
              imageUrl = imgList.first['image_url']?.toString() ?? '';
            }
          }

          if (imageUrl.isEmpty) {
            imageUrl = 'assets/images/rawtruckr.jpg';
            isAsset = true;
          }

          loaded.add({
            'id': restId,
            'restaurant_id': restId,
            'favorite_id': favMap['id']?.toString(),
            'name': name,
            'category': category,
            'price': restMap['price_range']?.toString() ?? '฿ 100-300 บาท',
            'rating': (restMap['rating'] as num?)?.toDouble() ?? 4.5,
            'image': imageUrl,
            'isAsset': isAsset,
            'isBookmarked': true,
            'isFavorite': true,
            'address': restMap['address']?.toString() ?? '',
            'phone': restMap['phone']?.toString() ?? '',
            'google_maps_url': restMap['google_maps_url']?.toString() ?? '',
          });
        }

        favorites.clear();
        favorites.addAll(loaded);
        _hasLoadedFromSupabase = true;
        return favorites;
      }
    } catch (e) {
      debugPrint('Note: Error fetching favorites from Supabase: $e');
    }
    return favorites;
  }

  /// Add restaurant to favorites list (updates in-memory instantly & syncs to Supabase)
  static void addFavorite(Map<String, dynamic> restaurant, {String? userId}) {
    final name = (restaurant['name'] as String?)?.trim() ?? '';
    final restId = restaurant['id']?.toString() ??
        restaurant['restaurant_id']?.toString() ??
        '';

    if (name.isEmpty && restId.isEmpty) return;

    final existingIndex = favorites.indexWhere((r) {
      final rName = (r['name'] as String?)?.trim().toLowerCase() ?? '';
      final rId = (r['id'] as String?)?.trim().toLowerCase() ?? '';
      final rRestId =
          (r['restaurant_id'] as String?)?.trim().toLowerCase() ?? '';

      if (restId.isNotEmpty && (rId == restId || rRestId == restId)) {
        return true;
      }
      return name.isNotEmpty && rName == name.toLowerCase();
    });

    final copy = Map<String, dynamic>.from(restaurant);
    copy['isBookmarked'] = true;
    copy['isFavorite'] = true;

    if (existingIndex >= 0) {
      favorites[existingIndex] = copy;
    } else {
      favorites.insert(0, copy);
    }

    // Fire async background sync to Supabase
    _syncInsertToSupabase(copy, explicitUserId: userId);
  }

  /// Remove restaurant from favorites list by name or restaurant_id
  static void removeFavorite(String identifier, {String? userId}) {
    final clean = identifier.trim().toLowerCase();
    String? matchedRestaurantId;

    favorites.removeWhere((r) {
      final rName = (r['name'] as String?)?.trim().toLowerCase() ?? '';
      final rId = (r['id'] as String?)?.trim().toLowerCase() ?? '';
      final rRestId =
          (r['restaurant_id'] as String?)?.trim().toLowerCase() ?? '';

      final matches = rName == clean || rId == clean || rRestId == clean;
      if (matches) {
        matchedRestaurantId = (r['restaurant_id'] ?? r['id'])?.toString();
      }
      return matches;
    });

    // Fire async background sync deletion to Supabase
    _syncDeleteFromSupabase(
      identifier: identifier,
      knownRestaurantId: matchedRestaurantId,
      explicitUserId: userId,
    );
  }

  /// Check if a restaurant is already bookmarked (by name or UUID)
  static bool isFavorite(String identifier) {
    final clean = identifier.trim().toLowerCase();
    return favorites.any((r) {
      final rName = (r['name'] as String?)?.trim().toLowerCase() ?? '';
      final rId = (r['id'] as String?)?.trim().toLowerCase() ?? '';
      final rRestId =
          (r['restaurant_id'] as String?)?.trim().toLowerCase() ?? '';
      return rName == clean || rId == clean || rRestId == clean;
    });
  }

  /// Asynchronously checks if restaurant is in Supabase favorites table
  static Future<bool?> checkIsFavoriteInDb(String restaurantId,
      {String? userId}) async {
    if (!isSupabaseAvailable) return null;
    try {
      final uid = userId ?? await getCurrentUserId();
      if (uid == null) return null;

      final client = Supabase.instance.client;
      final row = await client
          .from('favorites')
          .select('id')
          .eq('user_id', uid)
          .eq('restaurant_id', restaurantId)
          .maybeSingle();

      return row != null;
    } catch (e) {
      debugPrint('Note: Error checking favorite in DB: $e');
      return null;
    }
  }

  /// Async background insert to Supabase favorites table
  static Future<void> _syncInsertToSupabase(
    Map<String, dynamic> restaurant, {
    String? explicitUserId,
  }) async {
    if (!isSupabaseAvailable) return;
    try {
      final uid = explicitUserId ?? await getCurrentUserId();
      if (uid == null) return;

      final client = Supabase.instance.client;
      String? restId = restaurant['restaurant_id']?.toString() ??
          restaurant['id']?.toString();

      // If restId is missing or not a UUID, find by restaurant name
      if (restId == null || restId.length < 30) {
        final name = (restaurant['name'] as String?)?.trim() ?? '';
        if (name.isNotEmpty) {
          final found = await client
              .from('restaurants')
              .select('id')
              .ilike('name', name)
              .limit(1)
              .maybeSingle();
          if (found != null && found['id'] != null) {
            restId = found['id'].toString();
          }
        }
      }

      if (restId == null || restId.isEmpty) return;

      // Check if already in favorites
      final existing = await client
          .from('favorites')
          .select('id')
          .eq('user_id', uid)
          .eq('restaurant_id', restId)
          .maybeSingle();

      if (existing == null) {
        await client.from('favorites').insert({
          'user_id': uid,
          'restaurant_id': restId,
        });
      }
    } catch (e) {
      debugPrint('Note: Error syncing insert to Supabase favorites: $e');
    }
  }

  /// Async background delete from Supabase favorites table
  static Future<void> _syncDeleteFromSupabase({
    required String identifier,
    String? knownRestaurantId,
    String? explicitUserId,
  }) async {
    if (!isSupabaseAvailable) return;
    try {
      final uid = explicitUserId ?? await getCurrentUserId();
      if (uid == null) return;

      final client = Supabase.instance.client;
      String? restId = knownRestaurantId;

      // Check if identifier itself is a UUID
      if (restId == null && identifier.length >= 30) {
        restId = identifier;
      }

      // If still missing, query restaurants table by name
      if (restId == null) {
        final found = await client
            .from('restaurants')
            .select('id')
            .ilike('name', identifier.trim())
            .limit(1)
            .maybeSingle();
        if (found != null && found['id'] != null) {
          restId = found['id'].toString();
        }
      }

      if (restId == null || restId.isEmpty) return;

      await client
          .from('favorites')
          .delete()
          .eq('user_id', uid)
          .eq('restaurant_id', restId);
    } catch (e) {
      debugPrint('Note: Error syncing delete from Supabase favorites: $e');
    }
  }
}

