import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import '../core/mock_data.dart';
import '../main.dart';
import '../models/filter_criteria_model.dart';
import '../models/restaurant_model.dart';
import '../models/review_model.dart';
import '../models/swipe_session_model.dart';
import '../services/review_service.dart';
import '../services/swipe_session_service.dart';

// 1. Master Restaurants List
class RestaurantsNotifier extends StateNotifier<List<RestaurantModel>> {
  RestaurantsNotifier() : super(MockData.restaurants) {
    loadRestaurants();
  }

  Future<void> loadRestaurants() async {
    try {
      dynamic response;
      try {
        response = await supabase
            .from('restaurants')
            .select('*, restaurant_images(*), cuisine_types(*), menu_items(*)')
            .order('crated_at', ascending: false);
      } catch (_) {
        try {
          response = await supabase
              .from('restaurants')
              .select(
                '*, restaurant_images(*), cuisine_types(*), menu_items(*)',
              )
              .order('created_at', ascending: false);
        } catch (_) {
          try {
            response = await supabase
                .from('restaurants')
                .select(
                  '*, restaurant_images(*), cuisine_types(*), menu_items(*)',
                );
          } catch (_) {
            try {
              response = await supabase
                  .from('restaurants')
                  .select('*, restaurant_images(*)');
            } catch (_) {
              response = await supabase.from('restaurants').select();
            }
          }
        }
      }

      if (response != null && response is List && response.isNotEmpty) {
        final List<RestaurantModel> loaded = [];
        for (final item in response) {
          loaded.add(RestaurantModel.fromJson(Map<String, dynamic>.from(item)));
        }
        if (loaded.isNotEmpty) {
          state = loaded;
        }
      }
    } catch (e) {
      debugPrint('Note: Error loading restaurants from Supabase: $e');
    }
  }

  Future<void> addRestaurant(RestaurantModel restaurant) async {
    state = [restaurant, ...state];
    try {
      await supabase.from('restaurants').insert(restaurant.toJson());
    } catch (_) {}
  }

  Future<void> updateRestaurant(RestaurantModel updated) async {
    state = [
      for (final r in state)
        if (r.id == updated.id) updated else r,
    ];
    try {
      await supabase
          .from('restaurants')
          .update(updated.toJson())
          .eq('id', updated.id);
    } catch (_) {}
  }

  Future<void> updateRestaurantStatus(
    String id,
    String newStatus, {
    String? rejectionReason,
  }) async {
    state = [
      for (final r in state)
        if (r.id == id)
          r.copyWith(status: newStatus, rejectionReason: rejectionReason)
        else
          r,
    ];
    try {
      final updateData = <String, dynamic>{'status': newStatus};
      if (rejectionReason != null) {
        updateData['rejection_reason'] = rejectionReason;
      }
      await supabase.from('restaurants').update(updateData).eq('id', id);
    } catch (_) {}
  }

  void toggleFavorite(String id) {
    state = [
      for (final r in state)
        if (r.id == id) r.copyWith(isFavorite: !r.isFavorite) else r,
    ];
  }

  void addDish(String restaurantId, SignatureDish dish) {
    state = [
      for (final r in state)
        if (r.id == restaurantId)
          r.copyWith(signatureDishes: [...r.signatureDishes, dish])
        else
          r,
    ];
  }

  void removeDish(String restaurantId, int dishIndex) {
    state = [
      for (final r in state)
        if (r.id == restaurantId)
          r.copyWith(
            signatureDishes: [
              for (int i = 0; i < r.signatureDishes.length; i++)
                if (i != dishIndex) r.signatureDishes[i],
            ],
          )
        else
          r,
    ];
  }
}

final restaurantsProvider =
    StateNotifierProvider<RestaurantsNotifier, List<RestaurantModel>>((ref) {
      return RestaurantsNotifier();
    });

// 2. Filter Criteria Provider
final filterCriteriaProvider = StateProvider<FilterCriteriaModel>(
  (ref) => FilterCriteriaModel(),
);

