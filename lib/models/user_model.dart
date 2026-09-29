class UserModel {
  final String id;
  final String email;
  final String name;
  final String phone;
  final String role; // 'user', 'owner', 'admin'
  final int swipeCount;
  final String? avatarUrl;
  final List<String> dietaryPreferences;
  final String? ownedRestaurantId;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.phone = '',
    required this.role,
    this.swipeCount = 0,
    this.avatarUrl,
    this.dietaryPreferences = const [],
    this.ownedRestaurantId,
  });

  bool get isOwner => role.toLowerCase() == 'owner';
  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get isCustomer => role.toLowerCase() == 'customer' || role.toLowerCase() == 'user';
  bool get isRegularUser => isCustomer;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    List<String> prefs = [];
    if (json['dietary_preferences'] != null && json['dietary_preferences'] is List) {
      prefs = (json['dietary_preferences'] as List).map((e) => e.toString()).toList();
    }

    final fName = (json['first_name'] ?? json['fname'])?.toString().trim() ?? '';
    final lName = (json['last_name'] ?? json['lname'])?.toString().trim() ?? '';
    final combinedFnameLname = [fName, lName].where((s) => s.isNotEmpty).join(' ');

    String resolvedName = combinedFnameLname.isNotEmpty
        ? combinedFnameLname
        : (json['name']?.toString().trim() ?? '');
    if (resolvedName.isEmpty) {
      final emailPrefix = json['email']?.toString().split('@').first ?? 'ผู้ใช้งาน';
      if (emailPrefix.contains('.')) {
        resolvedName = emailPrefix
            .split('.')
            .map((p) => p.isNotEmpty ? '${p[0].toUpperCase()}${p.substring(1)}' : '')
            .join(' ');
      } else {
        resolvedName = emailPrefix;
      }
    }

    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: resolvedName,
      phone: json['phone']?.toString() ?? '',
      role: json['user_type']?.toString() ?? json['role']?.toString() ?? 'customer',
      swipeCount: (json['swipe_count'] as num?)?.toInt() ?? 0,
      avatarUrl: json['avatar_url']?.toString(),
      dietaryPreferences: prefs,
      ownedRestaurantId: json['owned_restaurant_id']?.toString(),
    );
  }

  String get userType => role;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'user_type': role,
      'role': role,
      'swipe_count': swipeCount,
      'avatar_url': avatarUrl,
      'dietary_preferences': dietaryPreferences,
      'owned_restaurant_id': ownedRestaurantId,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? role,
    int? swipeCount,
    String? avatarUrl,
    List<String>? dietaryPreferences,
    String? ownedRestaurantId,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      swipeCount: swipeCount ?? this.swipeCount,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
      ownedRestaurantId: ownedRestaurantId ?? this.ownedRestaurantId,
    );
  }
}
