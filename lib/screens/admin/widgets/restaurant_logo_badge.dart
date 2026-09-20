import 'package:flutter/material.dart';

class RestaurantLogoBadge extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final double size;

  const RestaurantLogoBadge({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    if (name.contains('เตาอุ่น')) {
      return _buildTaoOonBadge();
    } else if (name.contains('KAME KAFE') || name.contains('Kame')) {
      return _buildKameKafeBadge();
    } else if (name.contains('สุกี้ช้างเผือก')) {
      return _buildSukiChangPhueakBadge();
    } else if (name.contains('Kohatsu')) {
      return _buildKohatsuBadge();
    } else if (name.contains('ข้าวบ้านก๋ง')) {
      return _buildGrandpaBadge();
    } else if (name.contains('Potto')) {
      return _buildPottoBadge();
    }

    // ร้านทั่วไป
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFFDECEF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF5D5DC)),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? Image.network(
              imageUrl!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(),
            )
          : _buildFallbackIcon(),
    );
  }

  Widget _buildFallbackIcon() {
    return Center(
      child: Icon(
        Icons.restaurant_rounded,
        color: const Color(0xFF7B182D),
        size: size * 0.45,
      ),
    );
  }

  /// Badge สไตล์ Kohatsu Matcha ตามรูปที่ 2 (แก้วชาเขียว)
  Widget _buildKohatsuBadge() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFE8EFE5),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (imageUrl != null)
            Image.network(
              imageUrl!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const SizedBox(),
            ),
          // Layer ข้อมูลร้าน Kohatsu Matcha
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFF1F6EC).withValues(alpha: 0.9),
                  Colors.white.withValues(alpha: 0.7),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Kohatsu',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF386641),
                    letterSpacing: -0.2,
                  ),
                ),
                const Text(
                  'こうはつまっちゃ',
                  style: TextStyle(
                    fontSize: 7,
                    color: Color(0xFF6A994E),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildDrinkCup(const Color(0xFF6A994E), const Color(0xFFD4E09B)),
                    const SizedBox(width: 4),
                    _buildDrinkCup(const Color(0xFF386641), Colors.white),
                    const SizedBox(width: 4),
                    _buildDrinkCup(const Color(0xFF81B29A), const Color(0xFFE9D8A6)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrinkCup(Color top, Color bottom) {
    return Container(
      width: 12,
      height: 18,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: Colors.grey.shade400, width: 0.5),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, bottom],
        ),
      ),
    );
  }

  /// Badge สไตล์ ข้าวบ้านก๋ง (คุณตาสวมหมวกใส่แว่นตา)
  Widget _buildGrandpaBadge() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAEAEA)),
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // หมวก
                    Container(
                      width: 38,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: Color(0xFF6C969D),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                    ),
                    // หน้าและแว่นตา
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Container(
                        width: 32,
                        height: 30,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFCEADE),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF4A4A4A), width: 1),
                        ),
                        child: const Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.remove_red_eye_outlined, size: 10, color: Color(0xFF333333)),
                              SizedBox(width: 2),
                              Icon(Icons.remove_red_eye_outlined, size: 10, color: Color(0xFF333333)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                const Text(
                  'ข้าวบ้านก๋ง',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF262626),
                  ),
                ),
                const Text(
                  'GRANDPA HOME KITCHEN',
                  style: TextStyle(
                    fontSize: 5.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF8C8C8C),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Badge สไตล์ Potto Hot Pot (วงกลมสีฟ้า Potto)
  Widget _buildPottoBadge() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5EA)),
      ),
      child: Center(
        child: Container(
          width: size - 12,
          height: size - 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF0077B6),
            border: Border.all(color: const Color(0xFF0096C7), width: 2),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'POTTO',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'พ็อตโตะ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 1),
              Text(
                'Hot Pot Master',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Badge สไตล์ เตาอุ่น (ภาพชั้นวางขนมปังเบเกอรี่อบอุ่นสดใหม่ ตรงตามภาพที่ 1 และ 3)
  Widget _buildTaoOonBadge() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFFBF4EB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8D7C3)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ภาพถ่ายชั้นวางขนมอบ เตาอุ่น
          Image.network(
            'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: const Color(0xFFEEDBC5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bakery_dining_rounded, color: Color(0xFF8D5B28), size: 32),
                  const SizedBox(height: 2),
                  Text(
                    'เตาอุ่น',
                    style: TextStyle(
                      fontSize: size * 0.14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF5B3914),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Gradient เงาด้านล่าง
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: size * 0.45,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.55),
                    Colors.transparent,
                  ],
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
              alignment: Alignment.bottomLeft,
              child: Text(
                'เตาอุ่น',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: size * 0.13,
                  shadows: const [
                    Shadow(color: Colors.black45, blurRadius: 3),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Badge สไตล์ KAME KAFE (แก้วเครื่องดื่มเย็น 4 แก้วบนโต๊ะตารางสีเขียว ตรงตามภาพที่ 1 และ 3)
  Widget _buildKameKafeBadge() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF7BA684),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF5E8B67)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // พื้นหลังลายตารางหมากรุกสีเขียว
          CustomPaint(
            painter: _GreenCheckeredPainter(),
          ),
          // แถวแก้วกาแฟ 4 แก้ว
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildMiniIcedCup(
                    topColor: const Color(0xFF3D271D), // กาแฟเข้ม
                    bottomColor: const Color(0xFF5C382A),
                    hasIce: true,
                  ),
                  _buildMiniIcedCup(
                    topColor: const Color(0xFFC79255), // ลาเต้
                    bottomColor: const Color(0xFFF6E7D2), // นม
                    hasIce: true,
                  ),
                  _buildMiniIcedCup(
                    topColor: const Color(0xFF477348), // มัทฉะเข้ม
                    bottomColor: const Color(0xFFF1F8EE), // นมสด
                    hasIce: true,
                  ),
                  _buildMiniIcedCup(
                    topColor: const Color(0xFFE27429), // ชาส้ม/พีช
                    bottomColor: const Color(0xFFF9C48F),
                    hasIce: true,
                  ),
                ],
              ),
            ),
          ),
          // ป้ายชื่อ KAME KAFE ด้านล่าง
          Positioned(
            left: 0,
            right: 0,
            bottom: 2,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'KAME KAFE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: size * 0.10,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniIcedCup({
    required Color topColor,
    required Color bottomColor,
    required bool hasIce,
  }) {
    final cupWidth = (size - 18) / 4.4;
    final cupHeight = size * 0.52;
    return Container(
      width: cupWidth,
      height: cupHeight,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.white, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ฝาแก้วใส
          Container(
            height: 3,
            color: Colors.white.withValues(alpha: 0.9),
          ),
          // ส่วนบนของน้ำ
          Container(
            height: cupHeight * 0.45,
            color: topColor,
          ),
          // ส่วนล่างของน้ำ (เช่น เลเยอร์นม)
          Expanded(
            child: Container(
              color: bottomColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Badge สไตล์ สุกี้ช้างเผือก (ตราโลโก้วงกลมรูปคุณลุงสวมแว่นตาขาว-ดำ ตรงตามภาพที่ 1 และ 3)
  Widget _buildSukiChangPhueakBadge() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // วงกลมดำรูปคุณลุงสุกี้ช้างเผือก
            Container(
              width: size * 0.62,
              height: size * 0.62,
              decoration: const BoxDecoration(
                color: Color(0xFF1E1E1E),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ศีรษะและแว่นตา
                    Icon(
                      Icons.face_rounded,
                      color: Colors.white,
                      size: size * 0.40,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'สุกี้ช้างเผือก',
              style: TextStyle(
                fontSize: size * 0.12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF222222),
                letterSpacing: -0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Painter วาดลายตารางหมากรุกสีเขียวสำหรับ KAME KAFE
class _GreenCheckeredPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final lightGreen = Paint()..color = const Color(0xFF88AF91);
    final darkGreen = Paint()..color = const Color(0xFF6B9475);

    const int cols = 6;
    const int rows = 6;
    final cellW = size.width / cols;
    final cellH = size.height / rows;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final paint = (r + c) % 2 == 0 ? lightGreen : darkGreen;
        canvas.drawRect(
          Rect.fromLTWH(c * cellW, r * cellH, cellW, cellH),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
