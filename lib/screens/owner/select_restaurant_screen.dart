import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'owner_dashboard_screen.dart';
import '../restaurants/open_restaurant_intro_screen.dart';

/// สีหลักของฝั่งเจ้าของร้าน (Burgundy / Red Maroon)
const Color kOwnerPrimaryColor = Color(0xFF7C1431);
const Color kOwnerBorderColor = Color(0xFFF0E5E7);
const Color kOwnerAddCardBg = Color(0xFFF9ECEF);
const Color kOwnerAddCardBorder = Color(0xFFEAD4D8);

/// โมเดลข้อมูลร้านอาหารของเจ้าของร้าน
class OwnerRestaurantItem {
  final String id;
  final String name;
  final String category;
  final String? imageUrl;
  final String? assetPath;

  const OwnerRestaurantItem({
    required this.id,
    required this.name,
    required this.category,
    this.imageUrl,
    this.assetPath,
  });
}

/// ผู้จัดการข้อมูลร้านอาหารของเจ้าของร้าน (In-memory session storage)
class OwnerRestaurantManager {
  static final List<OwnerRestaurantItem> _defaultList = [
    const OwnerRestaurantItem(
      id: '1',
      name: 'THE CHICKEN',
      category: 'ร้านฟาสต์ฟู้ด',
      imageUrl: 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=500&auto=format&fit=crop&q=80',
      assetPath: 'assets/images/menu_korean_chicken.jpg',
    ),
    const OwnerRestaurantItem(
      id: '2',
      name: 'WANJOI',
      category: 'เบเกอรี่&เครื่องดื่ม',
      imageUrl: 'https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=500&auto=format&fit=crop&q=80',
      assetPath: 'assets/images/the_volcano.jpg',
    ),
  ];

  static List<OwnerRestaurantItem> restaurants = List.from(_defaultList);

  static void addRestaurant(OwnerRestaurantItem item) {
    restaurants.add(item);
  }

  static void resetToDefault() {
    restaurants = List.from(_defaultList);
  }
}

/// หน้าจอ "เลือกร้านของคุณ" ก่อนเข้าหน้าแดชบอร์ดเจ้าของร้าน
class SelectRestaurantScreen extends StatefulWidget {
  const SelectRestaurantScreen({super.key});

  @override
  State<SelectRestaurantScreen> createState() => _SelectRestaurantScreenState();
}

