import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'edit_profile_success_screen.dart';
import 'forgot_password_screen.dart';

class EditUserProfileScreen extends StatefulWidget {
  final String initialName;
  final String initialEmail;
  final String initialPhone;

  const EditUserProfileScreen({
    super.key,
    this.initialName = 'Emma',
    this.initialEmail = 'Emma.carter@gmail.com',
    this.initialPhone = '099-888-7777',
  });

  @override
  State<EditUserProfileScreen> createState() => _EditUserProfileScreenState();
}

class _EditUserProfileScreenState extends State<EditUserProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _emailController = TextEditingController(text: widget.initialEmail);
    _phoneController = TextEditingController(text: widget.initialPhone == '-' ? '' : widget.initialPhone);
    _passwordController = TextEditingController(text: '********');

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
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('กรุณากรอกชื่อ - นามสกุล'),
          backgroundColor: const Color(0xFF6E162B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    // Navigate to Success Screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => EditProfileSuccessScreen(
          updatedData: {
            'name': name,
            'email': email.isNotEmpty ? email : widget.initialEmail,
            'phone': phone.isNotEmpty ? phone : (widget.initialPhone == '-' ? '' : widget.initialPhone),
          },
        ),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ForgotPasswordScreen(
          initialEmail: _emailController.text.isNotEmpty
              ? _emailController.text
              : widget.initialEmail,
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
          // 1. TOP SOLID BURGUNDY HEADER WITH TITLE
          // ==========================================
          Container(
            color: const Color(0xFF6E162B),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              left: 10,
              right: 20,
              bottom: 14,
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
                      padding: EdgeInsets.only(right: 34), // Center title properly
                      child: Text(
                        'แก้ไขข้อมูลผู้ใช้งาน',
                        style: TextStyle(
                          fontSize: 19,
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
          // 2. SCROLLABLE FORM BODY
          // ==========================================
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Field 1: ชื่อ - นามสกุล
                  _buildFieldLabel('ชื่อ - นามสกุล'),
                  const SizedBox(height: 7),
                  _buildInputField(
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                  ),

                  const SizedBox(height: 18),

                  // Field 2: อีเมล
                  _buildFieldLabel('อีเมล'),
                  const SizedBox(height: 7),
                  _buildInputField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 18),

                  // Field 3: เบอร์โทรศัพท์
                  _buildFieldLabel('เบอร์โทรศัพท์'),
                  const SizedBox(height: 7),
                  _buildInputField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 18),

                  // Field 4: รหัสผ่าน
                  _buildFieldLabel('รหัสผ่าน'),
                  const SizedBox(height: 7),
                  _buildInputField(
                    controller: _passwordController,
                    obscureText: true,
                  ),

                  const SizedBox(height: 8),

                  // Forgot Password Link (ลืมรหัสผ่าน)
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: _showForgotPasswordDialog,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                        child: Text(
                          'ลืมรหัสผ่าน',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF7E777B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Action Button 1: บันทึกข้อมูล (Solid Burgundy Button)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6E162B),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _saveProfile,
                      child: const Text(
                        'บันทึกข้อมูล',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Action Button 2: ยกเลิก (Outlined Button)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF6E162B),
                        side: const BorderSide(
                          color: Color(0xFF6E162B),
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'ยกเลิก',
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

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Color(0xFF221F21),
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFDCD4D6),
          width: 1.1,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        cursorColor: const Color(0xFF6E162B),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF221F21),
        ),
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