// 3. Filtered Restaurants for Swipe & Discover
bool checkCategoryMatch(String selectedCat, List<String> restaurantCategories) {
  final normSelected = selectedCat.trim().toLowerCase();
  for (final cat in restaurantCategories) {
    if (cat.trim().toLowerCase() == normSelected) return true;
  }

  // Category alias mappings between Flow categories and database cuisine types
  const aliases = <String, List<String>>{
    'thai': [
      'อาหารไทย',
      'thai',
      'somtum_isan',
      'northern_thai',
      'southern_thai',
      'a_la_carte',
      'street_food',
      'made_to_order',
      'อาหารอีสาน',
      'อาหารเหนือ',
      'อาหารใต้',
    ],
    'อาหารไทย': [
      'thai',
      'somtum_isan',
      'northern_thai',
      'southern_thai',
      'a_la_carte',
      'street_food',
      'made_to_order',
      'อาหารอีสาน',
      'อาหารเหนือ',
      'อาหารใต้',
    ],
    'japanese': ['อาหารญี่ปุ่น', 'japanese'],
    'อาหารญี่ปุ่น': ['japanese'],
    'chinese': ['อาหารจีน', 'chinese'],
    'อาหารจีน': ['chinese'],
    'korean': ['อาหารเกาหลี', 'korean'],
    'อาหารเกาหลี': ['korean'],
    'shabu_hotpot': [
      'ชาบู/ฮอกพอด',
      'ปิ้งย่าง/ชาบู',
      'shabu_grill',
      'mookata',
      'buffet',
      'shabu_hotpot',
      'หมูกระทะ',
      'ชาบู / ปิ้งย่าง / หมูกระทะ',
    ],
    'ชาบู/ฮอกพอด': [
      'shabu_hotpot',
      'ปิ้งย่าง/ชาบู',
      'shabu_grill',
      'mookata',
      'buffet',
      'หมูกระทะ',
    ],
    'mookata': [
      'หมูกระทะ',
      'ปิ้งย่าง/ชาบู',
      'shabu_grill',
      'shabu_hotpot',
      'buffet',
      'mookata',
      'ชาบู/ฮอกพอด',
      'ชาบู / ปิ้งย่าง / หมูกระทะ',
    ],
    'หมูกระทะ': [
      'mookata',
      'ปิ้งย่าง/ชาบู',
      'shabu_grill',
      'shabu_hotpot',
      'buffet',
      'ชาบู/ฮอกพอด',
    ],
    'healthy': [
      'อาหารสุขภาพ',
      'อาหารมังสวิรัติ',
      'อาหารฮาลาล',
      'healthy_clean',
      'healthy',
      'vegetarian',
      'halal',
      'อาหารคลีน / สุขภาพ',
    ],
    'อาหารสุขภาพ': [
      'healthy',
      'อาหารมังสวิรัติ',
      'อาหารฮาลาล',
      'healthy_clean',
      'vegetarian',
    ],
    'fast_food': [
      'ฟาสต์ฟู้ด',
      'อาหารฟาสฟู้ด',
      'อาหารอิตาเลียน',
      'fastfood',
      'fast_food',
      'italian_western',
      'ฟาสต์ฟู้ด / เบอร์เกอร์',
    ],
    'ฟาสต์ฟู้ด': [
      'fast_food',
      'อาหารฟาสฟู้ด',
      'อาหารอิตาเลียน',
      'fastfood',
      'italian_western',
    ],
    'noodles': ['ก๋วยเตี๋ยว', 'ก๋วยเตี๋ยว / บะหมี่', 'noodles', 'บะหมี่'],
    'ก๋วยเตี๋ยว': ['noodles', 'ก๋วยเตี๋ยว / บะหมี่', 'บะหมี่'],
    'a_la_carte': [
      'อาหารตามสั่ง',
      'ตามสั่ง / สตรีทฟู้ด',
      'made_to_order',
      'street_food',
      'a_la_carte',
      'thai',
      'อาหารไทย',
      'อาหารเช้า',
      'breakfast',
    ],
    'อาหารตามสั่ง': [
      'a_la_carte',
      'made_to_order',
      'street_food',
      'thai',
      'ตามสั่ง / สตรีทฟู้ด',
    ],
    'dessert_bakery': [
      'ขนมหวาน/เบเกอรี่',
      'ของหวาน',
      'อาหารเช้า',
      'cafe_dessert',
      'dessert_bakery',
      'breakfast',
      'คาเฟ่ / ของหวาน',
      'เบเกอรี่',
    ],
    'ขนมหวาน/เบเกอรี่': [
      'dessert_bakery',
      'ของหวาน',
      'อาหารเช้า',
      'cafe_dessert',
      'เบเกอรี่',
    ],
    'cafe_beverage': [
      'คาเฟ่/เครื่องดื่ม',
      'คาเฟ่',
      'cafe_dessert',
      'cafe_beverage',
      'cafe',
      'คาเฟ่ / ของหวาน',
      'เครื่องดื่ม',
    ],
    'คาเฟ่/เครื่องดื่ม': [
      'cafe_beverage',
      'คาเฟ่',
      'cafe_dessert',
      'cafe',
      'เครื่องดื่ม',
    ],
    'italian_western': [
      'อาหารอิตาเลียน',
      'fast_food',
      'italian_western',
      'พิซซ่า',
      'สเต็ก',
    ],
    'อาหารอิตาเลียน': ['italian_western', 'fast_food', 'พิซซ่า', 'สเต็ก'],
    'somtum_isan': [
      'อาหารอีสาน',
      'somtum_isan',
      'thai',
      'อาหารไทย',
      'ส้มตำ / ยำ / อาหารอีสาน',
      'ส้มตำ',
    ],
    'อาหารอีสาน': ['somtum_isan', 'thai', 'ส้มตำ'],
    'northern_thai': ['อาหารเหนือ', 'northern_thai', 'thai', 'อาหารไทย'],
    'อาหารเหนือ': ['northern_thai', 'อาหารเหนือ', 'thai', 'อาหารไทย'],
    'southern_thai': ['อาหารใต้', 'southern_thai', 'thai', 'อาหารไทย'],
    'อาหารใต้': ['southern_thai', 'อาหารใต้', 'thai', 'อาหารไทย'],
  };

  final mapped = aliases[normSelected] ?? aliases[selectedCat];
  if (mapped != null) {
    for (final alias in mapped) {
      final normAlias = alias.trim().toLowerCase();
      for (final cat in restaurantCategories) {
        if (cat.trim().toLowerCase() == normAlias) return true;
      }
    }
  }
  return false;
}

