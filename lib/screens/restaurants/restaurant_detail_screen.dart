import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/favorite_manager.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? restaurantData;

  const RestaurantDetailScreen({
    super.key,
    this.restaurantData,
  });

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  late bool _isBookmarked;

  @override
  void initState() {
    super.initState();
    final name = widget.restaurantData?['name'] ?? 'ดังเจริญ';
    // Check FavoriteManager or restaurantData
    _isBookmarked = widget.restaurantData?['isBookmarked'] ??
        FavoriteManager.isFavorite(name);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  void _onBookmarkTapped() {
    HapticFeedback.selectionClick();
    if (_isBookmarked) {
      _showRemoveFavoriteDialog();
    } else {
      _showAddFavoriteDialog();
    }
  }

  /// Confirmation Dialog: "ต้องการเพิ่มในรายการโปรด"
  void _showAddFavoriteDialog() {
    final String name = widget.restaurantData?['name'] ?? 'ดังเจริญ';

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (BuildContext dialogContext) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 280,
              decoration: BoxDecoration(
                color: const Color(0xFFF7EAEC), // Tinted soft rose background matching screenshot
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFD4ADB5),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dialog Title Text: "ต้องการเพิ่มในรายการโปรด"
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 26),
                    child: Text(
                      'ต้องการเพิ่มในรายการโปรด',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF221F21),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),

                  // Horizontal Divider Line
                  Container(
                    height: 1.0,
                    color: const Color(0xFFD4ADB5),
                  ),

                  // Actions Row: ยกเลิก | ยืนยัน
                  SizedBox(
                    height: 48,
                    child: Row(
                      children: [
                        // Left Button: ยกเลิก
                        Expanded(
                          child: InkWell(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(18),
                            ),
                            onTap: () => Navigator.of(dialogContext).pop(),
                            child: const Center(
                              child: Text(
                                'ยกเลิก',
                                style: TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF221F21),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Vertical Divider Line
                        Container(
                          width: 1.0,
                          height: double.infinity,
                          color: const Color(0xFFD4ADB5),
                        ),

                        // Right Button: ยืนยัน
                        Expanded(
                          child: InkWell(
                            borderRadius: const BorderRadius.only(
                              bottomRight: Radius.circular(18),
                            ),
                            onTap: () {
                              Navigator.of(dialogContext).pop();
                              setState(() {
                                _isBookmarked = true;
                                widget.restaurantData?['isBookmarked'] = true;
                              });

                              // Sync with FavoriteManager
                              FavoriteManager.addFavorite(
                                _getCurrentRestaurantData(),
                              );

                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('เพิ่ม "$name" ในรายการโปรดเรียบร้อยแล้ว'),
                                  backgroundColor: const Color(0xFF6E162B),
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            },
                            child: const Center(
                              child: Text(
                                'ยืนยัน',
                                style: TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF221F21),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Confirmation Dialog: "ต้องการลบจากรายการโปรด"
  void _showRemoveFavoriteDialog() {
    final String name = widget.restaurantData?['name'] ?? 'ดังเจริญ';

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (BuildContext dialogContext) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 280,
              decoration: BoxDecoration(
                color: const Color(0xFFF7EAEC),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFD4ADB5),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dialog Title Text: "ต้องการลบจากรายการโปรด"
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 26),
                    child: Text(
                      'ต้องการลบจากรายการโปรด',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF221F21),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),

                  // Horizontal Divider Line
                  Container(
                    height: 1.0,
                    color: const Color(0xFFD4ADB5),
                  ),

                  // Actions Row: ยกเลิก | ยืนยัน
                  SizedBox(
                    height: 48,
                    child: Row(
                      children: [
                        // Left Button: ยกเลิก
                        Expanded(
                          child: InkWell(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(18),
                            ),
                            onTap: () => Navigator.of(dialogContext).pop(),
                            child: const Center(
                              child: Text(
                                'ยกเลิก',
                                style: TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF221F21),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Vertical Divider Line
                        Container(
                          width: 1.0,
                          height: double.infinity,
                          color: const Color(0xFFD4ADB5),
                        ),

                        // Right Button: ยืนยัน
                        Expanded(
                          child: InkWell(
                            borderRadius: const BorderRadius.only(
                              bottomRight: Radius.circular(18),
                            ),
                            onTap: () {
                              Navigator.of(dialogContext).pop();
                              setState(() {
                                _isBookmarked = false;
                                widget.restaurantData?['isBookmarked'] = false;
                              });

                              // Sync with FavoriteManager
                              FavoriteManager.removeFavorite(name);

                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('ลบ "$name" ออกจากรายการโปรดแล้ว'),
                                  backgroundColor: const Color(0xFF6E162B),
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            },
                            child: const Center(
                              child: Text(
                                'ยืนยัน',
                                style: TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF221F21),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Map<String, dynamic> _getCurrentRestaurantData() {
    if (widget.restaurantData != null) {
      return Map<String, dynamic>.from(widget.restaurantData!);
    }
    return {
      'name': 'ดังเจริญ',
      'category': 'ประเภทร้านอาหาร: อาหารญี่ปุ่น',
      'price': '฿฿ 89-109 บาท',
      'rating': 4.8,
      'image': 'assets/images/dang_jaroen.jpg',
      'isAsset': true,
      'isBookmarked': _isBookmarked,
    };
  }

  Future<void> _openMapLink(String urlString) async {
    final uri = Uri.parse(
      urlString.startsWith('http') ? urlString : 'https://$urlString',
    );
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      // Graceful fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    // Default restaurant data matching "User - Detailร้าน5" (ดังเจริญ)
    final String name = widget.restaurantData?['name'] ?? 'ดังเจริญ';
    final String category = widget.restaurantData?['category'] ?? 'อาหารญี่ปุ่น';
    final String image = widget.restaurantData?['image'] ?? 'assets/images/dang_jaroen.jpg';

    // Address & phone details
    final String address = widget.restaurantData?['address'] ??
        '84/2 ม.14 ถ.สุเทพ ต.สุเทพ อ.เมือง เมืองเชียงใหม่ เชียงใหม่';
    final String mapUrl = widget.restaurantData?['mapUrl'] ?? 'www.googlemap.com';
    final String phone = widget.restaurantData?['phone'] ?? '0951409878';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left_rounded,
            color: Color(0xFF6E162B),
            size: 32,
          ),
          onPressed: () => Navigator.of(context).pop(_isBookmarked),
        ),
        titleSpacing: 0,
        title: const Text(
          'รายละเอียดร้านอาหาร',
          style: TextStyle(
            fontSize: 18.5,
            fontWeight: FontWeight.w800,
            color: Color(0xFF6E162B),
            letterSpacing: -0.2,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.2),
          child: Container(
            color: const Color(0xFFE8D5D8),
            height: 1.2,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // SECTION 1: RESTAURANT OVERVIEW & BOOKMARK
            // ==========================================
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Restaurant Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: 86,
                    height: 86,
                    child: Image.asset(
                      image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFFF1ECEF),
                        child: const Icon(
                          Icons.restaurant_rounded,
                          color: Color(0xFF6E162B),
                          size: 36,
                        ),
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
                        name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF221F21),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        category.startsWith('ประเภท') ? category : 'ประเภทร้านอาหาร: $category',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B6568),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),

                // Bookmark Ribbon Icon (Outline when unbookmarked, Solid when bookmarked)
                GestureDetector(
                  onTap: _onBookmarkTapped,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                    child: Icon(
                      _isBookmarked
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: const Color(0xFF6E162B), // Signature burgundy
                      size: 32,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),
            _buildDivider(),
            const SizedBox(height: 14),

            // ==========================================
            // SECTION 2: ที่อยู่ ช่องทางติดต่อ (ADDRESS & CONTACT)
            // ==========================================
            _buildSectionHeader('ที่อยู่ ช่องทางติดต่อ'),
            const SizedBox(height: 10),

            // Address & Map Link
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2.0),
                  child: Icon(
                    Icons.location_on_outlined,
                    color: Color(0xFF6E162B),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        address,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF5A5255),
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () => _openMapLink(mapUrl),
                        child: Text(
                          mapUrl,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF4A89DC),
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
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
                  color: Color(0xFF6E162B),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  phone,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF5A5255),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),
            _buildDivider(),
            const SizedBox(height: 14),

            // ==========================================
            // SECTION 3: เวลาเปิด-ปิด (OPENING HOURS)
            // ==========================================
            _buildSectionHeader('เวลาเปิด-ปิด'),
            const SizedBox(height: 10),

            _buildHoursRow('อาทิตย์', '11.00 - 22.00'),
            _buildHoursRow('จันทร์', '11.00 - 14.00 และ 16.00 - 22.00'),
            _buildHoursRow('อังคาร', '11.00 - 14.00 และ 16.00 - 22.00'),
            _buildHoursRow('พุธ', '11.00 - 14.00 และ 16.00 - 22.00'),
            _buildHoursRow('พฤหัสบดี', '11.00 - 14.00 และ 16.00 - 22.00'),
            _buildHoursRow('ศุกร์', '11.00 - 14.00 และ 16.00 - 22.00'),
            _buildHoursRow('เสาร์', '11.00 - 22.00'),

            const SizedBox(height: 18),
            _buildDivider(),
            const SizedBox(height: 14),

            // ==========================================
            // SECTION 4: สิ่งอำนวยความสะดวก (AMENITIES 5 BADGES)
            // ==========================================
            _buildSectionHeader('สิ่งอำนวยความสะดวก'),
            const SizedBox(height: 12),

            // Row 1: 4 Badges
            Row(
              children: [
                Expanded(child: _buildAmenityBadge(Icons.two_wheeler_rounded, 'รถจักรยานยนต์')),
                const SizedBox(width: 10),
                Expanded(child: _buildAmenityBadge(Icons.local_shipping_rounded, 'เดลิเวอรี่')),
                const SizedBox(width: 10),
                Expanded(child: _buildAmenityBadge(Icons.groups_rounded, 'เหมาะกับกลุ่ม')),
                const SizedBox(width: 10),
                Expanded(child: _buildAmenityBadge(Icons.child_care_rounded, 'เหมาะกับเด็ก')),
              ],
            ),
            const SizedBox(height: 10),

            // Row 2: 1 Badge (เครื่องปรับอากาศ)
            Row(
              children: [
                SizedBox(
                  width: (MediaQuery.of(context).size.width - 40 - 30) / 4,
                  child: _buildAmenityBadge(Icons.ac_unit_rounded, 'เครื่องปรับอากาศ'),
                ),
              ],
            ),

            const SizedBox(height: 18),
            _buildDivider(),
            const SizedBox(height: 14),

            // ==========================================
            // SECTION 5: เมนูอาหาร (MENU ITEMS)
            // ==========================================
            _buildSectionHeader('เมนูอาหาร'),
            const SizedBox(height: 12),

            _buildMenuItem(
              name: 'ข้าวหน้าเนื้อเสือร้องไห้ออสเตรเลีย',
              price: '฿109',
              imagePath: image,
            ),
            const SizedBox(height: 14),
            _buildMenuItem(
              name: 'หมึกทอดสไปซี่',
              price: '฿89',
              imagePath: image,
            ),
            const SizedBox(height: 14),
            _buildMenuItem(
              name: 'ข้าวแกงกะหรี่หมูทอด',
              price: '฿109',
              imagePath: image,
            ),

            const SizedBox(height: 18),
            _buildDivider(),
            const SizedBox(height: 14),

            // ==========================================
            // SECTION 6: รีวิวร้านอาหาร (REVIEWS)
            // ==========================================
            Row(
              children: [
                _buildSectionHeader('รีวิวร้านอาหาร'),
                const SizedBox(width: 8),
                const Icon(
                  Icons.star_rounded,
                  color: Color(0xFF6E162B),
                  size: 20,
                ),
                const SizedBox(width: 4),
                const Text(
                  '4.8',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6E162B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Review Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFEFE8EB),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'UserA',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF221F21),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFF6E162B),
                        size: 17,
                      ),
                      const SizedBox(width: 3),
                      const Text(
                        '5.0',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF6E162B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'ร้านสะอาด มีห้องน้ำที่สะอาด สะดวกสบาย มีที่จอดรถเยอะ......',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF5A5255),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15.5,
        fontWeight: FontWeight.w800,
        color: Color(0xFF221F21),
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1.0,
      width: double.infinity,
      color: const Color(0xFFF2DDE1),
    );
  }

  Widget _buildHoursRow(String day, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            day,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF5A5255),
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF5A5255),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenityBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFF2DDE1),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: const Color(0xFF6E162B),
            size: 26,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF5A5255),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required String name,
    required String price,
    required String imagePath,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: 72,
            height: 72,
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFFF1ECEF),
                child: const Icon(
                  Icons.fastfood_rounded,
                  color: Color(0xFF6E162B),
                  size: 28,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF221F21),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                price,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF221F21),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
