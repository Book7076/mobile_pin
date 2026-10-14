import 'swipe_session_model.dart';

class SignatureDish {
  final String name;
  final int price;
  final String? imageUrl;
  final String? description;
  final String? priceDisplay;
  final bool isAvailable;

  SignatureDish({
    required this.name,
    required this.price,
    this.imageUrl,
    this.description,
    this.priceDisplay,
    this.isAvailable = true,
  });

  String get formattedPrice => priceDisplay ?? '฿$price';

  factory SignatureDish.fromJson(Map<String, dynamic> json) {
    bool available = true;
    if (json.containsKey('is_available') && json['is_available'] != null) {
      available = json['is_available'] == true;
    } else if (json['sort_order'] != null && (json['sort_order'] as num) < 0) {
      available = false;
    } else if (json['isAvailable'] != null) {
      available = json['isAvailable'] == true;
    }

    return SignatureDish(
      name: json['name'] as String? ?? '',
      price: json['price'] is int
          ? json['price'] as int
          : int.tryParse(json['price'].toString()) ?? 0,
      imageUrl: json['image_url'] as String?,
      description: json['description'] as String?,
      priceDisplay: json['price_display'] as String?,
      isAvailable: available,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'price': price,
        'image_url': imageUrl,
        'description': description,
        'price_display': priceDisplay,
        'is_available': isAvailable,
      };
}

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
  final List<String> categories;
  final double rating;
  final int reviewCount;
  final int priceLevel; // 1, 2, 3
  final String priceRange;
  final List<String> imageUrls;
  final String? logoUrl; // is_logo = true (profile logo)
  final String openHours;
  final bool isOpen;
  final List<SignatureDish> signatureDishes;
  final List<String> features;
  final bool isFavorite;
  final bool isLiked;
  final double? distanceKm;
  final String? locationBadge;
  final String? googleMapsUrl;
  final int? cuisineTypeId;
  final String? cuisineTypeName;
  final String? rejectionReason;
  final DateTime? createdAt;

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
    this.categories = const [],
    this.rating = 0.0,
    this.reviewCount = 0,
    this.priceLevel = 1,
    this.priceRange = '50 - 150 บาท',
    this.imageUrls = const [],
    this.logoUrl,
    this.openHours = '10:00 - 21:00 น.',
    this.isOpen = true,
    this.signatureDishes = const [],
    this.features = const ['มีที่จอดรถ', 'ห้องแอร์', 'รับโอนเงิน'],
    this.isFavorite = false,
    this.isLiked = false,
    this.distanceKm,
    this.locationBadge,
    this.googleMapsUrl,
    this.cuisineTypeId,
    this.cuisineTypeName,
    this.rejectionReason,
    this.createdAt,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedCategories = [];
    if (json['categories'] != null) {
      if (json['categories'] is List) {
        parsedCategories = (json['categories'] as List).map((e) => e.toString()).toList();
      } else if (json['categories'] is String) {
        parsedCategories = (json['categories'] as String).split(',').map((e) => e.trim()).toList();
      }
    }

    final int? cuisineTypeId = (json['cuisine_type_id'] as num?)?.toInt();
    String? cuisineTypeName;
    if (json['cuisine_types'] != null) {
      if (json['cuisine_types'] is Map) {
        cuisineTypeName = json['cuisine_types']['name']?.toString();
      } else if (json['cuisine_types'] is List && (json['cuisine_types'] as List).isNotEmpty) {
        final first = (json['cuisine_types'] as List).first;
        if (first is Map) {
          cuisineTypeName = first['name']?.toString();
        }
      }
    }

    // ประเภทอาหารของแต่ละร้านคือ cuisine_type_id อิงตาม database (รูปที่ 2 และ 3)
    if ((cuisineTypeName == null || cuisineTypeName.isEmpty) && cuisineTypeId != null) {
      cuisineTypeName = mapCuisineTypeIdToName(cuisineTypeId);
    }

    if (cuisineTypeName != null && cuisineTypeName.isNotEmpty) {
      parsedCategories = [cuisineTypeName];
    } else if (parsedCategories.isEmpty && cuisineTypeId != null) {
      parsedCategories = [mapCuisineTypeIdToName(cuisineTypeId)];
    }

