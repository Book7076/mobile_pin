import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'report_problem_success_screen.dart';

/// Data model representing each of the 4 problem categories
class ReportCategory {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final String restaurantHint;
  final String detailHint;
  final bool isRestaurantRecommended;

  const ReportCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.restaurantHint,
    required this.detailHint,
    this.isRestaurantRecommended = false,
  });
}

class ReportProblemScreen extends StatefulWidget {
  final String? initialCategory;
  final String? initialRestaurant;

  /// The 4 standard, professional problem categories for MealMate
  static const List<ReportCategory> categories = [
    ReportCategory(
      id: 'store_info',
      title: 'ข้อมูลร้านค้าไม่ถูกต้อง',
      subtitle: 'ชื่อร้าน เมนู ราคา เวลาเปิด-ปิด พิกัด หรือเบอร์โทรศัพท์',
      icon: Icons.storefront_outlined,
      restaurantHint: 'ระบุชื่อร้านค้าที่พบข้อมูลไม่ถูกต้อง (จำเป็น)',
      detailHint: 'อธิบายข้อมูลที่ไม่ถูกต้อง เช่น เวลาเปิดจริง, เมนูหรือราคาที่เปลี่ยนไป, ตำแหน่งบนแผนที่ไม่ตรง...',
      isRestaurantRecommended: true,
    ),
    ReportCategory(
      id: 'store_closed',
      title: 'ร้านค้าปิดหรือไม่พบร้าน',
      subtitle: 'ร้านปิดถาวร ปิดชั่วคราว ย้ายที่ตั้ง หรือค้นหาตามพิกัดไม่พบ',
      icon: Icons.location_off_outlined,
      restaurantHint: 'ระบุชื่อร้านค้าที่ปิดหรือค้นหาไม่พบ (จำเป็น)',
      detailHint: 'อธิบายปัญหา เช่น เดินทางไปตามหมุดแล้วไม่พบร้าน, ร้านปิดกิจการถาวรแล้ว, ย้ายสถานที่...',
      isRestaurantRecommended: true,
    ),
    ReportCategory(
      id: 'app_issue',
      title: 'ปัญหาการใช้งานแอปพลิเคชัน',
      subtitle: 'แอปค้าง บั๊กการทำงาน ระบบปัด/บันทึกร้าน หรือปัญหาบัญชีผู้ใช้',
      icon: Icons.phone_android_rounded,
      restaurantHint: 'ร้านค้าที่เกี่ยวข้อง (ถ้ามี หรือเว้นว่างได้)',
      detailHint: 'อธิบายปัญหาที่พบ เช่น แอปเด้งขณะใช้งาน, แผนที่ไม่โหลด, บันทึกร้านไม่ได้, เข้าสู่ระบบไม่ได้...',
      isRestaurantRecommended: false,
    ),
    ReportCategory(
      id: 'other',
      title: 'อื่นๆ',
      subtitle: 'ข้อเสนอแนะเพื่อการพัฒนา ติชม หรือปัญหาอื่นๆ ที่ต้องการแจ้งให้ทีมงานทราบ',
      icon: Icons.more_horiz_rounded,
      restaurantHint: 'ร้านค้าที่เกี่ยวข้อง (ถ้ามี หรือเว้นว่างได้)',
      detailHint: 'ระบุข้อเสนอแนะหรือปัญหาที่ต้องการแจ้งทีมงานเพิ่มเติม...',
      isRestaurantRecommended: false,
    ),
  ];

  const ReportProblemScreen({
    super.key,
    this.initialCategory,
    this.initialRestaurant,
  });

  @override
  State<ReportProblemScreen> createState() => _ReportProblemScreenState();
}

class _ReportProblemScreenState extends State<ReportProblemScreen> {
  late ReportCategory _selectedCategory;
  late final TextEditingController _restaurantController;
  late final TextEditingController _detailController;
  late final TextEditingController _emailController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    // Match initial category if provided, or default to the 1st category (ข้อมูลร้านค้าไม่ถูกต้อง)
    final initial = widget.initialCategory;
    if (initial != null && initial.isNotEmpty) {
      _selectedCategory = ReportProblemScreen.categories.firstWhere(
        (c) => c.title == initial || c.id == initial,
        orElse: () => ReportProblemScreen.categories[0],
      );
    } else {
      _selectedCategory = ReportProblemScreen.categories[0];
    }

    _restaurantController = TextEditingController(text: widget.initialRestaurant ?? '');
    _detailController = TextEditingController();
    _emailController = TextEditingController();

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

