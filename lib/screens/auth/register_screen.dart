import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart';
import '../onboarding/onboarding_flow_screen.dart';
import 'login_screen.dart';

/// Register Screen (สมัครสมาชิก): 100% Pure Dart implementation.
/// Form fields match the reference image:
/// 1. ชื่อ (ชื่อจริง)
/// 2. นามสกุล (นามสกุล)
/// 3. เลขบัตรประชาชน (กรุณากรอกเลขบัตรประชาชน)
/// 4. อีเมล (กรุณากรอกอีเมล)
/// 5. รหัสผ่าน (กรุณากรอกรหัสผ่าน)
/// 6. ยืนยันรหัสผ่าน (กรุณากรอกเพื่อยืนยันรหัสผ่าน)
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _citizenIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    // Configure system status bar to be transparent with light icons
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
    _firstNameController.dispose();
    _lastNameController.dispose();
    _citizenIdController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitRegister() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final citizenId = _citizenIdController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Field Validations
    if (firstName.isEmpty) {
      _showMessage('กรุณากรอกชื่อจริง');
      return;
    }

    if (lastName.isEmpty) {
      _showMessage('กรุณากรอกนามสกุล');
      return;
    }

    if (citizenId.isEmpty) {
      _showMessage('กรุณากรอกเลขบัตรประชาชน');
      return;
    }

    if (citizenId.length != 13) {
      _showMessage('เลขบัตรประชาชนต้องมี 13 หลัก');
      return;
    }

    if (email.isEmpty || !email.contains('@')) {
      _showMessage('กรุณากรอกอีเมลให้ถูกต้อง');
      return;
    }

    if (password.isEmpty) {
      _showMessage('กรุณากรอกรหัสผ่าน');
      return;
    }

    if (password.length < 6) {
      _showMessage('รหัสผ่านต้องมีความยาวอย่างน้อย 6 ตัวอักษร');
      return;
    }

    if (password != confirmPassword) {
      _showMessage('รหัสผ่านและยืนยันรหัสผ่านไม่ตรงกัน');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'citizen_id': citizenId,
        },
      );

      final user = response.user ?? supabase.auth.currentUser;
      if (user != null) {
        try {
          await supabase.from('users').upsert({
            'id': user.id,
            'email': email,
            'role': 'user',
            'swipe_count': 0,
          });
        } catch (_) {
          // If trigger already handled insertion, ignore
        }
      }

      if (mounted) {
        // Navigate to Onboarding Flow (Splash Screen 2 -> Splash Screen 3)
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const OnboardingFlowScreen(userRole: 'user'),
          ),
        );
      }
    } on AuthException catch (error) {
      if (mounted) {
        _showMessage(error.message);
      }
    } catch (error) {
      if (mounted) {
        _showMessage('เกิดข้อผิดพลาดในการสมัครสมาชิก: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF6E162B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color burgundy = Color(0xFF6E162B);
    const Color inputBg = Color(0xFFEFECEF);
    const Color hintColor = Color(0xFFA8A4A8);
    const Color textColor = Color(0xFF1D1D24);

    final double screenHeight = MediaQuery.of(context).size.height;
    final double headerHeight = screenHeight * 0.29; // Increased red header section

    return Scaffold(
      backgroundColor: burgundy,
      body: Stack(
        children: [
          // 1. Burgundy Top Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: headerHeight + 36,
            child: SafeArea(
              bottom: false,
              child: Stack(
                children: [
                  // Optional Back Button
                  Positioned(
                    top: 8,
                    left: 12,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                      splashRadius: 22,
                    ),
                  ),

                  // Header Title & Subtitle
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'สมัครสมาชิก',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24, // Reduced header title size
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'สมัครสมาชิกเพื่อเริ่มต้นใช้งาน',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.5, // Reduced by 1 unit
                              color: Colors.white.withOpacity(0.85),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. White Card Container (Overlapping Header)
          Positioned.fill(
            top: headerHeight,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(34),
                  topRight: Radius.circular(34),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x28000000),
                    blurRadius: 16,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(34),
                  topRight: Radius.circular(34),
                ),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28.0,
                    vertical: 28.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Field 1: ชื่อ
                      _buildInputLabel('ชื่อ'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _firstNameController,
                        hintText: 'ชื่อ',
                        inputBg: inputBg,
                        hintColor: hintColor,
                        textColor: textColor,
                      ),

                      const SizedBox(height: 18),

                      // Field 2: นามสกุล
                      _buildInputLabel('นามสกุล'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _lastNameController,
                        hintText: 'นามสกุล',
                        inputBg: inputBg,
                        hintColor: hintColor,
                        textColor: textColor,
                      ),

                      const SizedBox(height: 18),

                      // Field 3: เลขบัตรประชาชน
                      _buildInputLabel('เลขบัตรประชาชน'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _citizenIdController,
                        hintText: 'กรุณากรอกเลขบัตรประชาชน',
                        inputBg: inputBg,
                        hintColor: hintColor,
                        textColor: textColor,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(13),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // Field 4: อีเมล
                      _buildInputLabel('อีเมล'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _emailController,
                        hintText: 'กรุณากรอกอีเมล',
                        inputBg: inputBg,
                        hintColor: hintColor,
                        textColor: textColor,
                        keyboardType: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 18),

                      // Field 5: รหัสผ่าน
                      _buildInputLabel('รหัสผ่าน'),
                      const SizedBox(height: 8),
                      _buildPasswordField(
                        controller: _passwordController,
                        hintText: 'กรุณากรอกรหัสผ่าน',
                        obscure: _obscurePassword,
                        onToggle: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        inputBg: inputBg,
                        hintColor: hintColor,
                        textColor: textColor,
                      ),

                      const SizedBox(height: 18),

                      // Field 6: ยืนยันรหัสผ่าน
                      _buildInputLabel('ยืนยันรหัสผ่าน'),
                      const SizedBox(height: 8),
                      _buildPasswordField(
                        controller: _confirmPasswordController,
                        hintText: 'กรุณากรอกเพื่อยืนยันรหัสผ่าน',
                        obscure: _obscureConfirmPassword,
                        onToggle: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                        inputBg: inputBg,
                        hintColor: hintColor,
                        textColor: textColor,
                      ),

                      const SizedBox(height: 28),

                      // Submit Button: "สมัครสมาชิก"
                      SizedBox(
                        height: 52,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(26),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x386E162B),
                                blurRadius: 16,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: burgundy,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: burgundy.withOpacity(0.7),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(26),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.2,
                                    ),
                                  )
                                : const Text(
                                    'สมัครสมาชิก',
                                    style: TextStyle(
                                      fontSize: 16, // Reduced by 1 unit from 17
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Switch to Login Link
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            } else {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              );
                            }
                          },
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 13.5, // Reduced by 1 unit from 14.5
                              ),
                              children: [
                                TextSpan(
                                  text: 'มีบัญชีอยู่แล้วใช่ไหม? ',
                                  style: TextStyle(
                                    color: Color(0xFF7A7578),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                TextSpan(
                                  text: 'เข้าสู่ระบบ',
                                  style: TextStyle(
                                    color: burgundy,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14, // Reduced by 1 unit from 15
        fontWeight: FontWeight.w700,
        color: Color(0xFF1D1D24),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required Color inputBg,
    required Color hintColor,
    required Color textColor,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: inputBg,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: TextStyle(fontSize: 14, color: textColor), // Reduced by 1 unit
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: hintColor,
            fontSize: 14, // Reduced by 1 unit
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool obscure,
    required VoidCallback onToggle,
    required Color inputBg,
    required Color hintColor,
    required Color textColor,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: inputBg,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              style: TextStyle(fontSize: 14, color: textColor), // Reduced by 1 unit
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: hintColor,
                  fontSize: 14, // Reduced by 1 unit
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: hintColor,
              size: 20,
            ),
            onPressed: onToggle,
            splashRadius: 20,
          ),
        ],
      ),
    );
  }
}
