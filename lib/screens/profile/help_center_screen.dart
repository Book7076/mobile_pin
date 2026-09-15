import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
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

  void _showFaqDetail({
    required String question,
    required String answer,
    required IconData icon,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7EAEC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(icon, color: const Color(0xFF6E162B), size: 22),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question,
                    style: const TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF221F21),
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(height: 1.0, color: const Color(0xFFF3DFE2)),
            const SizedBox(height: 18),
            Text(
              answer,
              style: const TextStyle(
                fontSize: 14.5,
                color: Color(0xFF555555),
                height: 1.55,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6E162B),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text(
                  'เข้าใจแล้ว',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
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
                        'ศูนย์ช่วยเหลือ',
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
          // 2. SCROLLABLE FAQ LIST
          // ==========================================
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title: คำถามที่พบบ่อย
                  const Text(
                    'คำถามที่พบบ่อย',
                    style: TextStyle(
                      fontSize: 17.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E1E1E),
                      letterSpacing: -0.2,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 1. วิธีการใช้งานแอปพลิเคชั่น?
                  _buildFaqCard(
                    icon: Icons.storefront_outlined,
                    question: 'วิธีการใช้งานแอปพลิเคชั่น?',
                    answer:
                        'คุณสามารถค้นหาร้านอาหารที่ต้องการจากแถบค้นหา หรือเลือกดูตามหมวดหมู่อาหารยอดนิยม และกดดูรายละเอียดร้านอาหาร รวมถึงตำแหน่งที่ตั้งและเมนูเด็ดได้ทันที',
                  ),

                  const SizedBox(height: 12),

                  // 2. เมื่อเจอร้านที่ถูกใจแล้วทำยังไงต่อ?
                  _buildFaqCard(
                    icon: Icons.access_time_rounded,
                    question: 'เมื่อเจอร้านที่ถูกใจแล้วทำยังไงต่อ?',
                    answer:
                        'คุณสามารถกดบันทึกเป็น "รายการโปรด" โดยแตะที่ป้ายบุ๊กมาร์กมุมขวาบน หรือกดโทรเพื่อติดต่อสอบถาม และกดปุ่มแผนที่เพื่อนำทางไปยังร้านอาหารได้ทันที',
                  ),

                  const SizedBox(height: 12),

                  // 3. วิธีการเปลี่ยนอีเมลและเบอร์โทร?
                  _buildFaqCard(
                    icon: Icons.edit_outlined,
                    question: 'วิธีการเปลี่ยนอีเมลและเบอร์โทร?',
                    answer:
                        'เข้าสู่เมนู "โปรไฟล์" จากแถบเมนูด้านล่าง จากนั้นกดปุ่ม "แก้ไขข้อมูล" เพื่อกรอกชื่อ อีเมล หรือเบอร์โทรศัพท์ใหม่ แล้วกดปุ่ม "บันทึกข้อมูล"',
                  ),

                  const SizedBox(height: 12),

                  // 4. เพิ่มหรือลบรายการโปรดอย่างไร?
                  _buildFaqCard(
                    icon: Icons.restaurant_rounded,
                    question: 'เพิ่มหรือลบรายการโปรดอย่างไร?',
                    answer:
                        'แตะที่ไอคอนป้ายบุ๊กมาร์กมุมขวาบนของหน้ารายละเอียดร้านอาหาร เมื่อเป็นป้ายสีแดงทึบแสดงว่าบันทึกแล้ว หากต้องการลบให้แตะป้ายอีกครั้งและกดยืนยันการลบ',
                  ),

                  const SizedBox(height: 12),

                  // 5. ลืมรหัสผ่านทำยังไง?
                  _buildFaqCard(
                    icon: Icons.error_outline_rounded,
                    question: 'ลืมรหัสผ่านทำยังไง?',
                    answer:
                        'ไปที่หน้า "แก้ไขข้อมูล" แล้วแตะที่ข้อความ "ลืมรหัสผ่าน" ระบบจะให้กรอกอีเมลเพื่อส่งรหัส OTP 6 หลัก เมื่อยืนยันรหัสแล้วจะสามารถตั้งรหัสผ่านใหม่ได้ทันที',
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqCard({
    required IconData icon,
    required String question,
    required String answer,
  }) {
    return Container(
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
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _showFaqDetail(
            question: question,
            answer: answer,
            icon: icon,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                // Burgundy Icon
                Icon(
                  icon,
                  color: const Color(0xFF6E162B),
                  size: 23,
                ),

                const SizedBox(width: 14),

                // Question Title
                Expanded(
                  child: Text(
                    question,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF221F21),
                      letterSpacing: -0.2,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Trailing Chevron
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF6E162B),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
