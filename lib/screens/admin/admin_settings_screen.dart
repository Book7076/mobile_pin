import 'package:flutter/material.dart';
import '../../main.dart';
import '../auth/login_screen.dart';
import 'admin_theme.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  void _showLogoutConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: const [
            Icon(Icons.logout_rounded, color: AdminTheme.primaryMaroon, size: 26),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'ยืนยันการออกจากระบบ',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: const Text(
          'คุณต้องการออกจากระบบผู้ดูแลระบบ Meaimate ใช่หรือไม่?',
          style: TextStyle(fontSize: 14.5, color: Color(0xFF333333)),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await supabase.auth.signOut();
              } catch (_) {}
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF800F2F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('ออกจากระบบ', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. ส่วนหัว (Header): การตั้งค่า & ไอคอนกระดิ่ง (ตรงตามภาพที่ 2)
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 18, bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'การตั้งค่า',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AdminTheme.primaryMaroon,
                      letterSpacing: -0.3,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: AdminTheme.primaryMaroon,
                      size: 28,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('ไม่มีการแจ้งเตือนใหม่'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // 2. การ์ดโปรไฟล์ Admin: อวาตาร์ A, ชื่อ Admin, อีเมล mealmate001@gmail.com (ตรงตามภาพที่ 2)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFF3E7E8), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Row(
                  children: [
                    // อวาตาร์วงกลมสีแดงเบอร์กันดี พร้อมตัวอักษร A สีขาว
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor: Color(0xFF800F2F),
                      child: Text(
                        'A',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // ข้อมูลแอดมิน
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Admin',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E1E1E),
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: const [
                              Icon(
                                Icons.email_outlined,
                                size: 14,
                                color: Color(0xFF757575),
                              ),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'mealmate001@gmail.com',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF757575),
                                    fontWeight: FontWeight.w400,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 3. การ์ดปุ่มกด "ออกจากระบบ" (ตรงตามภาพที่ 2)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFF3E7E8), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => _showLogoutConfirmDialog(context),
                  splashColor: AdminTheme.primaryMaroon.withOpacity(0.05),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.logout_rounded,
                          color: Color(0xFF1E1E1E),
                          size: 22,
                        ),
                        SizedBox(width: 14),
                        Text(
                          'ออกจากระบบ',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E1E1E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