// Backward-compatible alias
bool _checkCategoryMatch(
  String selectedCat,
  List<String> restaurantCategories,
) => checkCategoryMatch(selectedCat, restaurantCategories);

/// Converts any category slug or name into a clean Thai display label
String formatCategoryDisplayName(String cat) {
  final norm = cat.trim().toLowerCase();

  for (final fc in AppConstants.flowCategories) {
    if (fc['id']?.toString().toLowerCase() == norm ||
        fc['name']?.toString().toLowerCase() == norm) {
      return fc['name'] as String;
    }
  }

  for (final fc in AppConstants.foodCategories) {
    if (fc['id']?.toString().toLowerCase() == norm) {
      return fc['name'] as String;
    }
  }

  switch (norm) {
    case 'northern_thai':
      return 'อาหารเหนือ';
    case 'southern_thai':
      return 'อาหารใต้';
    case 'somtum_isan':
      return 'อาหารอีสาน';
    case 'street_food':
    case 'made_to_order':
      return 'อาหารตามสั่ง';
    case 'shabu_grill':
      return 'ปิ้งย่าง/ชาบู';
    case 'cafe_dessert':
      return 'คาเฟ่/ของหวาน';
    case 'healthy_clean':
      return 'อาหารสุขภาพ';
    case 'vegetarian':
      return 'อาหารมังสวิรัติ';
    case 'halal':
      return 'อาหารฮาลาล';
    case 'italian_western':
      return 'อาหารอิตาเลียน';
    case 'breakfast':
      return 'อาหารเช้า';
    case 'buffet':
      return 'บุฟเฟต์';
  }

  if (cat.contains(RegExp(r'[\u0E00-\u0E7F]'))) {
    return cat.trim();
  }

  return cat;
}

