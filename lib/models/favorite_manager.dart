/// In-memory manager for favorite restaurants across screens
class FavoriteManager {
  static final List<Map<String, dynamic>> favorites = [
    {
      'name': 'RawTruckr',
      'category': 'อาหารเกาหลี',
      'price': '฿ 150-350 บาท',
      'rating': 4.4,
      'image': 'assets/images/rawtruckr.jpg',
      'isAsset': true,
      'isBookmarked': true,
    },
    {
      'name': 'ครัวปันเจียง',
      'category': 'อาหารไทย/อาหารตามสั่ง',
      'price': '฿ 60-90 บาท',
      'rating': 4.7,
      'image': 'assets/images/krua_pan_jiang.jpg',
      'isAsset': true,
      'isBookmarked': true,
    },
    {
      'name': 'ก๋วยเตี๋ยวเรือขั้นเทพ',
      'category': 'อาหารไทย/ก๋วยเตี๋ยว',
      'price': '฿ 50-80 บาท',
      'rating': 4.3,
      'image': 'assets/images/boat_noodles.jpg',
      'isAsset': true,
      'isBookmarked': true,
    },
    {
      'name': 'TEDS Coffee & Eatery',
      'category': 'ร้านกาแฟ/ขนมหวาน',
      'price': '฿ 60-150 บาท',
      'rating': 4.9,
      'image': 'assets/images/teds_coffee.jpg',
      'isAsset': true,
      'isBookmarked': true,
    },
  ];

  /// Add restaurant to favorites list
  static void addFavorite(Map<String, dynamic> restaurant) {
    final name = (restaurant['name'] as String?)?.trim().toLowerCase() ?? '';
    if (name.isEmpty) return;
    if (!favorites.any((r) => (r['name'] as String).trim().toLowerCase() == name)) {
      final copy = Map<String, dynamic>.from(restaurant);
      copy['isBookmarked'] = true;
      copy['isFavorite'] = true;
      favorites.insert(0, copy);
    }
  }

  /// Remove restaurant from favorites list by name
  static void removeFavorite(String name) {
    final clean = name.trim().toLowerCase();
    favorites.removeWhere((r) => (r['name'] as String).trim().toLowerCase() == clean);
  }

  /// Check if a restaurant is already bookmarked
  static bool isFavorite(String name) {
    final clean = name.trim().toLowerCase();
    return favorites.any((r) => (r['name'] as String).trim().toLowerCase() == clean);
  }
}
