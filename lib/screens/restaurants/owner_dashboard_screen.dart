import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import 'shop_details_screen.dart';
import 'edit_shop_photo_screen.dart';

class OwnerDashboardScreen extends StatefulWidget {
  final Map<String, dynamic>? shopData;

  const OwnerDashboardScreen({
    super.key,
    this.shopData,
  });

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  // Theme Color: Dark Maroon matching the reference
  static const Color maroonColor = Color(0xFF7A1428);
  static const Color cardBorderColor = Color(0xFFF2E6E8);

  bool _isInitialized = false;
  late Map<String, dynamic> _shopData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _shopData = Map<String, dynamic>.from(widget.shopData ?? routeArgs ?? {});
      _isInitialized = true;
    }
  }

  void _navigateTo(String title, {String? namedRoute, Widget? screen}) {
    if (screen != null) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => screen),
      );
      return;
    }

    if (namedRoute != null) {
      // Check if named route exists
      Navigator.of(context).pushNamed(namedRoute).catchError((_) {
        // Fallback to placeholder if route not found
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => OwnerPlaceholderScreen(title: title)),
        );
      });
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => OwnerPlaceholderScreen(title: title)),
    );
  }

  void _onBackToUserProfile() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const HomeScreen(initialIndex: 2),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic restaurant information from previous flow
    final String shopName = _shopData['name']?.toString().isNotEmpty == true
        ? _shopData['name'].toString()
        : 'THE CHICKEN';

    final String? imageUrl = (_shopData['imageUrl'] != null && _shopData['imageUrl'].toString().trim().isNotEmpty)
        ? _shopData['imageUrl'].toString()
        : null;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _onBackToUserProfile();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // --- Top Header Section with Overlapping Restaurant Circle Avatar ---
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                // Maroon Header Box
                Container(
                  width: double.infinity,
                  height: 190,
                  color: maroonColor,
                  child: SafeArea(
                    bottom: false,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12, top: 4),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 22,
                          ),
                          onPressed: _onBackToUserProfile,
                        ),
                      ),
                    ),
                  ),
                ),

                // Restaurant Logo / Image Circle Avatar (Overlapping header and body)
                Positioned(
                  top: 70,
                  child: Container(
                    width: 190,
                    height: 190,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFBF4E8), // Warm beige ring matching reference
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(6),
                    child: ClipOval(
                      child: (imageUrl != null && imageUrl.trim().isNotEmpty)
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const CustomPaint(
                                  size: Size(190, 190),
                                  painter: AvatarPlaceholderPainter(),
                                );
                              },
                            )
                          : const CustomPaint(
                              size: Size(190, 190),
                              painter: AvatarPlaceholderPainter(),
                            ),
                    ),
                  ),
                ),
              ],
            ),

          // Space for bottom half of the overlapping circle avatar (190 / 2 - 25 offset ≈ 80px)
          const SizedBox(height: 85),

          // --- 5 Core Section Cards & Bottom Customer Support Button ---
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Row 1: สถิติ, เมนูอาหาร, ข้อมูลร้าน
                  Row(
                    children: [
                      // 1. สถิติ (Statistics)
                      Expanded(
                        child: _buildMenuCard(
                          title: 'สถิติ',
                          iconWidget: CustomPaint(
                            size: const Size(36, 36),
                            painter: _StatChartPainter(maroonColor),
                          ),
                          onTap: () => _navigateTo('สถิติ', namedRoute: '/owner-statistics'),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // 2. เมนูอาหาร (Menu Management Placeholder)
                      Expanded(
                        child: _buildMenuCard(
                          title: 'เมนูอาหาร',
                          iconWidget: const Icon(
                            Icons.soup_kitchen_outlined,
                            color: maroonColor,
                            size: 38,
                          ),
                          onTap: () => _navigateTo('เมนูอาหาร', namedRoute: '/menu-management'),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // 3. ข้อมูลร้าน (Shop Details Screen)
                      Expanded(
                        child: _buildMenuCard(
                          title: 'ข้อมูลร้าน',
                          iconWidget: SizedBox(
                            width: 38,
                            height: 38,
                            child: Stack(
                              alignment: Alignment.center,
                              children: const [
                                Icon(
                                  Icons.home_outlined,
                                  color: maroonColor,
                                  size: 38,
                                ),
                                Positioned(
                                  top: 15,
                                  child: Icon(
                                    Icons.favorite,
                                    color: maroonColor,
                                    size: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onTap: () async {
                            final updated = await Navigator.of(context).push<Map<String, dynamic>>(
                              MaterialPageRoute(
                                builder: (_) => ShopDetailsScreen(shopData: _shopData),
                              ),
                            );
                            if (updated != null) {
                              setState(() {
                                _shopData = Map<String, dynamic>.from(updated);
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Row 2: ข้อความ, รีวิว, (ว่าง 1 ช่องเพื่อรักษา Grid 3 คอลัมน์)
                  Row(
                    children: [
                      // 4. ข้อความ (Messages Placeholder)
                      Expanded(
                        child: _buildMenuCard(
                          title: 'ข้อความ',
                          iconWidget: const Icon(
                            Icons.sms,
                            color: maroonColor,
                            size: 36,
                          ),
                          onTap: () => _navigateTo('ข้อความ', namedRoute: '/owner-messages'),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // 5. รีวิว (Reviews Placeholder)
                      Expanded(
                        child: _buildMenuCard(
                          title: 'รีวิว',
                          iconWidget: const Icon(
                            Icons.sentiment_satisfied_alt,
                            color: maroonColor,
                            size: 38,
                          ),
                          onTap: () => _navigateTo('รีวิว', namedRoute: '/owner-reviews'),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Empty slot to balance 3-column layout
                      const Expanded(
                        child: SizedBox(),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Bottom Customer Support Button
                  Container(
                    width: double.infinity,
                    height: 52,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1CFD4), // Soft grey background matching reference
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _navigateTo(
                          'ศูนย์ช่วยเหลือติดต่อฝ่ายบริการลูกค้า',
                          namedRoute: '/owner-support',
                        ),
                        child: const Center(
                          child: Text(
                            'ศูนย์ช่วยเหลือติดต่อฝ่ายบริการลูกค้า',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: maroonColor,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
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

  Widget _buildMenuCard({
    required String title,
    required Widget iconWidget,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 98,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: maroonColor.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              iconWidget,
              const SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: maroonColor,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Painter for the exact trendline chart icon in "สถิติ"
class _StatChartPainter extends CustomPainter {
  final Color color;

  _StatChartPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // L-shaped axes
    final axesPath = Path()
      ..moveTo(4, 5)
      ..lineTo(4, size.height - 4)
      ..lineTo(size.width - 4, size.height - 4);
    canvas.drawPath(axesPath, paint);

    // Trendline inside
    final linePath = Path()
      ..moveTo(10, size.height - 11)
      ..lineTo(size.width * 0.42, size.height * 0.46)
      ..lineTo(size.width * 0.62, size.height * 0.58)
      ..lineTo(size.width - 8, size.height * 0.24);
    canvas.drawPath(linePath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Minimal placeholder screen for partner features / unimplemented sections
class OwnerPlaceholderScreen extends StatelessWidget {
  final String title;

  const OwnerPlaceholderScreen({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: const Color(0xFF7A1428),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF1F2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.construction_rounded,
                  size: 56,
                  color: Color(0xFF7A1428),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'หน้านี้อยู่ระหว่างการพัฒนาโดยทีมงาน',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
