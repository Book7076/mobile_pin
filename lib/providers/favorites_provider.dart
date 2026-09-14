import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/restaurant_model.dart';
import 'restaurant_provider.dart';

// Selected sub-tab in Favorites Screen
final favoriteSubTabProvider = StateProvider<String>((ref) => 'all');

// Provider returning filtered favorites based on the sub-tab
final filteredFavoritesProvider = Provider<List<RestaurantModel>>((ref) {
  final allRestaurants = ref.watch(restaurantsProvider);
  final swipeSession = ref.watch(swipeSessionProvider);
  final subTab = ref.watch(favoriteSubTabProvider);

  // Filter restaurants that are marked favorite or liked
  final favorites = allRestaurants.where((r) => r.isFavorite).toList();

  if (subTab == 'all') {
    return favorites;
  } else if (subTab == 'swiped') {
    // Restaurants matched from current/recent swipe sessions
    final swipedIds = swipeSession.likedRestaurants.map((r) => r.id).toSet();
    return allRestaurants.where((r) => swipedIds.contains(r.id)).toList();
  } else if (subTab == 'saved') {
    // Restaurants manually bookmarked / saved
    return favorites.where((r) => !r.isLiked).toList();
  } else {
    // Filter by specific category (e.g. thai, cafe_dessert, japanese)
    return favorites.where((r) => r.categories.contains(subTab)).toList();
  }
});
