import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'go_to_owner_screen.dart';

class OpenRestaurantIntroScreen extends StatefulWidget {
  const OpenRestaurantIntroScreen({super.key});

  @override
  State<OpenRestaurantIntroScreen> createState() => _OpenRestaurantIntroScreenState();
}

class _OpenRestaurantIntroScreenState extends State<OpenRestaurantIntroScreen> {
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

  void _navigateToRegistration() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const GoToOwnerScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ==========================================
          // 1. TOP SOLID BURGUNDY HEADER
          // ==========================================
          Container(
            color: const Color(0xFF6E162B),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 14,
              bottom: 16,
              left: 14,
              right: 14,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.chevron_left_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const Expanded(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(right: 34),
                      child: Text(
                        'เปิดร้านอาหาร',
                        style: TextStyle(
                          fontSize: 19.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ==========================================
          // 2. SCROLLABLE INTRO BODY
          // ==========================================
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
              child: Column(
                children: [
                  const SizedBox(height: 6),

                  // Hero Title
                  const Text(
                    'เปิดร้านอาหารกับ MealMate',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF6E162B),
                      letterSpacing: -0.3,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Hero Subtitle
                  const Text(
                    'ขยายฐานลูกค้าให้ร้านอาหารของคุณ เข้าถึงนักศึกษาและบุคลากร\nรอบมหาวิทยาลัยเชียงใหม่ได้ทันที',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF666666),
                      height: 1.45,
                    ),
                  ),

                  const SizedBox(height: 22),

                  // 3 White Metric Cards
                  Row(
                    children: [
                      // Metric 1: 50+
                      Expanded(
                        child: _buildMetricCard(
                          value: '50+',
                          label: 'ร้านค้าที่เข้าร่วม',
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Metric 2: 2-3
                      Expanded(
                        child: _buildMetricCard(
                          value: '2-3',
                          label: 'กิโลเมตรรอบ มช.',
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Metric 3: ฿0
                      Expanded(
                        child: _buildMetricCard(
                          value: '฿0',
                          label: 'ไม่มีค่าใช้จ่ายใน\nการลงทะเบียน',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 3 Key Benefit Cards
                  _buildBenefitCard(
                    title: 'เข้าถึงลูกค้าใกล้ร้าน',
                    description:
                        'ร้านของคุณจะแสดงในหน้าปัดของผู้ใช้งานทันทีหลังผ่านการอนุมัติ',
                  ),
                  const SizedBox(height: 12),

                  _buildBenefitCard(
                    title: 'จัดการร้านได้เองแบบเรียลไทม์',
                    description:
                        'สามารถแก้ไขเมนู ราคา เวลาเปิด-ปิด ได้โดยไม่ต้องรออนุมัติซ้ำ',
                  ),
                  const SizedBox(height: 12),

                  _buildBenefitCard(
                    title: 'เหมาะกับร้านทุกขนาด',
                    description:
                        'โดยเฉพาะร้านเปิดใหม่หรือร้านที่ต้องการเพิ่มการมองเห็น สำหรับกลุ่มนักศึกษาและบุคลากร',
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // ==========================================
          // 3. BOTTOM BUTTON & DIVIDER
          // ==========================================
          Container(
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 1.0,
                  color: const Color(0xFFF2DDE1),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 14,
                    bottom: MediaQuery.of(context).padding.bottom + 14,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6E162B),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        shadowColor: const Color(0x336E162B),
                      ),
                      onPressed: _navigateToRegistration,
                      child: const Text(
                        'เริ่มลงทะเบียนร้าน',
                        style: TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.2,
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
    );
  }

  /// Metric Card (White background, soft border, burgundy highlight)
  Widget _buildMetricCard({
    required String value,
    required String label,
  }) {
    return Container(
      height: 98,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFF2DDE1),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w800,
                color: Color(0xFF6E162B),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF555555),
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Benefit Card (Light pink/blush background, white circular icon, bold title & description)
  Widget _buildBenefitCard({
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF6F7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFFAEAEC),
          width: 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Circular White Store Icon Container
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6E162B).withOpacity(0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.storefront_outlined,
                color: Color(0xFF6E162B),
                size: 26,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Benefit Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6E162B),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF555555),
                    height: 1.35,
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
