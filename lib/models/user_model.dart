class UserModel {
  final String id;
  final String email;
  final String role;
  final int swipeCount;

  UserModel({
    required this.id,
    required this.email,
    required this.role,
    required this.swipeCount,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      role: json['role'] as String? ?? 'user',
      swipeCount: json['swipe_count'] as int? ?? 0,
    );
  }
}
