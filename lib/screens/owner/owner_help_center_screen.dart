import 'package:flutter/material.dart';

/// สีหลักของแบรนด์ตามภาพ (แดงเบอร์กันดี / เลือดหมูเข้ม)
const Color kOwnerPrimaryColor = Color(0xFF7C1431);
const Color kOwnerBgColor = Color(0xFFFBF8F9);
const Color kOwnerBorderColor = Color(0xFFF2EAEB);

class FaqItemData {
  final IconData icon;
  final String question;
  final String answer;

  const FaqItemData({
    required this.icon,
    required this.question,
    required this.answer,
  });
}

class OwnerHelpCenterScreen extends StatefulWidget {
  const OwnerHelpCenterScreen({super.key});

  @override
  State<OwnerHelpCenterScreen> createState() => _OwnerHelpCenterScreenState();
}

class _OwnerHelpCenterScreenState extends State<OwnerHelpCenterScreen> {
  // เก็บ index ของคำถามที่กำลังกางออก (สามารถเปิด-ปิดได้อย่างอิสระ)
  final Set<int> _expandedIndices = {};

  final List<FaqItemData> _faqList = const [
    FaqItemData(
      icon: Icons.storefront_outlined,
      question: 'สมัครเป็นร้านค้าได้อย่างไร?',
      answer: '1. กด “เพิ่มร้าน”\n'
          '2. กรอกข้อมูลร้านให้ครบถ้วน\n'
          '3. เพิ่มเมนูอาหารอย่างน้อย 1 เมนู\n'
          '4. ส่งคำขอเปิดร้าน\n'
          '5. ระบบจะใช้เวลาอนุมัติประมาณ 3-5 วัน\n\n'
          'เมื่อได้รับการอนุมัติ\n'
          'ร้านของคุณจะเปิดใช้งานทันที',
    ),
    FaqItemData(
      icon: Icons.access_time_rounded,
      question: 'ใช้เวลานานแค่ไหนว่าจะอนุมัติร้านค้า?',
      answer: 'ใช้เวลา 2-5 วันในการอนุมัติร้านค้า\n\n'
          'ทีมงานจะดำเนินการตรวจสอบความถูกต้องของข้อมูลร้านค้า เอกสารประกอบ และเมนูอาหาร โดยเมื่อได้รับการอนุมัติแล้ว ระบบจะส่งการแจ้งเตือนและร้านของคุณจะเปิดใช้งานบนแอปพลิเคชันทันที',
    ),
    FaqItemData(
      icon: Icons.edit_outlined,
      question: 'สามารถแก้ไขข้อมูลร้านได้หรือไม่?',
      answer: 'สามารถแก้ไขได้ตลอดเวลา\n\n'
          'ไปที่เมนู “ข้อมูลร้าน”\n'
          'แล้วกด “แก้ไข”\n'
          'จากนั้นปรับปรุงข้อมูลที่ต้องการ\n'
          'แล้วกด “บันทึก”\n\n'
          'ข้อมูลใหม่จะอัปเดตให้ทันที',
    ),
    FaqItemData(
      icon: Icons.restaurant_rounded,
      question: 'เพิ่มหรือลบเมนูอาหารได้อย่างไร?',
      answer: 'ไปที่เมนู “ข้อมูลร้าน”\n'
          'เลือกหัวข้อ “เมนูอาหาร”\n\n'
          'คุณสามารถ\n'
          'กด “เพิ่มเมนู” เพื่อเพิ่มเมนูใหม่\n'
          'กด “แก้ไข” เพื่อปรับข้อมูลเมนูเดิม\n'
          'กด “ลบ” เพื่อลบเมนูที่ไม่ต้องการ\n\n'
          'จากนั้นกด “บันทึก”',
    ),
    FaqItemData(
      icon: Icons.error_outline_rounded,
      question: 'ร้านถูกปฏิเสธต้องทำอย่างไร?',
      answer: 'หากร้านของคุณไม่ได้รับการอนุมัติ\n'
          'สามารถทำตามขั้นตอนนี้ได้เลย\n\n'
          '1. ตรวจสอบสาเหตุจากอีเมลหรือสถานะร้านที่ข้อมูลโปรไฟล์ร้าน\n'
          '2. แก้ไขข้อมูลให้ถูกต้องครบถ้วน\n'
          '3. เพิ่มเมนูอาหารอย่างน้อย 1 เมนู\n'
          '4. ส่งคำขอเปิดร้านใหม่อีกครั้ง\n\n'
          'เมื่อแก้ไขเรียบร้อยแล้ว ระบบจะตรวจสอบ\n'
          'และแจ้งผลให้ทราบอีกครั้ง',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kOwnerBgColor,
      appBar: AppBar(
        backgroundColor: kOwnerPrimaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 34),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'ศูนย์ช่วยเหลือ',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // หัวข้อคำถามที่พบบ่อย
              const Padding(
                padding: EdgeInsets.only(left: 4.0, bottom: 16.0),
                child: Text(
                  'คำถามที่พบบ่อย',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
              ),

              // รายการการ์ดคำถาม-คำตอบทั้ง 5 ข้อ
              ...List.generate(_faqList.length, (index) {
                final item = _faqList[index];
                final isExpanded = _expandedIndices.contains(index);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildFaqAccordionCard(index, item, isExpanded),
                );
              }),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaqAccordionCard(int index, FaqItemData item, bool isExpanded) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kOwnerBorderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ส่วนหัวข้อคำถาม (กดเพื่อกางออก/พับเก็บ)
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedIndices.remove(index);
                } else {
                  _expandedIndices.add(index);
                }
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              child: Row(
                children: [
                  // ไอคอนประจำคำถาม สีแดงเบอร์กันดี
                  Icon(
                    item.icon,
                    color: kOwnerPrimaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 14),

                  // ข้อความคำถาม
                  Expanded(
                    child: Text(
                      item.question,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF222222),
                      ),
                    ),
                  ),

                  // ลูกศร (ขวาเมื่อพับ, ขึ้นเมื่อกางออก)
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.chevron_right_rounded,
                    color: kOwnerPrimaryColor,
                    size: isExpanded ? 24 : 22,
                  ),
                ],
              ),
            ),
          ),

          // เมื่อกางออก: แสดงเส้นคั่นบางๆ และเนื้อหาคำตอบ
          if (isExpanded) ...[
            const Divider(height: 1, thickness: 1, color: kOwnerBorderColor),
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 20.0),
              child: Text(
                item.answer,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF222222),
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
