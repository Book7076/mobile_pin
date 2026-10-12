import 'dart:math';

/// Maps flow category strings to database `cuisine_types` integer IDs (1..17).
/// Matches database table `cuisine_types` in Supabase:
/// 1: อาหารไทย
/// 2: อาหารญี่ปุ่น
/// 3: อาหารเกาหลี
/// 4: อาหารจีน
/// 5: ขนมหวาน/เบเกอรี่ (ของหวาน)
/// 6: อาหารอิตาเลียน
/// 7: ฟาสต์ฟู้ด (อาหารฟาสฟู้ด)
/// 8: อาหารสุขภาพ (อาหารฮาลาล)
/// 9: อาหารมังสวิรัติ
/// 10: ก๋วยเตี๋ยว
/// 11: คาเฟ่/เครื่องดื่ม (คาเฟ่)
/// 12: ชาบู/ฮอกพอด, หมูกระทะ (ปิ้งย่าง/ชาบู)
/// 17: อาหารตามสั่ง
int? mapCategoryToCuisineTypeId(String? category) {
  if (category == null || category.trim().isEmpty) return null;
  final lower = category.trim().toLowerCase();

  if (lower == 'northern_thai' || lower.contains('เหนือ')) return 15;
  if (lower == 'southern_thai' || lower.contains('ใต้')) return 16;
  if (lower == 'somtum_isan' || lower.contains('อีสาน') || lower.contains('ส้มตำ')) return 14;
  if (lower == 'breakfast' || lower.contains('อาหารเช้า')) return 13;
  if (lower == 'vegetarian' || lower.contains('มังสวิรัติ')) return 9;
  if (lower == 'thai' || lower.contains('ไทย')) return 1;
  if (lower == 'japanese' || lower.contains('ญี่ปุ่น')) return 2;
  if (lower == 'korean' || lower.contains('เกาหลี')) return 3;
  if (lower == 'chinese' || lower.contains('จีน')) return 4;
  if (lower == 'dessert_bakery' ||
      lower.contains('ขนมหวาน') ||
      lower.contains('เบเกอรี่') ||
      lower.contains('ของหวาน')) {
    return 5;
  }
  if (lower == 'italian_western' || lower.contains('อิตาเลียน') || lower.contains('สเต็ก') || lower.contains('พิซซ่า')) {
    return 6;
  }
  if (lower == 'fast_food' ||
      lower == 'fastfood' ||
      lower.contains('ฟาสต์ฟู้ด') ||
      lower.contains('ฟาสฟู้ด')) {
    return 7;
  }
  if (lower == 'healthy' ||
      lower.contains('สุขภาพ') ||
      lower.contains('ฮาลาล') ||
      lower.contains('คลีน')) {
    return 8;
  }
  if (lower == 'noodles' || lower.contains('ก๋วยเตี๋ยว') || lower.contains('บะหมี่')) {
    return 10;
  }
  if (lower == 'cafe_beverage' ||
      lower.contains('คาเฟ่') ||
      lower.contains('เครื่องดื่ม') ||
      lower.contains('กาแฟ')) {
    return 11;
  }
  if (lower == 'shabu_hotpot' ||
      lower == 'mookata' ||
      lower.contains('ชาบู') ||
      lower.contains('หมูกระทะ') ||
      lower.contains('ฮอกพอด') ||
      lower.contains('ปิ้งย่าง')) {
    return 12;
  }
  if (lower == 'a_la_carte' ||
      lower.contains('ตามสั่ง') ||
      lower.contains('สตรีทฟู้ด')) {
    return 17;
  }

  return 1; // Default fallback to Thai
}

/// Maps database `cuisine_type_id` (1..17) to official Thai name
String mapCuisineTypeIdToName(int id) {
  switch (id) {
    case 1:
      return 'อาหารไทย';
    case 2:
      return 'อาหารญี่ปุ่น';
    case 3:
      return 'อาหารเกาหลี';
    case 4:
      return 'อาหารจีน';
    case 5:
      return 'ของหวาน';
    case 6:
      return 'อาหารอิตาเลียน';
    case 7:
      return 'อาหารฟาสฟู้ด';
    case 8:
      return 'อาหารฮาลาล';
    case 9:
      return 'อาหารมังสวิรัติ';
    case 10:
      return 'ก๋วยเตี๋ยว';
    case 11:
      return 'คาเฟ่';
    case 12:
      return 'ปิ้งย่าง/ชาบู';
    case 13:
      return 'อาหารเช้า';
    case 14:
      return 'อาหารอีสาน';
    case 15:
      return 'อาหารเหนือ';
    case 16:
      return 'อาหารใต้';
    case 17:
      return 'อาหารตามสั่ง';
    default:
      return 'อาหารทั่วไป';
  }
}

