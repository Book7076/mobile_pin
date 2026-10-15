class UserModel {
  final String id;
  final String email;
  final String name;
  final String phone;
  final String role; // 'user', 'owner', 'admin'
  final int swipeCount;
  final String? avatarUrl;
  final String? username;
  final List<String> dietaryPreferences;
  final String? ownedRestaurantId;
  final DateTime? termsAcceptedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.phone = '',
    required this.role,
    this.swipeCount = 0,
    this.avatarUrl,
    this.username,
    this.dietaryPreferences = const [],
    this.ownedRestaurantId,
    this.termsAcceptedAt,
  });

  bool get isOwner =>
      role.trim().toLowerCase() == 'owner' ||
      userType.trim().toLowerCase() == 'owner';
  bool get isAdmin =>
      role.trim().toLowerCase() == 'admin' ||
      userType.trim().toLowerCase() == 'admin';
  bool get isCustomer =>
      !isOwner && !isAdmin;
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

    final rawRole = json['role']?.toString().trim().toLowerCase();
    final rawUserType = json['user_type']?.toString().trim().toLowerCase();
    String resolvedRole = 'customer';
    if (rawRole == 'owner' || rawUserType == 'owner') {
      resolvedRole = 'owner';
    } else if (rawRole == 'admin' || rawUserType == 'admin') {
      resolvedRole = 'admin';
    } else if (json['user_type'] != null && json['user_type'].toString().trim().isNotEmpty) {
      resolvedRole = json['user_type'].toString().trim();
    } else if (json['role'] != null && json['role'].toString().trim().isNotEmpty) {
      resolvedRole = json['role'].toString().trim();
    }

    DateTime? termsAcceptedAt;
    if (json['terms_accepted_at'] != null && json['terms_accepted_at'].toString().isNotEmpty) {
      termsAcceptedAt = DateTime.tryParse(json['terms_accepted_at'].toString());
    }

    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: resolvedName,
      phone: json['phone']?.toString() ?? '',
      role: resolvedRole,
      swipeCount: (json['swipe_count'] as num?)?.toInt() ?? 0,
      avatarUrl: json['image_url']?.toString() ?? json['avatar_url']?.toString(),
      username: json['username']?.toString(),
      dietaryPreferences: prefs,
      ownedRestaurantId: json['owned_restaurant_id']?.toString(),
      termsAcceptedAt: termsAcceptedAt,
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
      'image_url': avatarUrl,
      'username': username,
      'dietary_preferences': dietaryPreferences,
      'owned_restaurant_id': ownedRestaurantId,
      'terms_accepted_at': termsAcceptedAt?.toIso8601String(),
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
    String? username,
    bool clearAvatar = false,
    List<String>? dietaryPreferences,
    String? ownedRestaurantId,
    DateTime? termsAcceptedAt,
    bool clearTermsAcceptedAt = false,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      swipeCount: swipeCount ?? this.swipeCount,
      avatarUrl: clearAvatar ? null : (avatarUrl ?? this.avatarUrl),
      username: username ?? this.username,
      dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
      ownedRestaurantId: ownedRestaurantId ?? this.ownedRestaurantId,
      termsAcceptedAt: clearTermsAcceptedAt ? null : (termsAcceptedAt ?? this.termsAcceptedAt),
    );
  }
}
