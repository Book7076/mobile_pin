import 'package:flutter_test/flutter_test.dart';
import 'package:pin_mobile/models/favorite_manager.dart';

void main() {
  group('FavoriteManager Unit Tests', () {
    test('FavoriteManager contains initial favorites for preview & offline mode', () {
      expect(FavoriteManager.favorites.isNotEmpty, isTrue);
      expect(FavoriteManager.isFavorite('RawTruckr'), isTrue);
      expect(FavoriteManager.isFavorite('0d22ab1d-70aa-4783-b7f7-645e9040a71d'), isTrue);
    });

    test('addFavorite adds a new restaurant to favorites list and marks isFavorite true', () {
      const testName = 'ร้านก๋วยเตี๋ยวรสเด็ดทดสอบ';
      const testId = '11111111-2222-3333-4444-555555555555';

      expect(FavoriteManager.isFavorite(testName), isFalse);

      FavoriteManager.addFavorite({
        'id': testId,
        'restaurant_id': testId,
        'name': testName,
        'category': 'ก๋วยเตี๋ยว',
        'price': '฿ 50-80 บาท',
        'rating': 4.8,
        'image': 'assets/images/boat_noodles.jpg',
        'isAsset': true,
      });

      expect(FavoriteManager.isFavorite(testName), isTrue);
      expect(FavoriteManager.isFavorite(testId), isTrue);

      // Clean up
      FavoriteManager.removeFavorite(testId);
      expect(FavoriteManager.isFavorite(testName), isFalse);
      expect(FavoriteManager.isFavorite(testId), isFalse);
    });

    test('removeFavorite removes restaurant by name and by ID', () {
      const testName = 'ร้านข้าวมันไก่ทดสอบ';
      const testId = 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee';

      FavoriteManager.addFavorite({
        'id': testId,
        'restaurant_id': testId,
        'name': testName,
        'category': 'อาหารจานเดียว',
        'price': '฿ 60 บาท',
        'rating': 4.5,
      });

      expect(FavoriteManager.isFavorite(testName), isTrue);

      FavoriteManager.removeFavorite(testName);
      expect(FavoriteManager.isFavorite(testName), isFalse);
      expect(FavoriteManager.isFavorite(testId), isFalse);
    });

    test('fetchFavorites handles uninitialized Supabase gracefully without throwing', () async {
      final list = await FavoriteManager.fetchFavorites();
      expect(list, isNotNull);
      expect(list.isNotEmpty, isTrue);
    });
  });
}
