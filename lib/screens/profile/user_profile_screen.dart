import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../main.dart';
import '../auth/login_screen.dart';
import 'edit_user_profile_screen.dart';
import 'edit_user_photo_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final bool showDeleteDialogOnInit;

  const UserProfileScreen({
    super.key,
    this.showDeleteDialogOnInit = false,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late String _name;
  late String _email;
  late String _phone;
  final String _password = '********';
  String? _profilePhotoUrl;

  @override
  void initState() {
    super.initState();
    final currentUser = supabase.auth.currentUser;
    _name = 'Emma';
    _email = currentUser?.email ?? 'Emma.carter@gmail.com';
    _phone = '099-888-7777';

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

  void _openEditProfileScreen() async {
    final result = await Navigator.of(context).push<Map<String, String>>(
      MaterialPageRoute(
        builder: (_) => EditUserProfileScreen(
          initialName: _name,
          initialEmail: _email,
          initialPhone: _phone,
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _name = result['name'] ?? _name;
        _email = result['email'] ?? _email;
        _phone = result['phone'] ?? _phone;
      });
    }
  }

  void _openEditPhotoScreen() async {
    final result = await Navigator.of(context).push<String?>(
      MaterialPageRoute(
        builder: (_) => EditUserPhotoScreen(
          currentPhotoUrl: _profilePhotoUrl,
        ),
      ),
    );
    if (mounted) {
      setState(() {
        _profilePhotoUrl = result;
      });
    }
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
                            onTap: () async {
                              Navigator.of(dialogContext).pop();
                              try {
                                await supabase.auth.signOut();
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
                      padding: EdgeInsets.only(right: 34), // Offset leading button
                      child: Text(
                        'โปรไฟล์',
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
          // 2. SCROLLABLE BODY
          // ==========================================
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 6),

                  // User Avatar with Camera Badge
                  Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Large Circular Profile Avatar
                        GestureDetector(
                          onTap: _openEditPhotoScreen,
                          child: Container(
                            width: 124,
                            height: 124,
                            decoration: const BoxDecoration(
                              color: Color(0xFF6E162B),
                              shape: BoxShape.circle,
                            ),
                            child: _profilePhotoUrl != null
                                ? ClipOval(
                                    child: Image.network(
                                      _profilePhotoUrl!,
                                      width: 124,
                                      height: 124,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Center(
                                        child: Icon(
                                          Icons.person_rounded,
                                          color: Colors.white,
                                          size: 88,
                                        ),
                                      ),
                                    ),
                                  )
                                : const Center(
                                    child: Icon(
                                      Icons.person_rounded,
                                      color: Colors.white,
                                      size: 88,
                                    ),
                                  ),
                          ),
                        ),

                        // Camera Icon Badge at Bottom-Right
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _openEditPhotoScreen,
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF6E162B),
                                  width: 1.4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.camera_alt_outlined,
                                  color: Color(0xFF6E162B),
                                  size: 19,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Section Title: ข้อมูลผู้ใช้งาน
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'ข้อมูลผู้ใช้งาน',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF6E162B),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Information Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFF2DDE1),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Row 1: ชื่อ -นามสกุล
                        _buildInfoRow('ชื่อ -นามสกุล', _name),
                        _buildDivider(),

                        // Row 2: อีเมล
                        _buildInfoRow('อีเมล', _email),
                        _buildDivider(),

                        // Row 3: เบอร์โทรศัพท์
                        _buildInfoRow('เบอร์โทรศัพท์', _phone),
                        _buildDivider(),

                        // Row 4: รหัสผ่าน
                        _buildInfoRow('รหัสผ่าน', _password),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Button 1: แก้ไขข้อมูล (Outlined Button)
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
                      onPressed: _openEditProfileScreen,
                      child: const Text(
                        'แก้ไขข้อมูล',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Button 2: ลบบัญชี (Solid Filled Button)
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13.5,
              color: Color(0xFF7E777B),
              fontWeight: FontWeight.w500,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13.5,
                color: Color(0xFF221F21),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1.0,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: const Color(0xFFF6E8EA),
    );
  }
}
