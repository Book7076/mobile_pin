import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
              .select('*, restaurant_images(*), cuisine_types(*), menu_items(*)')
              .order('created_at', ascending: false);
        } catch (_) {
          try {
            response = await supabase
                .from('restaurants')
                .select('*, restaurant_images(*), cuisine_types(*), menu_items(*)');
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
        if (r.id == updated.id) updated else r
    ];
    try {
      await supabase
          .from('restaurants')
          .update(updated.toJson())
          .eq('id', updated.id);
    } catch (_) {}
  }

  Future<void> updateRestaurantStatus(String id, String newStatus, {String? rejectionReason}) async {
    state = [
      for (final r in state)
        if (r.id == id)
          r.copyWith(status: newStatus, rejectionReason: rejectionReason)
        else
          r
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
        if (r.id == id) r.copyWith(isFavorite: !r.isFavorite) else r
    ];
  }

  void addDish(String restaurantId, SignatureDish dish) {
    state = [
      for (final r in state)
        if (r.id == restaurantId)
          r.copyWith(signatureDishes: [...r.signatureDishes, dish])
        else
          r
    ];
  }

  void removeDish(String restaurantId, int dishIndex) {
    state = [
      for (final r in state)
        if (r.id == restaurantId)
          r.copyWith(
            signatureDishes: [
              for (int i = 0; i < r.signatureDishes.length; i++)
                if (i != dishIndex) r.signatureDishes[i]
            ],
          )
        else
          r
    ];
  }
}

final restaurantsProvider =
    StateNotifierProvider<RestaurantsNotifier, List<RestaurantModel>>((ref) {
  return RestaurantsNotifier();
});

// 2. Filter Criteria Provider
final filterCriteriaProvider =
    StateProvider<FilterCriteriaModel>((ref) => FilterCriteriaModel());