class _SelectRestaurantScreenState extends State<SelectRestaurantScreen> {
  List<OwnerRestaurantItem> get _restaurantList => OwnerRestaurantManager.restaurants;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  /// นำทางเข้าสู่แดชบอร์ดของร้านนั้นทันที
  void _navigateToDashboard(OwnerRestaurantItem restaurant) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OwnerDashboardScreen(
          restaurantName: restaurant.name,
          restaurantCategory: restaurant.category,
          restaurantImageUrl: restaurant.imageUrl ?? restaurant.assetPath,
        ),
      ),
    );
  }

  /// นำทางเข้าสู่หน้าลงทะเบียนร้านอาหารอีกครั้ง
  void _navigateToRegistration() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const OpenRestaurantIntroScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      body: Column(
        children: [
          // ==========================================
          // 1. TOP BURGUNDY HEADER
          // ==========================================
          Container(
            width: double.infinity,
            color: kOwnerPrimaryColor,
            padding: EdgeInsets.only(
              top: statusBarHeight + 8,
              bottom: 22,
              left: 8,
              right: 8,
            ),
            child: Column(
              children: [
                // Top row with Back button
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.chevron_left_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),

                // Center MealMate Cutlery Logo
                const _PlateForkKnifeLogo(width: 68, height: 50),
                const SizedBox(height: 12),

                // "MealMate" Brand Text (Courier/Monospace look matching design)
                const Text(
                  'MealMate',
                  style: TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2.2,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 6),

                // "เลือกร้านของคุณ" Subtitle
                const Text(
                  'เลือกร้านของคุณ',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),

          // ==========================================
          // 2. RESTAURANTS LIST & ADD BUTTON
          // ==========================================
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              children: [
                // รายการร้านอาหารที่มี
                for (final restaurant in _restaurantList) ...[
                  _buildRestaurantCard(restaurant),
                  const SizedBox(height: 16),
                ],

                // การ์ดปุ่ม "เพิ่มร้านใหม่"
                _buildAddRestaurantCard(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// การ์ดร้านอาหารแต่ละร้าน (พื้นหลังขาว, รูปทรงกลมซ้าย, ชื่อ+หมวดหมู่ตรงกลาง, ลูกศรขวา)
  Widget _buildRestaurantCard(OwnerRestaurantItem restaurant) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kOwnerBorderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _navigateToDashboard(restaurant),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // รูปภาพร้านค้าทรงกลม
                Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFF2E6E8), width: 1.2),
                    color: Colors.white,
                  ),
                  child: ClipOval(
                    child: _buildRestaurantAvatar(restaurant),
                  ),
                ),
                const SizedBox(width: 16),

                // ข้อมูลชื่อและหมวดหมู่ร้านค้า
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        restaurant.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: kOwnerPrimaryColor,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        restaurant.category,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.normal,
                          color: Color(0xFF757575),
                        ),
                      ),
                    ],
                  ),
                ),

                // ลูกศรชี้ขวา (สีแดงเลือดหมู)
                const Icon(
                  Icons.chevron_right_rounded,
                  color: kOwnerPrimaryColor,
                  size: 38,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// แสดงรูปภาพ Avatar ของร้านค้า
  Widget _buildRestaurantAvatar(OwnerRestaurantItem restaurant) {
    final isChicken = restaurant.name.toUpperCase().contains('CHICKEN');
    final isWanjoi = restaurant.name.toUpperCase().contains('WANJOI');

    if (isChicken) {
      return Image.network(
        'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=500&auto=format&fit=crop&q=80',
        fit: BoxFit.cover,
        width: 74,
        height: 74,
        errorBuilder: (_, __, ___) => Image.asset(
          'assets/images/menu_korean_chicken.jpg',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFFE5A65E),
            child: const Icon(Icons.fastfood, color: Colors.white, size: 36),
          ),
        ),
      );
    }

    if (isWanjoi) {
      return Image.network(
        'https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=500&auto=format&fit=crop&q=80',
        fit: BoxFit.cover,
        width: 74,
        height: 74,
        errorBuilder: (_, __, ___) => Container(
          color: const Color(0xFF2E2421),
          child: const Center(
            child: Icon(Icons.bakery_dining_rounded, size: 36, color: Color(0xFFFFCC80)),
          ),
        ),
      );
    }

    // กรณีร้านอื่นๆ ที่เพิ่มเข้ามาใหม่
    if (restaurant.imageUrl != null && restaurant.imageUrl!.isNotEmpty) {
      return Image.network(
        restaurant.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallbackStoreIcon(restaurant),
      );
    }

    return _buildFallbackStoreIcon(restaurant);
  }

  Widget _buildFallbackStoreIcon(OwnerRestaurantItem restaurant) {
    return Container(
      color: kOwnerAddCardBg,
      child: const Center(
        child: Icon(
          Icons.restaurant_rounded,
          color: kOwnerPrimaryColor,
          size: 32,
        ),
      ),
    );
  }

  /// การ์ดปุ่ม "เพิ่มร้านใหม่" (พื้นหลังสีชมพูอ่อน ขอบเส้นประวงกลมพร้อมเครื่องหมาย +)
  Widget _buildAddRestaurantCard() {
    return Container(
      decoration: BoxDecoration(
        color: kOwnerAddCardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kOwnerAddCardBorder, width: 1.4),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _navigateToRegistration,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: [
                // วงกลมเส้นประพร้อมไอคอน +
                SizedBox(
                  width: 52,
                  height: 52,
                  child: CustomPaint(
                    painter: _DottedCirclePainter(
                      color: kOwnerPrimaryColor,
                      strokeWidth: 1.5,
                      dotCount: 18,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.add_rounded,
                        color: kOwnerPrimaryColor,
                        size: 30,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),

                // ข้อความ "เพิ่มร้านใหม่"
                const Text(
                  'เพิ่มร้านใหม่',
                  style: TextStyle(
                    fontSize: 18.5,
                    fontWeight: FontWeight.w800,
                    color: kOwnerPrimaryColor,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// PAINTERS
// ============================================================================

/// วาดโลโก้ MealMate รูปช้อนส้อม จานตรงกลาง และมีด (สีขาวตามภาพ mockup)
class _PlateForkKnifeLogo extends StatelessWidget {
  final double width;
  final double height;
  final Color color;

  const _PlateForkKnifeLogo({
    this.width = 68,
    this.height = 50,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _PlateForkKnifePainter(color: color),
    );
  }
}

class _PlateForkKnifePainter extends CustomPainter {
  final Color color;
  _PlateForkKnifePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // 1. Center Plate: solid circular disc
    final plateRadius = h * 0.40;
    final plateCenter = Offset(w * 0.50, h * 0.48);
    canvas.drawCircle(plateCenter, plateRadius, paint);

    // 2. Left Fork
    final forkCenterX = w * 0.23;
    final forkHandleWidth = w * 0.045;

    // Handle
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(forkCenterX, h * 0.72),
          width: forkHandleWidth,
          height: h * 0.44,
        ),
        const Radius.circular(2),
      ),
      paint,
    );

    // Base bar
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(forkCenterX, h * 0.48),
          width: w * 0.13,
          height: h * 0.08,
        ),
        const Radius.circular(2),
      ),
      paint,
    );

    // 3 Prongs
    const prongs = 3;
    final prongWidth = forkHandleWidth * 0.7;
    final prongSpacing = (w * 0.13 - prongWidth) / (prongs - 1);
    final prongLeft = forkCenterX - (w * 0.13) / 2 + prongWidth / 2;
    for (int i = 0; i < prongs; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            prongLeft + i * prongSpacing - prongWidth / 2,
            h * 0.16,
            prongWidth,
            h * 0.32,
          ),
          const Radius.circular(1.5),
        ),
        paint,
      );
    }

    // 3. Right Knife
    final knifeCenterX = w * 0.77;

    // Handle
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(knifeCenterX, h * 0.72),
          width: forkHandleWidth,
          height: h * 0.44,
        ),
        const Radius.circular(2),
      ),
      paint,
    );

    // Knife Blade: curved edge at outer top
    final knifePath = Path();
    knifePath.moveTo(knifeCenterX - forkHandleWidth / 2, h * 0.50);
    knifePath.lineTo(knifeCenterX - forkHandleWidth / 2, h * 0.16);
    knifePath.quadraticBezierTo(
      knifeCenterX + w * 0.075,
      h * 0.19,
      knifeCenterX + forkHandleWidth / 2,
      h * 0.50,
    );
    knifePath.close();
    canvas.drawPath(knifePath, paint);
  }

  @override
  bool shouldRepaint(covariant _PlateForkKnifePainter oldDelegate) =>
      oldDelegate.color != color;
}

/// วาดวงกลมเส้นประ (Dotted / Dashed Circle) สำหรับปุ่ม "เพิ่มร้านใหม่"
class _DottedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final int dotCount;

  _DottedCirclePainter({
    required this.color,
    this.strokeWidth = 1.6,
    this.dotCount = 18,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    const totalAngle = 2 * 3.141592653589793;
    final stepAngle = totalAngle / dotCount;
    final dashAngle = stepAngle * 0.5;

    for (int i = 0; i < dotCount; i++) {
      final startAngle = i * stepAngle;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        dashAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DottedCirclePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.dotCount != dotCount;
}
