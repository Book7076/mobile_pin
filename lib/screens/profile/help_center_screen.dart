import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _FaqItem {
  final IconData icon;
  final String question;
  final bool isNumbered;
  final List<String> content;

  const _FaqItem({
    required this.icon,
    required this.question,
    this.isNumbered = true,
    required this.content,
  });
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  // Index of the currently expanded FAQ card (3 is expanded to show Question 4 answer as requested)
  int? _expandedIndex = 3;

  final List<_FaqItem> _faqList = const [
    _FaqItem(
      icon: Icons.storefront_outlined,
      question: 'วิธีการใช้งานแอปพลิเคชั่น?',
      isNumbered: true,
      content: [
        'เมื่อสมัครสมาชิกแล้วเข้าสู่ระบบแล้ว',
        'เข้าสู่ “หน้าหลัก” กดตรงปัดสู่ร้านอาหาร',
        'เมื่อมีร้านอาหารขึ้นมา ปัดขวาคือถูกใจ ปัดซ้ายคือไม่ถูกใจ',
        'เมื่อได้รับร้านที่ถูกใจครบ 5 ร้านแล้วหรือกดหยุด',
        'ระบบจะแสดงผลร้านทั้งหมดพร้อมรายละเอียดร้านเพื่อใช้ในการตัดสินใจ',
      ],
    ),
    _FaqItem(
      icon: Icons.favorite_outline_rounded,
      question: 'เมื่อเจอร้านที่ถูกใจแล้วทำยังไงต่อ?',
      isNumbered: false,
      content: [
        'เมื่อปัดขวาครบ 5 ร้านแล้วระบบจะพาเข้าสู่หน้าสรุปร้านอาหารที่ถูกใจทันทีและสามารถเข้าดูรายละเอียดของแต่ละร้านอาหารได้',
        'หากเจอร้านที่ถูกใจแล้วสามารถกด"ถัดไป"เพื่อไปหน้าสรุปร้านอาหารได้ทันทีโดยไม่ต้องปัดขวาให้ครบ 5 ร้าน',
      ],
    ),
    _FaqItem(
      icon: Icons.edit_outlined,
      question: 'วิธีการเปลี่ยนอีเมลและเบอร์โทร?',
      isNumbered: false,
      content: [
        'ไปที่เมนู “ผู้ใช้งาน”\nแล้วกด “โปรไฟล์”\nจะมีให้กด “แก้ไขข้อมูล”\nแล้วจะสามารถแก้ไขชื่อ อีเมล และเบอร์โทรได้\nแล้วกด “บันทึกข้อมูล”\nระบบจะขึ้น “แก้ไขข้อมูลผู้ใช้สำเร็จ”\nแล้วกด “กลับเข้าสู่หน้าโปรไฟล์”',
        'การเปลี่ยนอีเมลและเบอร์โทรจะเสร็จสิ้นทันที',
      ],
    ),
    _FaqItem(
      icon: Icons.restaurant_rounded,
      question: 'เพิ่มหรือลบรายการโปรดอย่างไร?',
      isNumbered: false,
      content: [
        'สามารถเพิ่มได้หลายวิธี\nกดเครื่องหมายบันทึกตรงมุมขวาบนได้ตั้งแต่\nขั้นตอนการปัด ขั้นตอนการสรุปผลร้านอาหาร\nทั้งหมดและขั้นตอนสุดท้ายที่เลือกร้านอาหาร',
        'การลบรายการโปรด\nเข้าไปที่หน้า “รายการโปรด”\nเข้าตรงหน้ารายละเอียดร้านอาหารแต่ละร้าน\nกดเครื่องหมาย “บันทึก”\nแล้วกด “ยืนยัน”',
        'การเพิ่มหรือลบรายการโปรดจะเสร็จสิ้นทันที',
      ],
    ),
    _FaqItem(
      icon: Icons.error_outline_rounded,
      question: 'ลืมรหัสผ่านทำยังไง?',
      isNumbered: true,
      content: [
        'ไปที่หน้า "แก้ไขข้อมูล" แล้วกดที่ข้อความ "ลืมรหัสผ่าน"',
        'กรอกอีเมลที่ลงทะเบียนไว้ แล้วกด "ส่งรหัสยืนยัน"',
        'นำรหัส OTP 6 หลักที่ได้รับในอีเมลมากรอกเพื่อยืนยัน',
        'ตั้งรหัสผ่านใหม่ทั้ง 2 ช่องให้ตรงกัน แล้วกดยืนยัน',
        'ระบบจะแจ้งเตือนแก้ไขรหัสผ่านสำเร็จและสามารถเข้าใช้งานได้ทันที',
      ],
    ),
  ];

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
                  // Section Title: คำถามที่พบบ่อย
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

                  // 5 Expandable FAQ Cards
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _faqList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildFaqCard(index, _faqList[index]);
                    },
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

  Widget _buildFaqCard(int index, _FaqItem item) {
    final isExpanded = _expandedIndex == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
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
          onTap: () {
            setState(() {
              _expandedIndex = isExpanded ? null : index;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    // Burgundy Icon
                    Icon(
                      item.icon,
                      color: const Color(0xFF6E162B),
                      size: 23,
                    ),

                    const SizedBox(width: 13),

                    // Question Title in Burgundy
                    Expanded(
                      child: Text(
                        item.question,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF6E162B),
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Trailing Arrow (Up Chevron if expanded, Right Chevron if collapsed)
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.chevron_right_rounded,
                      color: const Color(0xFF6E162B),
                      size: 23,
                    ),
                  ],
                ),

                // Expandable Answers Content
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 14, left: 20, right: 6, bottom: 4),
                    child: item.isNumbered
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: item.content.asMap().entries.map((entry) {
                              final stepIndex = entry.key + 1;
                              final stepText = entry.value;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$stepIndex. ',
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1E1E1E),
                                        height: 1.48,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        stepText,
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF1E1E1E),
                                          height: 1.48,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: item.content.asMap().entries.map((entry) {
                              final isLast = entry.key == item.content.length - 1;
                              return Padding(
                                padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                                child: Text(
                                  entry.value,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF1E1E1E),
                                    height: 1.5,
                                    letterSpacing: -0.1,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 250),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
