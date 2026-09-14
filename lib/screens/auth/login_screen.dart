import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart';
import '../../widgets/meal_mate_logo.dart';
import '../../widgets/social_login_button.dart';
import '../home/home_screen.dart';
import '../admin/admin_dashboard.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isLogin = true;
  bool _obscurePassword = true;

  static const Color primaryBurgundy = Color(0xFF700F2B);
  static const Color primaryBurgundyTop = Color(0xFF7B1234);
  static const Color primaryBurgundyBottom = Color(0xFF660D27);
  static const Color inputFieldColor = Color(0xFFEBEBEB);
  static const Color textGrayColor = Color(0xFF757575);
  static const Color hintGrayColor = Color(0xFF9E9E9E);

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      if (_isLogin) {
        await supabase.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        await supabase.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }

      if (mounted) {
        final user = supabase.auth.currentUser;
        if (user != null) {
          try {
            final userData = await supabase
                .from('users')
                .select('role')
                .eq('id', user.id)
                .single();

            if (mounted) {
              if (userData['role'] == 'admin') {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const AdminDashboard()),
                );
              } else {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              }
            }
          } catch (_) {
            // Default to HomeScreen if user role lookup fails or user record isn't seeded yet
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            }
          }
        }
      }
    } on AuthException catch (error) {
      if (mounted) {
        _showSnackBar(error.message, isError: true);
      }
    } catch (error) {
      if (mounted) {
        _showSnackBar('เกิดข้อผิดพลาด: $error', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.notoSansThai(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: isError ? const Color(0xFFD32F2F) : primaryBurgundy,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _handleSocialLogin(String provider) {
    _showSnackBar('กำลังเชื่อมต่อระบบ $provider...', isError: false);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final headerHeight = (screenHeight * 0.35).clamp(210.0, 300.0);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: primaryBurgundy,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [primaryBurgundyTop, primaryBurgundyBottom],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Top Header with Logo
                          SizedBox(
                            height: headerHeight,
                            child: const Center(
                              child: MealMateLogo(size: 110),
                            ),
                          ),

                          // Bottom White Card
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(36),
                                  topRight: Radius.circular(36),
                                ),
                              ),
                              padding: const EdgeInsets.fromLTRB(28, 36, 28, 36),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Email Label
                                    Text(
                                      'อีเมล',
                                      style: GoogleFonts.notoSansThai(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF222222),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Email Text Field
                                    TextFormField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      style: GoogleFonts.notoSansThai(
                                        fontSize: 15,
                                        color: const Color(0xFF222222),
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'กรุณากรอกอีเมล',
                                        hintStyle: GoogleFonts.notoSansThai(
                                          fontSize: 14,
                                          color: hintGrayColor,
                                        ),
                                        filled: true,
                                        fillColor: inputFieldColor,
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 16,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(18),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(18),
                                          borderSide: const BorderSide(
                                            color: primaryBurgundy,
                                            width: 1.5,
                                          ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(18),
                                          borderSide: const BorderSide(
                                            color: Colors.redAccent,
                                            width: 1.2,
                                          ),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(18),
                                          borderSide: const BorderSide(
                                            color: Colors.redAccent,
                                            width: 1.5,
                                          ),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'กรุณากรอกอีเมล';
                                        }
                                        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                        if (!emailRegex.hasMatch(value.trim())) {
                                          return 'รูปแบบอีเมลไม่ถูกต้อง';
                                        }
                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 20),

                                    // Password Label
                                    Text(
                                      'รหัสผ่าน',
                                      style: GoogleFonts.notoSansThai(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF222222),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Password Text Field
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      textInputAction: TextInputAction.done,
                                      onFieldSubmitted: (_) => _submit(),
                                      style: GoogleFonts.notoSansThai(
                                        fontSize: 15,
                                        color: const Color(0xFF222222),
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'กรุณากรอกรหัสผ่าน',
                                        hintStyle: GoogleFonts.notoSansThai(
                                          fontSize: 14,
                                          color: hintGrayColor,
                                        ),
                                        filled: true,
                                        fillColor: inputFieldColor,
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 16,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(18),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(18),
                                          borderSide: const BorderSide(
                                            color: primaryBurgundy,
                                            width: 1.5,
                                          ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(18),
                                          borderSide: const BorderSide(
                                            color: Colors.redAccent,
                                            width: 1.2,
                                          ),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(18),
                                          borderSide: const BorderSide(
                                            color: Colors.redAccent,
                                            width: 1.5,
                                          ),
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                            color: hintGrayColor,
                                            size: 22,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscurePassword = !_obscurePassword;
                                            });
                                          },
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return 'กรุณากรอกรหัสผ่าน';
                                        }
                                        if (value.trim().length < 6) {
                                          return 'รหัสผ่านต้องมีความยาวอย่างน้อย 6 ตัวอักษร';
                                        }
                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 28),

                                    // Main Submit Button
                                    SizedBox(
                                      height: 52,
                                      child: ElevatedButton(
                                        onPressed: _isLoading ? null : _submit,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: primaryBurgundy,
                                          disabledBackgroundColor: primaryBurgundy.withValues(alpha: 0.7),
                                          foregroundColor: Colors.white,
                                          elevation: 2,
                                          shadowColor: primaryBurgundy.withValues(alpha: 0.4),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(26),
                                          ),
                                        ),
                                        child: _isLoading
                                            ? const SizedBox(
                                                width: 24,
                                                height: 24,
                                                child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2.5,
                                                ),
                                              )
                                            : Text(
                                                _isLogin ? 'เข้าสู่ระบบ' : 'สมัครสมาชิก',
                                                style: GoogleFonts.notoSansThai(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white,
                                                ),
                                              ),
                                      ),
                                    ),

                                    const SizedBox(height: 22),

                                    // Toggle Login / Sign Up Switcher
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          _isLogin
                                              ? 'ยังไม่มีบัญชีใช่ไหม? '
                                              : 'มีบัญชีอยู่แล้ว? ',
                                          style: GoogleFonts.notoSansThai(
                                            fontSize: 14,
                                            color: textGrayColor,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _isLogin = !_isLogin;
                                            });
                                          },
                                          child: Text(
                                            _isLogin ? 'สมัครสมาชิก' : 'เข้าสู่ระบบ',
                                            style: GoogleFonts.notoSansThai(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: primaryBurgundy,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 18),

                                    // "หรือ" (Or) Divider
                                    Center(
                                      child: Text(
                                        'หรือ',
                                        style: GoogleFonts.notoSansThai(
                                          fontSize: 14,
                                          color: hintGrayColor,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 18),

                                    // Social Login Buttons (Facebook & Google)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SocialLoginButton.facebook(
                                          onTap: () => _handleSocialLogin('Facebook'),
                                        ),
                                        const SizedBox(width: 24),
                                        SocialLoginButton.google(
                                          onTap: () => _handleSocialLogin('Google'),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 12),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
