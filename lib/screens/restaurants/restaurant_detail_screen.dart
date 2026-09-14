import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

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
    // Default to true (filled bookmark ribbon) as requested
    _isBookmarked = widget.restaurantData?['isBookmarked'] ?? true;

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

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isBookmarked
              ? 'บันทึกในรายการโปรดเรียบร้อยแล้ว'
              : 'ลบออกจากรายการโปรดแล้ว',
        ),
        backgroundColor: const Color(0xFF6E162B),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
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
    // Default data from user reference image if not provided
    final String name = widget.restaurantData?['name'] ?? 'RawTruckr';
    final String category =
        widget.restaurantData?['category'] ?? 'อาหารเกาหลี';
    final String image =
        widget.restaurantData?['image'] ?? 'assets/images/rawtruckr.jpg';

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
          onPressed: () => Navigator.of(context).pop(),
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
                        'ประเภทร้านอาหาร: $category',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B6568),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),

                // Filled Bookmark Ribbon (ป้ายแสดงสีที่เต็มช่อง)
                GestureDetector(
                  onTap: _toggleBookmark,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 2.0),
                    child: Icon(
                      _isBookmarked
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: const Color(0xFF6E162B), // Deep signature wine red
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
                      const Text(
                        '7/5 ถนน สุเทพ ตำบล สุเทพ อำเภอเมืองเชียงใหม่ เชียงใหม่',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF5A5255),
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () => _openMapLink('www.googlemap.com'),
                        child: const Text(
                          'www.googlemap.com',
                          style: TextStyle(
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
                const Text(
                  '0944498544',
                  style: TextStyle(
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
            _buildHoursRow('จันทร์', '11.00 - 22.00'),
            _buildHoursRow('อังคาร', '11.00 - 22.00'),
            _buildHoursRow('พุธ', '11.00 - 22.00'),
            _buildHoursRow('พฤหัสบดี', '11.00 - 22.00'),
            _buildHoursRow('ศุกร์', '11.00 - 22.00'),
            _buildHoursRow('เสาร์', '11.00 - 22.00'),

            const SizedBox(height: 18),
            _buildDivider(),
            const SizedBox(height: 14),

            // ==========================================
            // SECTION 4: สิ่งอำนวยความสะดวก (AMENITIES GRID)
            // ==========================================
            _buildSectionHeader('สิ่งอำนวยความสะดวก'),
            const SizedBox(height: 12),

            // 2 Rows of 4 Badges each
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildAmenityBadge(Icons.wifi_rounded, 'มีอินเทอร์เน็ต'),
                _buildAmenityBadge(Icons.directions_car_rounded, 'ที่จอดรถยนต์'),
                _buildAmenityBadge(Icons.two_wheeler_rounded, 'รถจักรยานยนต์'),
                _buildAmenityBadge(Icons.local_shipping_rounded, 'เดลิเวอรี่'),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildAmenityBadge(Icons.ac_unit_rounded, 'เครื่องปรับอากาศ'),
                _buildAmenityBadge(Icons.wc_rounded, 'มีห้องน้ำ'),
                _buildAmenityBadge(Icons.groups_rounded, 'เหมาะกับกลุ่ม'),
                _buildAmenityBadge(Icons.child_care_rounded, 'เหมาะกับเด็ก'),
              ],
            ),

            const SizedBox(height: 18),
            _buildDivider(),
            const SizedBox(height: 14),

            // ==========================================
            // SECTION 5: เมนูอาหาร (MENU)
            // ==========================================
            _buildSectionHeader('เมนูอาหาร'),
            const SizedBox(height: 14),

            // Menu Item 1: ไก่ทอดเกาหลี
            _buildMenuItem(
              title: 'ไก่ทอดเกาหลี',
              description: 'มีส่วนประกอบของแป้งสาลี, ไข่',
              price: '฿125-550',
              imagePath: 'assets/images/menu_korean_chicken.jpg',
            ),

            const SizedBox(height: 14),

            // Menu Item 2: รามยอน โรเซ่
            _buildMenuItem(
              title: 'รามยอน โรเซ่',
              description: 'มีส่วนประกอบของแป้งสาลี, ไข่',
              price: '฿230',
              imagePath: 'assets/images/menu_ramyeon.jpg',
            ),

            const SizedBox(height: 18),
            _buildDivider(),
            const SizedBox(height: 14),

            // ==========================================
            // SECTION 6: รีวิวร้านอาหาร (REVIEWS)
            // ==========================================
            Row(
              children: const [
                Text(
                  'รีวิวร้านอาหาร',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF221F21),
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.star_rounded,
                  color: Color(0xFF6E162B),
                  size: 19,
                ),
                SizedBox(width: 3),
                Text(
                  '4.5',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF221F21),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Review Card 1
            _buildReviewCard(
              username: 'UserA',
              rating: 5.0,
              comment: 'ร้านสะอาด มีห้องน้ำที่สะอาด สะดวกสบาย มีที่จอดรถเยอะ......',
            ),

            const SizedBox(height: 10),

            // Review Card 2
            _buildReviewCard(
              username: 'UserB',
              rating: 4.0,
              comment: 'อาหารอร่อยแต่รออาหารค่อนข้างนาน......',
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

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
      color: const Color(0xFFEFE6E7),
    );
  }

  Widget _buildHoursRow(String day, String hours) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            day,
            style: const TextStyle(fontSize: 13, color: Color(0xFF5A5255)),
          ),
          Text(
            hours,
            style: const TextStyle(fontSize: 13, color: Color(0xFF5A5255)),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenityBadge(IconData icon, String label) {
    return Container(
      width: 76,
      height: 68,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEAD8DB), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: const Color(0xFF6E162B),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF221F21),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required String title,
    required String description,
    required String price,
    required String imagePath,
  }) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: 64,
            height: 64,
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
                title,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF221F21),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF7E777B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                price,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF221F21),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard({
    required String username,
    required double rating,
    required String comment,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEAD8DB), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                username,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF221F21),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.star_rounded,
                color: Color(0xFF6E162B),
                size: 15,
              ),
              const SizedBox(width: 2),
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3F3B3E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            comment,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF5A5255),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