/// Checks if a restaurant matches a specific cuisine_type_id (1..17) from database
bool doesRestaurantMatchCuisineTypeId(
  RestaurantModel restaurant,
  int cuisineTypeId,
) {
  if (restaurant.cuisineTypeId != null &&
      restaurant.cuisineTypeId == cuisineTypeId) {
    return true;
  }
  final slugs = mapCuisineTypeIdToSlugs(cuisineTypeId);
  final thaiName = mapCuisineTypeIdToName(cuisineTypeId);
  final candidates = [...slugs, thaiName];
  for (final cand in candidates) {
    if (checkCategoryMatch(cand, restaurant.categories)) {
      return true;
    }
  }
  return false;
}

/// Returns the matched Thai category labels that BOTH the restaurant has
/// AND the user selected for this session (from swipe_session_cuisines).
List<String> getMatchedCuisineLabelsForRestaurant(
  RestaurantModel restaurant, {
  List<int>? sessionCuisineTypeIds,
  List<String>? selectedCategories,
}) {
  final matchedNames = <String>[];

  // 1. Primary source: check against sessionCuisineTypeIds (from swipe_session_cuisines)
  if (sessionCuisineTypeIds != null && sessionCuisineTypeIds.isNotEmpty) {
    for (final cid in sessionCuisineTypeIds) {
      if (doesRestaurantMatchCuisineTypeId(restaurant, cid)) {
        final name = mapCuisineTypeIdToName(cid);
        if (!matchedNames.contains(name)) {
          matchedNames.add(name);
        }
      }
    }
    if (matchedNames.isNotEmpty) {
      return matchedNames;
    }
  }

  // 2. Fallback to selectedCategories string list
  if (selectedCategories != null && selectedCategories.isNotEmpty) {
    for (final selectedCat in selectedCategories) {
      if (selectedCat.trim().toLowerCase() == 'all') continue;
      if (checkCategoryMatch(selectedCat, restaurant.categories)) {
        final displayName = formatCategoryDisplayName(selectedCat);
        if (!matchedNames.contains(displayName)) {
          matchedNames.add(displayName);
        }
      }
    }
    if (matchedNames.isNotEmpty) {
      return matchedNames;
    }
  }

  // 3. Fallback to restaurant's primary category
  final fallbackName = formatRestaurantCategory(restaurant);
  return [fallbackName];
}

/// Dynamically formats the category pill under the restaurant name:
/// If the user selected categories in the flow (e.g. "ก๋วยเตี๋ยว" or "อาหารเหนือ"),
/// the badge will display the matched category that the user selected.
/// If no categories were filtered by the user, falls back to the restaurant's primary category.
String formatRestaurantCategory(
  RestaurantModel restaurant, {
  List<String>? selectedCategories,
  List<int>? sessionCuisineTypeIds,
}) {
  if (sessionCuisineTypeIds != null && sessionCuisineTypeIds.isNotEmpty) {
    final matchedNames = <String>[];
    for (final cid in sessionCuisineTypeIds) {
      if (doesRestaurantMatchCuisineTypeId(restaurant, cid)) {
        final name = mapCuisineTypeIdToName(cid);
        if (!matchedNames.contains(name)) {
          matchedNames.add(name);
        }
      }
    }
    if (matchedNames.isNotEmpty) {
      return matchedNames.join('/');
    }
  }

  if (selectedCategories != null && selectedCategories.isNotEmpty) {
    final matchedNames = <String>[];
    for (final selectedCat in selectedCategories) {
      if (selectedCat.trim().toLowerCase() == 'all') continue;
      if (checkCategoryMatch(selectedCat, restaurant.categories)) {
        final displayName = formatCategoryDisplayName(selectedCat);
        if (!matchedNames.contains(displayName)) {
          matchedNames.add(displayName);
        }
      }
    }

    if (matchedNames.isNotEmpty) {
      return matchedNames.join('/');
    }
  }

  // Fallback to restaurant's own categories when no filter criteria was selected
  if (restaurant.id == 'rest_shabu_mouood' ||
      (restaurant.categories.contains('shabu_hotpot') &&
          restaurant.categories.contains('mookata'))) {
    return 'ชาบู/หมูกระทะ';
  }
  if (restaurant.id == 'rest_teds_coffee') {
    return 'ร้านกาแฟ/ขนมหวาน';
  }

  for (final cat in restaurant.categories) {
    if (cat.trim().toLowerCase() == 'all') continue;
    final name = formatCategoryDisplayName(cat);
    if (name.isNotEmpty && name.toLowerCase() != 'all') {
      return name;
    }
  }

  return restaurant.categories.isNotEmpty
      ? formatCategoryDisplayName(restaurant.categories.first)
      : 'อาหารทั่วไป';
}

