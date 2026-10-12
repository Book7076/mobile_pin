import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/image_crop_screen.dart';
import 'edit_profile_success_screen.dart';
import 'forgot_password_screen.dart';

class EditUserProfileScreen extends ConsumerStatefulWidget {
  final String initialUsername;
  final String initialName;
  final String initialEmail;
  final String initialPhone;
  final String? initialImageUrl;

  const EditUserProfileScreen({
    super.key,
    this.initialUsername = '',
    this.initialName = 'Emma',
    this.initialEmail = 'Emma.carter@gmail.com',
    this.initialPhone = '099-888-7777',
    this.initialImageUrl,
  });

  @override
  ConsumerState<EditUserProfileScreen> createState() => _EditUserProfileScreenState();
}

class _EditUserProfileScreenState extends ConsumerState<EditUserProfileScreen> {
  late final TextEditingController _usernameController;
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;
  String? _currentPhotoUrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.initialUsername);
    _nameController = TextEditingController(text: widget.initialName);
    _emailController = TextEditingController(text: widget.initialEmail);
    _phoneController = TextEditingController(
      text: widget.initialPhone == '-' ? '' : widget.initialPhone,
    );
    _passwordController = TextEditingController(text: '********');
    _currentPhotoUrl = widget.initialImageUrl;

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

  User? get _safeCurrentUser {
    try {
      return supabase.auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// แสดงตัวเลือกจัดการรูปโปรไฟล์ (ถ่ายรูป, เลือกจากคลัง, ลบรูป)
  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'รูปภาพโปรไฟล์',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6E162B),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6E162B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF6E162B)),
                ),
                title: const Text('ถ่ายรูปภาพ', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('ถ่ายรูปภาพใหม่ด้วยกล้องของคุณ'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final picker = ImagePicker();
                  final picked = await picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 1000,
                    maxHeight: 1000,
                    imageQuality: 85,
                  );
                  if (picked != null) {
                    await _processPickedPhoto(picked);
                  }
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6E162B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: Color(0xFF6E162B)),
                ),
                title: const Text('เลือกจากคลังรูปภาพ', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('เลือกรูปภาพจากเครื่องของคุณ'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final picker = ImagePicker();
                  final picked = await picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 1000,
                    maxHeight: 1000,
                    imageQuality: 85,
                  );
                  if (picked != null) {
                    await _processPickedPhoto(picked);
                  }
                },
              ),
              if (_currentPhotoUrl != null && _currentPhotoUrl!.trim().isNotEmpty) ...[
                const Divider(),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                  ),
                  title: const Text(
                    'ลบรูปภาพ',
                    style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red),
                  ),
                  subtitle: const Text('นำรูปภาพโปรไฟล์ออก'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _confirmDeletePhoto();
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// เปิดหน้าจอครอบตัดรูปภาพ 1:1 และแปลงเป็น URL
  Future<void> _processPickedPhoto(XFile picked) async {
    try {
      final rawBytes = await picked.readAsBytes();
      if (!mounted) return;

      final croppedBytes = await Navigator.push<Uint8List>(
        context,
        MaterialPageRoute(
          builder: (_) => ImageCropScreen(
            imageBytes: rawBytes,
            aspectRatio: 1.0,
            cornerRadius: 8.0,
            title: 'ครอบตัดรูปโปรไฟล์',
            subtitleTag: 'สัดส่วนรูปโปรไฟล์ 1:1',
          ),
        ),
      );

      if (croppedBytes == null) return;

      // 1. แปลงรูปที่ครอบตัดเป็น Data URL เบื้องต้น
      String convertedUrl = 'data:image/png;base64,${base64Encode(croppedBytes)}';

      // 2. พยายามอัปโหลดไฟล์รูปภาพไปยัง Supabase Storage Bucket เพื่อแปลงเป็น Public URL
      final userId = _safeCurrentUser?.id ?? ref.read(authProvider)?.id ?? 'user';
      final fileName = 'user_avatar_${userId}_${DateTime.now().millisecondsSinceEpoch}.png';

      for (final bucket in ['restaurant-images', 'avatars', 'user-avatars', 'profiles', 'menu-images']) {
        try {
          await supabase.storage.from(bucket).uploadBinary(
            fileName,
            croppedBytes,
            fileOptions: const FileOptions(contentType: 'image/png', upsert: true),
          );
          final pubUrl = supabase.storage.from(bucket).getPublicUrl(fileName);
          if (pubUrl.isNotEmpty) {
            convertedUrl = pubUrl;
            break;
          }
        } catch (_) {}
      }

      setState(() {
        _currentPhotoUrl = convertedUrl;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ครอบตัดและแปลงรูปภาพเป็น URL เรียบร้อยแล้ว'),
            backgroundColor: Color(0xFF6E162B),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error processing user profile photo: $e');
    }
  }

  /// ป็อปอัพยืนยันการลบรูปภาพ
  Future<void> _confirmDeletePhoto() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('ยืนยันลบรูปภาพ', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('คุณต้องการลบรูปภาพโปรไฟล์นี้ใช่หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('ลบรูปภาพ'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() {
        _currentPhotoUrl = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ลบรูปภาพเรียบร้อยแล้ว'),
          backgroundColor: Color(0xFF6E162B),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  Widget _buildAvatarWidget(String? imageUrl, {double size = 124}) {
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
            errorBuilder: (_, __, ___) => _buildFallbackIcon(size),
          );
        } catch (_) {
          return _buildFallbackIcon(size);
        }
      } else if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
        return Image.network(
          imageUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallbackIcon(size),
        );
      } else if (imageUrl.startsWith('assets/')) {
        return Image.asset(
          imageUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallbackIcon(size),
        );
      }
    }
    return _buildFallbackIcon(size);
  }

  Widget _buildFallbackIcon(double size) {
    return Center(
      child: Icon(
        Icons.person_rounded,
        color: Colors.white,
        size: size * 0.7,
      ),
    );
  }

  /// บันทึกข้อมูลโปรไฟล์ลงฐานข้อมูลตาราง users
  Future<void> _saveProfile() async {
    final username = _usernameController.text.trim();
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

    setState(() => _isSaving = true);

    try {
      final currentUser = _safeCurrentUser;
      final userId = currentUser?.id ?? ref.read(authProvider)?.id;
      final cleanPhone = phone.replaceAll(RegExp(r'[-\s]'), '');
      final nameParts = name.split(RegExp(r'\s+'));
      final firstName = nameParts.isNotEmpty ? nameParts.first : '';
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      final updatePayload = <String, dynamic>{
        'username': username,
        'first_name': firstName,
        'last_name': lastName,
        'phone': cleanPhone,
        'image_url': _currentPhotoUrl,
      };

      // 1. อัปเดตตาราง users ใน Supabase ฟิลด์ image_url
      if (userId != null && userId.isNotEmpty) {
        final updateRes = await supabase.from('users').update(updatePayload).eq('id', userId).select();
        if (updateRes.isEmpty) {
          await supabase.from('users').upsert({
            'id': userId,
            'email': currentUser?.email ?? email,
            ...updatePayload,
          });
        }
      } else if (currentUser?.email != null && currentUser!.email!.isNotEmpty) {
        final updateRes = await supabase.from('users').update(updatePayload).eq('email', currentUser!.email!).select();
        if (updateRes.isEmpty) {
          await supabase.from('users').upsert({
            'email': currentUser!.email!,
            ...updatePayload,
          });
        }
      } else if (email.isNotEmpty) {
        await supabase.from('users').update(updatePayload).eq('email', email);
      }

      // 2. อัปเดตข้อมูล Supabase Auth User Metadata
      if (currentUser != null) {
        await supabase.auth.updateUser(
          UserAttributes(
            data: {
              'username': username,
              'first_name': firstName,
              'last_name': lastName,
              'name': name,
              'phone': cleanPhone,
              'image_url': _currentPhotoUrl,
              'avatar_url': _currentPhotoUrl,
            },
          ),
        );
      }

      // 3. อัปเดต AuthProvider State
      ref.read(authProvider.notifier).updateProfile(
        name: name,
        phone: cleanPhone,
        dietaryPreferences: ref.read(authProvider)?.dietaryPreferences ?? [],
        username: username,
        avatarUrl: _currentPhotoUrl,
        clearAvatar: _currentPhotoUrl == null,
      );
    } catch (e) {
      debugPrint('Error saving user profile: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }

    if (!mounted) return;

    // นำทางไปยังหน้าสำเร็จพร้อมส่งข้อมูลที่อัปเดตกลับไป
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => EditProfileSuccessScreen(
          updatedData: {
            'username': username,
            'name': name,
            'email': email.isNotEmpty ? email : widget.initialEmail,
            'phone': phone.isNotEmpty ? phone : (widget.initialPhone == '-' ? '' : widget.initialPhone),
            'image_url': _currentPhotoUrl ?? '',
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
          // 1. TOP SOLID BURGUNDY HEADER (มีปุ่มบันทึกด้านขวาบน)
          // ==========================================
          Container(
            color: const Color(0xFF6E162B),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              left: 10,
              right: 14,
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
                  onPressed: () => Navigator.of(context).pop(), // กดย้อนกลับโดยไม่บันทึก ข้อมูลไม่เปลี่ยนแปลง
                ),
                const Expanded(
                  child: Center(
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
                // ปุ่ม "บันทึก" ด้านขวาบน
                TextButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'บันทึก',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // รูปที่ 3 ด้านบน: รูปโปรไฟล์พร้อมไอคอนกล้องสำหรับกดแก้ไขรูป
                  Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        GestureDetector(
                          onTap: _showPhotoOptions,
                          child: Container(
                            width: 124,
                            height: 124,
                            decoration: const BoxDecoration(
                              color: Color(0xFF6E162B),
                              shape: BoxShape.circle,
                            ),
                            child: _currentPhotoUrl != null && _currentPhotoUrl!.trim().isNotEmpty
                                ? ClipOval(
                                    child: _buildAvatarWidget(_currentPhotoUrl!, size: 124),
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
                        // ไอคอนกล้องถ่ายรูปที่มุมขวาล่างของวงกลม
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _showPhotoOptions,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF6E162B),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.12),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.camera_alt_outlined,
                                  color: Color(0xFF6E162B),
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

                  // Field 1: ชื่อผู้ใช้ (username ในตาราง users)
                  _buildFieldLabel('ชื่อผู้ใช้'),
                  const SizedBox(height: 7),
                  _buildInputField(
                    controller: _usernameController,
                    keyboardType: TextInputType.text,
                  ),

                  const SizedBox(height: 18),

                  // Field 2: ชื่อ - นามสกุล
                  _buildFieldLabel('ชื่อ - นามสกุล'),
                  const SizedBox(height: 7),
                  _buildInputField(
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                  ),

                  const SizedBox(height: 18),

                  // Field 3: อีเมล
                  _buildFieldLabel('อีเมล'),
                  const SizedBox(height: 7),
                  _buildInputField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 18),

                  // Field 4: เบอร์โทรศัพท์
                  _buildFieldLabel('เบอร์โทรศัพท์'),
                  const SizedBox(height: 7),
                  _buildInputField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 18),

                  // Field 5: รหัสผ่าน
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

                  const SizedBox(height: 40),
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
