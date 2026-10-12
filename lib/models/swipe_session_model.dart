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
  if (lower == 'italian_western' || lower.contains('อิตาเลียน') || lower.contains('สเต็ก')) {
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

/// Utility to generate RFC4122 v4 UUID
String generateClientUuidV4() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}

/// Model matching table `swipe_sessions` (Image 4)
/// Columns:
/// - id: uuid
/// - user_id: uuid
/// - cuisine_type_id: int8
/// - price_min: numeric
/// - price_max: numeric
/// - target_restaurant_count: int4
/// - status: text ("กำลังใช้" or "ปัดเสร็จแล้ว")
/// - created_at: timestamp
class SwipeSessionModel {
  static const String statusInProgress = 'กำลังใช้';
  static const String statusCompleted = 'ปัดเสร็จแล้ว';

  final String? id;
  final String? userId;
  final int? cuisineTypeId;
  final double priceMin;
  final double? priceMax;
  final int targetRestaurantCount;
  final String status;
  final DateTime? createdAt;

  SwipeSessionModel({
    this.id,
    this.userId,
    this.cuisineTypeId,
    this.priceMin = 50.0,
    this.priceMax,
    this.targetRestaurantCount = 0,
    this.status = statusInProgress,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'cuisine_type_id': cuisineTypeId,
      'price_min': priceMin,
      'price_max': priceMax,
      'target_restaurant_count': targetRestaurantCount,
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
          (json['target_restaurant_count'] as num?)?.toInt() ?? 0,
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
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
