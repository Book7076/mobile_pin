class ReviewModel {
  final String id;
  final String restaurantId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final double rating;
  final String comment;
  final String? photoUrl;
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
    this.photoUrl,
    this.imageUrls = const [],
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    String? pUrl = json['photo_url']?.toString();
    List<String> images = [];
    if (json['image_urls'] != null && json['image_urls'] is List) {
      images = (json['image_urls'] as List).map((e) => e.toString()).toList();
    } else if (pUrl != null && pUrl.isNotEmpty) {
      images = [pUrl];
    }

    String uName = json['user_name']?.toString() ?? '';
    String? uAvatar;
    if (json['users'] != null && json['users'] is Map) {
      final u = json['users'] as Map;
      final fName = u['first_name']?.toString().trim() ?? '';
      final lName = u['last_name']?.toString().trim() ?? '';
      if (fName.isNotEmpty || lName.isNotEmpty) {
        uName = '$fName $lName'.trim();
      } else if (u['email'] != null) {
        uName = u['email'].toString().split('@').first;
      }
      uAvatar = u['image_url']?.toString() ?? u['avatar_url']?.toString();
    }
    if (uName.isEmpty && json['contact_email'] != null) {
      uName = json['contact_email'].toString();
    }
    if (uName.isEmpty) uName = 'ผู้ใช้งาน';
    uAvatar ??= json['user_avatar']?.toString();

    final rawDate = json['create_at'] ?? json['created_at'];

    return ReviewModel(
      id: json['id']?.toString() ?? '',
      restaurantId: json['restaurant_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      userName: uName,
      userAvatar: uAvatar,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      comment: json['comment']?.toString() ?? '',
      photoUrl: pUrl,
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
      'photo_url': photoUrl,
      'image_urls': imageUrls,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toDatabaseJson() {
    return {
      if (id.isNotEmpty && !id.startsWith('rev_') && !id.startsWith('local_')) 'id': id,
      'restaurant_id': restaurantId,
      'user_id': userId,
      'rating': rating.round().clamp(1, 5),
      'comment': comment,
      if (photoUrl != null && photoUrl!.isNotEmpty) 'photo_url': photoUrl,
      'create_at': createdAt.toIso8601String(),
    };
  }

  ReviewModel copyWith({
    String? id,
    String? restaurantId,
    String? userId,
    String? userName,
    String? userAvatar,
    double? rating,
    String? comment,
    String? photoUrl,
    List<String>? imageUrls,
    DateTime? createdAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      photoUrl: photoUrl ?? this.photoUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