/// Returns category slugs and Thai aliases for a given `cuisine_type_id`
List<String> mapCuisineTypeIdToSlugs(int id) {
  switch (id) {
    case 1:
      return ['thai', 'อาหารไทย'];
    case 2:
      return ['japanese', 'อาหารญี่ปุ่น'];
    case 3:
      return ['korean', 'อาหารเกาหลี'];
    case 4:
      return ['chinese', 'อาหารจีน'];
    case 5:
      return ['dessert_bakery', 'ขนมหวาน/เบเกอรี่', 'ของหวาน', 'เบเกอรี่', 'cafe_dessert'];
    case 6:
      return ['italian_western', 'อาหารอิตาเลียน', 'สเต็ก', 'พิซซ่า'];
    case 7:
      return ['fast_food', 'ฟาสต์ฟู้ด', 'อาหารฟาสฟู้ด', 'fastfood'];
    case 8:
      return ['healthy', 'อาหารสุขภาพ', 'อาหารฮาลาล', 'halal', 'healthy_clean'];
    case 9:
      return ['vegetarian', 'อาหารมังสวิรัติ', 'มังสวิรัติ'];
    case 10:
      return ['noodles', 'ก๋วยเตี๋ยว', 'ก๋วยเตี๋ยว / บะหมี่', 'บะหมี่'];
    case 11:
      return ['cafe_beverage', 'คาเฟ่/เครื่องดื่ม', 'คาเฟ่', 'เครื่องดื่ม', 'กาแฟ', 'cafe'];
    case 12:
      return ['shabu_hotpot', 'mookata', 'ชาบู/ฮอกพอด', 'หมูกระทะ', 'ชาบู', 'ปิ้งย่าง/ชาบู', 'ชาบู / ปิ้งย่าง / หมูกระทะ'];
    case 13:
      return ['breakfast', 'อาหารเช้า'];
    case 14:
      return ['somtum_isan', 'อาหารอีสาน', 'ส้มตำ'];
    case 15:
      return ['northern_thai', 'อาหารเหนือ'];
    case 16:
      return ['southern_thai', 'อาหารใต้'];
    case 17:
      return ['a_la_carte', 'อาหารตามสั่ง', 'ตามสั่ง', 'สตรีทฟู้ด', 'street_food', 'made_to_order'];
    default:
      return [];
  }
}

/// Utility to generate RFC4122 v4 UUID
String generateClientUuidV4() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}

/// Standardized Direction values matching table `swipes` (Image 1)
class SwipeDirection {
  static const String left = 'left';
  static const String right = 'right';
}

/// Standardized Preference Type matching table `user_food_preferences` (Image 2)
class FoodPreferenceType {
  static const String like = 'like';
  static const String dislike = 'dislike';
}

/// Model matching table `swipe_sessions` (Image 4)
/// Columns:
/// - id: uuid
/// - user_id: uuid
/// - cuisine_type_id: int8
/// - price_min: numeric
/// - price_max: numeric
/// - target_restaurant_count: int4
/// - status: text ("กำลังใช้" / "เสร็จสิ้น" / "active" / "completed")
/// - created_at: timestamp
/// - swiped_count: int4
class SwipeSessionModel {
  static const String statusInProgress = 'กำลังใช้';
  static const String statusCompleted = 'เสร็จสิ้น';
  static const String statusLegacyCompleted = 'ปัดเสร็จแล้ว';
  static const String statusActive = 'active';
  static const String statusDone = 'completed';

  final String? id;
  final String? userId;
  final int? cuisineTypeId;
  final double priceMin;
  final double? priceMax;
  final int targetRestaurantCount;
  final int swipedCount;
  final String status;
  final DateTime? createdAt;

  SwipeSessionModel({
    this.id,
    this.userId,
    this.cuisineTypeId,
    this.priceMin = 50.0,
    this.priceMax,
    this.targetRestaurantCount = 5,
    this.swipedCount = 0,
    this.status = statusInProgress,
    this.createdAt,
  });

