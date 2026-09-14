import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants.dart';
import '../../models/restaurant_model.dart';
import '../../models/review_model.dart';
import '../../providers/restaurant_provider.dart';

/// Restaurant Detail Screen matching Mockup Image 4:
/// - Header: Back arrow (<) + "รายละเอียดร้านอาหาร" in Burgundy
/// - Restaurant card: Square thumbnail, name, category, bookmark button
/// - ที่อยู่ ช่องทางติดต่อ: Map pin, address, googlemap link, phone
/// - เวลาเปิด-ปิด: 7 days schedule (อาทิตย์ - เสาร์)
/// - สิ่งอำนวยความสะดวก: 4 feature cards (เหมาะกับกลุ่ม, เครื่องปรับอากาศ, รถจักรยานยนต์, มีห้องน้ำ)
/// - เมนูอาหาร: Square dishes (บุฟเฟต์ ฿249, กุ้งดอง, etc.)
/// - รีวิวร้านอาหาร: Star rating + Review cards (UserA, UserB) + Write review button
class RestaurantDetailScreen extends ConsumerWidget {
  final String restaurantId;

  const RestaurantDetailScreen({super.key, required this.restaurantId});

  Future<void> _openMap(String address, double lat, double lng) async {
    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  Future<void> _callPhone(String phone) async {
    final cleanPhone = phone.replaceAll(' ', '').replaceAll('-', '');
    final telUrl = Uri.parse('tel:$cleanPhone');
    try {
      if (await canLaunchUrl(telUrl)) {
        await launchUrl(telUrl);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurants = ref.watch(restaurantsProvider);
    final restaurant = restaurants.firstWhere(
      (r) => r.id == restaurantId,
      orElse: () => RestaurantModel(
        id: '',
        ownerId: '',
        name: 'ไม่พบข้อมูลร้าน',
        address: '',
        lat: 0,
        lng: 0,
        phone: '',
        status: 'approved',
      ),
    );

    if (restaurant.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppConstants.burgundyPrimary,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'รายละเอียดร้านอาหาร',
            style: TextStyle(
              color: AppConstants.burgundyPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(child: Text('ไม่พบข้อมูลร้านอาหารนี้')),
      );
    }

    final reviews = ref
        .watch(reviewsProvider.notifier)
        .getReviewsForRestaurant(restaurant.id);
    final isFav = restaurant.isFavorite;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppConstants.burgundyPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: const Text(
          'รายละเอียดร้านอาหาร',
          style: TextStyle(
            color: AppConstants.burgundyPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFF1F5F9), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Restaurant Header Card
            _buildRestaurantHeaderCard(context, ref, restaurant, isFav),

            const SizedBox(height: 16),
            const Divider(color: Color(0xFFE2E8F0), thickness: 0.8),
            const SizedBox(height: 16),

            // 2. ที่อยู่ ช่องทางติดต่อ
            _buildContactSection(context, restaurant),

            const SizedBox(height: 16),
            const Divider(color: Color(0xFFE2E8F0), thickness: 0.8),
            const SizedBox(height: 16),

            // 3. เวลาเปิด-ปิด
            _buildOpeningHoursSection(restaurant),

            const SizedBox(height: 16),
            const Divider(color: Color(0xFFE2E8F0), thickness: 0.8),
            const SizedBox(height: 16),

            // 4. สิ่งอำนวยความสะดวก
            _buildAmenitiesSection(restaurant),

            const SizedBox(height: 16),
            const Divider(color: Color(0xFFE2E8F0), thickness: 0.8),
            const SizedBox(height: 16),

            // 5. เมนูอาหาร
            _buildMenuSection(restaurant),

            const SizedBox(height: 16),
            const Divider(color: Color(0xFFE2E8F0), thickness: 0.8),
            const SizedBox(height: 16),

            // 6. รีวิวร้านอาหาร
            _buildReviewsSection(context, ref, restaurant, reviews),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// 1. Top Restaurant Header Card matching Mockup
  Widget _buildRestaurantHeaderCard(
    BuildContext context,
    WidgetRef ref,
    RestaurantModel restaurant,
    bool isFav,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Square Image
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 105,
            height: 105,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: restaurant.imageUrls.isNotEmpty
                ? Image.network(
                    restaurant.imageUrls.first,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Center(
                      child: Icon(
                        Icons.restaurant,
                        color: Color(0xFFCBD5E1),
                        size: 36,
                      ),
                    ),
                  )
                : const Center(
                    child: Icon(
                      Icons.restaurant,
                      color: Color(0xFFCBD5E1),
                      size: 36,
                    ),
                  ),
          ),
        ),

        const SizedBox(width: 16),

        // Name & Category
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                restaurant.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                'ประเภทร้านอาหาร: ${_getCategorySubtitle(restaurant)}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        // Bookmark Icon Button
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: Icon(
            isFav ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            color: AppConstants.burgundyPrimary,
            size: 30,
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            ref
                .read(restaurantsProvider.notifier)
                .toggleFavorite(restaurant.id);
          },
        ),
      ],
    );
  }

