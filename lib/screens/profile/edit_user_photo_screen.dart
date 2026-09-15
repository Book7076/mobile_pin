import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditUserPhotoScreen extends StatefulWidget {
  final String? currentPhotoUrl;

  const EditUserPhotoScreen({
    super.key,
    this.currentPhotoUrl,
  });

  @override
  State<EditUserPhotoScreen> createState() => _EditUserPhotoScreenState();
}

class _EditUserPhotoScreenState extends State<EditUserPhotoScreen> {
  String? _selectedPhotoUrl;

  @override
  void initState() {
    super.initState();
    _selectedPhotoUrl = widget.currentPhotoUrl;

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

  void _handleTakePhoto() {
    // Simulated Camera photo selection with feedback
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.camera_alt_rounded, color: Color(0xFF6E162B), size: 24),
                SizedBox(width: 8),
                Text(
                  'ถ่ายรูปภาพใหม่',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF6E162B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              'เลือกรูปภาพตัวอย่างจากการถ่ายรูป:',
              style: TextStyle(fontSize: 13.5, color: Color(0xFF555555)),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDemoPhotoItem(
                  'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&q=80',
                  'รูปที่ 1',
                  ctx,
                ),
                _buildDemoPhotoItem(
                  'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400&q=80',
                  'รูปที่ 2',
                  ctx,
                ),
                _buildDemoPhotoItem(
                  'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=400&q=80',
                  'รูปที่ 3',
                  ctx,
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _handleChooseFromGallery() {
    // Simulated Gallery selection with feedback
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.photo_library_rounded, color: Color(0xFF6E162B), size: 24),
                SizedBox(width: 8),
                Text(
                  'เลือกจากคลังรูปภาพ',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF6E162B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              'เลือกรูปภาพที่ต้องการใช้งานจากคลังรูป:',
              style: TextStyle(fontSize: 13.5, color: Color(0xFF555555)),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDemoPhotoItem(
                  'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&q=80',
                  'คลัง 1',
                  ctx,
                ),
                _buildDemoPhotoItem(
                  'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&q=80',
                  'คลัง 2',
                  ctx,
                ),
                _buildDemoPhotoItem(
                  'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=400&q=80',
                  'คลัง 3',
                  ctx,
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoPhotoItem(String url, String label, BuildContext ctx) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPhotoUrl = url;
        });
        Navigator.of(ctx).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เลือก $label แล้ว'),
            backgroundColor: const Color(0xFF6E162B),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF6E162B), width: 2),
              image: DecorationImage(
                image: NetworkImage(url),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  void _handleDeletePhoto() {
    setState(() {
      _selectedPhotoUrl = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('ลบรูปภาพแล้ว (เปลี่ยนเป็นรูปเริ่มต้น)'),
        backgroundColor: const Color(0xFF6E162B),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _savePhoto() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('บันทึกรูปโปรไฟล์เรียบร้อยแล้ว'),
        backgroundColor: const Color(0xFF6E162B),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    Navigator.of(context).pop<String?>(_selectedPhotoUrl);
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
                        'แก้ไขรูปภาพ',
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
          // 2. BODY CONTENT
          // ==========================================
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 10),

                      // Large Circular Profile Avatar (Diameter ~220px)
                      Container(
                        width: 220,
                        height: 220,
                        decoration: const BoxDecoration(
                          color: Color(0xFF6E162B),
                          shape: BoxShape.circle,
                        ),
                        child: _selectedPhotoUrl != null
                            ? ClipOval(
                                child: Image.network(
                                  _selectedPhotoUrl!,
                                  width: 220,
                                  height: 220,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Center(
                                    child: Icon(
                                      Icons.person_rounded,
                                      color: Colors.white,
                                      size: 150,
                                    ),
                                  ),
                                ),
                              )
                            : const Center(
                                child: Icon(
                                  Icons.person_rounded,
                                  color: Colors.white,
                                  size: 150,
                                ),
                              ),
                      ),

                      const SizedBox(height: 38),

                      // Options Card Container (ถ่ายรูป, เลือกจากคลัง, ลบรูปภาพ)
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFF2DDE1),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.025),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Option 1: ถ่ายรูป
                            _buildOptionItem(
                              title: 'ถ่ายรูป',
                              textColor: const Color(0xFF221F21),
                              onTap: _handleTakePhoto,
                              isTop: true,
                            ),

                            // Divider 1
                            const Divider(height: 1, thickness: 1, color: Color(0xFFF6E8EA)),

                            // Option 2: เลือกจากคลัง
                            _buildOptionItem(
                              title: 'เลือกจากคลัง',
                              textColor: const Color(0xFF221F21),
                              onTap: _handleChooseFromGallery,
                            ),

                            // Divider 2
                            const Divider(height: 1, thickness: 1, color: Color(0xFFF6E8EA)),

                            // Option 3: ลบรูปภาพ (Solid Burgundy Text)
                            _buildOptionItem(
                              title: 'ลบรูปภาพ',
                              textColor: const Color(0xFF6E162B),
                              onTap: _handleDeletePhoto,
                              isBottom: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Bottom Button: บันทึก (Light pink/cream filled button)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF7EAEC),
                          foregroundColor: const Color(0xFF6E162B),
                          elevation: 0,
                          side: const BorderSide(
                            color: Color(0xFFDEC2C8),
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _savePhoto,
                        child: const Text(
                          'บันทึก',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem({
    required String title,
    required Color textColor,
    required VoidCallback onTap,
    bool isTop = false,
    bool isBottom = false,
  }) {
    return InkWell(
      borderRadius: BorderRadius.vertical(
        top: isTop ? const Radius.circular(16) : Radius.zero,
        bottom: isBottom ? const Radius.circular(16) : Radius.zero,
      ),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14.5),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w600,
            color: textColor,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }
}
