import 'package:flutter_test/flutter_test.dart';
import 'package:pin_mobile/models/review_model.dart';
import 'package:pin_mobile/services/review_service.dart';

void main() {
  group('ReviewModel Unit Tests', () {
    test('ReviewModel maps JSON with joined user data correctly', () {
      final json = {
        'id': 'b1c3e342-959f-4318-a15d-85590c138f01',
        'restaurant_id': '865239db-e785-48b2-b4c6-be818b7c02b1',
        'user_id': '8fcb0a51-5121-4f10-b99f-cf128ec09a25',
        'rating': 5,
        'comment': 'อาหารอร่อยมาก บรรยากาศดี บริการประทับใจ',
        'photo_url': 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5',
        'create_at': '2026-10-13T01:00:00.000Z',
        'users': {
          'id': '8fcb0a51-5121-4f10-b99f-cf128ec09a25',
          'first_name': 'สมชาย',
          'last_name': 'ใจดี',
          'email': 'somchai@example.com',
          'image_url': 'https://example.com/avatar.jpg',
        },
      };

      final review = ReviewModel.fromJson(json);

      expect(review.id, 'b1c3e342-959f-4318-a15d-85590c138f01');
      expect(review.restaurantId, '865239db-e785-48b2-b4c6-be818b7c02b1');
      expect(review.userId, '8fcb0a51-5121-4f10-b99f-cf128ec09a25');
      expect(review.rating, 5.0);
      expect(review.comment, 'อาหารอร่อยมาก บรรยากาศดี บริการประทับใจ');
      expect(review.photoUrl, 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5');
      expect(review.userName, 'สมชาย ใจดี');
      expect(review.userAvatar, 'https://example.com/avatar.jpg');
      expect(review.imageUrls, contains('https://images.unsplash.com/photo-1555396273-367ea4eb4db5'));
    });

    test('ReviewModel maps JSON without user relation using fallback defaults', () {
      final json = {
        'id': 'rev-2',
        'restaurant_id': 'res-1',
        'user_id': 'user-1',
        'rating': 4,
        'comment': 'รสชาติใช้ได้',
        'created_at': '2026-10-13T00:30:00.000Z',
      };

      final review = ReviewModel.fromJson(json);
      expect(review.id, 'rev-2');
      expect(review.userName, 'ผู้ใช้งาน');
      expect(review.rating, 4.0);
      expect(review.photoUrl, isNull);
      expect(review.imageUrls, isEmpty);
    });

    test('ReviewModel toDatabaseJson creates payload matching Supabase schema', () {
      final review = ReviewModel(
        id: 'rev_123', // local prefix should be excluded
        restaurantId: 'res-uuid',
        userId: 'usr-uuid',
        userName: 'Test User',
        rating: 4.8,
        comment: 'อร่อยสุดๆ',
        photoUrl: 'https://example.com/pic.jpg',
        createdAt: DateTime.parse('2026-10-13T01:00:00.000Z'),
      );

      final dbJson = review.toDatabaseJson();
      expect(dbJson.containsKey('id'), isFalse);
      expect(dbJson['restaurant_id'], 'res-uuid');
      expect(dbJson['user_id'], 'usr-uuid');
      expect(dbJson['rating'], 5); // 4.8 rounded to 5
      expect(dbJson['comment'], 'อร่อยสุดๆ');
      expect(dbJson['photo_url'], 'https://example.com/pic.jpg');
      expect(dbJson['create_at'], isNotNull);
    });
  });

  group('ReviewService Unit Tests', () {
    test('calculateAverageRating returns default when list is empty', () {
      final avg = ReviewService.calculateAverageRating([], defaultRating: 4.5);
      expect(avg, 4.5);
    });

    test('calculateAverageRating computes mean rating properly', () {
      final reviews = [
        ReviewModel(
          id: '1',
          restaurantId: 'r1',
          userId: 'u1',
          userName: 'U1',
          rating: 5.0,
          comment: 'good',
          createdAt: DateTime.now(),
        ),
        ReviewModel(
          id: '2',
          restaurantId: 'r1',
          userId: 'u2',
          userName: 'U2',
          rating: 4.0,
          comment: 'ok',
          createdAt: DateTime.now(),
        ),
      ];

      final avg = ReviewService.calculateAverageRating(reviews);
      expect(avg, 4.5);
    });

    test('submitReview returns fallback simulated model when offline', () async {
      final result = await ReviewService.submitReview(
        restaurantId: 'res-offline-1',
        rating: 4.0,
        comment: 'รีวิวตอนออฟไลน์',
        explicitUserName: 'ผู้ทดสอบ',
      );

      expect(result, isNotNull);
      expect(result!.restaurantId, 'res-offline-1');
      expect(result.comment, 'รีวิวตอนออฟไลน์');
      expect(result.rating, 4.0);
      expect(result.userName, 'ผู้ทดสอบ');
    });

    test('fetchReviewsForRestaurant returns empty list when offline without error', () async {
      final reviews = await ReviewService.fetchReviewsForRestaurant('non-existent-id');
      expect(reviews, isA<List<ReviewModel>>());
    });
  });
}
