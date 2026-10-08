import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../home/home_screen.dart';
import 'owner_stats_screen.dart';
import 'owner_menu_screen.dart';
import 'owner_restaurant_info_screen.dart';
import 'owner_reviews_screen.dart';
import 'owner_help_center_screen.dart';

/// สีหลักของแบรนด์ตามภาพ (แดงเบอร์กันดี / เลือดหมูเข้ม)
const Color kOwnerPrimaryColor = Color(0xFF7C1431);
const Color kOwnerBorderColor = Color(0xFFF3E7EA);
const Color kOwnerButtonGrey = Color(0xFFD6D0D3);

class OwnerDashboardScreen extends StatefulWidget {
  final String? restaurantId;
  final String restaurantName;
  final String? restaurantCategory;
  final String? restaurantImageUrl;

  const OwnerDashboardScreen({
    super.key,
    this.restaurantId,
    this.restaurantName = 'The CHICKEN',
    this.restaurantCategory,
    this.restaurantImageUrl,
  });

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  late String _displayName;
  String? _displayCategory;
  String? _displayImageUrl;

  @override
  void initState() {
    super.initState();
    _displayName = widget.restaurantName;
    _displayCategory = widget.restaurantCategory;
    _displayImageUrl = widget.restaurantImageUrl;
    _refreshRestaurantData();
  }

  Future<void> _refreshRestaurantData() async {
    if (widget.restaurantId == null) return;
    try {
      final res = await Supabase.instance.client
          .from('restaurants')
          .select('*, cuisine_types(id, name)')
          .eq('id', widget.restaurantId!)
          .maybeSingle();

      if (res != null && mounted) {
        setState(() {
          _displayName = res['name']?.toString() ?? _displayName;
          if (res['image_url'] != null && res['image_url'].toString().isNotEmpty) {
            _displayImageUrl = res['image_url'].toString();
          }
          if (res['cuisine_types'] != null && res['cuisine_types']['name'] != null) {
            _displayCategory = res['cuisine_types']['name'].toString();
          }
        });

        if (_displayImageUrl == null || _displayImageUrl!.isEmpty) {
          try {
            final imgRes = await Supabase.instance.client
                .from('restaurant_images')
                .select('image_url, is_logo, sort_order')
                .eq('restaurant_id', widget.restaurantId!)
                .order('sort_order', ascending: true);
            if (imgRes is List && imgRes.isNotEmpty && mounted) {
              final match = imgRes.firstWhere(
                (item) => item['is_logo'] == true,
                orElse: () => imgRes.first,
              );
              if (match['image_url'] != null) {
                setState(() {
                  _displayImageUrl = match['image_url'].toString();
                });
              }
            }
          } catch (_) {}
        }

        if (res['cuisine_types'] == null || res['cuisine_types']['name'] == null) {
          final cTypeId = res['cuisine_type_id'];
          if (cTypeId != null) {
            try {
              final int cId = (cTypeId as num).toInt();
              final cType = await Supabase.instance.client
                  .from('cuisine_types')
                  .select('name')
                  .eq('id', cId)
                  .maybeSingle();
              if (cType != null && cType['name'] != null && mounted) {
                setState(() {
                  _displayCategory = cType['name'].toString();
                });
              }
            } catch (_) {}
          }
        }
      }
    } catch (_) {}
  }

