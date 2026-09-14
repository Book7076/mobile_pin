import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'forgot_password_otp_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String initialEmail;

  const ForgotPasswordScreen({
    super.key,
    this.initialEmail = 'Example@gmail.com',
  });

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);

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
    _emailController.dispose();
    super.dispose();
  }

  void _sendOtp() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('กรุณากรอกอีเมลหรือเบอร์โทรศัพท์'),
          backgroundColor: const Color(0xFF6E162B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ForgotPasswordOtpScreen(
          email: email,
        ),
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),

                  // Circular Lock Badge
                  Container(
                    width: 96,
                    height: 96,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD9B4BC), // Soft dusty rose badge
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.lock_rounded,
                        color: Color(0xFF6E162B), // Solid burgundy padlock
                        size: 48,
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Instruction Text
                  const Text(
                    'กรอกอีเมลหรือเบอร์โทรที่ใช้สมัครสมาชิก\nเราจะส่งรหัสยืนยันให้คุณ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFF666666),
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 34),

                  // Input Label: อีเมล / เบอร์โทรศัพท์
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'อีเมล / เบอร์โทรศัพท์',
                      style: const TextStyle(
                        fontSize: 13.8,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF221F21),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Input Field
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(
                      fontSize: 14.5,
                      color: Color(0xFF221F21),
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Example@gmail.com',
                      hintStyle: const TextStyle(
                        color: Color(0xFFAAAAAA),
                        fontSize: 14.5,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      filled: true,
                      fillColor: Colors.white,
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

                  const SizedBox(height: 80),

                  // Bottom Action Button: ส่งรหัสยืนยัน
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
                      onPressed: _sendOtp,
                      child: const Text(
                        'ส่งรหัสยืนยัน',
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