  bool get isCompleted =>
      status == statusCompleted ||
      status == statusLegacyCompleted ||
      status == statusDone;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'cuisine_type_id': cuisineTypeId,
      'price_min': priceMin,
      'price_max': priceMax,
      'target_restaurant_count': targetRestaurantCount,
      'swiped_count': swipedCount,
      'status': status,
    };
    if (id != null) map['id'] = id;
    if (userId != null) map['user_id'] = userId;
    if (createdAt != null) map['created_at'] = createdAt!.toIso8601String();
    return map;
  }

  factory SwipeSessionModel.fromJson(Map<String, dynamic> json) {
    return SwipeSessionModel(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString(),
      cuisineTypeId: (json['cuisine_type_id'] as num?)?.toInt(),
      priceMin: (json['price_min'] as num?)?.toDouble() ?? 50.0,
      priceMax: (json['price_max'] as num?)?.toDouble(),
      targetRestaurantCount:
          (json['target_restaurant_count'] as num?)?.toInt() ?? 5,
      swipedCount: (json['swiped_count'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? statusInProgress,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  SwipeSessionModel copyWith({
    String? id,
    String? userId,
    int? cuisineTypeId,
    double? priceMin,
    double? priceMax,
    int? targetRestaurantCount,
    int? swipedCount,
    String? status,
    DateTime? createdAt,
  }) {
    return SwipeSessionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      cuisineTypeId: cuisineTypeId ?? this.cuisineTypeId,
      priceMin: priceMin ?? this.priceMin,
      priceMax: priceMax ?? this.priceMax,
      targetRestaurantCount:
          targetRestaurantCount ?? this.targetRestaurantCount,
      swipedCount: swipedCount ?? this.swipedCount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Model matching table `swipes` (Image 1)
/// Columns:
/// - id: uuid (PK)
/// - session_id: uuid (FK to swipe_sessions.id)
/// - user_id: uuid (FK to users.id)
/// - restaurant_id: uuid (FK to restaurants.id)
/// - direction: text ('left' / 'right')
/// - created_at: timestamp
class SwipeRecordModel {
  final String? id;
  final String sessionId;
  final String? userId;
  final String restaurantId;
  final String direction;
  final DateTime? createdAt;

  SwipeRecordModel({
    this.id,
    required this.sessionId,
    this.userId,
    required this.restaurantId,
    required this.direction,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'session_id': sessionId,
      'restaurant_id': restaurantId,
      'direction': direction,
    };
    if (id != null) map['id'] = id;
    if (userId != null) map['user_id'] = userId;
    if (createdAt != null) map['created_at'] = createdAt!.toIso8601String();
    return map;
  }

  factory SwipeRecordModel.fromJson(Map<String, dynamic> json) {
    return SwipeRecordModel(
      id: json['id']?.toString(),
      sessionId: json['session_id']?.toString() ?? '',
      userId: json['user_id']?.toString(),
      restaurantId: json['restaurant_id']?.toString() ?? '',
      direction: json['direction']?.toString() ?? SwipeDirection.left,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}

/// Model matching table `user_food_preferences` (Image 2)
/// Columns:
/// - id: uuid (PK)
/// - user_id: uuid (FK to users.id)
/// - food_tag_id: int8
/// - pref_type: text ('like' / 'dislike')
class UserFoodPreferenceModel {
  final String? id;
  final String userId;
  final int foodTagId;
  final String prefType;

  UserFoodPreferenceModel({
    this.id,
    required this.userId,
    required this.foodTagId,
    required this.prefType,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'user_id': userId,
      'food_tag_id': foodTagId,
      'pref_type': prefType,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory UserFoodPreferenceModel.fromJson(Map<String, dynamic> json) {
    return UserFoodPreferenceModel(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString() ?? '',
      foodTagId: (json['food_tag_id'] as num?)?.toInt() ?? 0,
      prefType: json['pref_type']?.toString() ?? FoodPreferenceType.like,
    );
  }
}

/// Model matching table `selected_restaurants` (Image 3)
/// Columns:
/// - id: uuid (PK)
/// - session_id: uuid (FK to swipe_sessions.id)
/// - restaurant_id: uuid (FK to restaurants.id)
/// - is_final_choice: bool
class SelectedRestaurantModel {
  final String? id;
  final String sessionId;
  final String restaurantId;
  final bool isFinalChoice;

  SelectedRestaurantModel({
    this.id,
    required this.sessionId,
    required this.restaurantId,
    this.isFinalChoice = false,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'session_id': sessionId,
      'restaurant_id': restaurantId,
      'is_final_choice': isFinalChoice,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory SelectedRestaurantModel.fromJson(Map<String, dynamic> json) {
    return SelectedRestaurantModel(
      id: json['id']?.toString(),
      sessionId: json['session_id']?.toString() ?? '',
      restaurantId: json['restaurant_id']?.toString() ?? '',
      isFinalChoice: json['is_final_choice'] == true,
    );
  }
}

/// Model matching table `swipe_session_cuisines`
/// Columns:
/// - session_id: uuid (FK to swipe_sessions.id)
/// - cuisine_type_id: int8 (FK to cuisine_types.id)
class SwipeSessionCuisineModel {
  final String sessionId;
  final int cuisineTypeId;

  SwipeSessionCuisineModel({
    required this.sessionId,
    required this.cuisineTypeId,
  });

  Map<String, dynamic> toJson() => {
    'session_id': sessionId,
    'cuisine_type_id': cuisineTypeId,
  };

  factory SwipeSessionCuisineModel.fromJson(Map<String, dynamic> json) =>
      SwipeSessionCuisineModel(
        sessionId: json['session_id']?.toString() ?? '',
        cuisineTypeId: (json['cuisine_type_id'] as num?)?.toInt() ?? 0,
      );
}
