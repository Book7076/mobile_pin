import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SettingsScreen extends StatefulWidget {
  final String email;
  final String phone;

  const SettingsScreen({
    super.key,
    this.email = 'Emma.carter@gmail.com',
    this.phone = '099-888-7777',
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Settings States
  String _contactChannel = 'อีเมล/การโทร';
  bool _notificationEnabled = true;
  bool _adInterestEnabled = true;
  String _language = 'ภาษาไทย';
  final String _appVersion = 'v.1.1';
  final String _terms = 'ผู้ใช้งานทั่วไป';

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

  void _showNotificationToggleDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'การแจ้งเตือน',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF6E162B),
          ),
        ),
        content: Text(
          _notificationEnabled
              ? 'คุณต้องการปิดการแจ้งเตือนหรือไม่?'
              : 'คุณต้องการเปิดการแจ้งเตือนหรือไม่?',
          style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('ยกเลิก', style: TextStyle(color: Color(0xFF7E777B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6E162B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              setState(() {
                _notificationEnabled = !_notificationEnabled;
              });
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_notificationEnabled
                      ? 'เปิดการแจ้งเตือนแล้ว'
                      : 'ปิดการแจ้งเตือนแล้ว'),
                  backgroundColor: const Color(0xFF6E162B),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            child: Text(_notificationEnabled ? 'ปิดการแจ้งเตือน' : 'เปิดการแจ้งเตือน'),
          ),
        ],
      ),
    );
  }

  void _showAdInterestToggleDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'ความสนใจโฆษณา',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF6E162B),
          ),
        ),
        content: Text(
          _adInterestEnabled
              ? 'คุณต้องการปิดการปรับแต่งโฆษณาตามความสนใจหรือไม่?'
              : 'คุณต้องการเปิดการปรับแต่งโฆษณาตามความสนใจหรือไม่?',
          style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('ยกเลิก', style: TextStyle(color: Color(0xFF7E777B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6E162B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              setState(() {
                _adInterestEnabled = !_adInterestEnabled;
              });
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_adInterestEnabled
                      ? 'เปิดความสนใจโฆษณาแล้ว'
                      : 'ปิดความสนใจโฆษณาแล้ว'),
                  backgroundColor: const Color(0xFF6E162B),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            child: Text(_adInterestEnabled ? 'ปิด' : 'เปิด'),
          ),
        ],
      ),
    );
  }

  void _showLanguageSelectionSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'เลือกภาษา (Select Language)',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF6E162B),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('ภาษาไทย (Thai)', style: TextStyle(fontWeight: FontWeight.w600)),
              trailing: _language == 'ภาษาไทย'
                  ? const Icon(Icons.check_circle_rounded, color: Color(0xFF6E162B))
                  : null,
              onTap: () {
                setState(() => _language = 'ภาษาไทย');
                Navigator.of(ctx).pop();
              },
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('English', style: TextStyle(fontWeight: FontWeight.w600)),
              trailing: _language == 'English'
                  ? const Icon(Icons.check_circle_rounded, color: Color(0xFF6E162B))
                  : null,
              onTap: () {
                setState(() => _language = 'English');
                Navigator.of(ctx).pop();
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordModal() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'เปลี่ยนรหัสผ่าน',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF6E162B),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF7E777B)),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: oldPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'รหัสผ่านเดิม',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'รหัสผ่านใหม่',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'ยืนยันรหัสผ่านใหม่',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6E162B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('เปลี่ยนรหัสผ่านสำเร็จแล้ว'),
                      backgroundColor: const Color(0xFF6E162B),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                },
                child: const Text('บันทึกรหัสผ่านใหม่', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'ข้อกำหนดการใช้งาน',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF6E162B),
          ),
        ),
        content: const SingleChildScrollView(
          child: Text(
            'ข้อกำหนดและเงื่อนไขการใช้งานแอปพลิเคชัน MealMate สำหรับผู้ใช้งานทั่วไป\n\n'
            '1. ผู้ใช้ต้องปฏิบัติตามกฎหมายและข้อบังคับที่เกี่ยวข้อง\n'
            '2. ข้อมูลส่วนบุคคลจะถูกเก็บรักษาตามนโยบายความเป็นส่วนตัว\n'
            '3. การสั่งอาหารและจองโต๊ะเป็นไปตามเงื่อนไขของแต่ละร้านอาหาร',
            style: TextStyle(fontSize: 13.5, color: Color(0xFF444444), height: 1.4),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6E162B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('เข้าใจแล้ว'),
          ),
        ],
      ),
    );
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
                      padding: EdgeInsets.only(right: 34), // Center balance
                      child: Text(
                        'การตั้งค่า',
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
          // 2. SCROLLABLE SETTINGS CONTENT
          // ==========================================
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ----------------------------------------
                  // Section 1: ความเป็นส่วนตัว
                  // ----------------------------------------
                  _buildSectionHeader('ความเป็นส่วนตัว'),
                  const SizedBox(height: 10),
                  _buildCardContainer([
                    _buildSettingRow(
                      label: 'การติดต่อสื่อสาร',
                      value: _contactChannel,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('ช่องทางติดต่อปัจจุบัน: $_contactChannel'),
                            backgroundColor: const Color(0xFF6E162B),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1, thickness: 1, color: Color(0xFFF7EBEF), indent: 16, endIndent: 16),
                    _buildSettingRow(
                      label: 'การแจ้งเตือน',
                      value: _notificationEnabled ? 'เปิด' : 'ปิด',
                      onTap: _showNotificationToggleDialog,
                    ),
                    const Divider(height: 1, thickness: 1, color: Color(0xFFF7EBEF), indent: 16, endIndent: 16),
                    _buildSettingRow(
                      label: 'ความสนใจโฆษณา',
                      value: _adInterestEnabled ? 'เปิด' : 'ปิด',
                      onTap: _showAdInterestToggleDialog,
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // ----------------------------------------
                  // Section 2: ความปลอดภัยของบัญชี
                  // ----------------------------------------
                  _buildSectionHeader('ความปลอดภัยของบัญชี'),
                  const SizedBox(height: 10),
                  _buildCardContainer([
                    _buildSettingRow(
                      label: 'ยืนยันเบอร์โทร',
                      value: widget.phone,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('เบอร์โทรศัพท์ยืนยันแล้ว: ${widget.phone}'),
                            backgroundColor: const Color(0xFF6E162B),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1, thickness: 1, color: Color(0xFFF7EBEF), indent: 16, endIndent: 16),
                    _buildSettingRow(
                      label: 'ยืนยันอีเมล',
                      value: widget.email,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('อีเมลยืนยันแล้ว: ${widget.email}'),
                            backgroundColor: const Color(0xFF6E162B),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1, thickness: 1, color: Color(0xFFF7EBEF), indent: 16, endIndent: 16),
                    _buildSettingRow(
                      label: 'เปลี่ยนรหัสผ่าน',
                      value: '********',
                      onTap: _showChangePasswordModal,
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // ----------------------------------------
                  // Section 3: เกี่ยวกับแอป
                  // ----------------------------------------
                  _buildSectionHeader('เกี่ยวกับแอป'),
                  const SizedBox(height: 10),
                  _buildCardContainer([
                    _buildSettingRow(
                      label: 'เวอร์ชั่นแอป',
                      value: _appVersion,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('MealMate เวอร์ชั่น: $_appVersion (เวอร์ชันล่าสุด)'),
                            backgroundColor: const Color(0xFF6E162B),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1, thickness: 1, color: Color(0xFFF7EBEF), indent: 16, endIndent: 16),
                    _buildSettingRow(
                      label: 'ข้อกำหนดการใช้งาน',
                      value: _terms,
                      onTap: _showTermsDialog,
                    ),
                    const Divider(height: 1, thickness: 1, color: Color(0xFFF7EBEF), indent: 16, endIndent: 16),
                    _buildSettingRow(
                      label: 'ภาษา',
                      value: _language,
                      onTap: _showLanguageSelectionSheet,
                    ),
                  ]),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15.5,
        fontWeight: FontWeight.w800,
        color: Color(0xFF6E162B),
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildCardContainer(List<Widget> children) {
    return Container(
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
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingRow({
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13.8,
                fontWeight: FontWeight.w500,
                color: Color(0xFF221F21),
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 13.8,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
