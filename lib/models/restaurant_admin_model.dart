class RestaurantMenuItem {
  final String name;
  final int price;
  final String? imageUrl;
  final String? description;

  const RestaurantMenuItem({
    required this.name,
    required this.price,
    this.imageUrl,
    this.description,
  });

  factory RestaurantMenuItem.fromJson(Map<String, dynamic> json) {
    return RestaurantMenuItem(
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toInt() ?? 0,
      imageUrl: json['image_url'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'price': price,
    'image_url': imageUrl,
    'description': description,
  };
}

class RestaurantAdminModel {
  final String id;
  final String ownerId;
  final String ownerName;
  final String name;
  final String? storeCode; // เช่น "111U1103"
  final String address;
  final String? mapUrl; // เช่น "www.googlemap.com"
  final double lat;
  final double lng;
  final String phone;
  final String? email;
  final String? menu;
  final String? imageUrl;
  final String status; // 'pending' (รออนุมัติ), 'approved' (อนุมัติ), 'rejected' (ไม่อนุมัติ)
  final DateTime createdAt;
  final String? rejectionReason;
  final String? reviewerName; // เช่น "ปนัสยา"
  final DateTime? requestSubmittedDate; // เช่น วันที่ส่งคำขอ 3 ส.ค. 2569
  final String? category; // เช่น "เครื่องดื่ม/คาเฟ่"
  final String? documentUrl;
  final Map<String, String>? openingHours;
  final List<String>? amenities; // เช่น ["จอดจักรยานยนต์", "มีอินเทอร์เน็ต"]
  final List<RestaurantMenuItem> menuItems;

  RestaurantAdminModel({
    required this.id,
    required this.ownerId,
    this.ownerName = 'ผู้ประกอบการ',
    required this.name,
    this.storeCode,
    required this.address,
    this.mapUrl,
    this.lat = 18.7883,
    this.lng = 98.9853,
    required this.phone,
    this.email,
    this.menu,
    this.imageUrl,
    required this.status,
    required this.createdAt,
    this.rejectionReason,
    this.reviewerName,
    this.requestSubmittedDate,
    this.category,
    this.documentUrl,
    this.openingHours,
    this.amenities,
    this.menuItems = const [],
  });

  /// จัดรูปแบบวันที่เป็นภาษาไทย พ.ศ. เช่น "2 ส.ค. 2569"
  String get formattedThaiDate {
    const List<String> thaiMonths = [
      'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
      'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'
    ];
    final int thaiYear = createdAt.year + 543;
    final String monthName = thaiMonths[createdAt.month - 1];
    return '${createdAt.day} $monthName $thaiYear';
  }

  /// จัดรูปแบบเวลาเป็นภาษาไทย เช่น "09.00 น."
  String get formattedThaiTime {
    final hour = createdAt.hour.toString().padLeft(2, '0');
    final minute = createdAt.minute.toString().padLeft(2, '0');
    return '$hour.$minute น.';
  }

  /// วันที่ส่งคำขอเป็นภาษาไทย เช่น "3 ส.ค. 2569"
  String get formattedRequestDate {
    final date = requestSubmittedDate ?? createdAt;
    const List<String> thaiMonths = [
      'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
      'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'
    ];
    final int thaiYear = date.year + 543;
    final String monthName = thaiMonths[date.month - 1];
    return '${date.day} $monthName $thaiYear';
  }

  /// ป้ายกำกับสถานะภาษาไทย
  String get statusThaiLabel {
    switch (status) {
      case 'approved':
        return 'อนุมัติ';
      case 'rejected':
        return 'ไม่อนุมัติ';
      case 'pending':
      default:
        return 'รออนุมัติ';
    }
  }

  RestaurantAdminModel copyWith({
    String? id,
    String? ownerId,
    String? ownerName,
    String? name,
    String? storeCode,
    String? address,
    String? mapUrl,
    double? lat,
    double? lng,
    String? phone,
    String? email,
    String? menu,
    String? imageUrl,
    String? status,
    DateTime? createdAt,
    String? rejectionReason,
    String? reviewerName,
    DateTime? requestSubmittedDate,
    bool clearRejection = false,
    String? category,
    String? documentUrl,
    Map<String, String>? openingHours,
    List<String>? amenities,
    List<RestaurantMenuItem>? menuItems,
  }) {
    return RestaurantAdminModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      name: name ?? this.name,
      storeCode: storeCode ?? this.storeCode,
      address: address ?? this.address,
      mapUrl: mapUrl ?? this.mapUrl,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      menu: menu ?? this.menu,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      rejectionReason: clearRejection ? null : (rejectionReason ?? this.rejectionReason),
      reviewerName: clearRejection ? null : (reviewerName ?? this.reviewerName),
      requestSubmittedDate: requestSubmittedDate ?? this.requestSubmittedDate,
      category: category ?? this.category,
      documentUrl: documentUrl ?? this.documentUrl,
      openingHours: openingHours ?? this.openingHours,
      amenities: amenities ?? this.amenities,
      menuItems: menuItems ?? this.menuItems,
    );
  }

  factory RestaurantAdminModel.fromJson(Map<String, dynamic> json) {
    List<RestaurantMenuItem> parsedMenuItems = [];
    if (json['menu_items'] != null && json['menu_items'] is List) {
      parsedMenuItems = (json['menu_items'] as List)
          .map((item) => RestaurantMenuItem.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    Map<String, String>? parsedOpeningHours;
    if (json['opening_hours'] != null && json['opening_hours'] is Map) {
      parsedOpeningHours = Map<String, String>.from(json['opening_hours'] as Map);
    } else if (json['operating_hours'] != null && json['operating_hours'] is List) {
      parsedOpeningHours = {};
      const dayNames = {
        1: 'จันทร์',
        2: 'อังคาร',
        3: 'พุธ',
        4: 'พฤหัสบดี',
        5: 'ศุกร์',
        6: 'เสาร์',
        7: 'อาทิตย์',
      };
      for (final h in (json['operating_hours'] as List)) {
        if (h is Map) {
          final dayNum = h['day_of_week'] as int? ?? 1;
          final dayName = dayNames[dayNum] ?? 'วัน $dayNum';
          if (h['is_closed'] == true) {
            parsedOpeningHours[dayName] = 'ปิดทำการ';
          } else {
            final openStr = (h['open_time']?.toString() ?? '08:00').substring(0, 5).replaceAll(':', '.');
            final closeStr = (h['close_time']?.toString() ?? '20:00').substring(0, 5).replaceAll(':', '.');
            parsedOpeningHours[dayName] = '$openStr - $closeStr';
          }
        }
      }
    }

    List<String>? parsedAmenities;
    if (json['amenities'] != null && json['amenities'] is List) {
      parsedAmenities = List<String>.from(json['amenities'] as List);
    }

    // Resolve ownerName from users relation if needed
    String ownerName = json['owner_name'] as String? ?? '';
    if (ownerName.isEmpty && json['users'] != null && json['users'] is Map) {
      final u = json['users'] as Map;
      final first = u['first_name']?.toString() ?? '';
      final last = u['last_name']?.toString() ?? '';
      ownerName = '$first $last'.trim();
    }
    if (ownerName.isEmpty) ownerName = 'ผู้ประกอบการ';

    // Resolve category from cuisine_types relation if needed
    String? category = json['category'] as String?;
    if (category == null || category.isEmpty) {
      if (json['cuisine_types'] != null && json['cuisine_types'] is Map) {
        category = json['cuisine_types']['name']?.toString();
      }
    }

    // Resolve imageUrl from restaurant_images relation if needed
    String? imageUrl = json['image_url'] as String?;
    if (imageUrl == null || imageUrl.isEmpty) {
      if (json['restaurant_images'] != null && json['restaurant_images'] is List) {
        final imgList = (json['restaurant_images'] as List).whereType<Map>().toList();
        final logo = imgList.firstWhere(
          (m) => m['is_logo'] == true || m['is_logo'] == 1,
          orElse: () => imgList.isNotEmpty ? imgList.first : {},
        );
        imageUrl = logo['image_url']?.toString();
        if (imageUrl == null || imageUrl.isEmpty) {
          if (imgList.isNotEmpty) {
            imageUrl = imgList.first['image_url']?.toString();
          }
        }
      }
    }
    if (imageUrl == null || imageUrl.isEmpty) {
      if (parsedMenuItems.isNotEmpty && parsedMenuItems.first.imageUrl != null) {
        imageUrl = parsedMenuItems.first.imageUrl;
      }
    }

    // Resolve phone & email from users if empty
    String phone = json['phone'] as String? ?? '';
    if (phone.isEmpty && json['users'] != null && json['users'] is Map) {
      phone = json['users']['phone']?.toString() ?? '';
    }
    String? email = json['email'] as String?;
    if ((email == null || email.isEmpty) && json['users'] != null && json['users'] is Map) {
      email = json['users']['email']?.toString();
    }

    // Resolve store code
    String? storeCode = json['store_code'] as String?;
    if (storeCode == null || storeCode.isEmpty) {
      final idStr = json['id']?.toString() ?? '';
      if (idStr.isNotEmpty) {
        storeCode = '111U${idStr.length >= 4 ? idStr.substring(0, 4).toUpperCase() : '0000'}';
      }
    }

    return RestaurantAdminModel(
      id: json['id'] as String? ?? '',
      ownerId: json['owner_id'] as String? ?? '',
      ownerName: ownerName,
      name: json['name'] as String? ?? '',
      storeCode: storeCode,
      address: json['address'] as String? ?? '',
      mapUrl: (json['google_maps_url'] ?? json['map_url'])?.toString(),
      lat: (json['lat'] as num?)?.toDouble() ?? 18.7883,
      lng: (json['lng'] as num?)?.toDouble() ?? 98.9853,
      phone: phone,
      email: email,
      menu: json['menu'] as String?,
      imageUrl: imageUrl,
      status: json['status'] as String? ?? 'pending',
      createdAt: (json['crated_at'] != null
              ? DateTime.tryParse(json['crated_at'].toString())
              : null) ??
          (json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString())
              : null) ??
          DateTime.now(),
      rejectionReason: json['rejection_reason'] as String?,
      reviewerName: json['reviewer_name'] as String?,
      requestSubmittedDate: json['request_submitted_date'] != null
          ? DateTime.tryParse(json['request_submitted_date'] as String)
          : null,
      category: category,
      documentUrl: json['document_url'] as String?,
      openingHours: parsedOpeningHours,
      amenities: parsedAmenities,
      menuItems: parsedMenuItems,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'owner_name': ownerName,
      'name': name,
      'store_code': storeCode,
      'address': address,
      'map_url': mapUrl,
      'lat': lat,
      'lng': lng,
      'phone': phone,
      'email': email,
      'menu': menu,
      'image_url': imageUrl,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'rejection_reason': rejectionReason,
      'reviewer_name': reviewerName,
      'request_submitted_date': requestSubmittedDate?.toIso8601String(),
      'category': category,
      'document_url': documentUrl,
      'opening_hours': openingHours,
      'amenities': amenities,
      'menu_items': menuItems.map((m) => m.toJson()).toList(),
    };
  }
}