    List<String> parsedImages = [];
    String? logoImageUrl;
    if (json['restaurant_images'] != null && json['restaurant_images'] is List) {
      final imgList = (json['restaurant_images'] as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      // Separate menu/food photos (is_logo == false) and profile logo photos (is_logo == true)
      final menuFoodImages = imgList.where((e) {
        final isLogo = e['is_logo'];
        return isLogo == false || isLogo == 'false' || isLogo == 0 || isLogo == '0';
      }).toList();
      menuFoodImages.sort((a, b) => ((a['sort_order'] ?? 99) as num).compareTo((b['sort_order'] ?? 99) as num));

      final logoImages = imgList.where((e) {
        final isLogo = e['is_logo'];
        return isLogo == true || isLogo == 'true' || isLogo == 1 || isLogo == '1';
      }).toList();
      logoImages.sort((a, b) => ((a['sort_order'] ?? 99) as num).compareTo((b['sort_order'] ?? 99) as num));

      if (logoImages.isNotEmpty) {
        logoImageUrl = logoImages.first['image_url']?.toString();
      }

      final nonLogoUrls = menuFoodImages
          .map((e) => e['image_url']?.toString() ?? '')
          .where((u) => u.isNotEmpty)
          .toList();

      final logoUrls = logoImages
          .map((e) => e['image_url']?.toString() ?? '')
          .where((u) => u.isNotEmpty)
          .toList();

      // Prioritize non-logo (is_logo == false) food/menu photos at the front for swipe card display
      parsedImages = [...nonLogoUrls, ...logoUrls];
    }
    if (parsedImages.isEmpty) {
      if (json['image_urls'] != null && json['image_urls'] is List) {
        parsedImages = (json['image_urls'] as List).map((e) => e.toString()).toList();
      } else if (json['image_url'] != null && json['image_url'].toString().isNotEmpty) {
        parsedImages = [json['image_url'].toString()];
      } else if (json['imageUrl'] != null && json['imageUrl'].toString().isNotEmpty) {
        parsedImages = [json['imageUrl'].toString()];
      }
    }

    if (parsedImages.isEmpty) {
      parsedImages = [
        'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800&q=80',
      ];
    }

    List<SignatureDish> parsedDishes = [];
    if (json['signature_dishes'] != null && json['signature_dishes'] is List) {
      parsedDishes = (json['signature_dishes'] as List)
          .map((d) => SignatureDish.fromJson(Map<String, dynamic>.from(d as Map)))
          .toList();
    } else if (json['menu_items'] != null && json['menu_items'] is List) {
      parsedDishes = (json['menu_items'] as List)
          .whereType<Map>()
          .map((d) => SignatureDish.fromJson(Map<String, dynamic>.from(d)))
          .toList();
    }

    int computedPriceLevel = (json['price_level'] as num?)?.toInt() ?? 1;
    String computedPriceRange = json['price_range']?.toString() ?? '60 - 180 ฿';

    if (parsedDishes.isNotEmpty) {
      final validPrices = parsedDishes
          .map((d) => d.price)
          .where((p) => p > 0)
          .toList();
      if (validPrices.isNotEmpty) {
        validPrices.sort();
        final minPrice = validPrices.first;
        final maxPrice = validPrices.last;
        computedPriceRange = minPrice == maxPrice ? '$minPrice ฿' : '$minPrice - $maxPrice ฿';

        if (minPrice < 100) {
          computedPriceLevel = 1;
        } else if (minPrice <= 300) {
          computedPriceLevel = 2;
        } else {
          computedPriceLevel = 3;
        }
      }
    }

    List<String> parsedFeatures = ['มีที่จอดรถ', 'ห้องแอร์', 'พร้อมเพย์'];
    if (json['features'] != null && json['features'] is List) {
      parsedFeatures = (json['features'] as List).map((e) => e.toString()).toList();
    }

    DateTime? parsedCreatedAt;
    if (json['crated_at'] != null) {
      parsedCreatedAt = DateTime.tryParse(json['crated_at'].toString());
    } else if (json['created_at'] != null) {
      parsedCreatedAt = DateTime.tryParse(json['created_at'].toString());
    }

    return RestaurantModel(
      id: json['id']?.toString() ?? '',
      ownerId: json['owner_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'ร้านอาหาร',
      address: json['address']?.toString() ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 13.7563,
      lng: (json['lng'] as num?)?.toDouble() ?? 100.5018,
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString(),
      menu: json['menu']?.toString(),
      status: json['status']?.toString() ?? 'approved',
      categories: parsedCategories.isNotEmpty ? parsedCategories : ['thai'],
      rating: () {
        if (json['reviews'] != null && json['reviews'] is List) {
          final rList = json['reviews'] as List;
          final numericRatings = rList
              .map((r) => (r is Map) ? (r['rating'] as num?)?.toDouble() : null)
              .whereType<double>()
              .toList();
          if (numericRatings.isNotEmpty) {
            final total = numericRatings.fold<double>(0.0, (s, e) => s + e);
            return double.parse((total / numericRatings.length).toStringAsFixed(1));
          }
        }
        return (json['rating'] as num?)?.toDouble() ?? 0.0;
      }(),
      reviewCount: () {
        if (json['reviews'] != null && json['reviews'] is List) {
          return (json['reviews'] as List).length;
        }
        return (json['review_count'] as num?)?.toInt() ?? 0;
      }(),
      priceLevel: computedPriceLevel,
      priceRange: computedPriceRange,
      imageUrls: parsedImages,
      logoUrl: logoImageUrl ?? json['logo_url']?.toString(),
      openHours: json['open_hours']?.toString() ?? '10:00 - 21:00 น.',
      isOpen: json['is_open'] as bool? ?? true,
      signatureDishes: parsedDishes,
      features: parsedFeatures,
      isFavorite: json['is_favorite'] as bool? ?? false,
      isLiked: json['is_liked'] as bool? ?? false,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      googleMapsUrl: json['google_maps_url']?.toString() ?? json['map_url']?.toString(),
      cuisineTypeId: (json['cuisine_type_id'] as num?)?.toInt(),
      cuisineTypeName: cuisineTypeName,
      rejectionReason: json['rejection_reason']?.toString(),
      createdAt: parsedCreatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'name': name,
      'address': address,
      'lat': lat,
      'lng': lng,
      'phone': phone,
      'email': email,
      'menu': menu,
      'status': status,
      'categories': categories,
      'rating': rating,
      'review_count': reviewCount,
      'price_level': priceLevel,
      'price_range': priceRange,
      'image_urls': imageUrls,
      if (logoUrl != null) 'logo_url': logoUrl,
      'open_hours': openHours,
      'is_open': isOpen,
      'signature_dishes': signatureDishes.map((d) => d.toJson()).toList(),
      'features': features,
      'is_favorite': isFavorite,
      'is_liked': isLiked,
      'distance_km': distanceKm,
      if (googleMapsUrl != null) 'google_maps_url': googleMapsUrl,
      if (cuisineTypeId != null) 'cuisine_type_id': cuisineTypeId,
      if (cuisineTypeName != null) 'cuisine_type_name': cuisineTypeName,
      if (rejectionReason != null) 'rejection_reason': rejectionReason,
    };
  }

  RestaurantModel copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? address,
    double? lat,
    double? lng,
    String? phone,
    String? email,
    String? menu,
    String? status,
    List<String>? categories,
    double? rating,
    int? reviewCount,
    int? priceLevel,
    String? priceRange,
    List<String>? imageUrls,
    String? logoUrl,
    String? openHours,
    bool? isOpen,
    List<SignatureDish>? signatureDishes,
    List<String>? features,
    bool? isFavorite,
    bool? isLiked,
    double? distanceKm,
    String? googleMapsUrl,
    int? cuisineTypeId,
    String? cuisineTypeName,
    String? rejectionReason,
    DateTime? createdAt,
  }) {
    return RestaurantModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      address: address ?? this.address,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      menu: menu ?? this.menu,
      status: status ?? this.status,
      categories: categories ?? this.categories,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      priceLevel: priceLevel ?? this.priceLevel,
      priceRange: priceRange ?? this.priceRange,
      imageUrls: imageUrls ?? this.imageUrls,
      logoUrl: logoUrl ?? this.logoUrl,
      openHours: openHours ?? this.openHours,
      isOpen: isOpen ?? this.isOpen,
      signatureDishes: signatureDishes ?? this.signatureDishes,
      features: features ?? this.features,
      isFavorite: isFavorite ?? this.isFavorite,
      isLiked: isLiked ?? this.isLiked,
      distanceKm: distanceKm ?? this.distanceKm,
      googleMapsUrl: googleMapsUrl ?? this.googleMapsUrl,
      cuisineTypeId: cuisineTypeId ?? this.cuisineTypeId,
      cuisineTypeName: cuisineTypeName ?? this.cuisineTypeName,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
