import 'package:flutter/material.dart';

class EditMenuPhotoScreen extends StatefulWidget {
  final String? currentImageUrl;
  final bool isEditing;

  const EditMenuPhotoScreen({
    super.key,
    this.currentImageUrl,
    this.isEditing = false,
  });

  @override
  State<EditMenuPhotoScreen> createState() => _EditMenuPhotoScreenState();
}

class _EditMenuPhotoScreenState extends State<EditMenuPhotoScreen> {
  // Visual Reference Color: Dark Maroon matching the reference
  static const Color maroonColor = Color(0xFF7A1428);
  static const Color cancelBgColor = Color(0xFFFBF1F2);
  static const Color cancelBorderColor = Color(0xFFF3D5DA);
  static const Color cardBorderColor = Color(0xFFF2E6E8);

  // Temporary state for the image URL within this edit screen
  late String? _tempImageUrl;

  // Preset sample food images for gallery / camera simulation
  final List<Map<String, String>> _sampleImages = const [
    {
      'name': 'ข้าวไก่กรอบซอสน้ำปลา',
      'url': 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=500',
    },
    {
      'name': 'ข้าวไก่ย่างน้ำจิ้มแจ่ว',
      'url': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500',
    },
    {
      'name': 'ข้าวไก่เทอริยากิ',
      'url': 'https://images.unsplash.com/photo-1548946526-f69e2424cf45?w=500',
    },
    {
      'name': 'ข้าวไก่กรอบเกาหลี',
      'url': 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=500',
    },
    {
      'name': 'ข้าวไก่แซ่บ',
      'url': 'https://images.unsplash.com/photo-1517701604599-bb29b565090c?w=500',
    },
    {
      'name': 'ของหวาน / เค้ก',
      'url': 'https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=500',
    },
    {
      'name': 'เครื่องดื่ม / ชา กาแฟ',
      'url': 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=500',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tempImageUrl = widget.currentImageUrl;
  }

  // 1. ถ่ายรูป (Camera simulation / options)
  void _onTakePhoto() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ถ่ายรูปภาพอาหารใหม่',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'เลือกรูปภาพที่ถ่ายจำลองจากกล้อง:',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _sampleImages.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final item = _sampleImages[index];
                  final isSelected = _tempImageUrl == item['url'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _tempImageUrl = item['url'];
                      });
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? maroonColor : Colors.grey.shade300,
                          width: isSelected ? 2.5 : 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(item['url']!, fit: BoxFit.cover),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // 2. เลือกจากคลัง (Gallery Picker Simulation + Custom URL)
  void _onChooseFromGallery() {
    final TextEditingController urlController = TextEditingController();

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
                  'เลือกรูปจากคลังภาพ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'เลือกจากคลังภาพตัวอย่าง:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _sampleImages.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final item = _sampleImages[index];
                  final isSelected = _tempImageUrl == item['url'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _tempImageUrl = item['url'];
                      });
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? maroonColor : Colors.grey.shade300,
                          width: isSelected ? 2.5 : 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(item['url']!, fit: BoxFit.cover),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'หรือระบุ URL รูปภาพ:',
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
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: maroonColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  if (urlController.text.trim().isNotEmpty) {
                    setState(() {
                      _tempImageUrl = urlController.text.trim();
                    });
                  }
                  Navigator.pop(ctx);
                },
                child: const Text('ใช้รูปนี้', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 3. ลบรูปภาพ (Delete photo -> show placeholder in preview)
  void _onDeletePhoto() {
    setState(() {
      _tempImageUrl = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ลบรูปภาพแล้ว (กด "บันทึก" เพื่อยืนยันการเปลี่ยนแปลง)'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Cancel / Discard temporary changes
  void _onCancel() {
    Navigator.of(context).pop();
  }

  // Save / Commit temporary photo to Edit/Add Menu screen
  void _onSave() {
    Navigator.of(context).pop({'saved': true, 'imageUrl': _tempImageUrl});
  }

  @override
  Widget build(BuildContext context) {
    const double avatarSize = 250;
    final String pageTitle = widget.isEditing ? 'แก้ไขรูปภาพ' : 'เพิ่มรูปภาพ';

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
              onPressed: _onCancel,
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 36),

              // --- Circular Menu Photo Avatar (Image or Placeholder with Plus sign) ---
              Center(
                child: Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFD9D9D9),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: (_tempImageUrl != null && _tempImageUrl!.trim().isNotEmpty)
                        ? Image.network(
                            _tempImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.add,
                                  size: 72,
                                  color: maroonColor,
                                ),
                              );
                            },
                          )
                        : const Center(
                            child: Icon(
                              Icons.add,
                              size: 72,
                              color: maroonColor,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // --- Actions Card (ถ่ายรูป, เลือกจากคลัง, ลบรูปภาพ) ---
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cardBorderColor, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // 1. ถ่ายรูป
                    _buildOptionTile(
                      label: 'ถ่ายรูป',
                      textColor: const Color(0xFF1E1E1E),
                      onTap: _onTakePhoto,
                    ),

                    const Divider(height: 1, color: Color(0xFFE5E7EB)),

                    // 2. เลือกจากคลัง
                    _buildOptionTile(
                      label: 'เลือกจากคลัง',
                      textColor: const Color(0xFF1E1E1E),
                      onTap: _onChooseFromGallery,
                    ),

                    const Divider(height: 1, color: Color(0xFFE5E7EB)),

                    // 3. ลบรูปภาพ
                    _buildOptionTile(
                      label: 'ลบรูปภาพ',
                      textColor: maroonColor,
                      onTap: _onDeletePhoto,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // --- Cancel Button Card (ยกเลิก) ---
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: cancelBgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cancelBorderColor, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: maroonColor.withOpacity(0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _onCancel,
                    child: const Center(
                      child: Text(
                        'ยกเลิก',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: maroonColor,
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

  Widget _buildOptionTile({
    required String label,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 52,
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
