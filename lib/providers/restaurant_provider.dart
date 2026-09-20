import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/mock_data.dart';
import '../models/filter_criteria_model.dart';
import '../models/restaurant_model.dart';
import '../models/review_model.dart';

// 1. Master Restaurants List
class RestaurantsNotifier extends StateNotifier<List<RestaurantModel>> {
  RestaurantsNotifier() : super(MockData.restaurants);

  void addRestaurant(RestaurantModel restaurant) {
    state = [restaurant, ...state];
  }

  void updateRestaurant(RestaurantModel updated) {
    state = [
      for (final r in state)
        if (r.id == updated.id) updated else r
    ];
  }

  void updateRestaurantStatus(String id, String newStatus) {
    state = [
      for (final r in state)
        if (r.id == id) r.copyWith(status: newStatus) else r
    ];
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
  if (restaurantCategories.contains(selectedCat)) return true;

  // Category alias mappings between Flow categories and restaurant dataset
  const aliases = <String, List<String>>{
    'shabu_hotpot': ['shabu_grill', 'mookata', 'buffet'],
    'mookata': ['shabu_grill', 'shabu_hotpot', 'buffet'],
    'a_la_carte': ['made_to_order', 'street_food', 'thai'],
    'made_to_order': ['a_la_carte', 'street_food'],
    'street_food': ['a_la_carte', 'made_to_order'],
    'cafe_beverage': ['cafe_dessert'],
    'cafe_dessert': ['cafe_beverage', 'dessert_bakery'],
    'dessert_bakery': ['cafe_dessert'],
    'healthy': ['healthy_clean'],
    'healthy_clean': ['healthy'],
    'fast_food': ['fastfood'],
    'fastfood': ['fast_food'],
    'somtum_isan': ['thai', 'street_food'],
  };

  final mapped = aliases[selectedCat];
  if (mapped != null) {
    return mapped.any((alias) => restaurantCategories.contains(alias));
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
      // If restaurant has signature dishes, check if any dish is within budget
      if (restaurant.signatureDishes.isNotEmpty) {
        final hasAffordableDish =
            restaurant.signatureDishes.any((dish) => dish.price <= budget);
        if (!hasAffordableDish) {
          if (budget < 100 && restaurant.priceLevel > 1) return false;
          if (budget < 300 && restaurant.priceLevel > 2) return false;
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

  SwipeSessionState({
    this.likedRestaurants = const [],
    this.passedRestaurants = const [],
    this.selectedWinner,
    this.isSessionFinished = false,
  });

  SwipeSessionState copyWith({
    List<RestaurantModel>? likedRestaurants,
    List<RestaurantModel>? passedRestaurants,
    RestaurantModel? selectedWinner,
    bool? isSessionFinished,
  }) {
    return SwipeSessionState(
      likedRestaurants: likedRestaurants ?? this.likedRestaurants,
      passedRestaurants: passedRestaurants ?? this.passedRestaurants,
      selectedWinner: selectedWinner ?? this.selectedWinner,
      isSessionFinished: isSessionFinished ?? this.isSessionFinished,
    );
  }
}

class SwipeSessionNotifier extends StateNotifier<SwipeSessionState> {
  SwipeSessionNotifier() : super(SwipeSessionState());

  void like(RestaurantModel restaurant) {
    final updatedLiked = [...state.likedRestaurants, restaurant];
    final isFinished = updatedLiked.length >= 5;
    state = state.copyWith(
      likedRestaurants: updatedLiked,
      isSessionFinished: isFinished,
    );
  }

  void pass(RestaurantModel restaurant) {
    state = state.copyWith(
      passedRestaurants: [...state.passedRestaurants, restaurant],
    );
  }

  void finishSession() {
    state = state.copyWith(isSessionFinished: true);
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
  ReviewsNotifier() : super(MockData.reviews);

  void addReview(ReviewModel review) {
    state = [review, ...state];
  }

  List<ReviewModel> getReviewsForRestaurant(String restaurantId) {
    return state.where((r) => r.restaurantId == restaurantId).toList();
  }
}

final reviewsProvider =
    StateNotifierProvider<ReviewsNotifier, List<ReviewModel>>((ref) {
  return ReviewsNotifier();
});
