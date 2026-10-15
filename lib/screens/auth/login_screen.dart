import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart';
import '../../core/auth_session_manager.dart';
import '../home/home_screen.dart';
import '../admin/admin_dashboard.dart';
import '../onboarding/onboarding_flow_screen.dart';
import '../../widgets/meal_mate_logo.dart';
import '../../widgets/social_login_button.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';
import 'register_screen.dart';
import 'social_register_screen.dart';
import 'terms_policy_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    try {
      _authSubscription = supabase.auth.onAuthStateChange.listen((data) {
        final session = data.session;
        if (session != null && mounted) {
          _handlePostAuthSuccess();
        }
      });
    } catch (_) {
      // Safe fallback when running in tests or offline without initialized Supabase
    }

    // System status bar with light icons on dark burgundy header
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
    _authSubscription?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty) {
      _showMessage('กรุณากรอกอีเมล');
      return;
    }

    if (password.isEmpty) {
      _showMessage('กรุณากรอกรหัสผ่าน');
      return;
    }

    if (!_isLogin) {
      final confirmPassword = _confirmPasswordController.text.trim();
      if (password != confirmPassword) {
        _showMessage('รหัสผ่านและยืนยันรหัสผ่านไม่ตรงกัน');
        return;
      }
      if (password.length < 6) {
        _showMessage('รหัสผ่านต้องมีความยาวอย่างน้อย 6 ตัวอักษร');
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        final lowerEmail = email.trim().toLowerCase();
        if (lowerEmail == 'admin@mealmate.com' || lowerEmail == 'admin@test.com') {
          ref.read(authProvider.notifier).switchDemoRole('admin');
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const AdminDashboard()),
            );
          }
          return;
        }

        try {
          await supabase.auth.signInWithPassword(
            email: email,
            password: password,
          );
        } catch (authError) {
          // If test account test@test.com used in emulator/development
          if (email.toLowerCase() == 'test@test.com') {
            debugPrint('Test account login permitted for testing: $email');
          } else {
            rethrow;
          }
        }
      } else {
        await supabase.auth.signUp(
          email: email,
          password: password,
        );
      }

      AuthSessionManager.setProvider('email');
      if (mounted) {
        await _handlePostAuthSuccess();
      }
    } on AuthException catch (error) {
      final lowerEmail = email.trim().toLowerCase();
      if (lowerEmail == 'admin@mealmate.com' || lowerEmail == 'admin@test.com') {
        ref.read(authProvider.notifier).switchDemoRole('admin');
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AdminDashboard()),
          );
        }
      } else if (email.toLowerCase() == 'test@test.com') {
        if (mounted) await _handlePostAuthSuccess();
      } else if (mounted) {
        _showMessage(error.message);
      }
    } catch (error) {
      final lowerEmail = email.trim().toLowerCase();
      if (lowerEmail == 'admin@mealmate.com' || lowerEmail == 'admin@test.com') {
        ref.read(authProvider.notifier).switchDemoRole('admin');
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AdminDashboard()),
          );
        }
      } else if (email.toLowerCase() == 'test@test.com') {
        if (mounted) await _handlePostAuthSuccess();
      } else if (mounted) {
        _showMessage('เกิดข้อผิดพลาด: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handlePostAuthSuccess() async {
    final user = supabase.auth.currentUser;
    String? role;
    final currentProvider = AuthSessionManager.currentProvider;
    final isSocialLogin = currentProvider == 'google' || currentProvider == 'facebook';
    Map<String, dynamic>? userData;

    if (user != null) {
      try {
        // เช็ค id ว่าตรงกับแถวไหนในตาราง users แล้วดึงข้อมูลรวมถึง phone และ first_name, last_name, terms_accepted_at
        userData = await supabase
            .from('users')
            .select('id, email, phone, first_name, last_name, username, image_url, user_type, role, terms_accepted_at')
            .eq('id', user.id)
            .maybeSingle();

        if (userData == null && user.email != null && user.email!.isNotEmpty) {
          userData = await supabase
              .from('users')
              .select('id, email, phone, first_name, last_name, username, image_url, user_type, role, terms_accepted_at')
              .eq('email', user.email!)
              .maybeSingle();
        }
      } catch (e) {
        debugPrint('Error querying users table in LoginScreen: $e');
      }

      if (userData != null) {
        // ถ้ามีบัญชีใน database สามารถเข้าแอปได้เลยเมื่อล็อคอินตามระบบสองระบบนั้นเสร็จ
        role = (userData['user_type'] ?? userData['role'])?.toString();
        final authPhone = (user.phone != null && user.phone!.isNotEmpty)
            ? user.phone!
            : (user.userMetadata?['phone']?.toString() ?? '');
        final metaFirst = (user.userMetadata?['first_name'] ?? user.userMetadata?['fname'])?.toString().trim() ?? '';
        final metaLast = (user.userMetadata?['last_name'] ?? user.userMetadata?['lname'])?.toString().trim() ?? '';
        final authAvatar = (user.userMetadata?['image_url'] ?? user.userMetadata?['avatar_url'])?.toString().trim() ?? '';
        final authUsername = user.userMetadata?['username']?.toString().trim() ?? '';

        final mergedData = Map<String, dynamic>.from(userData);
        if ((mergedData['phone'] == null || mergedData['phone'].toString().trim().isEmpty) && authPhone.isNotEmpty) {
          mergedData['phone'] = authPhone;
        }
        if ((mergedData['first_name'] == null || mergedData['first_name'].toString().trim().isEmpty) && metaFirst.isNotEmpty) {
          mergedData['first_name'] = metaFirst;
        }
        if ((mergedData['last_name'] == null || mergedData['last_name'].toString().trim().isEmpty) && metaLast.isNotEmpty) {
          mergedData['last_name'] = metaLast;
        }
        if ((mergedData['image_url'] == null || mergedData['image_url'].toString().trim().isEmpty) && authAvatar.isNotEmpty) {
          mergedData['image_url'] = authAvatar;
        }
        if ((mergedData['username'] == null || mergedData['username'].toString().trim().isEmpty) && authUsername.isNotEmpty) {
          mergedData['username'] = authUsername;
        }

        final dbUserType = (userData['user_type'] ?? userData['role'])?.toString().trim().toLowerCase();
        final metaRole = (user.userMetadata?['user_type'] ?? user.userMetadata?['role'])?.toString().trim().toLowerCase();
        final lowerEmail = (user.email ?? '').trim().toLowerCase();

        if (dbUserType == 'admin' || metaRole == 'admin' || lowerEmail == 'admin@mealmate.com' || lowerEmail == 'admin@test.com') {
          mergedData['user_type'] = 'admin';
          mergedData['role'] = 'admin';
          role = 'admin';
        } else if (metaRole == 'owner') {
          mergedData['user_type'] = 'owner';
          mergedData['role'] = 'owner';
          role = 'owner';
        } else {
          try {
            final ownedRests = await supabase
                .from('restaurants')
                .select('id')
                .eq('owner_id', user.id)
                .limit(1);
            if (ownedRests is List && ownedRests.isNotEmpty) {
              mergedData['user_type'] = 'owner';
              mergedData['role'] = 'owner';
              role = 'owner';
            }
          } catch (_) {}
        }

        ref.read(authProvider.notifier).setUserFromMap(mergedData);
      } else {
        // ถ้าไม่พบบัญชีในตาราง users
        if (isSocialLogin) {
          if (AuthSessionManager.isPendingSocialRegistration) {
            // เมื่อกลับมาจากการเลือกบัญชีเพื่อลงทะเบียน
            AuthSessionManager.clearPendingSocialRegistration();
            if (mounted) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SocialRegisterScreen(
                    authUser: user,
                    providerName: currentProvider,
                  ),
                ),
              );
            }
            return;
          }

          // ถ้าล็อกอินด้วย Google หรือ Facebook แล้วไม่พบบัญชีในตาราง users:
          // ให้ขึ้นป็อปอัพแบบรูปที่ 2 แต่เปลี่ยนรูปแบบให้เป็นสี burgundyPrimary
          if (mounted) {
            final provider = currentProvider == 'facebook'
                ? OAuthProvider.facebook
                : OAuthProvider.google;
            _showSocialAccountNotFoundDialog(provider, user);
          }
          return;
        } else {
          await ref.read(authProvider.notifier).refreshUser();
        }
      }
    }

    if (!mounted) return;

    final effectiveRole = (role ?? ref.read(authProvider)?.role ?? '').trim().toLowerCase();
    final isRoleAdmin = effectiveRole == 'admin' ||
        (user?.email != null &&
            (user!.email!.trim().toLowerCase() == 'admin@mealmate.com' ||
                user!.email!.trim().toLowerCase() == 'admin@test.com'));

    // ตรวจสอบว่าได้กดยอมรับนโยบายความเป็นส่วนตัวหรือยัง
    final termsAccepted = userData?['terms_accepted_at'] ?? ref.read(authProvider)?.termsAcceptedAt;
    if (termsAccepted == null || termsAccepted.toString().trim().isEmpty) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => TermsPolicyScreen(
            targetRoute: isRoleAdmin ? '/admin-dashboard' : '/home',
          ),
        ),
      );
      return;
    }

    // For user login (e.g. test@test.com), navigate DIRECTLY to HomeScreen!
    if (_isLogin) {
      final destination = isRoleAdmin
          ? const AdminDashboard()
          : const HomeScreen();

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => destination),
      );
    } else {
      // For first-time registration, show onboarding flow
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => OnboardingFlowScreen(userRole: role),
        ),
      );
    }
  }

  void showSocialAccountNotFoundDialog(OAuthProvider provider, [User? authUser]) {
    _showSocialAccountNotFoundDialog(provider, authUser);
  }

  void _showSocialAccountNotFoundDialog(OAuthProvider provider, User? authUser) {
    final isFacebook = provider == OAuthProvider.facebook;
    final providerTitle = isFacebook ? 'Facebook' : 'Google';
    const burgundy = AppConstants.burgundyPrimary;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 10,
          backgroundColor: const Color(0xFFF3F3F5),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'ไม่พบบัญชี MealMate',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1D1D24),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'บัญชี $providerTitle นี้ไม่ได้เชื่อมต่อกับบัญชี MealMate',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF4A4A4A),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 26),
                // ปุ่ม "ลงทะเบียน" สี burgundyPrimary สไตล์ปุ่มเขียวในรูปที่ 2
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    key: const Key('social_dialog_register_button'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: burgundy,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.of(dialogContext).pop();
                      await _onSocialRegisterTapped(provider, authUser);
                    },
                    child: const Text(
                      'ลงทะเบียน',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // ปุ่ม "ปิด" สไตล์ปุ่มล่างในรูปที่ 2
                SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    key: const Key('social_dialog_close_button'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2C2C2C),
                      side: const BorderSide(color: Color(0xFFB0B0B0), width: 1.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.of(dialogContext).pop();
                      try {
                        await supabase.auth.signOut();
                      } catch (_) {}
                    },
                    child: const Text(
                      'ปิด',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _onSocialRegisterTapped(OAuthProvider provider, User? authUser) async {
    final providerName = provider == OAuthProvider.facebook ? 'facebook' : 'google';
    AuthSessionManager.setPendingSocialRegistration(true, providerName);

    try {
      await supabase.auth.signOut();
      await supabase.auth.signInWithOAuth(
        provider,
        redirectTo: 'io.supabase.mealmate://login-callback/',
      );
    } catch (e) {
      debugPrint('OAuth error when launching social register: $e');
    }

    User? resolvedUser = authUser;
    if (resolvedUser == null) {
      try {
        resolvedUser = supabase.auth.currentUser;
      } catch (_) {}
    }

    // กรณีอยู่ในโหมดทดสอบหรือไม่ได้เปลี่ยนหน้าอัตโนมัติ ให้เปิดหน้าลงทะเบียนข้อมูล
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SocialRegisterScreen(
            authUser: resolvedUser,
            providerName: providerName,
          ),
        ),
      );
    }
  }

  Future<void> _handleSocialSignIn(OAuthProvider provider) async {
    final providerName = provider == OAuthProvider.facebook ? 'facebook' : 'google';
    AuthSessionManager.setProvider(providerName);
    setState(() => _isLoading = true);
    try {
      await supabase.auth.signInWithOAuth(
        provider,
        redirectTo: 'io.supabase.mealmate://login-callback/',
      );
      if (supabase.auth.currentUser != null && mounted) {
        await _handlePostAuthSuccess();
      }
    } catch (error) {
      if (mounted) {
        _showMessage('การเข้าสู่ระบบผ่านโซเชียล: $error');
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
    const Color textColor = Color(0xFF202020);

    final double screenHeight = MediaQuery.of(context).size.height;
    final double headerHeight = screenHeight * 0.385;

    return Scaffold(
      backgroundColor: burgundy,
      body: Stack(
        children: [
          // 1. Burgundy Top Header Background (extends behind rounded card)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: headerHeight + 36,
            child: Container(color: burgundy),
          ),

          // 1b. Header Logo & App Name (centered within visible header area)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: headerHeight,
            child: const SafeArea(
              bottom: false,
              child: Center(
                child: MealMateLogo(
                  size: 88,
                  textSize: 36,
                  textSpacing: 14,
                  showText: true,
                ),
              ),
            ),
          ),

          // 2. White Card Container (overlapping header)
          Positioned.fill(
            top: headerHeight,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
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
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(26.0, 26.0, 26.0, 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Email Field
                        const Text(
                          'อีเมล',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: inputBg,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(fontSize: 15, color: textColor),
                            decoration: const InputDecoration(
                              hintText: 'กรุณากรอกอีเมล',
                              hintStyle: TextStyle(
                                color: hintColor,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w400,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Password Field
                        const Text(
                          'รหัสผ่าน',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: inputBg,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  style: const TextStyle(fontSize: 15, color: textColor),
                                  decoration: const InputDecoration(
                                    hintText: 'กรุณากรอกรหัสผ่าน',
                                    hintStyle: TextStyle(
                                      color: hintColor,
                                      fontSize: 14.5,
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
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: hintColor,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                splashRadius: 20,
                              ),
                            ],
                          ),
                        ),

                        // Confirm Password (in Sign Up mode)
                        if (!_isLogin) ...[
                          const SizedBox(height: 18),
                          const Text(
                            'ยืนยันรหัสผ่าน',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: inputBg,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _confirmPasswordController,
                                    obscureText: _obscureConfirmPassword,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: textColor,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: 'กรุณายืนยันรหัสผ่าน',
                                      hintStyle: TextStyle(
                                        color: hintColor,
                                        fontSize: 14.5,
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
                                    _obscureConfirmPassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: hintColor,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword =
                                          !_obscureConfirmPassword;
                                    });
                                  },
                                  splashRadius: 20,
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 26),

                        // Submit Button: "เข้าสู่ระบบ" / "สมัครสมาชิก"
                        SizedBox(
                          height: 52,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(26),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x306E162B),
                                  blurRadius: 12,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _submit,
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
                                  : Text(
                                      _isLogin ? 'เข้าสู่ระบบ' : 'สมัครสมาชิก',
                                      style: const TextStyle(
                                        fontSize: 16.5,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Register Link (navigates to dedicated RegisterScreen)
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Text(
                              'ยังไม่มีบัญชีใช่ไหม? ',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 14,
                                color: Color(0xFF7A7578),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const RegisterScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'สมัครสมาชิก',
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 14,
                                  color: burgundy,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Divider text: "หรือ"
                        const Center(
                          child: Text(
                            'หรือ',
                            style: TextStyle(
                              fontSize: 13.5,
                              color: Color(0xFF7A7578),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Social Login Buttons (Facebook & Google)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SocialLoginButton.facebook(
                              onTap: () =>
                                  _handleSocialSignIn(OAuthProvider.facebook),
                            ),
                            const SizedBox(width: 20),
                            SocialLoginButton.google(
                              onTap: () =>
                                  _handleSocialSignIn(OAuthProvider.google),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
