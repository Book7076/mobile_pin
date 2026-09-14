import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'reset_password_success_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({
    super.key,
    required this.email,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    // Set default demo text as shown in mockup
    _newPasswordController.text = 'Password123';
    _confirmPasswordController.text = 'Password123';

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

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submitNewPassword() {
    final newPass = _newPasswordController.text;
    final confirmPass = _confirmPasswordController.text;

    if (newPass.isEmpty || confirmPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('กรุณากรอกรหัสผ่านใหม่ให้ครบถ้วน'),
          backgroundColor: const Color(0xFF6E162B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    if (newPass != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('รหัสผ่านไม่ตรงกัน กรุณาตรวจสอบอีกครั้ง'),
          backgroundColor: const Color(0xFF6E162B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    if (newPass.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('รหัสผ่านต้องมีอย่างน้อย 8 ตัวอักษร'),
          backgroundColor: const Color(0xFF6E162B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ResetPasswordSuccessScreen(),
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
                      padding: EdgeInsets.only(right: 34),
                      child: Text(
                        'ลืมรหัสผ่าน',
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
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // Circular Lock Badge
                  Center(
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD9B4BC),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.lock_rounded,
                          color: Color(0xFF6E162B),
                          size: 48,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Field 1: รหัสผ่านใหม่
                  const Text(
                    'รหัสผ่านใหม่',
                    style: TextStyle(
                      fontSize: 13.8,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF221F21),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _newPasswordController,
                    obscureText: _obscureNew,
                    style: const TextStyle(
                      fontSize: 14.5,
                      color: Color(0xFF221F21),
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: '*********',
                      hintStyle: const TextStyle(
                        color: Color(0xFFAAAAAA),
                        fontSize: 14.5,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      filled: true,
                      fillColor: Colors.white,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: const Color(0xFF888888),
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscureNew = !_obscureNew),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2CDD1), width: 1.2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF6E162B), width: 1.4),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Field 2: ยืนยันรหัสผ่านใหม่
                  const Text(
                    'ยืนยันรหัสผ่านใหม่',
                    style: TextStyle(
                      fontSize: 13.8,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF221F21),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirm,
                    style: const TextStyle(
                      fontSize: 14.5,
                      color: Color(0xFF221F21),
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: '*********',
                      hintStyle: const TextStyle(
                        color: Color(0xFFAAAAAA),
                        fontSize: 14.5,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      filled: true,
                      fillColor: Colors.white,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: const Color(0xFF888888),
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2CDD1), width: 1.2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF6E162B), width: 1.4),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Password Validation Rules
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          '• อย่างน้อย 8 ตัวอักษร',
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Color(0xFF777777),
                            height: 1.5,
                          ),
                        ),
                        Text(
                          '• มีอักษรพิมพ์ใหญ่อย่างน้อย 1 ตัวอักษร',
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Color(0xFF777777),
                            height: 1.5,
                          ),
                        ),
                        Text(
                          '• มีตัวเลขอย่างน้อย 1 ตัว',
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Color(0xFF777777),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Action Button: ยืนยัน
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6E162B),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        shadowColor: const Color(0x336E162B),
                      ),
                      onPressed: _submitNewPassword,
                      child: const Text(
                        'ยืนยัน',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
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
}
