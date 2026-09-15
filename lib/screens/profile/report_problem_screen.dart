import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReportProblemScreen extends StatefulWidget {
  const ReportProblemScreen({super.key});

  @override
  State<ReportProblemScreen> createState() => _ReportProblemScreenState();
}

class _ReportProblemScreenState extends State<ReportProblemScreen> {
  String? _selectedCategory;
  final TextEditingController _restaurantController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final List<String> _categories = [
    'ปัญหาการใช้งานแอปพลิเคชันทั่วไป',
    'ข้อมูลร้านอาหารไม่ถูกต้อง',
    'ร้านอาหารปิดหรือไม่พบร้าน',
    'ปัญหาเกี่ยวกับบัญชีหรือรหัสผ่าน',
    'ปัญหาเกี่ยวกับรายการโปรด',
    'ข้อเสนอแนะเพื่อการพัฒนาแอป',
    'อื่นๆ',
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
  void dispose() {
    _restaurantController.dispose();
    _detailController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'เลือกประเภทปัญหา',
                      style: TextStyle(
                        fontSize: 17.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E1E1E),
                        letterSpacing: -0.2,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Color(0xFF6E162B)),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(height: 1.0, color: const Color(0xFFF2DDE1)),
                const SizedBox(height: 8),
                ...List.generate(_categories.length, (index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat;

                  return InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      setState(() {
                        _selectedCategory = cat;
                      });
                      Navigator.of(ctx).pop();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            cat,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? const Color(0xFF6E162B) : const Color(0xFF221F21),
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFF6E162B),
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _submitReport() {
    FocusScope.of(context).unfocus();

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'กรุณาเลือกประเภทปัญหา',
            style: TextStyle(fontFamily: 'Prompt'),
          ),
          backgroundColor: const Color(0xFF6E162B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    if (_detailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'กรุณาระบุรายละเอียดปัญหาที่พบ',
            style: TextStyle(fontFamily: 'Prompt'),
          ),
          backgroundColor: const Color(0xFF6E162B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    // Show Success Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Color(0xFFF7EAEC),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.check_rounded,
                  color: Color(0xFF6E162B),
                  size: 36,
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'ส่งรายงานปัญหาสำเร็จ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E1E1E),
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'ทีมงานได้รับรายงานของท่านเรียบร้อยแล้ว และจะเร่งตรวจสอบพร้อมปรับปรุงบริการต่อไป',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: Color(0xFF666666),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6E162B),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'ตกลง',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
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
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
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
                          'รายงานปัญหา',
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
            // 2. SCROLLABLE FORM FIELDS
            // ==========================================
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Field 1: ประเภทปัญหา
                    _buildFieldLabel('ประเภทปัญหา'),
                    const SizedBox(height: 8),
                    _buildCategorySelector(),

                    const SizedBox(height: 20),

                    // Field 2: ร้านค้าที่เกี่ยวข้อง(ถ้ามี)
                    _buildFieldLabel('ร้านค้าที่เกี่ยวข้อง(ถ้ามี)'),
                    const SizedBox(height: 8),
                    _buildTextInput(
                      controller: _restaurantController,
                      hintText: 'ร้านค้า',
                    ),

                    const SizedBox(height: 20),

                    // Field 3: รายละเอียด
                    _buildFieldLabel('รายละเอียด'),
                    const SizedBox(height: 8),
                    _buildTextInput(
                      controller: _detailController,
                      hintText: 'อธิบายปัญหาที่พบเพิ่มเติม...',
                      minLines: 5,
                      maxLines: 7,
                    ),

                    const SizedBox(height: 20),

                    // Field 4: อีเมลติดต่อกลับ
                    _buildFieldLabel('อีเมลติดต่อกลับ'),
                    const SizedBox(height: 8),
                    _buildTextInput(
                      controller: _emailController,
                      hintText: 'อีเมล@gmail.com',
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 36),

                    // Submit Button: ส่งรายงาน
                    SizedBox(
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
                        ),
                        onPressed: _submitReport,
                        child: const Text(
                          'ส่งรายงาน',
                          style: TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Color(0xFF221F21),
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFF2DDE1),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _showCategoryPicker,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedCategory ?? 'เลือกประเภทปัญหา',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: _selectedCategory != null ? FontWeight.w600 : FontWeight.w400,
                    color: _selectedCategory != null
                        ? const Color(0xFF221F21)
                        : const Color(0xFFAAAAAA),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF555555),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextInput({
    required TextEditingController controller,
    required String hintText,
    int minLines = 1,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFF2DDE1),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        minLines: minLines,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 14.5,
          color: Color(0xFF221F21),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: 14.5,
            color: Color(0xFFAAAAAA),
            fontWeight: FontWeight.w400,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }
}
