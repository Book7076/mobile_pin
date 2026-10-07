class ReviewModel {
  final String id;
  final String restaurantId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final double rating;
  final String comment;
  final List<String> imageUrls;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.restaurantId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.rating,
    required this.comment,
    this.imageUrls = const [],
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    List<String> images = [];
    if (json['image_urls'] != null && json['image_urls'] is List) {
      images = (json['image_urls'] as List).map((e) => e.toString()).toList();
    } else if (json['photo_url'] != null && json['photo_url'].toString().isNotEmpty) {
      images = [json['photo_url'].toString()];
    }

    String uName = json['user_name']?.toString() ?? '';
    if (uName.isEmpty && json['users'] != null && json['users'] is Map) {
      final u = json['users'] as Map;
      final fName = u['first_name']?.toString().trim() ?? '';
      final lName = u['last_name']?.toString().trim() ?? '';
      if (fName.isNotEmpty || lName.isNotEmpty) {
        uName = '$fName $lName'.trim();
      } else if (u['email'] != null) {
        uName = u['email'].toString().split('@').first;
      }
    }
    if (uName.isEmpty) uName = 'ผู้ใช้งาน';

    final rawDate = json['created_at'] ?? json['create_at'];

    return ReviewModel(
      id: json['id']?.toString() ?? '',
      restaurantId: json['restaurant_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      userName: uName,
      userAvatar: json['user_avatar']?.toString() ?? (images.isNotEmpty ? images.first : null),
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      comment: json['comment']?.toString() ?? '',
      imageUrls: images,
      createdAt: rawDate != null 
          ? DateTime.tryParse(rawDate.toString()) ?? DateTime.now() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'user_id': userId,
      'user_name': userName,
      'user_avatar': userAvatar,
      'rating': rating,
      'comment': comment,
      'image_urls': imageUrls,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
