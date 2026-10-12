import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart';
import '../../core/auth_session_manager.dart';
import '../../core/social_link_manager.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/social_login_buttons.dart';
import '../auth/login_screen.dart';
import 'social_connect_screen.dart';

class SettingsScreen extends StatefulWidget {
  final String email;
  final String phone;
  final String? loginProvider;
  final String? socialUserName;
  final bool showDeleteDialogOnInit;

  const SettingsScreen({
    super.key,
    this.email = 'Emma.carter@gmail.com',
    this.phone = '099-888-7777',
    this.loginProvider,
    this.socialUserName,
    this.showDeleteDialogOnInit = false,
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
  late String _currentProvider;
  late String _socialName;

  User? get _safeCurrentUser {
    try {
      return supabase.auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _currentProvider = widget.loginProvider ?? AuthSessionManager.currentProvider;
    _socialName = widget.socialUserName ?? AuthSessionManager.socialUserName;
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    if (widget.showDeleteDialogOnInit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showDeleteAccountDialog();
        }
      });
    }
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

  Widget _buildFacebookBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF3FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC4DBFC), width: 1.1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 17,
            height: 17,
            decoration: const BoxDecoration(
              color: Color(0xFF1877F2),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const SizedBox(
              width: 10,
              height: 10,
              child: FittedBox(
                child: SizedBox(
                  width: 26,
                  height: 26,
                  child: CustomPaint(
                    painter: FacebookLogoPainter(),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'Facebook',
            style: TextStyle(
              fontSize: 12.8,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1877F2),
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1.1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 15,
            height: 15,
            child: FittedBox(
              child: SizedBox(
                width: 26,
                height: 26,
                child: CustomPaint(
                  painter: GoogleLogoPainter(),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'Google',
            style: TextStyle(
              fontSize: 12.8,
              fontWeight: FontWeight.w700,
              color: Color(0xFF3C4043),
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  void _showSocialAccountDetailsSheet(String provider) {
    final isFacebook = provider.toLowerCase() == 'facebook';
    final providerTitle = isFacebook ? 'Facebook' : 'Google';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (modalContext, setModalState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Top Grab Handle
                Center(
                  child: Container(
                    width: 42,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2DCE0),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                // Branded Icon Circle
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: isFacebook ? const Color(0xFF1877F2) : Colors.white,
                    shape: BoxShape.circle,
                    border: isFacebook
                        ? null
                        : Border.all(color: const Color(0xFFE3E3E3), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: (isFacebook ? const Color(0xFF1877F2) : Colors.black)
                            .withOpacity(0.12),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: isFacebook
                      ? const SizedBox(
                          width: 38,
                          height: 38,
                          child: FittedBox(
                            child: SizedBox(
                              width: 26,
                              height: 26,
                              child: CustomPaint(
                                painter: FacebookLogoPainter(),
                              ),
                            ),
                          ),
                        )
                      : const SizedBox(
                          width: 34,
                          height: 34,
                          child: FittedBox(
                            child: SizedBox(
                              width: 26,
                              height: 26,
                              child: CustomPaint(
                                painter: GoogleLogoPainter(),
                              ),
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 14),

                // Main Title
                Text(
                  'เข้าสู่ระบบด้วย $providerTitle',
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF221F21),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                // Verified status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFC8E6C9)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_rounded, size: 14, color: Color(0xFF2E7D32)),
                      SizedBox(width: 4),
                      Text(
                        'บัญชีเชื่อมต่อและยืนยันแล้ว',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Profile Info Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F7F8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEFE8EB)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'ชื่อบัญชีผู้ใช้',
                            style: TextStyle(
                              fontSize: 13.5,
                              color: Color(0xFF7E777B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _socialName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF221F21),
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Divider(height: 1, color: Color(0xFFEFE8EB)),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'อีเมลที่ผูกไว้',
                            style: TextStyle(
                              fontSize: 13.5,
                              color: Color(0xFF7E777B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            widget.email,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF221F21),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Security Note
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF3F5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFF3DDE2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.shield_outlined,
                          size: 18,
                          color: Color(0xFF6E162B),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'บัญชีของคุณได้รับการคุ้มครองความปลอดภัยโดย $providerTitle โดยตรง ไม่จำเป็นต้องใช้รหัสผ่านในการเข้าใช้งาน',
                          style: const TextStyle(
                            fontSize: 12.8,
                            color: Color(0xFF5A4B4F),
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Optional Set Password Button (For hybrid auth support)
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6E162B),
                      side: const BorderSide(color: Color(0xFF6E162B), width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.lock_outline_rounded, size: 18),
                    label: const Text(
                      'ตั้งรหัสผ่านสำหรับอีเมล',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                    ),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _showChangePasswordModal();
                    },
                  ),
                ),

                const SizedBox(height: 10),

                // Close Button
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6E162B),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('เข้าใจแล้ว', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  ),
                ),

                const SizedBox(height: 16),

                // Demo / Test Mode Switcher
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F1F3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'ทดสอบโหมด: ',
                        style: TextStyle(fontSize: 11.5, color: Color(0xFF7E777B), fontWeight: FontWeight.w600),
                      ),
                      GestureDetector(
                        onTap: () {
                          AuthSessionManager.setProvider('facebook');
                          setState(() {
                            _currentProvider = 'facebook';
                          });
                          Navigator.of(ctx).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: _currentProvider == 'facebook' ? const Color(0xFF1877F2) : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Facebook',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _currentProvider == 'facebook' ? Colors.white : const Color(0xFF555555),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          AuthSessionManager.setProvider('google');
                          setState(() {
                            _currentProvider = 'google';
                          });
                          Navigator.of(ctx).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: _currentProvider == 'google' ? const Color(0xFF3C4043) : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Google',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _currentProvider == 'google' ? Colors.white : const Color(0xFF555555),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          AuthSessionManager.setProvider('email');
                          setState(() {
                            _currentProvider = 'email';
                          });
                          Navigator.of(ctx).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: _currentProvider == 'email' ? const Color(0xFF6E162B) : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'รหัสผ่าน',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _currentProvider == 'email' ? Colors.white : const Color(0xFF555555),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
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

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.40),
      builder: (BuildContext dialogContext) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 280,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: const Color(0xFFFAF4F5),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFDEC4C8),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Confirmation Question
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 26),
                    child: Text(
                      'ต้องการลบบัญชีใช่หรือไม่',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E1E1E),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),

                  // Horizontal Divider
                  Container(height: 1.0, color: const Color(0xFFDEC4C8)),

                  // Actions: ยกเลิก | ยืนยัน
                  SizedBox(
                    height: 48,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Left Button: ยกเลิก (Solid Burgundy Text)
                        Expanded(
                          child: InkWell(
                            key: const Key('cancel_delete_account_btn'),
                            onTap: () => Navigator.of(dialogContext).pop(),
                            child: const Center(
                              child: Text(
                                'ยกเลิก',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF6E162B),
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Center Vertical Divider
                        Container(
                          width: 1.0,
                          color: const Color(0xFFDEC4C8),
                        ),

                        // Right Button: ยืนยัน (Dark Text)
                        Expanded(
                          child: InkWell(
                            key: const Key('confirm_delete_account_btn'),
                            onTap: () async {
                              Navigator.of(dialogContext).pop();
                              await _confirmDeleteAccount();
                            },
                            child: const Center(
                              child: Text(
                                'ยืนยัน',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E1E1E),
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDeleteAccount() async {
    final currentUser = _safeCurrentUser;
    final currentUserId = currentUser?.id;
    if (currentUserId != null) {
      try {
        await supabase.from('users').delete().eq('id', currentUserId);
      } catch (_) {}
    } else if (widget.email.isNotEmpty && !widget.email.contains('Emma.carter@gmail.com')) {
      try {
        await supabase.from('users').delete().eq('email', widget.email);
      } catch (_) {}
    }

    try {
      await supabase.auth.signOut();
    } catch (_) {}

    try {
      AuthSessionManager.clearOverride();
    } catch (_) {}

    try {
      ProviderScope.containerOf(context, listen: false).read(authProvider.notifier).logout();
    } catch (_) {}

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('ลบบัญชีผู้ใช้เรียบร้อยแล้ว'),
          backgroundColor: const Color(0xFF6E162B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
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
                  _buildSectionHeader(
                    'ความปลอดภัยของบัญชี',
                    onLongPress: () {
                      _showQuickModeSwitcherSheet();
                    },
                  ),
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
                    
                    // Row 3: เชื่อมต่อ facebook google
                    _buildSettingRow(
                      key: const Key('settings_social_connect_row'),
                      label: 'เชื่อมต่อ facebook google',
                      valueWidget: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (SocialLinkManager.isFacebookLinked)
                            _buildFacebookBadge()
                          else if (SocialLinkManager.isGoogleLinked)
                            _buildGoogleBadge()
                          else
                            const Text(
                              'ยังไม่เชื่อมต่อ',
                              style: TextStyle(
                                fontSize: 13.8,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF7E777B),
                                letterSpacing: -0.2,
                              ),
                            ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                            color: Color(0xFFB0AAB0),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SocialConnectScreen(
                              email: widget.email,
                            ),
                          ),
                        ).then((_) {
                          setState(() {});
                        });
                      },
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

                  // ----------------------------------------
                  // Button: ลบบัญชี (Delete Account Button)
                  // ----------------------------------------
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      key: const Key('settings_delete_account_button'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6E162B),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _showDeleteAccountDialog,
                      child: const Text(
                        'ลบบัญชี',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onLongPress}) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15.5,
          fontWeight: FontWeight.w800,
          color: Color(0xFF6E162B),
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  void _showQuickModeSwitcherSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'เลือกช่องทางเข้าสู่ระบบเพื่อทดสอบ',
              style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800, color: Color(0xFF6E162B)),
            ),
            const SizedBox(height: 14),
            ListTile(
              leading: const Icon(Icons.facebook_rounded, color: Color(0xFF1877F2)),
              title: const Text('เข้าสู่ระบบด้วย Facebook', style: TextStyle(fontWeight: FontWeight.w600)),
              trailing: _currentProvider == 'facebook' ? const Icon(Icons.check_circle_rounded, color: Color(0xFF6E162B)) : null,
              onTap: () {
                AuthSessionManager.setProvider('facebook');
                setState(() => _currentProvider = 'facebook');
                Navigator.of(ctx).pop();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.g_mobiledata_rounded, size: 30, color: Color(0xFFEA4335)),
              title: const Text('เข้าสู่ระบบด้วย Google', style: TextStyle(fontWeight: FontWeight.w600)),
              trailing: _currentProvider == 'google' ? const Icon(Icons.check_circle_rounded, color: Color(0xFF6E162B)) : null,
              onTap: () {
                AuthSessionManager.setProvider('google');
                setState(() => _currentProvider = 'google');
                Navigator.of(ctx).pop();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.lock_rounded, color: Color(0xFF6E162B)),
              title: const Text('เข้าสู่ระบบด้วย อีเมล/รหัสผ่าน', style: TextStyle(fontWeight: FontWeight.w600)),
              trailing: _currentProvider == 'email' ? const Icon(Icons.check_circle_rounded, color: Color(0xFF6E162B)) : null,
              onTap: () {
                AuthSessionManager.setProvider('email');
                setState(() => _currentProvider = 'email');
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
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
    Key? key,
    required String label,
    String? value,
    Widget? valueWidget,
    VoidCallback? onTap,
  }) {
    return InkWell(
      key: key,
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13.8,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF221F21),
                  letterSpacing: -0.2,
                ),
              ),
            ),
            const SizedBox(width: 12),
            valueWidget ??
                Text(
                  value ?? '',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 13.8,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                    letterSpacing: -0.2,
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
