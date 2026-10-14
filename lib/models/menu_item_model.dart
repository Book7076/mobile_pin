class MenuItemModel {
  final String id;
  final String restaurantId;
  final String name;
  final double price;
  final String? imageUrl;
  final bool isAvailable;
  final String category;

  const MenuItemModel({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.price,
    this.imageUrl,
    this.isAvailable = true,
    this.category = 'ทั่วไป',
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    bool available = true;
    if (json.containsKey('is_available') && json['is_available'] != null) {
      available = json['is_available'] == true;
    } else if (json['sort_order'] != null && (json['sort_order'] as num) < 0) {
      available = false;
    } else if (json['isAvailable'] != null) {
      available = json['isAvailable'] == true;
    }

    return MenuItemModel(
      id: json['id']?.toString() ?? '',
      restaurantId: json['restaurant_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['image_url']?.toString(),
      isAvailable: available,
      category: json['category']?.toString() ?? 'ทั่วไป',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'name': name,
      'price': price,
      'image_url': imageUrl,
      'is_available': isAvailable,
      'category': category,
    };
  }

  /// Only includes columns present in Supabase `menu_items` table
  Map<String, dynamic> toInsertMap() {
    return {
      'restaurant_id': restaurantId,
      'name': name,
      'price': price,
      if (imageUrl != null && imageUrl!.isNotEmpty) 'image_url': imageUrl,
    };
  }

  MenuItemModel copyWith({
    String? id,
    String? restaurantId,
    String? name,
    double? price,
    String? imageUrl,
    bool? isAvailable,
    String? category,
  }) {
    return MenuItemModel(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      name: name ?? this.name,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      category: category ?? this.category,
    );
  }
}