final filteredRestaurantsProvider = Provider<List<RestaurantModel>>((ref) {
  final allRestaurants = ref.watch(restaurantsProvider);
  final criteria = ref.watch(filterCriteriaProvider);
  final session = ref.watch(swipeSessionProvider);

  return allRestaurants.where((restaurant) {
    // Only approved restaurants in discovery/swipe
    if (restaurant.status != 'approved') return false;

    // Filter by session cuisines (from swipe_session_cuisines - real source of truth)
    // เอาร้านที่มีประเภทใดประเภทหนึ่งตรงกับที่ผู้ใช้เลือก
    if (session.sessionCuisineTypeIds.isNotEmpty) {
      final matchesAnySessionCuisine = session.sessionCuisineTypeIds.any(
        (cid) => doesRestaurantMatchCuisineTypeId(restaurant, cid),
      );
      if (!matchesAnySessionCuisine) return false;
    } else if (criteria.selectedCategories.isNotEmpty &&
        !criteria.selectedCategories.contains('all')) {
      if (criteria.matchAllCategories) {
        // AND match: restaurant must contain ALL selected categories
        final hasAll = criteria.selectedCategories.every(
          (cat) => _checkCategoryMatch(cat, restaurant.categories),
        );
        if (!hasAll) return false;
      } else {
        // OR match: restaurant must contain AT LEAST ONE of selected categories
        final hasAny = criteria.selectedCategories.any(
          (cat) => _checkCategoryMatch(cat, restaurant.categories),
        );
        if (!hasAny) return false;
      }
    }

    // Filter by price tier (1, 2, 3)
    if (criteria.selectedPriceTiers.isNotEmpty) {
      if (!criteria.selectedPriceTiers.contains(restaurant.priceLevel)) {
        return false;
      }
    }

    // Filter by max budget (Flow 4)
    if (criteria.maxBudget != null) {
      final budget = criteria.maxBudget!;
      if (restaurant.signatureDishes.isNotEmpty) {
        // Direct match: has at least one dish within budget
        final hasDirectMatch = restaurant.signatureDishes.any(
          (dish) => dish.price > 0 && dish.price <= budget,
        );
        if (!hasDirectMatch) {
          // If no direct dish, allow slight flexibility (+15% or +10 THB)
          final minDishPrice = restaurant.signatureDishes
              .map((d) => d.price)
              .where((p) => p > 0)
              .fold<int>(999999, (prev, elem) => elem < prev ? elem : prev);

          final tolerance = (budget * 0.15).round();
          if (minDishPrice > budget + (tolerance > 10 ? tolerance : 10)) {
            return false;
          }
        }
      } else {
        if (budget < 100 && restaurant.priceLevel > 1) return false;
        if (budget < 300 && restaurant.priceLevel > 2) return false;
      }
    }

    // Filter by min rating
    if (criteria.minRating > 0 && restaurant.rating < criteria.minRating) {
      return false;
    }

    // Filter by Open Now
    if (criteria.openNowOnly && !restaurant.isOpen) {
      return false;
    }

    // Filter by Scope (all, favorites, visited)
    if (criteria.scope == 'favorites' && !restaurant.isFavorite) {
      return false;
    }

    return true;
  }).toList();
});

// 4. Current Swipe Session Notifier
class SwipeSessionState {
  final List<RestaurantModel> likedRestaurants;
  final List<RestaurantModel> passedRestaurants;
  final RestaurantModel? selectedWinner; // For the "Pick One for Me" feature
  final bool isSessionFinished;
  final String? currentSessionDbId;
  final int? cuisineTypeId; // Fallback backup
  final List<int>
  sessionCuisineTypeIds; // Real data from swipe_session_cuisines
  final double? priceMin;
  final double? priceMax;
  final int targetRestaurantCount;
  final int swipedCount;
  final String status; // 'กำลังใช้', 'เสร็จสิ้น' / 'ปัดเสร็จแล้ว'