  void _handleBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const HomeScreen(initialIndex: 2),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final topBarHeight = screenSize.height * 0.22;
    const avatarDiameter = 190.0;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // พื้นหลังด้านบนสีแดงเลือดหมูเข้ม
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: topBarHeight,
              child: Container(
                color: kOwnerPrimaryColor,
              ),
            ),

          // เนื้อหาหลักที่เลื่อนได้ (กันล้นหน้าจอทุกขนาด)
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // เว้นระยะจากขอบบนให้ตรงกับขอบล่างของแถบสี
                  SizedBox(height: topBarHeight - MediaQuery.of(context).padding.top - (avatarDiameter / 2)),

                  // รูปโปรไฟล์ร้านค้าทรงกลมตรงกลาง
                  Center(
                    child: Container(
                      width: avatarDiameter,
                      height: avatarDiameter,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: Colors.white, width: 4.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: _buildRestaurantAvatar(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // แสดงชื่อร้านอาหารที่เลือก
                  Text(
                    _displayName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: kOwnerPrimaryColor,
                      letterSpacing: 0.4,
                    ),
                  ),
                  if (_displayCategory != null && _displayCategory!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      _displayCategory!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // ตารางเมนูกดเลือก 5 เมนู
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        // แถวที่ 1: สถิติ, เมนูอาหาร, ข้อมูลร้าน
                        Row(
                          children: [
                            Expanded(
                              child: _buildMenuCard(
                                title: 'สถิติ',
                                icon: const _StatsChartIcon(color: kOwnerPrimaryColor, size: 46),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => OwnerStatsScreen(
                                      restaurantId: widget.restaurantId,
                                      restaurantName: _displayName,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _buildMenuCard(
                                title: 'เมนูอาหาร',
                                icon: const _FoodMenuIcon(color: kOwnerPrimaryColor, size: 46),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => OwnerMenuScreen(
                                      restaurantId: widget.restaurantId,
                                      restaurantName: _displayName,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _buildMenuCard(
                                title: 'ข้อมูลร้าน',
                                icon: const _StoreInfoIcon(color: kOwnerPrimaryColor, size: 46),
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => OwnerRestaurantInfoScreen(
                                        restaurantId: widget.restaurantId,
                                        restaurantName: _displayName,
                                        restaurantCategory: _displayCategory,
                                        restaurantImageUrl: _displayImageUrl,
                                      ),
                                    ),
                                  );
                                  _refreshRestaurantData();
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // แถวที่ 2: รีวิว (ว่าง 2 ช่องเพื่อรักษา Grid 3 คอลัมน์)
                        Row(
                          children: [
                            Expanded(
                              child: _buildMenuCard(
                                title: 'รีวิว',
                                icon: const _ReviewSmileIcon(color: kOwnerPrimaryColor, size: 46),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => OwnerReviewsScreen(
                                      restaurantId: widget.restaurantId,
                                      restaurantName: _displayName,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            // ช่องว่างเพื่อให้คอลัมน์ขนาดเท่ากันตรงเป๊ะ
                            const Expanded(child: SizedBox()),
                            const SizedBox(width: 14),
                            const Expanded(child: SizedBox()),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 50),

                  // ปุ่มศูนย์ช่วยเหลือติดต่อฝ่ายบริการลูกค้า
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const OwnerHelpCenterScreen()),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: kOwnerButtonGrey,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'ศูนย์ช่วยเหลือติดต่อฝ่ายบริการลูกค้า',
                            style: TextStyle(
                              color: kOwnerPrimaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // ปุ่มย้อนกลับด้านบนซ้าย (วางไว้ชั้นบนสุดของ Stack เพื่อให้แตะกดได้ 100% ไม่ถูก ScrollView ทับ)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                  child: IconButton(
                    icon: const Icon(
                      Icons.chevron_left_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                    onPressed: _handleBack,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  /// การ์ดเมนูสี่เหลี่ยมสีขาว ขอบมน เงาละมุน
  Widget _buildMenuCard({
    required String title,
    required Widget icon,
    required VoidCallback onTap,
  }) {
    return AspectRatio(
      aspectRatio: 0.96,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kOwnerBorderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: kOwnerPrimaryColor.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            splashColor: kOwnerPrimaryColor.withOpacity(0.12),
            highlightColor: kOwnerPrimaryColor.withOpacity(0.06),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Center(child: icon),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: kOwnerPrimaryColor,
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// รูปภาพโปรไฟล์ของร้านอาหารที่เลือก
  Widget _buildRestaurantAvatar() {
    if (_displayImageUrl != null && _displayImageUrl!.isNotEmpty) {
      if (_displayImageUrl!.startsWith('assets/')) {
        return Image.asset(
          _displayImageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallbackAvatar(),
        );
      }
      return Image.network(
        _displayImageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallbackAvatar(),
      );
    }
    return _buildFallbackAvatar();
  }

  Widget _buildFallbackAvatar() {
    final nameUpper = _displayName.toUpperCase();
    if (nameUpper.contains('CHICKEN')) {
      return _buildDefaultChickenLogo();
    }
    if (nameUpper.contains('WANJOI')) {
      return _buildDefaultWanjoiLogo();
    }
    return Container(
      color: const Color(0xFFF9ECEF),
      child: const Center(
        child: Icon(
          Icons.storefront_rounded,
          color: kOwnerPrimaryColor,
          size: 64,
        ),
      ),
    );
  }

  /// โลโก้ของร้าน "WANJOI" (บิงซู / เบเกอรี่)
  Widget _buildDefaultWanjoiLogo() {
    return Container(
      color: const Color(0xFF2E2421),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.network(
            'https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=500&auto=format&fit=crop&q=80',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, __, ___) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bakery_dining_rounded, size: 60, color: Colors.orange[200]),
                  const SizedBox(height: 6),
                  const Text(
                    'WANJOI',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// โลโก้ไก่ทอด "The CHICKEN" แบบเดียวกับในภาพ
  Widget _buildDefaultChickenLogo() {
    return Container(
      color: Colors.white,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ภาพไก่ทอดด้านล่าง
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 125,
            child: Image.network(
              'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=500&auto=format&fit=crop&q=80',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFFE5A65E),
                child: const Icon(Icons.fastfood, size: 55, color: Colors.white),
              ),
            ),
          ),

          // ตัวหนังสือ "The CHICKEN" ด้านบน
          Positioned(
            top: 14,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'The',
                  style: TextStyle(
                    fontSize: 22,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w400,
                    color: Colors.brown[700],
                    height: 0.9,
                  ),
                ),
                const Text(
                  'CHICKEN',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFD61825),
                    letterSpacing: 1.2,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ไอคอนวาดด้วย CustomPainter ให้รูปทรงและลายเส้นตรงกับภาพต้นฉบับ 100%
// ---------------------------------------------------------------------------

/// 1. ไอคอน สถิติ (กราฟเส้นพร้อมแกนพิกัด L)
class _StatsChartIcon extends StatelessWidget {
  final Color color;
  final double size;

  const _StatsChartIcon({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _StatsPainter(color: color),
    );
  }
}

class _StatsPainter extends CustomPainter {
  final Color color;
  _StatsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // แกน L (แกน Y และ X)
    final axisPath = Path();
    axisPath.moveTo(w * 0.15, h * 0.20);
    axisPath.lineTo(w * 0.15, h * 0.85);
    axisPath.lineTo(w * 0.85, h * 0.85);
    canvas.drawPath(axisPath, paint);

    // เส้นกราฟที่พุ่งขึ้น
    final chartPath = Path();
    chartPath.moveTo(w * 0.28, h * 0.68);
    chartPath.lineTo(w * 0.44, h * 0.42);
    chartPath.lineTo(w * 0.60, h * 0.55);
    chartPath.lineTo(w * 0.84, h * 0.26);
    canvas.drawPath(chartPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 2. ไอคอน เมนูอาหาร (ชามอาหารพร้อมไอร้อน 3 เส้น)
class _FoodMenuIcon extends StatelessWidget {
  final Color color;
  final double size;

  const _FoodMenuIcon({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _FoodMenuPainter(color: color),
    );
  }
}

class _FoodMenuPainter extends CustomPainter {
  final Color color;
  _FoodMenuPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // เส้นไอร้อน 3 เส้นด้านบน
    final steam1 = Path()
      ..moveTo(w * 0.35, h * 0.32)
      ..cubicTo(w * 0.38, h * 0.25, w * 0.32, h * 0.20, w * 0.35, h * 0.14);
    canvas.drawPath(steam1, paint);

    final steam2 = Path()
      ..moveTo(w * 0.50, h * 0.32)
      ..cubicTo(w * 0.53, h * 0.25, w * 0.47, h * 0.20, w * 0.50, h * 0.14);
    canvas.drawPath(steam2, paint);

    final steam3 = Path()
      ..moveTo(w * 0.65, h * 0.32)
      ..cubicTo(w * 0.68, h * 0.25, w * 0.62, h * 0.20, w * 0.65, h * 0.14);
    canvas.drawPath(steam3, paint);

    // ปากชาม (เส้นตรงแนวนอนขอบชาม)
    canvas.drawLine(Offset(w * 0.16, h * 0.42), Offset(w * 0.84, h * 0.42), paint);

    // ตัวชามครึ่งวงรี
    final bowlPath = Path()
      ..moveTo(w * 0.20, h * 0.42)
      ..cubicTo(w * 0.20, h * 0.76, w * 0.80, h * 0.76, w * 0.80, h * 0.42);
    canvas.drawPath(bowlPath, paint);

    // ฐานชามด้านล่าง
    canvas.drawLine(Offset(w * 0.38, h * 0.77), Offset(w * 0.62, h * 0.77), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 3. ไอคอน ข้อมูลร้าน (บ้านพร้อมรูปหัวใจข้างใน)
class _StoreInfoIcon extends StatelessWidget {
  final Color color;
  final double size;

  const _StoreInfoIcon({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _StoreInfoPainter(color: color),
    );
  }
}

class _StoreInfoPainter extends CustomPainter {
  final Color color;
  _StoreInfoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // โครงบ้านและหลังคา
    final housePath = Path();
    housePath.moveTo(w * 0.15, h * 0.45);
    housePath.lineTo(w * 0.50, h * 0.18);
    housePath.lineTo(w * 0.85, h * 0.45);
    housePath.lineTo(w * 0.80, h * 0.45);
    housePath.lineTo(w * 0.80, h * 0.85);
    housePath.lineTo(w * 0.20, h * 0.85);
    housePath.lineTo(w * 0.20, h * 0.45);
    housePath.close();
    canvas.drawPath(housePath, strokePaint);

    // รูปหัวใจตรงกลางบ้าน (Filled)
    final heartPath = Path();
    final cx = w * 0.50;
    final cy = h * 0.62;
    const s = 0.8;

    heartPath.moveTo(cx, cy + (6 * s));
    heartPath.cubicTo(cx - (12 * s), cy - (2 * s), cx - (12 * s), cy - (11 * s), cx - (5 * s), cy - (11 * s));
    heartPath.cubicTo(cx - (1 * s), cy - (11 * s), cx, cy - (7 * s), cx, cy - (5 * s));
    heartPath.cubicTo(cx, cy - (7 * s), cx + (1 * s), cy - (11 * s), cx + (5 * s), cy - (11 * s));
    heartPath.cubicTo(cx + (12 * s), cy - (11 * s), cx + (12 * s), cy - (2 * s), cx, cy + (6 * s));
    heartPath.close();

    canvas.drawPath(heartPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 4. ไอคอน รีวิว (ใบหน้ายิ้มกลมพร้อมดวงตาและรอยยิ้ม)
class _ReviewSmileIcon extends StatelessWidget {
  final Color color;
  final double size;

  const _ReviewSmileIcon({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _ReviewSmilePainter(color: color),
    );
  }
}

class _ReviewSmilePainter extends CustomPainter {
  final Color color;
  _ReviewSmilePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // วงกลมใบหน้า
    canvas.drawCircle(Offset(w * 0.50, h * 0.50), w * 0.36, strokePaint);

    // ดวงตาทรงกลม 2 ข้าง
    canvas.drawCircle(Offset(w * 0.38, h * 0.42), w * 0.05, dotPaint);
    canvas.drawCircle(Offset(w * 0.62, h * 0.42), w * 0.05, dotPaint);

    // รอยยิ้ม
    final smilePath = Path()
      ..moveTo(w * 0.33, h * 0.56)
      ..cubicTo(w * 0.40, h * 0.74, w * 0.60, h * 0.74, w * 0.67, h * 0.56);
    canvas.drawPath(smilePath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
