import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';

/// Social Registration Screen:
/// When a user signs in via Google or Facebook but has no record in the `users` table:
/// Displays a registration form to collect required profile info:
/// 1. ชื่อ (first_name)
/// 2. นามสกุล (last_name)
/// 3. ชื่อผู้ใช้ (username)
/// 4. เบอร์โทรศัพท์ (phone)
/// All fields are mandatory. Checks for duplicate username and phone against Supabase.
/// Inserts record with id == auth.uid() (never randomly generated).
/// Directly enters the app without re-logging in.
class SocialRegisterScreen extends ConsumerStatefulWidget {
  final User? authUser;
  final String providerName; // 'google' or 'facebook'

  const SocialRegisterScreen({
    super.key,
    this.authUser,
    this.providerName = 'google',
  });

  @override
  ConsumerState<SocialRegisterScreen> createState() => _SocialRegisterScreenState();
}

class _SocialRegisterScreenState extends ConsumerState<SocialRegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _populateInitialData();

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

  User? _getAuthUser() {
    if (widget.authUser != null) return widget.authUser;
    try {
      return supabase.auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  void _populateInitialData() {
    final user = _getAuthUser();
    if (user != null) {
      final meta = user.userMetadata;
      if (meta != null) {
        final fName = (meta['first_name'] ?? meta['fname'])?.toString().trim();
        final lName = (meta['last_name'] ?? meta['lname'])?.toString().trim();
        final fullName = (meta['full_name'] ?? meta['name'])?.toString().trim();

        if (fName != null && fName.isNotEmpty) {
          _firstNameController.text = fName;
        } else if (fullName != null && fullName.isNotEmpty) {
          final parts = fullName.split(' ');
          _firstNameController.text = parts.first;
          if (parts.length > 1) {
            _lastNameController.text = parts.sublist(1).join(' ');
          }
        }

        if (lName != null && lName.isNotEmpty && _lastNameController.text.isEmpty) {
          _lastNameController.text = lName;
        }

        final uName = meta['username']?.toString().trim();
        if (uName != null && uName.isNotEmpty) {
          _usernameController.text = uName;
        }

        final phone = (user.phone != null && user.phone!.isNotEmpty)
            ? user.phone!
            : meta['phone']?.toString().trim();
        if (phone != null && phone.isNotEmpty) {
          _phoneController.text = phone;
        }
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitSocialRegister() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final username = _usernameController.text.trim();
    final phone = _phoneController.text.trim();

    // ทุกช่องในหน้าลงทะเบียนต้องกรอกทั้งหมด
    if (firstName.isEmpty) {
      _showMessage('กรุณากรอกชื่อจริง');
      return;
    }

    if (lastName.isEmpty) {
      _showMessage('กรุณากรอกนามสกุล');
      return;
    }

    if (username.isEmpty) {
      _showMessage('กรุณากรอกชื่อผู้ใช้');
      return;
    }

    if (phone.isEmpty) {
      _showMessage('กรุณากรอกเบอร์โทรศัพท์');
      return;
    }

    if (phone.length < 9 || !RegExp(r'^0[0-9]{8,9}$').hasMatch(phone)) {
      _showMessage('กรุณากรอกเบอร์โทรศัพท์ให้ถูกต้อง');
      return;
    }

    final currentUser = _getAuthUser();
    if (currentUser == null) {
      _showMessage('ไม่พบข้อมูลการยืนยันตัวตน กรุณาเข้าสู่ระบบใหม่อีกครั้ง');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ตรวจสอบชื่อผู้ใช้และเบอร์โทรที่มีคนใช้แล้วต้องแจ้งเตือน
      final existingUsername = await supabase
          .from('users')
          .select('id')
          .eq('username', username)
          .maybeSingle();

      if (existingUsername != null && existingUsername['id'] != currentUser.id) {
        if (mounted) {
          setState(() => _isLoading = false);
          _showMessage('ชื่อผู้ใช้นี้ถูกใช้งานแล้ว');
        }
        return;
      }

      final existingPhone = await supabase
          .from('users')
          .select('id')
          .eq('phone', phone)
          .maybeSingle();

      if (existingPhone != null && existingPhone['id'] != currentUser.id) {
        if (mounted) {
          setState(() => _isLoading = false);
          _showMessage('เบอร์โทรศัพท์นี้ถูกใช้งานแล้ว');
        }
        return;
      }
    } catch (checkErr) {
      debugPrint('Database duplicate check error: $checkErr');
    }

    try {
      // ตรวจสอบไม่ให้สร้างซ้ำ โดยใช้ id เดียวกับ auth.uid()
      final existingUser = await supabase
          .from('users')
          .select('id')
          .eq('id', currentUser.id)
          .maybeSingle();

      final avatarUrl = (currentUser.userMetadata?['avatar_url'] ??
              currentUser.userMetadata?['picture'])
          ?.toString();

      final newUserData = <String, dynamic>{
        'id': currentUser.id, // auth.uid() ต้องตรงกับผู้ใช้ที่ล็อกอิน ไม่ใช่สุ่มสร้างใหม่
        'email': currentUser.email ?? '',
        'phone': phone,
        'first_name': firstName,
        'last_name': lastName,
        'username': username,
        'user_type': 'customer',
        'role': 'customer',
        'swipe_count': 0,
      };

      if (avatarUrl != null && avatarUrl.isNotEmpty) {
        newUserData['image_url'] = avatarUrl;
      }

      if (existingUser != null) {
        await supabase.from('users').update(newUserData).eq('id', currentUser.id);
      } else {
        await supabase.from('users').insert(newUserData);
      }

      // เมื่อกดลงทะเบียนเสร็จสามารถเข้าแอปได้เลย ไม่ต้องล็อคอินอีกรอบ
      ref.read(authProvider.notifier).setUserFromMap(newUserData);

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (error) {
      if (mounted) {
        _showMessage('เกิดข้อผิดพลาดในการลงทะเบียน: $error');
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
        backgroundColor: AppConstants.burgundyPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color burgundy = AppConstants.burgundyPrimary;
    const Color inputBg = Color(0xFFEFECEF);
    const Color hintColor = Color(0xFFA8A4A8);
    const Color textColor = Color(0xFF1D1D24);

    final double screenHeight = MediaQuery.of(context).size.height;
    final double headerHeight = screenHeight * 0.22;
    final providerTitle = widget.providerName.toLowerCase().contains('facebook') ? 'Facebook' : 'Google';
    final user = _getAuthUser();
    final emailText = user?.email ?? '';

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
            child: Container(color: burgundy),
          ),

          // Header Content
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: headerHeight,
            child: SafeArea(
              bottom: false,
              child: Stack(
                children: [
                  Positioned(
                    top: 4,
                    left: 6,
                    child: IconButton(
                      key: const Key('social_register_back_button'),
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 22,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      splashRadius: 22,
                      tooltip: 'ย้อนกลับ',
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 52.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'ลงทะเบียนสมาชิก',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'เชื่อมต่อบัญชีกับ $providerTitle',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.5,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. White Card Container
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
                    padding: const EdgeInsets.fromLTRB(24.0, 22.0, 24.0, 28.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (emailText.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFBF4F6),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE8D0D6)),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.account_circle_outlined,
                                  color: burgundy,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    emailText,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: burgundy,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // 1. ชื่อ
                        _buildInputLabel('ชื่อ'),
                        const SizedBox(height: 6),
                        _buildTextField(
                          fieldKey: const Key('first_name_field'),
                          controller: _firstNameController,
                          hintText: 'ชื่อจริง',
                          inputBg: inputBg,
                          hintColor: hintColor,
                          textColor: textColor,
                        ),

                        const SizedBox(height: 14),

                        // 2. นามสกุล
                        _buildInputLabel('นามสกุล'),
                        const SizedBox(height: 6),
                        _buildTextField(
                          fieldKey: const Key('last_name_field'),
                          controller: _lastNameController,
                          hintText: 'นามสกุล',
                          inputBg: inputBg,
                          hintColor: hintColor,
                          textColor: textColor,
                        ),

                        const SizedBox(height: 14),

                        // 3. ชื่อผู้ใช้
                        _buildInputLabel('ชื่อผู้ใช้'),
                        const SizedBox(height: 6),
                        _buildTextField(
                          fieldKey: const Key('username_field'),
                          controller: _usernameController,
                          hintText: 'กรุณากรอกชื่อผู้ใช้',
                          inputBg: inputBg,
                          hintColor: hintColor,
                          textColor: textColor,
                        ),

                        const SizedBox(height: 14),

                        // 4. เบอร์โทรศัพท์
                        _buildInputLabel('เบอร์โทรศัพท์'),
                        const SizedBox(height: 6),
                        _buildTextField(
                          fieldKey: const Key('phone_field'),
                          controller: _phoneController,
                          hintText: 'กรุณากรอกเบอร์โทรศัพท์',
                          inputBg: inputBg,
                          hintColor: hintColor,
                          textColor: textColor,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                        ),

                        const SizedBox(height: 28),

                        // Submit Button: "ลงทะเบียน"
                        SizedBox(
                          height: 50,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x306E162B),
                                  blurRadius: 12,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              key: const Key('social_register_submit_button'),
                              onPressed: _isLoading ? null : _submitSocialRegister,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: burgundy,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: burgundy.withOpacity(0.7),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
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
                                      'ลงทะเบียน',
                                      style: TextStyle(
                                        fontSize: 16.5,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),
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

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14.5,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1D1D24),
      ),
    );
  }

  Widget _buildTextField({
    Key? fieldKey,
    required TextEditingController controller,
    required String hintText,
    required Color inputBg,
    required Color hintColor,
    required Color textColor,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      key: fieldKey,
      height: 50,
      decoration: BoxDecoration(
        color: inputBg,
        borderRadius: BorderRadius.circular(15),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: TextStyle(fontSize: 14.5, color: textColor),
        decoration: InputDecoration(
          hintText: hintText,
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
    );
  }
}
