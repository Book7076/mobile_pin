import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart';
import '../../providers/auth_provider.dart';
import 'owner_dashboard_screen.dart';
import '../restaurants/open_restaurant_intro_screen.dart';
import '../../widgets/meal_mate_logo.dart';

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
  final String? status;

  const OwnerRestaurantItem({
    required this.id,
    required this.name,
    required this.category,
    this.imageUrl,
    this.assetPath,
    this.status,
  });
}

/// ผู้จัดการข้อมูลร้านอาหารของเจ้าของร้าน (สำหรับเก็บใน session หรือใช้ในการทดสอบ)
class OwnerRestaurantManager {
  static List<OwnerRestaurantItem> restaurants = [
    OwnerRestaurantItem(
      id: '1',
      name: 'THE CHICKEN',
      category: 'ร้านฟาสต์ฟู้ด',
      assetPath: 'assets/images/chicken.png',
      status: 'approved',
    ),
    OwnerRestaurantItem(
      id: '2',
      name: 'WANJOI',
      category: 'เบเกอรี่&เครื่องดื่ม',
      assetPath: 'assets/images/wanjoi.png',
      status: 'approved',
    ),
  ];

  static void addRestaurant(OwnerRestaurantItem item) {
    restaurants.add(item);
  }

  static void clear() {
    restaurants = [];
  }

  static void resetToDefault() {
    restaurants = [
      OwnerRestaurantItem(
        id: '1',
        name: 'THE CHICKEN',
        category: 'ร้านฟาสต์ฟู้ด',
        assetPath: 'assets/images/chicken.png',
        status: 'approved',
      ),
      OwnerRestaurantItem(
        id: '2',
        name: 'WANJOI',
        category: 'เบเกอรี่&เครื่องดื่ม',
        assetPath: 'assets/images/wanjoi.png',
        status: 'approved',
      ),
    ];
  }
}

/// หน้าจอ "เลือกร้านของคุณ" ก่อนเข้าหน้าแดชบอร์ดเจ้าของร้าน
class SelectRestaurantScreen extends ConsumerStatefulWidget {
  const SelectRestaurantScreen({super.key});

  @override
  ConsumerState<SelectRestaurantScreen> createState() => _SelectRestaurantScreenState();
}

class _SelectRestaurantScreenState extends ConsumerState<SelectRestaurantScreen> {
  List<OwnerRestaurantItem> _dbRestaurants = [];
  bool _isLoading = true;

  bool get _isSupabaseActive {
    try {
      return Supabase.instance.client != null;
    } catch (_) {
      return false;
    }
  }

  List<OwnerRestaurantItem> get _restaurantList =>
      _isSupabaseActive ? _dbRestaurants : OwnerRestaurantManager.restaurants;