// 3. Filtered Restaurants for Swipe & Discover
bool _checkCategoryMatch(String selectedCat, List<String> restaurantCategories) {
  final normSelected = selectedCat.trim().toLowerCase();
  for (final cat in restaurantCategories) {
    if (cat.trim().toLowerCase() == normSelected) return true;
  }

  // Category alias mappings between Flow categories and database cuisine types
  const aliases = <String, List<String>>{
    'thai': ['อาหารไทย', 'thai', 'somtum_isan', 'northern_thai', 'southern_thai', 'a_la_carte', 'street_food', 'made_to_order'],
    'อาหารไทย': ['thai', 'somtum_isan', 'northern_thai', 'southern_thai', 'a_la_carte', 'street_food', 'made_to_order'],
    'japanese': ['อาหารญี่ปุ่น', 'japanese'],
    'อาหารญี่ปุ่น': ['japanese'],
    'chinese': ['อาหารจีน', 'chinese'],
    'อาหารจีน': ['chinese'],
    'korean': ['อาหารเกาหลี', 'korean'],
    'อาหารเกาหลี': ['korean'],
    'shabu_hotpot': ['ชาบู/ฮอกพอด', 'ปิ้งย่าง/ชาบู', 'shabu_grill', 'mookata', 'buffet', 'shabu_hotpot', 'หมูกระทะ', 'ชาบู / ปิ้งย่าง / หมูกระทะ'],
    'ชาบู/ฮอกพอด': ['shabu_hotpot', 'ปิ้งย่าง/ชาบู', 'shabu_grill', 'mookata', 'buffet', 'หมูกระทะ'],
    'mookata': ['หมูกระทะ', 'ปิ้งย่าง/ชาบู', 'shabu_grill', 'shabu_hotpot', 'buffet', 'mookata', 'ชาบู/ฮอกพอด', 'ชาบู / ปิ้งย่าง / หมูกระทะ'],
    'หมูกระทะ': ['mookata', 'ปิ้งย่าง/ชาบู', 'shabu_grill', 'shabu_hotpot', 'buffet', 'ชาบู/ฮอกพอด'],
    'healthy': ['อาหารสุขภาพ', 'อาหารมังสวิรัติ', 'อาหารฮาลาล', 'healthy_clean', 'healthy', 'vegetarian', 'halal', 'อาหารคลีน / สุขภาพ'],
    'อาหารสุขภาพ': ['healthy', 'อาหารมังสวิรัติ', 'อาหารฮาลาล', 'healthy_clean', 'vegetarian'],
    'fast_food': ['ฟาสต์ฟู้ด', 'อาหารฟาสฟู้ด', 'อาหารอิตาเลียน', 'fastfood', 'fast_food', 'italian_western', 'ฟาสต์ฟู้ด / เบอร์เกอร์'],
    'ฟาสต์ฟู้ด': ['fast_food', 'อาหารฟาสฟู้ด', 'อาหารอิตาเลียน', 'fastfood', 'italian_western'],
    'noodles': ['ก๋วยเตี๋ยว', 'ก๋วยเตี๋ยว / บะหมี่', 'noodles'],
    'ก๋วยเตี๋ยว': ['noodles', 'ก๋วยเตี๋ยว / บะหมี่'],
    'a_la_carte': ['อาหารตามสั่ง', 'ตามสั่ง / สตรีทฟู้ด', 'made_to_order', 'street_food', 'a_la_carte', 'thai', 'อาหารไทย', 'อาหารเช้า', 'breakfast'],
    'อาหารตามสั่ง': ['a_la_carte', 'made_to_order', 'street_food', 'thai', 'ตามสั่ง / สตรีทฟู้ด'],
    'dessert_bakery': ['ขนมหวาน/เบเกอรี่', 'ของหวาน', 'อาหารเช้า', 'cafe_dessert', 'dessert_bakery', 'breakfast', 'คาเฟ่ / ของหวาน'],
    'ขนมหวาน/เบเกอรี่': ['dessert_bakery', 'ของหวาน', 'อาหารเช้า', 'cafe_dessert'],
    'cafe_beverage': ['คาเฟ่/เครื่องดื่ม', 'คาเฟ่', 'cafe_dessert', 'cafe_beverage', 'cafe', 'คาเฟ่ / ของหวาน'],
    'คาเฟ่/เครื่องดื่ม': ['cafe_beverage', 'คาเฟ่', 'cafe_dessert', 'cafe'],
    'italian_western': ['อาหารอิตาเลียน', 'fast_food', 'italian_western'],
    'อาหารอิตาเลียน': ['italian_western', 'fast_food'],
    'somtum_isan': ['อาหารอีสาน', 'somtum_isan', 'thai', 'อาหารไทย'],
    'อาหารอีสาน': ['somtum_isan', 'thai'],
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

final filteredRestaurantsProvider = Provider<List<RestaurantModel>>((ref) {
  final allRestaurants = ref.watch(restaurantsProvider);
  final criteria = ref.watch(filterCriteriaProvider);

  return allRestaurants.where((restaurant) {
    // Only approved restaurants in discovery/swipe
    if (restaurant.status != 'approved') return false;

    // Filter by category
    if (criteria.selectedCategories.isNotEmpty &&
        !criteria.selectedCategories.contains('all')) {
      if (criteria.matchAllCategories) {
        // AND match: restaurant must contain ALL selected categories
        final hasAll = criteria.selectedCategories
            .every((cat) => _checkCategoryMatch(cat, restaurant.categories));
        if (!hasAll) return false;
      } else {
        // OR match: restaurant must contain AT LEAST ONE of selected categories
        final hasAny = criteria.selectedCategories
            .any((cat) => _checkCategoryMatch(cat, restaurant.categories));
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
        final hasDirectMatch = restaurant.signatureDishes
            .any((dish) => dish.price > 0 && dish.price <= budget);
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
  final int? cuisineTypeId;
  final double? priceMin;
  final double? priceMax;
  final int targetRestaurantCount;
  final String status; // 'กำลังใช้', 'ปัดเสร็จแล้ว'

  SwipeSessionState({
    this.likedRestaurants = const [],
    this.passedRestaurants = const [],
    this.selectedWinner,
    this.isSessionFinished = false,
    this.currentSessionDbId,
    this.cuisineTypeId,
    this.priceMin = 50.0,
    this.priceMax,
    this.targetRestaurantCount = 0,
    this.status = SwipeSessionModel.statusInProgress,
  });

  SwipeSessionState copyWith({
    List<RestaurantModel>? likedRestaurants,
    List<RestaurantModel>? passedRestaurants,
    RestaurantModel? selectedWinner,
    bool? isSessionFinished,
    String? currentSessionDbId,
    int? cuisineTypeId,
    double? priceMin,
    double? priceMax,
    int? targetRestaurantCount,
    String? status,
  }) {
    return SwipeSessionState(
      likedRestaurants: likedRestaurants ?? this.likedRestaurants,
      passedRestaurants: passedRestaurants ?? this.passedRestaurants,
      selectedWinner: selectedWinner ?? this.selectedWinner,
      isSessionFinished: isSessionFinished ?? this.isSessionFinished,
      currentSessionDbId: currentSessionDbId ?? this.currentSessionDbId,
      cuisineTypeId: cuisineTypeId ?? this.cuisineTypeId,
      priceMin: priceMin ?? this.priceMin,
      priceMax: priceMax ?? this.priceMax,
      targetRestaurantCount:
          targetRestaurantCount ?? this.targetRestaurantCount,
      status: status ?? this.status,
    );
  }
}

class SwipeSessionNotifier extends StateNotifier<SwipeSessionState> {
  SwipeSessionNotifier() : super(SwipeSessionState());

  /// Initializes a session in local state and creates record in Supabase `swipe_sessions` table
  Future<String?> initSession({
    int? cuisineTypeId,
    double? priceMin = 50.0,
    double? priceMax,
    String? explicitUserId,
  }) async {
    final effectiveMin = priceMin ?? 50.0;
    // Generate/insert in Supabase
    final dbId = await SwipeSessionService.createSession(
      cuisineTypeId: cuisineTypeId,
      priceMin: effectiveMin,
      priceMax: priceMax,
      explicitUserId: explicitUserId,
    );

    state = state.copyWith(
      currentSessionDbId: dbId,
      cuisineTypeId: cuisineTypeId,
      priceMin: effectiveMin,
      priceMax: priceMax,
      targetRestaurantCount: 0,
      status: SwipeSessionModel.statusInProgress,
    );

    return dbId;
  }

  void like(RestaurantModel restaurant) {
    final updatedLiked = [...state.likedRestaurants, restaurant];
    final isFinished = updatedLiked.length >= 5;
    final newCount = updatedLiked.length;
    final newStatus = isFinished
        ? SwipeSessionModel.statusCompleted
        : SwipeSessionModel.statusInProgress;

    state = state.copyWith(
      likedRestaurants: updatedLiked,
      targetRestaurantCount: newCount,
      status: newStatus,
      isSessionFinished: isFinished,
    );

    // Sync to Supabase in background
    if (state.currentSessionDbId != null) {
      SwipeSessionService.updateSession(
        sessionId: state.currentSessionDbId,
        targetRestaurantCount: newCount,
        status: newStatus,
      );
      SwipeSessionService.recordSwipe(
        restaurantId: restaurant.id,
        direction: 'right',
        sessionId: state.currentSessionDbId,
      );
    }
  }

  void pass(RestaurantModel restaurant) {
    state = state.copyWith(
      passedRestaurants: [...state.passedRestaurants, restaurant],
    );

    if (state.currentSessionDbId != null) {
      SwipeSessionService.recordSwipe(
        restaurantId: restaurant.id,
        direction: 'left',
        sessionId: state.currentSessionDbId,
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
      );
    }
  }

  void setWinner(RestaurantModel restaurant) {
    state = state.copyWith(selectedWinner: restaurant);
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
      final dbReviews =
          await ReviewService.fetchReviewsForRestaurant(restaurantId);
      if (dbReviews.isNotEmpty) {
        final others =
            state.where((r) => r.restaurantId != restaurantId).toList();
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