  SwipeSessionState({
    this.likedRestaurants = const [],
    this.passedRestaurants = const [],
    this.selectedWinner,
    this.isSessionFinished = false,
    this.currentSessionDbId,
    this.cuisineTypeId,
    this.sessionCuisineTypeIds = const [],
    this.priceMin = 50.0,
    this.priceMax,
    this.targetRestaurantCount = 5,
    this.swipedCount = 0,
    this.status = SwipeSessionModel.statusInProgress,
  });

  bool get isCompleted =>
      isSessionFinished ||
      status == SwipeSessionModel.statusCompleted ||
      status == SwipeSessionModel.statusLegacyCompleted ||
      status == SwipeSessionModel.statusDone;

  SwipeSessionState copyWith({
    List<RestaurantModel>? likedRestaurants,
    List<RestaurantModel>? passedRestaurants,
    RestaurantModel? selectedWinner,
    bool? isSessionFinished,
    String? currentSessionDbId,
    int? cuisineTypeId,
    List<int>? sessionCuisineTypeIds,
    double? priceMin,
    double? priceMax,
    int? targetRestaurantCount,
    int? swipedCount,
    String? status,
  }) {
    return SwipeSessionState(
      likedRestaurants: likedRestaurants ?? this.likedRestaurants,
      passedRestaurants: passedRestaurants ?? this.passedRestaurants,
      selectedWinner: selectedWinner ?? this.selectedWinner,
      isSessionFinished: isSessionFinished ?? this.isSessionFinished,
      currentSessionDbId: currentSessionDbId ?? this.currentSessionDbId,
      cuisineTypeId: cuisineTypeId ?? this.cuisineTypeId,
      sessionCuisineTypeIds:
          sessionCuisineTypeIds ?? this.sessionCuisineTypeIds,
      priceMin: priceMin ?? this.priceMin,
      priceMax: priceMax ?? this.priceMax,
      targetRestaurantCount:
          targetRestaurantCount ?? this.targetRestaurantCount,
      swipedCount: swipedCount ?? this.swipedCount,
      status: status ?? this.status,
    );
  }
}

class SwipeSessionNotifier extends StateNotifier<SwipeSessionState> {
  SwipeSessionNotifier() : super(SwipeSessionState());

  /// Initializes a session in local state and creates record in Supabase `swipe_sessions` and `swipe_session_cuisines`
  Future<String?> initSession({
    int? cuisineTypeId,
    List<int>? cuisineTypeIds,
    double? priceMin = 50.0,
    double? priceMax,
    int targetRestaurantCount = 5,
    String? explicitUserId,
  }) async {
    final effectiveMin = priceMin ?? 50.0;
    final effectiveCuisineIds = <int>[
      if (cuisineTypeIds != null && cuisineTypeIds.isNotEmpty)
        ...cuisineTypeIds
      else if (cuisineTypeId != null)
        cuisineTypeId,
    ];

    final fallbackCuisineId = effectiveCuisineIds.isNotEmpty
        ? effectiveCuisineIds.first
        : cuisineTypeId;

    // Generate/insert in Supabase (Image 4 + swipe_session_cuisines)
    final dbId = await SwipeSessionService.createSession(
      cuisineTypeId: fallbackCuisineId,
      cuisineTypeIds: effectiveCuisineIds,
      priceMin: effectiveMin,
      priceMax: priceMax,
      targetRestaurantCount: targetRestaurantCount,
      explicitUserId: explicitUserId,
    );

    state = state.copyWith(
      currentSessionDbId: dbId,
      cuisineTypeId: fallbackCuisineId,
      sessionCuisineTypeIds: effectiveCuisineIds,
      priceMin: effectiveMin,
      priceMax: priceMax,
      targetRestaurantCount: targetRestaurantCount,
      swipedCount: 0,
      status: SwipeSessionModel.statusInProgress,
    );

    return dbId;
  }