  @override
  void initState() {
    super.initState();
    _loadOwnerRestaurants();
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

  /// ดึงข้อมูลร้านอาหารของ Owner ที่ล็อกอินอยู่จากตาราง restaurants ใน Supabase
  Future<void> _loadOwnerRestaurants() async {
    setState(() => _isLoading = true);

    try {
      final authUser = supabase.auth.currentUser;
      final riverpodUser = ref.read(authProvider);

      final currentUid = authUser?.id ?? riverpodUser?.id;
      final currentEmail = authUser?.email ?? riverpodUser?.email;

      List<dynamic> response = [];

      // 1. ค้นหาโดยใช้ ID จาก Authentication (Supabase Auth UID)
      if (currentUid != null && currentUid.isNotEmpty) {
        try {
          response = await supabase
              .from('restaurants')
              .select('*, cuisine_types(id, name)')
              .eq('owner_id', currentUid);
        } catch (e) {
          debugPrint('Error querying restaurants by owner_id ($currentUid): $e');
        }
      }

      // 2. สำรอง: ถ้าไม่พบ เผื่อกรณีข้อมูลใน DB บางแถวผูกกับ ID ในตาราง public users
      if (response.isEmpty && currentEmail != null && currentEmail.isNotEmpty) {
        try {
          final userRow = await supabase
              .from('users')
              .select('id')
              .eq('email', currentEmail)
              .maybeSingle();
          if (userRow != null && userRow['id'] != null && userRow['id'] != currentUid) {
            final altResponse = await supabase
                .from('restaurants')
                .select('*, cuisine_types(id, name)')
                .eq('owner_id', userRow['id']);
            if (altResponse.isNotEmpty) {
              response = altResponse;
            }
          }
        } catch (e) {
          debugPrint('Error querying fallback userRow: $e');
        }
      }

      if (response.isNotEmpty) {
        final items = <OwnerRestaurantItem>[];
        for (final data in response) {
          String category = 'ร้านอาหาร';
          if (data['cuisine_types'] != null && data['cuisine_types']['name'] != null) {
            category = data['cuisine_types']['name'].toString();
          } else {
            final cuisineId = data['cuisine_type_id'];
            if (cuisineId != null) {
              try {
                final int cId = (cuisineId as num).toInt();
                final cType = await supabase
                    .from('cuisine_types')
                    .select('name')
                    .eq('id', cId)
                    .maybeSingle();
                if (cType != null && cType['name'] != null) {
                  category = cType['name'].toString();
                }
              } catch (_) {}
            }
          }

          // ตรวจสอบรูปภาพจาก data['image_url'] หรือจากตาราง restaurant_images
          String? imgUrl = data['image_url']?.toString();
          if (imgUrl == null || imgUrl.isEmpty) {
            try {
              final imgRes = await supabase
                  .from('restaurant_images')
                  .select('image_url, is_logo, sort_order')
                  .eq('restaurant_id', data['id'])
                  .order('sort_order', ascending: true);
              if (imgRes is List && imgRes.isNotEmpty) {
                final match = imgRes.firstWhere(
                  (item) => item['is_logo'] == true,
                  orElse: () => imgRes.first,
                );
                if (match['image_url'] != null) {
                  imgUrl = match['image_url'].toString();
                }
              }
            } catch (_) {}
          }

          items.add(
            OwnerRestaurantItem(
              id: data['id']?.toString() ?? '',
              name: data['name']?.toString() ?? 'ร้านของฉัน',
              category: category,
              imageUrl: imgUrl,
              status: data['status']?.toString() ?? 'pending',
            ),
          );
        }
        if (mounted) {
          setState(() {
            _dbRestaurants = items;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _dbRestaurants = [];
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading owner restaurants from Supabase: $e');
      if (e.toString().contains('initialize the supabase instance') && mounted) {
        setState(() {
          _dbRestaurants = OwnerRestaurantManager.restaurants;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// นำทางเข้าสู่แดชบอร์ดของร้านนั้นทันที
  void _navigateToDashboard(OwnerRestaurantItem restaurant) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OwnerDashboardScreen(
          restaurantId: restaurant.id,
          restaurantName: restaurant.name,
          restaurantCategory: restaurant.category,
          restaurantImageUrl: restaurant.imageUrl ?? restaurant.assetPath,
        ),
      ),
    );
  }

  /// นำทางเข้าสู่หน้าลงทะเบียนร้านอาหารอีกครั้ง
  Future<void> _navigateToRegistration() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const OpenRestaurantIntroScreen(),
      ),
    );
    _loadOwnerRestaurants();
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
                // Back Button (Top Left)
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

                // Center MealMate Official App Logo (ปรับขนาดโลโก้ให้ใหญ่และเด่นกว่าตัวอักษร)
                const MealMateLogo(
                  size: 82,
                  showText: true,
                  textSize: 24,
                  textSpacing: 10,
                  ringColor: Colors.white,
                  iconColor: Colors.white,
                  animateHeart: false,
                ),
                const SizedBox(height: 6),

                // "เลือกร้านของคุณ" Subtitle
                const Text(
                  'เลือกร้านของคุณ',
                  style: TextStyle(
                    fontSize: 14.5,
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
            child: RefreshIndicator(
              onRefresh: _loadOwnerRestaurants,
              color: kOwnerPrimaryColor,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                children: [
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.0),
                        child: CircularProgressIndicator(color: kOwnerPrimaryColor),
                      ),
                    )
                  else if (_restaurantList.isEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
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
                      child: Column(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: const BoxDecoration(
                              color: kOwnerAddCardBg,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.storefront_outlined,
                              color: kOwnerPrimaryColor,
                              size: 38,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'ยังไม่มีร้านอาหารในระบบ',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: kOwnerPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'คุณยังไม่ได้ลงทะเบียนร้านอาหาร กดปุ่ม "เพิ่มร้านใหม่" ด้านล่างเพื่อเริ่มสร้างร้านอาหารของคุณ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.5,
                              color: Colors.grey[600],
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    // รายการร้านอาหารจริงจาก Supabase
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

                // ข้อมูลชื่อและหมวดหมู่ร้านค้า พร้อม Badge สถานะ
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              restaurant.category,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.normal,
                                color: Color(0xFF757575),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (restaurant.status != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: restaurant.status == 'approved'
                                    ? Colors.green.withOpacity(0.12)
                                    : Colors.orange.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                restaurant.status == 'approved' ? 'อนุมัติแล้ว' : 'รออนุมัติ',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: restaurant.status == 'approved' ? Colors.green[800] : Colors.orange[800],
                                ),
                              ),
                            ),
                          ],
                        ],
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
    if (restaurant.imageUrl != null && restaurant.imageUrl!.isNotEmpty) {
      if (restaurant.imageUrl!.startsWith('assets/')) {
        return Image.asset(
          restaurant.imageUrl!,
          fit: BoxFit.cover,
          width: 74,
          height: 74,
          errorBuilder: (_, __, ___) => _buildFallbackStoreIcon(restaurant),
        );
      }
      return Image.network(
        restaurant.imageUrl!,
        fit: BoxFit.cover,
        width: 74,
        height: 74,
        errorBuilder: (_, __, ___) => _buildFallbackStoreIcon(restaurant),
      );
    }

    if (restaurant.assetPath != null && restaurant.assetPath!.isNotEmpty) {
      return Image.asset(
        restaurant.assetPath!,
        fit: BoxFit.cover,
        width: 74,
        height: 74,
        errorBuilder: (_, __, ___) => _buildFallbackStoreIcon(restaurant),
      );
    }

    return _buildFallbackStoreIcon(restaurant);
  }

  Widget _buildFallbackStoreIcon(OwnerRestaurantItem restaurant) {
    final initial = restaurant.name.trim().isNotEmpty
        ? restaurant.name.trim().substring(0, 1).toUpperCase()
        : 'R';

    return Container(
      color: kOwnerAddCardBg,
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: kOwnerPrimaryColor,
          ),
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