  /// Show professional Bottom Sheet to choose between all 4 problem categories
  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
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
                // Top Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7EAEC),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.report_problem_outlined,
                            color: Color(0xFF6E162B),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'เลือกประเภทปัญหา',
                              style: TextStyle(
                                fontSize: 17.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1E1E1E),
                                letterSpacing: -0.2,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'มีทั้งหมด 4 หมวดหมู่เพื่อการแก้ไขที่ตรงจุด',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF777777),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Color(0xFF6E162B)),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(height: 1.0, color: const Color(0xFFF2DDE1)),
                const SizedBox(height: 14),

                // 4 Professional Category Cards
                ...List.generate(ReportProblemScreen.categories.length, (index) {
                  final cat = ReportProblemScreen.categories[index];
                  final isSelected = _selectedCategory.id == cat.id;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFFBF4F5) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF6E162B)
                            : const Color(0xFFEEEEEE),
                        width: isSelected ? 1.6 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF6E162B).withOpacity(0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedCategory = cat;
                          });
                          Navigator.of(ctx).pop();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              // Icon badge
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF6E162B)
                                      : const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  cat.icon,
                                  color: isSelected ? Colors.white : const Color(0xFF555555),
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Text content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          cat.title,
                                          style: TextStyle(
                                            fontSize: 14.5,
                                            fontWeight: isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w600,
                                            color: isSelected
                                                ? const Color(0xFF6E162B)
                                                : const Color(0xFF221F21),
                                          ),
                                        ),
                                        if (isSelected) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 1.5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF6E162B),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: const Text(
                                              'เลือกอยู่',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      cat.subtitle,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF777777),
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 8),

                              // Radio / Checkmark indicator
                              Icon(
                                isSelected
                                    ? Icons.check_circle_rounded
                                    : Icons.radio_button_unchecked_rounded,
                                color: isSelected
                                    ? const Color(0xFF6E162B)
                                    : const Color(0xFFCCCCCC),
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Submit problem report with validation & confirmation dialog
  void _submitReport() {
    FocusScope.of(context).unfocus();

    if (_detailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'กรุณาระบุรายละเอียดปัญหาที่พบ เพื่อให้ทีมงานช่วยเหลือได้ถูกต้อง',
                  style: TextStyle(fontFamily: 'Prompt', fontSize: 13.5),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF6E162B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    // Optional email format validation
    final email = _emailController.text.trim();
    if (email.isNotEmpty && (!email.contains('@') || !email.contains('.'))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'รูปแบบอีเมลไม่ถูกต้อง กรุณาตรวจสอบอีกครั้ง',
                  style: TextStyle(fontFamily: 'Prompt', fontSize: 13.5),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFB3261E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Simulate quick professional submission delay
    Future.delayed(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      setState(() => _isSubmitting = false);

      // Navigate to full-screen ReportProblemSuccessScreen matching the reference design
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ReportProblemSuccessScreen(
            category: _selectedCategory.title,
            restaurant: _restaurantController.text.trim(),
          ),
        ),
      );
    });
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
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Field 1: ประเภทปัญหา (Dropdown)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildFieldLabel('ประเภทปัญหา'),
                        Text(
                          '4 ประเภท',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF6E162B).withOpacity(0.85),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildCategorySelector(),

                    // Quick switcher pills for the 4 categories
                    const SizedBox(height: 10),
                    _buildQuickCategoryChips(),

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
                      hintText: _selectedCategory.detailHint,
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

                    const SizedBox(height: 32),

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
                        onPressed: _isSubmitting ? null : _submitReport,
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
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

  /// Interactive Category Dropdown Field
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
                Row(
                  children: [
                    Icon(
                      _selectedCategory.icon,
                      size: 20,
                      color: const Color(0xFF6E162B),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _selectedCategory.title,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF221F21),
                      ),
                    ),
                  ],
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

  /// Quick switcher chips for all 4 categories directly on the form
  Widget _buildQuickCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: ReportProblemScreen.categories.map((cat) {
          final isSelected = _selectedCategory.id == cat.id;

          // Short label for chip display
          String shortLabel = cat.title;
          if (cat.id == 'store_info') shortLabel = 'ข้อมูลร้านค้า';
          if (cat.id == 'store_closed') shortLabel = 'ร้านปิด/ไม่พบร้าน';
          if (cat.id == 'app_issue') shortLabel = 'ปัญหาแอป';
          if (cat.id == 'other') shortLabel = 'อื่นๆ';

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _selectedCategory = cat;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF6E162B) : const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF6E162B)
                        : const Color(0xFFE5E5E5),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      cat.icon,
                      size: 14,
                      color: isSelected ? Colors.white : const Color(0xFF666666),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      shortLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : const Color(0xFF444444),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
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
