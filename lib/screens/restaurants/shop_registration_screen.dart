import 'dart:math';
import 'package:flutter/material.dart';
import 'shop_details_screen.dart';

class ShopRegistrationScreen extends StatefulWidget {
  const ShopRegistrationScreen({super.key});

  @override
  State<ShopRegistrationScreen> createState() => _ShopRegistrationScreenState();
}

class _ShopRegistrationScreenState extends State<ShopRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? _selectedCategory;

  // 11 Categories specified in requirements
  final List<String> _categories = const [
    'อาหารไทย',
    'อาหารญี่ปุ่น',
    'อาหารจีน',
    'อาหารเกาหลี',
    'ชาบู/ฮอทพอท',
    'หมูกระทะ',
    'อาหารสุขภาพ',
    'ฟาสต์ฟู้ด',
    'อาหารตามสั่ง',
    'ขนมหวาน/เบเกอรี่',
    'เครื่องดื่ม/คาเฟ่',
  ];

  // Visual Reference Color: Dark Maroon
  static const Color maroonColor = Color(0xFF670E14);
  static const Color inputBgColor = Color(0xFFF2F2F4);
  static const Color labelColor = Color(0xFF1E1E1E);

  @override
  void dispose() {
    _shopNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Validate Thai phone number (9-10 digits starting with 0)
  bool _isValidThaiPhone(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[-\s]'), '');
    final phoneRegex = RegExp(r'^0[0-9]{8,9}$');
    return phoneRegex.hasMatch(cleanPhone);
  }

  void _onRegisterPressed() {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      // Generate shop code once (e.g. FD3429) so it is preserved
      final shopCode = 'FD${1000 + Random().nextInt(9000)}';

      final shopData = {
        'shopCode': shopCode,
        'name': _shopNameController.text.trim(),
        'category': _selectedCategory,
        'address': _addressController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': 'ITLOVER@GMAIL.COM',
        'mapUrl': 'www.googlemap.com',
      };

      // Navigate to "รายละเอียดร้านอาหาร" (Shop Details Screen)
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ShopDetailsScreen(shopData: shopData),
          settings: RouteSettings(
            name: '/shop-details',
            arguments: shopData,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'กรุณากรอกข้อมูลให้ครบถ้วนและถูกต้อง',
            style: TextStyle(fontFamily: 'Roboto'),
          ),
          backgroundColor: maroonColor,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  InputDecoration _buildInputDecoration({required String hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFF9E9E9E),
        fontSize: 14,
      ),
      filled: true,
      fillColor: inputBgColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: maroonColor, width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: labelColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: maroonColor,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Header Section (Maroon Background)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                child: Column(
                  children: const [
                    Text(
                      'ลงทะเบียนร้านค้า',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'ลงทะเบียนเพื่อเปิดร้านค้า',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),

              // Form Section (White Background with large rounded top corners)
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Field 1: ชื่อร้าน
                            _buildFieldLabel('ชื่อร้าน'),
                            TextFormField(
                              controller: _shopNameController,
                              textInputAction: TextInputAction.next,
                              decoration: _buildInputDecoration(
                                hintText: 'กรุณากรอกชื่อร้าน',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'กรุณากรอกชื่อร้าน';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),

                            // Field 2: เลือกหมวดหมู่ (Dropdown)
                            _buildFieldLabel('เลือกหมวดหมู่'),
                            DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              isExpanded: true,
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: Color(0xFF4A4A4A),
                                size: 24,
                              ),
                              hint: const Text(
                                'หมวดหมู่อาหาร',
                                style: TextStyle(
                                  color: Color(0xFF9E9E9E),
                                  fontSize: 14,
                                ),
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: inputBgColor,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: maroonColor,
                                    width: 1.2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.redAccent,
                                    width: 1,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.redAccent,
                                    width: 1.2,
                                  ),
                                ),
                              ),
                              dropdownColor: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              items: _categories.map((String category) {
                                return DropdownMenuItem<String>(
                                  value: category,
                                  child: Text(
                                    category,
                                    style: const TextStyle(
                                      color: Color(0xFF222222),
                                      fontSize: 14,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedCategory = newValue;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'กรุณาเลือกหมวดหมู่';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),

                            // Field 3: ที่อยู่ร้านอาหาร
                            _buildFieldLabel('ที่อยู่ร้านอาหาร'),
                            TextFormField(
                              controller: _addressController,
                              textInputAction: TextInputAction.next,
                              maxLines: 1,
                              decoration: _buildInputDecoration(
                                hintText: 'กรุณากรอกที่อยู่',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'กรุณากรอกที่อยู่';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),

                            // Field 4: ช่องทางการติดต่อ (เบอร์โทรศัพท์)
                            _buildFieldLabel('ช่องทางการติดต่อ'),
                            TextFormField(
                              controller: _phoneController,
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.phone,
                              decoration: _buildInputDecoration(
                                hintText: 'กรุณากรอกเบอร์โทรศัพท์',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'กรุณากรอกเบอร์โทรศัพท์';
                                }
                                if (!_isValidThaiPhone(value)) {
                                  return 'กรุณากรอกหมายเลขโทรศัพท์ให้ถูกต้อง (เช่น 0812345678)';
                                }
                                return null;
                              },
                              onFieldSubmitted: (_) => _onRegisterPressed(),
                            ),
                            const SizedBox(height: 32),

                            // ปุ่ม “ลงทะเบียน”
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _onRegisterPressed,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: maroonColor,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'ลงทะเบียน',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
    );
  }
}