  String _getCategorySubtitle(RestaurantModel restaurant) {
    if (restaurant.id == 'rest_shabu_mouood') {
      return 'ชาบู, หมูกระทะ';
    }
    if (restaurant.id == 'rest_rawtruckr') {
      return 'อาหารเกาหลี';
    }
    if (restaurant.id == 'rest_teds_coffee') {
      return 'กาแฟ, ขนมหวาน/เบเกอรี่';
    }
    if (restaurant.categories.isNotEmpty) {
      final names = restaurant.categories.map((catId) {
        for (final c in AppConstants.flowCategories) {
          if (c['id'] == catId) return c['name'] as String;
        }
        return catId;
      }).toList();
      return names.join(', ');
    }
    return 'อาหารทั่วไป';
  }

  /// 2. ที่อยู่ ช่องทางติดต่อ
  Widget _buildContactSection(
    BuildContext context,
    RestaurantModel restaurant,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ที่อยู่ ช่องทางติดต่อ',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),

        // Address & Google Map link
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.location_on_outlined,
              color: AppConstants.burgundyPrimary,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.address.isNotEmpty
                        ? restaurant.address
                        : '83 ถนน สุเทพ ตำบลสุเทพ อำเภอเมืองเชียงใหม่',
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFF334155),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 2),
                  InkWell(
                    onTap: () => _openMap(
                      restaurant.address,
                      restaurant.lat,
                      restaurant.lng,
                    ),
                    child: const Text(
                      'www.googlemap.com',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF1D4ED8),
                        decoration: TextDecoration.underline,
                        decorationColor: Color(0xFF1D4ED8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Phone
        Row(
          children: [
            const Icon(
              Icons.phone_outlined,
              color: AppConstants.burgundyPrimary,
              size: 20,
            ),
            const SizedBox(width: 10),
            InkWell(
              onTap: () => _callPhone(restaurant.phone),
              child: Text(
                restaurant.phone.isNotEmpty ? restaurant.phone : '095 446 1156',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF334155),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 3. เวลาเปิด-ปิด Schedule
  Widget _buildOpeningHoursSection(RestaurantModel restaurant) {
    final days = [
      'อาทิตย์',
      'จันทร์',
      'อังคาร',
      'พุธ',
      'พฤหัสบดี',
      'ศุกร์',
      'เสาร์',
    ];

    final hours = restaurant.openHours.isNotEmpty
        ? restaurant.openHours.replaceAll(' น.', '')
        : '11.00 - 23.00';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'เวลาเปิด-ปิด',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 10),
        Column(
          children: days.map((day) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    day,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFF475569),
                    ),
                  ),
                  Text(
                    hours,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFF334155),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 4. สิ่งอำนวยความสะดวก (8 items in 2 rows of 4 matching Mockup Image 1)
  Widget _buildAmenitiesSection(RestaurantModel restaurant) {
    final List<Map<String, dynamic>> allAmenities = [
      {'icon': Icons.wifi_rounded, 'label': 'มีอินเทอร์เน็ต'},
      {'icon': Icons.directions_car_rounded, 'label': 'ที่จอดรถยนต์'},
      {'icon': Icons.two_wheeler_rounded, 'label': 'รถจักรยานยนต์'},
      {'icon': Icons.delivery_dining_rounded, 'label': 'เดลิเวอรี่'},
      {'icon': Icons.ac_unit_rounded, 'label': 'เครื่องปรับอากาศ'},
      {'icon': Icons.favorite_border_rounded, 'label': 'มีห้องน้ำ'},
      {'icon': Icons.groups_rounded, 'label': 'เหมาะกับกลุ่ม'},
      {'icon': Icons.child_care_rounded, 'label': 'เหมาะกับเด็ก'},
    ];

    final row1 = allAmenities.sublist(0, 4);
    final row2 = allAmenities.sublist(4, 8);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'สิ่งอำนวยความสะดวก',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: row1.map((item) => _buildAmenityCard(item)).toList(),
        ),
        const SizedBox(height: 10),
        Row(
          children: row2.map((item) => _buildAmenityCard(item)).toList(),
        ),
      ],
    );
  }

  Widget _buildAmenityCard(Map<String, dynamic> item) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 2,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFF1F5F9),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item['icon'] as IconData,
              color: AppConstants.burgundyPrimary,
              size: 26,
            ),
            const SizedBox(height: 6),
            Text(
              item['label'] as String,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// 5. เมนูอาหาร
  Widget _buildMenuSection(RestaurantModel restaurant) {
    final dishes = restaurant.signatureDishes.isNotEmpty
        ? restaurant.signatureDishes
        : [
            SignatureDish(
              name: 'บุฟเฟต์',
              price: 249,
              imageUrl: restaurant.imageUrls.isNotEmpty
                  ? restaurant.imageUrls.first
                  : 'https://images.unsplash.com/photo-1547928576-a4a33237cbc3?w=400&q=80',
            ),
            SignatureDish(
              name: 'กุ้งดอง',
              price: 0,
              imageUrl:
                  'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=400&q=80',
            ),
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'เมนูอาหาร',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 14),
        Column(
          children: dishes.map((dish) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 90,
                      height: 75,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child:
                          (dish.imageUrl != null && dish.imageUrl!.isNotEmpty)
                          ? Image.network(
                              dish.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const Icon(
                                Icons.restaurant,
                                color: Color(0xFFCBD5E1),
                                size: 28,
                              ),
                            )
                          : const Icon(
                              Icons.restaurant,
                              color: Color(0xFFCBD5E1),
                              size: 28,
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dish.name,
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        if (dish.description != null &&
                            dish.description!.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            dish.description!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          dish.formattedPrice,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 6. รีวิวร้านอาหาร
  Widget _buildReviewsSection(
    BuildContext context,
    WidgetRef ref,
    RestaurantModel restaurant,
    List<ReviewModel> reviews,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row: รีวิวร้านอาหาร + Star + Rating (Matching Mockup Image 4)
        Row(
          children: [
            const Text(
              'รีวิวร้านอาหาร',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.star_rounded,
              color: AppConstants.burgundyPrimary,
              size: 20,
            ),
            const SizedBox(width: 3),
            Text(
              '${restaurant.rating}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Reviews Cards
        if (reviews.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Text(
              'ยังไม่มีรีวิวสำหรับร้านนี้ เป็นคนแรกที่รีวิวเลย!',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
              textAlign: TextAlign.center,
            ),
          )
        else
          Column(
            children: reviews.map((rev) {
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFF1F5F9),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          rev.userName,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.star_rounded,
                          color: AppConstants.burgundyPrimary,
                          size: 16,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          rev.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      rev.comment,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF475569),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
