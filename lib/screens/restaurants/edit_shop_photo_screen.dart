import 'package:flutter/material.dart';

class EditShopPhotoScreen extends StatefulWidget {
  final String? currentImageUrl;

  const EditShopPhotoScreen({
    super.key,
    this.currentImageUrl,
  });

  @override
  State<EditShopPhotoScreen> createState() => _EditShopPhotoScreenState();
}

class _EditShopPhotoScreenState extends State<EditShopPhotoScreen> {
  // Visual Reference Color: Dark Maroon matching the reference
  static const Color maroonColor = Color(0xFF7A1428);
  static const Color cancelBgColor = Color(0xFFFBF1F2);
  static const Color cancelBorderColor = Color(0xFFF3D5DA);
  static const Color cardBorderColor = Color(0xFFF2E6E8);

  // Temporary state for the image URL within this edit screen
  late String? _tempImageUrl;

  // Preset sample images for gallery / camera simulation
  final List<Map<String, String>> _sampleImages = const [
    {
      'name': 'ไก่ทอด (The Chicken)',
      'url': 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=500',
    },
    {
      'name': 'เบอร์เกอร์และเฟรนช์ฟรายส์',
      'url': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500',
    },
    {
      'name': 'พิซซ่าเตาฟืน',
      'url': 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=500',
    },
    {
      'name': 'กาแฟและคาเฟ่',
      'url': 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=500',
    },
    {
      'name': 'อาหารญี่ปุ่น / ซูชิ',
      'url': 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=500',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tempImageUrl = widget.currentImageUrl;
  }

  // 1. ถ่ายรูป (Camera simulation / options)
  void _onTakePhoto() {
    // Show quick photo source picker sheet
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
                  'ถ่ายรูปภาพใหม่',
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
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _tempImageUrl = item['url'];
                      });
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('ถ่ายภาพสำเร็จ (พรีวิวในหน้าแก้ไข)'),
                          backgroundColor: maroonColor,
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: maroonColor.withOpacity(0.5), width: 1.5),
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

  // 2. เลือกจากคลัง (Gallery / URL Picker)
  void _onChooseFromGallery() {
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
                  'เลือกจากคลังรูปภาพ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                hintText: 'https://example.com/restaurant.jpg',
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
        backgroundColor: maroonColor,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // 4. บันทึก (Save changes and return to Shop Details)
  void _onSave() {
    Navigator.of(context).pop({
      'updated': true,
      'imageUrl': _tempImageUrl,
    });
  }

  // 5. ยกเลิก (Cancel and discard temporary changes)
  void _onCancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    const double avatarSize = 230;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: maroonColor,
        elevation: 0,
        leadingWidth: 150,
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
              'แก้ไขรูปภาพ',
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 36),

              // --- Circular Shop Profile Avatar (Image or Placeholder) ---
              Center(
                child: Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
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
                              return CustomPaint(
                                size: const Size(avatarSize, avatarSize),
                                painter: AvatarPlaceholderPainter(),
                              );
                            },
                          )
                        : CustomPaint(
                            size: const Size(avatarSize, avatarSize),
                            painter: AvatarPlaceholderPainter(),
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

// Custom Painter for the Placeholder Avatar matching Figma image 2 exactly
// (Gray circular background with muted mauve/pink head and torso silhouette)
class AvatarPlaceholderPainter extends CustomPainter {
  final Color bgColor;
  final Color silhouetteColor;

  const AvatarPlaceholderPainter({
    this.bgColor = const Color(0xFFD9D9D9),
    this.silhouetteColor = const Color(0xFFB57C89),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = bgColor;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      bgPaint,
    );

    // Clip to circle boundary
    final clipPath = Path()
      ..addOval(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.clipPath(clipPath);

    final silPaint = Paint()
      ..color = silhouetteColor
      ..style = PaintingStyle.fill;

    // Head circle
    final headRadius = size.width * 0.22;
    final headCenter = Offset(size.width / 2, size.height * 0.38);
    canvas.drawCircle(headCenter, headRadius, silPaint);

    // Shoulders & torso (rounded oval anchored at bottom)
    final torsoRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.90),
      width: size.width * 0.72,
      height: size.height * 0.64,
    );
    canvas.drawOval(torsoRect, silPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
