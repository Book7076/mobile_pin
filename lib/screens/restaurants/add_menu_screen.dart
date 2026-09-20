import 'package:flutter/material.dart';
import 'edit_menu_photo_screen.dart';

class AddMenuScreen extends StatefulWidget {
  final Map<String, dynamic>? shopData;
  final Map<String, dynamic>? initialMenu;
  final bool isEditing;

  const AddMenuScreen({
    super.key,
    this.shopData,
    this.initialMenu,
    this.isEditing = false,
  });

  @override
  State<AddMenuScreen> createState() => _AddMenuScreenState();
}

class _AddMenuScreenState extends State<AddMenuScreen> {
  static const Color maroonColor = Color(0xFF7A1428);

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController(text: '79');
  final TextEditingController _customCategoryController = TextEditingController();

  String _selectedCategory = 'อาหารจานเดียว';
  String? _selectedImageUrl;
  bool _isRecommended = false;
  bool _isHidden = false;
  bool _isCategoryExpanded = true;

  final List<String> _categories = [
    'อาหารจานเดียว',
    'ซุป',
    'ของหวาน',
    'เครื่องดื่ม',
    'อื่นๆ',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialMenu != null) {
      _nameController.text = widget.initialMenu!['name']?.toString() ?? '';
      _descController.text = widget.initialMenu!['description']?.toString() ?? '';
      final p = widget.initialMenu!['price'];
      if (p != null) {
        _priceController.text = (p is num) ? p.toInt().toString() : p.toString();
      }
      _selectedImageUrl = widget.initialMenu!['imageUrl']?.toString();
      _isRecommended = widget.initialMenu!['isRecommended'] == true;
      _isHidden = widget.initialMenu!['isHidden'] == true;
      final cat = widget.initialMenu!['category']?.toString() ?? 'อาหารจานเดียว';
      if (_categories.contains(cat)) {
        _selectedCategory = cat;
      } else {
        _selectedCategory = 'อื่นๆ';
        _customCategoryController.text = cat;
      }
    } else {
      // Default for new menu
      _selectedImageUrl = null;
      _priceController.text = '';
      _isRecommended = false;
      _isHidden = false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  // Navigate to Edit Menu Photo Screen matching Reference media_3
  Future<void> _openEditPhotoScreen() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => EditMenuPhotoScreen(
          currentImageUrl: _selectedImageUrl,
          isEditing: widget.isEditing,
        ),
      ),
    );

    if (result != null && result['saved'] == true) {
      setState(() {
        _selectedImageUrl = result['imageUrl'] as String?;
      });
    }
  }

  // Dialog to enter / edit price (digits only, > 0)
  void _showPriceDialog() {
    final controller = TextEditingController(text: _priceController.text);
    String? errorText;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'ระบุราคาอาหาร (บาท)',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'ราคา (บาท)',
                  suffixText: 'บาท',
                  errorText: errorText,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: maroonColor, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('ยกเลิก', style: TextStyle(color: Colors.black54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: maroonColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                final text = controller.text.trim();
                final val = double.tryParse(text);
                if (val == null || val <= 0) {
                  setDialogState(() {
                    errorText = 'ราคาต้องมากกว่า 0 บาท';
                  });
                  return;
                }
                setState(() {
                  _priceController.text = (val % 1 == 0) ? val.toInt().toString() : val.toString();
                });
                Navigator.pop(ctx);
              },
              child: const Text('ตกลง', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // Delete menu confirmation dialog from Edit Menu screen
  Future<void> _confirmDeleteMenu() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'ต้องการลบเมนูนี้หรือไม่?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        content: Text(
          'ต้องการลบเมนู "${_nameController.text.trim()}" ออกจากร้านของคุณหรือไม่? เมื่อลบแล้วจะไม่สามารถกู้คืนได้',
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'ยกเลิก',
              style: TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: maroonColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'ลบ',
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      Navigator.of(context).pop({
        'deleted': true,
        'id': widget.initialMenu?['id'],
      });
    }
  }

  // Save Menu (Commit temporary state)
  void _saveMenu() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final price = double.tryParse(_priceController.text.trim());
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาระบุราคาอาหารที่มากกว่า 0 บาท'),
          backgroundColor: maroonColor,
        ),
      );
      _showPriceDialog();
      return;
    }

    final name = _nameController.text.trim();
    final desc = _descController.text.trim();
    final category = _selectedCategory == 'อื่นๆ'
        ? (_customCategoryController.text.trim().isNotEmpty ? _customCategoryController.text.trim() : 'อื่นๆ')
        : _selectedCategory;

    final menu = {
      'id': widget.initialMenu?['id'] ?? 'menu_${DateTime.now().millisecondsSinceEpoch}',
      'name': name,
      'price': price,
      'description': desc,
      'category': category,
      'imageUrl': _selectedImageUrl,
      'isRecommended': _isRecommended,
      'isHidden': _isHidden,
    };

    Navigator.of(context).pop(menu);
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
              width: 46,
              height: 24,
              padding: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: value ? maroonColor : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: maroonColor,
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
                    color: value ? Colors.white : maroonColor,
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
    final String pageTitle = widget.isEditing ? 'แก้ไขเมนูอาหาร' : 'เพิ่มเมนูอาหาร';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: maroonColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => Navigator.of(context).pop(), // Discard temporary state
            ),
            Text(
              pageTitle,
              style: const TextStyle(
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
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- 1. Food Photo + Price Row (matching Reference media_1 & media_2) ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Circular Food Image with overlay [📷 แก้ไข] Pill
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.bottomRight,
                      children: [
                        GestureDetector(
                          onTap: _openEditPhotoScreen,
                          child: Container(
                            width: 104,
                            height: 104,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFD9D9D9),
                              border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: (_selectedImageUrl != null && _selectedImageUrl!.trim().isNotEmpty)
                                  ? Image.network(
                                      _selectedImageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Center(
                                        child: Icon(Icons.add, size: 40, color: maroonColor),
                                      ),
                                    )
                                  : const Center(
                                      child: Icon(Icons.add, size: 40, color: maroonColor),
                                    ),
                            ),
                          ),
                        ),

                        // [📷 แก้ไข] pill badge
                        Positioned(
                          bottom: -2,
                          right: -4,
                          child: GestureDetector(
                            onTap: _openEditPhotoScreen,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFBF1F2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFF3D5DA), width: 1),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.camera_alt_outlined, color: maroonColor, size: 12),
                                  SizedBox(width: 4),
                                  Text(
                                    'แก้ไข',
                                    style: TextStyle(
                                      color: maroonColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 28),

                    // Price Section: "ราคา" + [ 79 บาท ] [ ✏️ ]
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ราคา',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: _showPriceDialog,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE5E7EB),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  _priceController.text.isEmpty
                                      ? 'ระบุราคา'
                                      : '${_priceController.text} บาท',
                                  style: const TextStyle(
                                    fontSize: 15,
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
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: const Color(0xFFD1D5DB)),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Icons.edit_note,
                                  size: 19,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // --- 2. ชื่อเมนู (Menu Name) ---
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
                  maxLength: 60,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'กรุณากรอกชื่อเมนูอาหาร';
                    }
                    return null;
                  },
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
                ),

                const SizedBox(height: 14),

                // --- 3. คำอธิบาย (Description - Optional, Multiline, Max 200) ---
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
                  maxLength: 200,
                  decoration: InputDecoration(
                    hintText: 'คำอธิบายเมนูอาหาร (ไม่บังคับ)',
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

                const SizedBox(height: 14),

                // --- 4. ประเภท (Dropdown / Expandable List) ---
                InkWell(
                  onTap: () {
                    setState(() {
                      _isCategoryExpanded = !_isCategoryExpanded;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'ประเภท',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Icon(
                          _isCategoryExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: Colors.black87,
                          size: 26,
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(color: Color(0xFFE5E7EB), thickness: 1),

                // Categories list (Expandable)
                if (_isCategoryExpanded) ...[
                  const SizedBox(height: 4),
                  ..._categories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? maroonColor : const Color(0xFF374151),
                          ),
                        ),
                      ),
                    );
                  }),

                  if (_selectedCategory == 'อื่นๆ') ...[
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _customCategoryController,
                      decoration: InputDecoration(
                        hintText: 'อื่นๆ โปรดระบุ',
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
                ] else ...[
                  // When collapsed, show selected category
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    child: Text(
                      _selectedCategory == 'อื่นๆ' && _customCategoryController.text.trim().isNotEmpty
                          ? _customCategoryController.text.trim()
                          : _selectedCategory,
                      style: const TextStyle(
                        fontSize: 14.5,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 8),
                const Divider(color: Color(0xFFE5E7EB), thickness: 1),
                const SizedBox(height: 12),

                // --- 5. Toggles: เมนูแนะนำ / ซ่อน ---
                _buildToggle(
                  title: 'เมนูแนะนำ',
                  value: _isRecommended,
                  onChanged: (val) {
                    setState(() {
                      _isRecommended = val;
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
                    });
                  },
                ),

                const SizedBox(height: 28),

                // --- 6. ลบเมนู (Delete Menu Button - Only on Edit Mode) ---
                if (widget.isEditing) ...[
                  const Divider(color: Color(0xFFE5E7EB), thickness: 1),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: _confirmDeleteMenu,
                      child: const Text(
                        'ลบเมนู',
                        style: TextStyle(
                          color: maroonColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
