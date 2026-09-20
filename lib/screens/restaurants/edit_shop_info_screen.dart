import 'package:flutter/material.dart';

class EditShopInfoScreen extends StatefulWidget {
  final String initialName;
  final String initialCategory;
  final String shopCode;

  const EditShopInfoScreen({
    super.key,
    required this.initialName,
    required this.initialCategory,
    required this.shopCode,
  });

  @override
  State<EditShopInfoScreen> createState() => _EditShopInfoScreenState();
}

class _EditShopInfoScreenState extends State<EditShopInfoScreen> {
  static const Color maroonColor = Color(0xFF7A1428);
  static const Color fieldBgColor = Color(0xFFEFEFEF);
  static const Color readOnlyBgColor = Color(0xFFEBEBEB);
  static const Color readOnlyTextColor = Color(0xFF8E8E93);

  // 11 Categories matching Shop Registration
  static const List<String> categories = [
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

  late TextEditingController _nameController;
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);

    // Initialize category, fallback to first item if not found in list
    if (categories.contains(widget.initialCategory)) {
      _selectedCategory = widget.initialCategory;
    } else {
      _selectedCategory = categories.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onSave() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณากรอกชื่อร้าน'),
          backgroundColor: maroonColor,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    Navigator.of(context).pop({
      'updated': true,
      'name': name,
      'category': _selectedCategory,
    });
  }

  void _onCancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: maroonColor,
        elevation: 0,
        leadingWidth: 160,
        leading: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
              onPressed: _onCancel,
            ),
            const Text(
              'แก้ไขชื่อร้าน',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _onSave,
            child: const Text(
              'บันทึก',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. ชื่อร้าน
              const Text(
                'ชื่อร้าน',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  fontWeight: FontWeight.normal,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: fieldBgColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF9E9E9E), width: 1.2),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // 2. รหัสร้าน (ไม่สามารถแก้ไขได้)
              Row(
                children: const [
                  Text(
                    'รหัสร้าน',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(width: 6),
                  Text(
                    '(ไม่สามารถแก้ไขได้)',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: readOnlyTextColor,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: readOnlyBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  widget.shopCode,
                  style: const TextStyle(
                    fontSize: 15,
                    color: readOnlyTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // 3. ประเภทอาหาร
              const Text(
                'ประเภทอาหาร',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                isExpanded: true,
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(12),
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                ),
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.transparent, // Figma shows clean field; keep subtle arrow or none
                  size: 0,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: fieldBgColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF9E9E9E), width: 1.2),
                  ),
                ),
                items: categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(
                      category,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 15,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
