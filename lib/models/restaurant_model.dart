class RestaurantModel {
  final String id;
  final String ownerId;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final String phone;
  final String? email;
  final String? menu;
  final String status; // 'pending', 'approved', 'rejected'

  RestaurantModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.phone,
    this.email,
    this.menu,
    required this.status,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      phone: json['phone'] as String,
      email: json['email'] as String?,
      menu: json['menu'] as String?,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'owner_id': ownerId,
      'name': name,
      'address': address,
      'lat': lat,
      'lng': lng,
      'phone': phone,
      'email': email,
      'menu': menu,
      'status': status,
    };
  }
}
