import 'package:flutter/material.dart';

class AddMenuScreen extends StatefulWidget {
  final Map<String, dynamic>? shopData;

  const AddMenuScreen({
    super.key,
    this.shopData,
  });

  @override
  State<AddMenuScreen> createState() => _AddMenuScreenState();
}

class _AddMenuScreenState extends State<AddMenuScreen> {
  static const Color maroonColor = Color(0xFF82152B);

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController(text: '45');
  final TextEditingController _customCategoryController = TextEditingController();

  String _selectedCategory = 'อาหารจานเดียว';
  String _selectedImageUrl = 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=300';
  bool _isRecommended = false;
  bool _isHidden = false;

  final List<String> _categories = [
    'อาหารจานเดียว',
    'ซุป',
    'ของหวาน',
    'เครื่องดื่ม',
    'อื่นๆ',
  ];

  final List<Map<String, String>> _sampleImages = [
    {'name': 'สลัด/อาหารจานเดียว', 'url': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=300'},
    {'name': 'ไก่ทอด', 'url': 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=300'},
    {'name': 'ต้มยำ/ซุป', 'url': 'https://images.unsplash.com/photo-1548946526-f69e2424cf45?w=300'},
    {'name': 'ของหวาน/เค้ก', 'url': 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=300'},
    {'name': 'เครื่องดื่ม/กาแฟ', 'url': 'https://images.unsplash.com/photo-1517701604599-bb29b565090c?w=300'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  void _showImagePickerSheet() {
    final urlController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'เลือกรูปอาหาร',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'เลือกจากภาพตัวอย่าง:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _sampleImages.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final item = _sampleImages[index];
                  final isCurrent = _selectedImageUrl == item['url'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedImageUrl = item['url']!;
                      });
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCurrent ? maroonColor : Colors.grey.shade300,
                          width: isCurrent ? 2.5 : 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          item['url']!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'หรือใส่ลิงก์รูปภาพ (URL):',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: urlController,
              decoration: InputDecoration(
                hintText: 'https://example.com/food.jpg',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: maroonColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  if (urlController.text.trim().isNotEmpty) {
                    setState(() {
                      _selectedImageUrl = urlController.text.trim();
                    });
                  }
                  Navigator.pop(ctx);
                },
                child: const Text('ใช้รูปนี้', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPriceDialog() {
    final controller = TextEditingController(text: _priceController.text);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ระบุราคาอาหาร (บาท)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'ราคา',
            suffixText: '฿',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ยกเลิก')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: maroonColor),
            onPressed: () {
              setState(() {
                _priceController.text = controller.text.trim();
              });
              Navigator.pop(ctx);
            },
            child: const Text('ตกลง', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _saveMenu() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
      final desc = _descController.text.trim();
      final category = _selectedCategory == 'อื่นๆ'
          ? (_customCategoryController.text.trim().isNotEmpty ? _customCategoryController.text.trim() : 'อื่นๆ')
          : _selectedCategory;

      final newMenu = {
        'id': 'menu_${DateTime.now().millisecondsSinceEpoch}',
        'name': name,
        'price': price,
        'description': desc,
        'category': category,
        'imageUrl': _selectedImageUrl,
        'isRecommended': _isRecommended,
        'isHidden': _isHidden,
      };

      Navigator.of(context).pop(newMenu);
    }
  }

  Widget _buildToggle({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => onChanged(!value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 24,
              padding: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: value ? maroonColor : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: value ? maroonColor : const Color(0xFF6B1D2F),
                  width: 2,
                ),
              ),
              child: Align(
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: value ? Colors.white : const Color(0xFF6B1D2F),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'เพิ่มเมนูอาหาร',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: maroonColor,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 19),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _saveMenu,
            child: const Text(
              'บันทึก',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top: Image Upload Circle + Price Box
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Circle Food Image with Camera Badge
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        GestureDetector(
                          onTap: _showImagePickerSheet,
                          child: Container(
                            width: 104,
                            height: 104,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFE5E7EB),
                              border: Border.all(color: const Color(0xFFD1D5DB), width: 1.5),
                            ),
                            child: ClipOval(
                              child: _selectedImageUrl.isNotEmpty
                                  ? Image.network(
                                      _selectedImageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.add,
                                        size: 40,
                                        color: maroonColor,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.add,
                                      size: 40,
                                      color: maroonColor,
                                    ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: GestureDetector(
                            onTap: _showImagePickerSheet,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.55),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.camera_alt, color: Colors.white, size: 10),
                                  SizedBox(width: 3),
                                  Text(
                                    'แก้ไข',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 24),

                    // Price Input Box
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _showPriceDialog,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5E7EB),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _priceController.text.isEmpty
                                  ? 'ระบุราคา ฿'
                                  : '${_priceController.text} ฿',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _showPriceDialog,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.edit_note,
                              size: 18,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ชื่อเมนู
                const Text(
                  'ชื่อเมนู',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'กรุณากรอกชื่อเมนูอาหาร',
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: maroonColor, width: 1.5),
                    ),
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'กรุณากรอกชื่อเมนู' : null,
                ),
                const SizedBox(height: 18),

                // คำอธิบาย
                const Text(
                  'คำอธิบาย',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _descController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'กรุณากรอกคำอธิบายเกี่ยวกับเมนูอาหารนี้...',
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: maroonColor, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // ประเภท (Dropdown / Selection List)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'ประเภท',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.black87,
                      size: 24,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Divider(color: Color(0xFFE5E7EB), thickness: 1),
                const SizedBox(height: 4),

                // Categories list
                ..._categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                            size: 18,
                            color: isSelected ? maroonColor : Colors.grey.shade400,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            cat,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? maroonColor : const Color(0xFF374151),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                if (_selectedCategory == 'อื่นๆ') ...[
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _customCategoryController,
                    decoration: InputDecoration(
                      hintText: 'อื่นๆโปรดระบุ',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: maroonColor, width: 1.2),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 8),
                const Divider(color: Color(0xFFE5E7EB), thickness: 1),
                const SizedBox(height: 12),

                // Toggles: เมนูแนะนำ / ซ่อน
                _buildToggle(
                  title: 'เมนูแนะนำ',
                  value: _isRecommended,
                  onChanged: (val) {
                    setState(() {
                      _isRecommended = val;
                      if (val) _isHidden = false;
                    });
                  },
                ),
                const SizedBox(height: 8),
                _buildToggle(
                  title: 'ซ่อน',
                  value: _isHidden,
                  onChanged: (val) {
                    setState(() {
                      _isHidden = val;
                      if (val) _isRecommended = false;
                    });
                  },
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
