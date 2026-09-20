class ApprovalMenuItem {
  final String name;
  final String ingredients;
  final String price;
  final String imageAsset;

  const ApprovalMenuItem({
    required this.name,
    required this.ingredients,
    required this.price,
    required this.imageAsset,
  });
}

class ApprovalRestaurant {
  final String id;
  final String name;
  final String code;
  final String category;
  final String lastUpdated;
  final String requestDate;
  final String address;
  final String mapUrl;
  final String phone;
  final String imageAsset;
  final Map<String, String> openingHours;
  final List<String> amenities;
  final List<ApprovalMenuItem> menuItems;
  final String status; // 'pending', 'approved', 'rejected'
  final String? rejectionReason;
  final String? rejectionDetails;
  final DateTime? revokedAt;

  const ApprovalRestaurant({
    required this.id,
    required this.name,
    required this.code,
    required this.category,
    required this.lastUpdated,
    required this.requestDate,
    required this.address,
    required this.mapUrl,
    required this.phone,
    required this.imageAsset,
    this.openingHours = const {},
    this.amenities = const [],
    this.menuItems = const [],
    required this.status,
    this.rejectionReason,
    this.rejectionDetails,
    this.revokedAt,
  });

  ApprovalRestaurant copyWith({
    String? id,
    String? name,
    String? code,
    String? category,
    String? lastUpdated,
    String? requestDate,
    String? address,
    String? mapUrl,
    String? phone,
    String? imageAsset,
    Map<String, String>? openingHours,
    List<String>? amenities,
    List<ApprovalMenuItem>? menuItems,
    String? status,
    String? rejectionReason,
    String? rejectionDetails,
    DateTime? revokedAt,
  }) {
    return ApprovalRestaurant(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      category: category ?? this.category,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      requestDate: requestDate ?? this.requestDate,
      address: address ?? this.address,
      mapUrl: mapUrl ?? this.mapUrl,
      phone: phone ?? this.phone,
      imageAsset: imageAsset ?? this.imageAsset,
      openingHours: openingHours ?? this.openingHours,
      amenities: amenities ?? this.amenities,
      menuItems: menuItems ?? this.menuItems,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      rejectionDetails: rejectionDetails ?? this.rejectionDetails,
      revokedAt: revokedAt ?? this.revokedAt,
    );
  }
}