  /// Fetches cuisines for the active session from `swipe_session_cuisines`
  Future<List<int>> loadSessionCuisines(String sessionId) async {
    final ids = await SwipeSessionService.fetchSessionCuisines(sessionId);
    if (ids.isNotEmpty) {
      state = state.copyWith(sessionCuisineTypeIds: ids);
    }
    return ids;
  }

  void like(RestaurantModel restaurant) {
    final updatedLiked = [...state.likedRestaurants, restaurant];
    final isFinished = updatedLiked.length >= 5;
    final newCount = updatedLiked.length;
    final newSwipedCount = state.swipedCount + 1;
    final newStatus = isFinished
        ? SwipeSessionModel.statusCompleted
        : SwipeSessionModel.statusInProgress;

    state = state.copyWith(
      likedRestaurants: updatedLiked,
      targetRestaurantCount: newCount,
      swipedCount: newSwipedCount,
      status: newStatus,
      isSessionFinished: isFinished,
    );

    // Sync to Supabase in background: inserts into `swipes` (Image 1),
    // increments `swiped_count` (Image 4), and inserts into `selected_restaurants` (Image 3)
    if (state.currentSessionDbId != null) {
      SwipeSessionService.recordSwipe(
        sessionId: state.currentSessionDbId,
        restaurantId: restaurant.id,
        direction: SwipeDirection.right,
        currentSwipedCount: state.swipedCount - 1,
      );
    }
  }

  void pass(RestaurantModel restaurant) {
    final newSwipedCount = state.swipedCount + 1;
    state = state.copyWith(
      passedRestaurants: [...state.passedRestaurants, restaurant],
      swipedCount: newSwipedCount,
    );

    if (state.currentSessionDbId != null) {
      SwipeSessionService.recordSwipe(
        sessionId: state.currentSessionDbId,
        restaurantId: restaurant.id,
        direction: SwipeDirection.left,
        currentSwipedCount: state.swipedCount - 1,
      );
    }
  }

  void finishSession() {
    state = state.copyWith(
      isSessionFinished: true,
      status: SwipeSessionModel.statusCompleted,
    );

    if (state.currentSessionDbId != null) {
      SwipeSessionService.completeSession(
        sessionId: state.currentSessionDbId,
        targetRestaurantCount: state.likedRestaurants.length,
        swipedCount: state.swipedCount,
      );
    }
  }

  void setWinner(RestaurantModel restaurant) {
    state = state.copyWith(
      selectedWinner: restaurant,
      status: SwipeSessionModel.statusCompleted,
      isSessionFinished: true,
    );

    // Updates `selected_restaurants`: is_final_choice = true (Image 3)
    // and `swipe_sessions`: status = 'เสร็จสิ้น' (Image 4)
    if (state.currentSessionDbId != null) {
      SwipeSessionService.markFinalChoice(
        sessionId: state.currentSessionDbId,
        restaurantId: restaurant.id,
      );
    }
  }

  void reset() {
    state = SwipeSessionState();
  }
}

final swipeSessionProvider =
    StateNotifierProvider<SwipeSessionNotifier, SwipeSessionState>((ref) {
      return SwipeSessionNotifier();
    });

// 5. Reviews Provider
class ReviewsNotifier extends StateNotifier<List<ReviewModel>> {
  ReviewsNotifier() : super(const []);

  Future<void> loadReviewsForRestaurant(String restaurantId) async {
    try {
      final dbReviews = await ReviewService.fetchReviewsForRestaurant(
        restaurantId,
      );
      if (dbReviews.isNotEmpty) {
        final others = state
            .where((r) => r.restaurantId != restaurantId)
            .toList();
        state = [...dbReviews, ...others];
      }
    } catch (_) {}
  }

  void addReview(ReviewModel review) {
    final filtered = state.where((r) => r.id != review.id).toList();
    state = [review, ...filtered];
  }

  List<ReviewModel> getReviewsForRestaurant(String restaurantId) {
    return state.where((r) => r.restaurantId == restaurantId).toList();
  }
}

final reviewsProvider =
    StateNotifierProvider<ReviewsNotifier, List<ReviewModel>>((ref) {
      return ReviewsNotifier();
    });
