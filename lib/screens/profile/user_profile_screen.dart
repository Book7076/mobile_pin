import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart';
import '../../core/auth_session_manager.dart';
import '../../widgets/social_login_buttons.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import 'edit_user_profile_screen.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  final bool showDeleteDialogOnInit;

  const UserProfileScreen({
    super.key,
    this.showDeleteDialogOnInit = false,
  });

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  String _username = '';
  late String _name;
  late String _email;
  late String _phone;
  final String _password = '********';
  String? _profilePhotoUrl;
  late String _currentProvider;

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
    final currentUser = _safeCurrentUser;
    _currentProvider = AuthSessionManager.currentProvider;

    final authUser = ref.read(authProvider);
    _username = authUser?.username ?? (currentUser?.userMetadata?['username']?.toString() ?? '');
    final authAvatar = authUser?.avatarUrl ??
        (currentUser?.userMetadata?['image_url']?.toString() ??
            currentUser?.userMetadata?['avatar_url']?.toString());
    if (authAvatar != null && authAvatar.trim().isNotEmpty) {
      _profilePhotoUrl = authAvatar.trim();
    }

    final metaFirst = (currentUser?.userMetadata?['first_name'] ?? currentUser?.userMetadata?['fname'])?.toString().trim() ?? '';
    final metaLast = (currentUser?.userMetadata?['last_name'] ?? currentUser?.userMetadata?['lname'])?.toString().trim() ?? '';
    final metaFullName = [metaFirst, metaLast].where((s) => s.isNotEmpty).join(' ');

    if (authUser?.name.isNotEmpty == true && authUser!.name != 'ผู้ใช้งาน' && !authUser.name.contains('@')) {
      _name = authUser.name;
    } else if (metaFullName.isNotEmpty) {
      _name = metaFullName;
    } else {
      final emailPrefix = currentUser?.email?.split('@').first ?? 'ผู้ใช้งาน';
      if (emailPrefix.contains('.')) {
        _name = emailPrefix.split('.').map((p) => p.isNotEmpty ? '${p[0].toUpperCase()}${p.substring(1)}' : '').join(' ');
      } else {
        _name = emailPrefix;
      }
    }

    _email = currentUser?.email ?? (authUser?.email.isNotEmpty == true ? authUser!.email : '');
    final authPhone = (authUser?.phone.isNotEmpty == true)
        ? authUser!.phone
        : (currentUser?.phone ?? (currentUser?.userMetadata?['phone']?.toString() ?? ''));
    _phone = authPhone.trim().isNotEmpty ? _formatPhoneNumber(authPhone) : '-';

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    // เช็ค id จากตาราง users แล้วดึง phone, username, image_url และ Fname Lname มาแสดง
    _loadUserFromUsersTable();
  }

  Future<void> _loadUserFromUsersTable() async {
    final currentUser = _safeCurrentUser;
    final userId = currentUser?.id ?? ref.read(authProvider)?.id;

    if (userId == null || userId.isEmpty) {
      return;
    }

    try {
      // 1. เช็ค id ของคนที่ล็อกอินว่าตรงกับแถวไหนในตาราง users (เชื่อมกับ username และ image_url)
      var data = await supabase
          .from('users')
          .select('id, email, phone, first_name, last_name, username, image_url')
          .eq('id', userId)
          .maybeSingle();

      if (data == null && currentUser?.email != null && currentUser!.email!.isNotEmpty) {
        data = await supabase
            .from('users')
            .select('id, email, phone, first_name, last_name, username, image_url')
            .eq('email', currentUser.email!)
            .maybeSingle();
      }

      final userRow = data;
      final authUser = ref.read(authProvider);

      // ดึงค่า username
      final rawUsername = userRow?['username']?.toString().trim() ??
          currentUser?.userMetadata?['username']?.toString().trim() ??
          authUser?.username ??
          '';

      // ดึงค่า image_url
      final rawImageUrl = userRow?['image_url']?.toString().trim() ??
          currentUser?.userMetadata?['image_url']?.toString().trim() ??
          currentUser?.userMetadata?['avatar_url']?.toString().trim() ??
          authUser?.avatarUrl;

      // ดึงค่า phone: จากตาราง users ก่อน ถ้าไม่มีให้ดึงจาก Supabase Auth
      var rawPhone = userRow?['phone']?.toString().trim();
      if (rawPhone == null || rawPhone.isEmpty) {
        rawPhone = currentUser?.phone?.trim();
      }
      if (rawPhone == null || rawPhone.isEmpty) {
        rawPhone = currentUser?.userMetadata?['phone']?.toString().trim();
      }

      // ดึงค่า first_name และ last_name จากตาราง users หรือ fallback จาก Auth userMetadata
      var rawFirstName = (userRow?['first_name'] ?? userRow?['fname'])?.toString().trim() ?? '';
      var rawLastName = (userRow?['last_name'] ?? userRow?['lname'])?.toString().trim() ?? '';

      if (rawFirstName.isEmpty) {
        rawFirstName = (currentUser?.userMetadata?['first_name'] ?? currentUser?.userMetadata?['fname'])?.toString().trim() ?? '';
      }
      if (rawLastName.isEmpty) {
        rawLastName = (currentUser?.userMetadata?['last_name'] ?? currentUser?.userMetadata?['lname'])?.toString().trim() ?? '';
      }

      // Format เป็น "Fname Lname"
      final combinedName = [rawFirstName, rawLastName].where((s) => s.isNotEmpty).join(' ');

      String resolvedName;
      if (combinedName.isNotEmpty) {
        resolvedName = combinedName;
      } else if (userRow?['name'] != null && userRow!['name'].toString().trim().isNotEmpty) {
        resolvedName = userRow['name'].toString().trim();
      } else {
        final emailPrefix = currentUser?.email?.split('@').first ?? 'ผู้ใช้งาน';
        if (emailPrefix.contains('.')) {
          resolvedName = emailPrefix.split('.').map((p) => p.isNotEmpty ? '${p[0].toUpperCase()}${p.substring(1)}' : '').join(' ');
        } else {
          resolvedName = emailPrefix;
        }
      }

      if (mounted) {
        setState(() {
          _username = rawUsername;
          _phone = (rawPhone != null && rawPhone.isNotEmpty)
              ? _formatPhoneNumber(rawPhone)
              : '-';
          _name = resolvedName;
          _email = userRow?['email']?.toString() ?? (currentUser?.email ?? _email);
          if (rawImageUrl != null && rawImageUrl.isNotEmpty) {
            _profilePhotoUrl = rawImageUrl;
          }
        });

        if (userRow != null) {
          final mergedData = Map<String, dynamic>.from(userRow);
          if (rawPhone != null && rawPhone.isNotEmpty) {
            mergedData['phone'] = rawPhone;
          }
          if (rawFirstName.isNotEmpty) {
            mergedData['first_name'] = rawFirstName;
          }
          if (rawLastName.isNotEmpty) {
            mergedData['last_name'] = rawLastName;
          }
          if (rawUsername.isNotEmpty) {
            mergedData['username'] = rawUsername;
          }
          if (rawImageUrl != null && rawImageUrl.isNotEmpty) {
            mergedData['image_url'] = rawImageUrl;
          }
          ref.read(authProvider.notifier).setUserFromMap(mergedData);
        }
      }
    } catch (_) {}
  }

  String _formatPhoneNumber(String raw) {
    var clean = raw.replaceAll(RegExp(r'[-\s]'), '');
    if (clean.startsWith('+66')) {
      clean = '0${clean.substring(3)}';
    } else if (clean.startsWith('66') && clean.length >= 11) {
      clean = '0${clean.substring(2)}';
    }
    if (clean.length == 10) {
      return '${clean.substring(0, 3)}-${clean.substring(3, 6)}-${clean.substring(6)}';
    } else if (clean.length == 9) {
      return '${clean.substring(0, 2)}-${clean.substring(2, 5)}-${clean.substring(5)}';
    }
    return raw;
  }

  void _openEditProfileScreen() async {
    final authUser = ref.read(authProvider);
    final currentPhone = _phone != '-' ? _phone : (authUser?.phone.isNotEmpty == true ? _formatPhoneNumber(authUser!.phone) : '');
    final currentName = _name != 'ผู้ใช้งาน' ? _name : (authUser?.name.isNotEmpty == true ? authUser!.name : _name);
    final currentEmail = _email.isNotEmpty ? _email : (authUser?.email.isNotEmpty == true ? authUser!.email : _email);

    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => EditUserProfileScreen(
          initialUsername: _username,
          initialName: currentName,
          initialEmail: currentEmail,
          initialPhone: currentPhone == '-' ? '' : currentPhone,
          initialImageUrl: _profilePhotoUrl,
        ),
      ),
    );

    if (result != null && mounted) {
      final phoneInput = result['phone']?.toString().trim() ?? '';
      final updatedPhone = phoneInput.isNotEmpty
          ? _formatPhoneNumber(phoneInput)
          : '-';
      final updatedUsername = result['username']?.toString() ?? _username;
      final updatedName = result['name']?.toString() ?? _name;
      final updatedEmail = result['email']?.toString() ?? _email;
      final updatedImageUrl = result['image_url']?.toString();

      setState(() {
        _username = updatedUsername;
        _name = updatedName;
        _email = updatedEmail;
        _phone = updatedPhone;
        _profilePhotoUrl = (updatedImageUrl != null && updatedImageUrl.isNotEmpty)
            ? updatedImageUrl
            : null;
      });

      // ดึงข้อมูลล่าสุดจากตาราง users เพื่อให้ตรงกับฐานข้อมูลเสมอ
      await _loadUserFromUsersTable();
    }
  }

  Widget _buildAvatarImage(String? imageUrl, {double size = 124}) {
    if (imageUrl != null && imageUrl.trim().isNotEmpty) {
      if (imageUrl.startsWith('data:image')) {
        try {
          final commaIndex = imageUrl.indexOf(',');
          final base64String = commaIndex != -1 ? imageUrl.substring(commaIndex + 1) : imageUrl;
          final bytes = base64Decode(base64String.replaceAll(RegExp(r'\s+'), ''));
          return Image.memory(
            bytes,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildFallbackAvatarIcon(size),
          );
        } catch (_) {
          return _buildFallbackAvatarIcon(size);
        }
      } else if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
        return Image.network(
          imageUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallbackAvatarIcon(size),
        );
      } else if (imageUrl.startsWith('assets/')) {
        return Image.asset(
          imageUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallbackAvatarIcon(size),
        );
      }
    }
    return _buildFallbackAvatarIcon(size);
  }

  Widget _buildFallbackAvatarIcon(double size) {
    return Center(
      child: Icon(
        Icons.person_rounded,
        color: Colors.white,
        size: size * 0.7,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final authUser = ref.watch(authProvider);
    final currentUser = _safeCurrentUser;
    final fallbackAuthPhone = (currentUser?.phone != null && currentUser!.phone!.isNotEmpty)
        ? currentUser.phone!
        : (currentUser?.userMetadata?['phone']?.toString() ?? '');

    final metaFirst = (currentUser?.userMetadata?['first_name'] ?? currentUser?.userMetadata?['fname'])?.toString().trim() ?? '';
    final metaLast = (currentUser?.userMetadata?['last_name'] ?? currentUser?.userMetadata?['lname'])?.toString().trim() ?? '';
    final metaFullName = [metaFirst, metaLast].where((s) => s.isNotEmpty).join(' ');

    final effectivePhone = (_phone != '-')
        ? _phone
        : (authUser?.phone.isNotEmpty == true
            ? _formatPhoneNumber(authUser!.phone)
            : (fallbackAuthPhone.isNotEmpty ? _formatPhoneNumber(fallbackAuthPhone) : '-'));
    final effectiveName = (_name != 'ผู้ใช้งาน' && !_name.contains('@'))
        ? _name
        : (authUser?.name.isNotEmpty == true && authUser!.name != 'ผู้ใช้งาน' && !authUser.name.contains('@')
            ? authUser.name
            : (metaFullName.isNotEmpty ? metaFullName : _name));
    final effectiveEmail = _email.isNotEmpty
        ? _email
        : (authUser?.email.isNotEmpty == true ? authUser!.email : (currentUser?.email ?? ''));

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

                  // User Avatar (Without Camera Badge - No edit on this screen)
                  Center(
                    child: Container(
                      width: 124,
                      height: 124,
                      decoration: const BoxDecoration(
                        color: Color(0xFF6E162B),
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: _buildAvatarImage(_profilePhotoUrl, size: 124),
                      ),
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
                        // Row 1: ชื่อผู้ใช้ (username ในตาราง users)
                        _buildInfoRow('ชื่อผู้ใช้', _username.isNotEmpty ? _username : '-'),
                        _buildDivider(),

                        // Row 2: ชื่อ - นามสกุล
                        _buildInfoRow('ชื่อ - นามสกุล', effectiveName),
                        _buildDivider(),

                        // Row 3: อีเมล
                        _buildInfoRow('อีเมล', effectiveEmail),
                        _buildDivider(),

                        // Row 4: เบอร์โทรศัพท์
                        _buildInfoRow('เบอร์โทรศัพท์', effectivePhone),
                        _buildDivider(),

                        // Row 5: รหัสผ่าน / เข้าสู่ระบบด้วย
                        if (_currentProvider == 'facebook')
                          _buildInfoRow('เข้าสู่ระบบด้วย', '', valueWidget: _buildFacebookBadge())
                        else if (_currentProvider == 'google')
                          _buildInfoRow('เข้าสู่ระบบด้วย', '', valueWidget: _buildGoogleBadge())
                        else
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

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacebookBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF3FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC4DBFC), width: 1.1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: const BoxDecoration(
              color: Color(0xFF1877F2),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const SizedBox(
              width: 9.5,
              height: 9.5,
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
          const SizedBox(width: 5),
          const Text(
            'Facebook',
            style: TextStyle(
              fontSize: 12.5,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1.1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 14,
            height: 14,
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
          const SizedBox(width: 5),
          const Text(
            'Google',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF3C4043),
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Widget? valueWidget}) {
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
            child: valueWidget ??
                Text(
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
