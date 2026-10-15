import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants.dart';
import '../../main.dart';
import '../../widgets/image_crop_screen.dart';
import '../owner/owner_edit_operating_hours_screen.dart';
import '../owner/owner_edit_amenities_screen.dart';
import '../owner/owner_edit_menu_item_screen.dart';
import 'restaurant_pending_review_screen.dart';
import '../../services/admin_restaurant_service.dart';
import '../../providers/auth_provider.dart';

/// Helper สำหรับสุ่มสร้าง UUID v4 ให้ตรงตามมาตรฐาน RFC 4122
String _generateUuidV4() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(256));
  values[6] = (values[6] & 0x0f) | 0x40; // version 4
  values[8] = (values[8] & 0x3f) | 0x80; // variant
  final hex = values.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}';
}

/// Draft model for menu items being added during restaurant registration.
/// Aligned strictly with database tables `menu_items`, `categories`, `menu_item_categories`:
/// - name: text
/// - price: numeric
/// - image_url: text
/// - categories: list of category names
class RestaurantMenuItemDraft {
  String name;
  double price;
  String imageUrl;
  List<String> categories;

  RestaurantMenuItemDraft({
    required this.name,
    required this.price,
    required this.imageUrl,
    this.categories = const ['ข้าว'],
  });
}

/// Helper model for operating hours schedule item
class OperatingScheduleItem {
  final int dayOfWeek; // 1=จันทร์ ... 7=อาทิตย์
  final String dayName;
  String openTime;
  String closeTime;
  bool isClosed;

  OperatingScheduleItem({
    required this.dayOfWeek,
    required this.dayName,
    required this.openTime,
    required this.closeTime,
    this.isClosed = false,
  });

  String get displayTime {
    if (isClosed) return 'ปิดร้าน';
    return '${openTime.replaceAll(':', '.')} - ${closeTime.replaceAll(':', '.')}';
  }
}

class CreateRestaurantScreen extends ConsumerStatefulWidget {
  final String? initialLogoImageUrl;
  final String? initialBannerImageUrl;

  const CreateRestaurantScreen({
    super.key,
    this.initialLogoImageUrl,
    this.initialBannerImageUrl,
  });

  @override
  ConsumerState<CreateRestaurantScreen> createState() =>
      _CreateRestaurantScreenState();
}

class _CreateRestaurantScreenState
    extends ConsumerState<CreateRestaurantScreen> {
  static const Color primaryBurgundy = Color(0xFF6E162B);
  static const Color accentMaroon = Color(0xFF7C1431);

  // 1. Basic Info (Unfilled by default)
  String _name = '';
  int? _selectedCuisineTypeId;
  String? _selectedCuisineTypeName;

  // 2. Photos (Unfilled by default)
  String? _logoImageUrl;
  String? _bannerImageUrl;

  // 3. Contact & Address (Unfilled by default)
  String _address = '';
  String _mapsUrl = '';
  String _phone = '';
  String _email = '';

  // 4. Operating Hours (7 days, starts empty/unfilled by default)
  final List<OperatingScheduleItem> _schedules = [
    OperatingScheduleItem(dayOfWeek: 7, dayName: 'อาทิตย์', openTime: '', closeTime: '', isClosed: true),
    OperatingScheduleItem(dayOfWeek: 1, dayName: 'จันทร์', openTime: '', closeTime: '', isClosed: true),
    OperatingScheduleItem(dayOfWeek: 2, dayName: 'อังคาร', openTime: '', closeTime: '', isClosed: true),
    OperatingScheduleItem(dayOfWeek: 3, dayName: 'พุธ', openTime: '', closeTime: '', isClosed: true),
    OperatingScheduleItem(dayOfWeek: 4, dayName: 'พฤหัสบดี', openTime: '', closeTime: '', isClosed: true),
    OperatingScheduleItem(dayOfWeek: 5, dayName: 'ศุกร์', openTime: '', closeTime: '', isClosed: true),
    OperatingScheduleItem(dayOfWeek: 6, dayName: 'เสาร์', openTime: '', closeTime: '', isClosed: true),
  ];

  // 5. Amenities / Facilities (Unfilled by default)
  final List<String> _selectedFacilities = [];

  // Available facilities options
  static const List<Map<String, dynamic>> _availableAmenities = [
    {'name': 'มีปลั๊กไฟ', 'icon': Icons.power},
    {'name': 'มีอินเทอร์เน็ต', 'icon': Icons.wifi},
    {'name': 'มีห้องน้ำ', 'icon': Icons.favorite_border_rounded},
    {'name': 'เครื่องปรับอากาศ', 'icon': Icons.ac_unit_rounded},
    {'name': 'เหมาะกับกลุ่ม', 'icon': Icons.groups_outlined},
    {'name': 'ที่จอดรถยนต์', 'icon': Icons.directions_car_outlined},
    {'name': 'ที่จอดมอเตอร์ไซค์', 'icon': Icons.two_wheeler_outlined},
    {'name': 'รับบัตรเครดิต', 'icon': Icons.credit_card_outlined},
    {'name': 'รับโอนเงิน/สแกนจ่าย', 'icon': Icons.qr_code_rounded},
    {'name': 'บริการส่งอาหาร', 'icon': Icons.delivery_dining_outlined},
  ];

  // 6. Food Menus (Must be at least 3 items, starts empty)
  final List<RestaurantMenuItemDraft> _menuItems = [];

  bool _isLoading = false;

  // Preset food images for quick and easy selection
  static const List<Map<String, String>> _foodPresets = [
    {
      'name': 'ข้าวกะเพราหมูกรอบไข่ดาว',
      'price': '65',
      'url': 'https://images.unsplash.com/photo-1562967914-608f82629710?w=400&q=80',
      'category': 'ข้าว',
    },
    {
      'name': 'ก๋วยเตี๋ยวต้มยำโบราณ',
      'price': '60',
      'url': 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400&q=80',
      'category': 'เมนูเส้น',
    },
    {
      'name': 'ส้มตำไทยคอหมูย่าง',
      'price': '85',
      'url': 'https://images.unsplash.com/photo-1559847844-5315695dadae?w=400&q=80',
      'category': 'ของทอด',
    },
    {
      'name': 'กาแฟคาปูชิโน่ร้อน',
      'price': '55',
      'url': 'https://images.unsplash.com/photo-1517256064527-09c73fc73e38?w=400&q=80',
      'category': 'เครื่องดื่ม',
    },
    {
      'name': 'แซลมอนซาชิมิรวม',
      'price': '180',
      'url': 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=400&q=80',
      'category': 'ข้าว',
    },
    {
      'name': 'วาฟเฟิลไอศกรีม',
      'price': '99',
      'url': 'https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=400&q=80',
      'category': 'ของหวาน',
    },
  ];

  // Preset logo & banner photos
  static const List<String> _sampleLogos = [
    'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=200&q=80',
    'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=200&q=80',
    'https://images.unsplash.com/photo-1552566626-52f8b828add9?w=200&q=80',
  ];

  static const List<String> _sampleBanners = [
    'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800&q=80',
    'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800&q=80',
    'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800&q=80',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialLogoImageUrl != null) {
      _logoImageUrl = widget.initialLogoImageUrl;
    }
    if (widget.initialBannerImageUrl != null) {
      _bannerImageUrl = widget.initialBannerImageUrl;
    }
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

  // Thai phone number validation (9-10 digits starting with 0)
  bool _isValidThaiPhone(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[-\s]'), '');
    final phoneRegex = RegExp(r'^0[0-9]{8,9}$');
    return phoneRegex.hasMatch(cleanPhone);
  }

  // Email format validation
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email.trim());
  }

  // Icon mapper for facilities
  IconData _getIconForFacility(String facility) {
    for (final item in _availableAmenities) {
      if (item['name'] == facility) {
        return item['icon'] as IconData;
      }
    }
    if (facility.contains('ปลั๊ก')) return Icons.power;
    if (facility.contains('เน็ต') || facility.contains('wifi')) return Icons.wifi;
    if (facility.contains('ห้องน้ำ')) return Icons.favorite_border_rounded;
    if (facility.contains('ปรับอากาศ') || facility.contains('แอร์')) return Icons.ac_unit_rounded;
    if (facility.contains('กลุ่ม')) return Icons.groups_outlined;
    return Icons.check_circle_outline_rounded;
  }

  // ==========================================================================
  // DIALOG: EDIT STORE NAME
  // ==========================================================================
  void _openEditNameDialog() {
    final ctrl = TextEditingController(text: _name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'ระบุชื่อร้านอาหาร',
          style: TextStyle(
            fontSize: 17.5,
            fontWeight: FontWeight.w800,
            color: primaryBurgundy,
          ),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'เช่น Roastniyom Coffee, ครัวริมรั้ว',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: primaryBurgundy, width: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBurgundy,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              final newName = ctrl.text.trim();
              if (newName.isNotEmpty) {
                setState(() {
                  _name = newName;
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // MODAL: PICK CUISINE TYPE
  // ==========================================================================
  void _openCuisineTypePicker() {
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'เลือกประเภทอาหาร',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: primaryBurgundy,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.grey),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: AppConstants.flowCategories.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    indent: 20,
                    endIndent: 20,
                    color: Color(0xFFF5F5F5),
                  ),
                  itemBuilder: (context, index) {
                    final item = AppConstants.flowCategories[index];
                    final int typeId = item['cuisine_type_id'] as int;
                    final String name = item['name'] as String;
                    final String emoji = item['emoji'] as String? ?? '🍽️';
                    final bool isSelected = _selectedCuisineTypeId == typeId;

                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? primaryBurgundy.withOpacity(0.1)
                              : const Color(0xFFF7F7F7),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      title: Text(
                        name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? primaryBurgundy : const Color(0xFF221F21),
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: primaryBurgundy,
                            )
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedCuisineTypeId = typeId;
                          _selectedCuisineTypeName = name;
                        });
                        Navigator.of(ctx).pop();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================================================
  // MODAL: PHOTO PICKER (Logo or Banner)
  // ==========================================================================
  // ==========================================================================
  // MODAL: PHOTO PICKERS (Matching owner_restaurant_info_screen.dart)
  // ==========================================================================

  /// เมนูเลือกรูปภาพโปรไฟล์ร้านอาหาร (เฉพาะกล้อง และ คลังภาพ ไม่มี URL - เหมือน owner_restaurant_info_screen)
  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'รูปภาพโปรไฟล์ร้านอาหาร',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryBurgundy.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: primaryBurgundy),
                ),
                title: const Text('ถ่ายรูปภาพ', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('ถ่ายรูปร้านจากกล้องของคุณ'),
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
                    color: primaryBurgundy.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: primaryBurgundy),
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
              if (_logoImageUrl != null && _logoImageUrl!.isNotEmpty) ...[
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
                  subtitle: const Text('นำรูปภาพโปรไฟล์ร้านนี้ออก'),
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

  /// เมนูตัวเลือกรูปภาพสำหรับหน้าปัดร้านอาหาร (ถ่ายรูป / คลังรูป / ลบรูป - เหมือน owner_restaurant_info_screen)
  void _showSwipeCardPhotoOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'รูปภาพสำหรับหน้าปัดร้านอาหาร',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryBurgundy.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: primaryBurgundy),
                ),
                title: const Text('ถ่ายรูปภาพ', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('ถ่ายรูปอาหารหรือเมนูจากกล้องของคุณ'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final picker = ImagePicker();
                  final picked = await picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 1200,
                    maxHeight: 1200,
                    imageQuality: 85,
                  );
                  if (picked != null) {
                    await _processPickedSwipeCardPhoto(picked);
                  }
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryBurgundy.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: primaryBurgundy),
                ),
                title: const Text('เลือกจากคลังรูปภาพ', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('เลือกรูปภาพจากเครื่องของคุณ'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final picker = ImagePicker();
                  final picked = await picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 1200,
                    maxHeight: 1200,
                    imageQuality: 85,
                  );
                  if (picked != null) {
                    await _processPickedSwipeCardPhoto(picked);
                  }
                },
              ),
              if (_bannerImageUrl != null && _bannerImageUrl!.isNotEmpty) ...[
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
                  subtitle: const Text('นำรูปสำหรับหน้าปัดนี้ออก'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _confirmDeleteSwipeCardPhoto();
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _openPhotoOptions({required bool isLogo}) {
    if (isLogo) {
      _showPhotoOptions();
    } else {
      _showSwipeCardPhotoOptions();
    }
  }

  /// ครอปรูปภาพโปรไฟล์ร้านอาหาร (1:1 สี่เหลี่ยมจัตุรัส)
  Future<void> _processPickedPhoto(XFile picked) async {
    try {
      final rawBytes = await picked.readAsBytes();
      if (!mounted) return;

      final croppedBytes = await Navigator.push<Uint8List>(
        context,
        MaterialPageRoute(
          builder: (_) => ImageCropScreen(imageBytes: rawBytes),
        ),
      );

      if (croppedBytes == null) return;

      // ขณะกรอกยังไม่ต้องบันทึกลง database หรือ storage ให้เก็บภาพใน Local State เพื่อแสดงผลเท่านั้น
      final convertedUrl = 'data:image/png;base64,${base64Encode(croppedBytes)}';

      setState(() {
        _logoImageUrl = convertedUrl;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ครอบตัดและเลือกรูปภาพเรียบร้อยแล้ว'),
            backgroundColor: primaryBurgundy,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error processing picked restaurant photo: $e');
    }
  }

  /// ครอปรูปภาพและแปลงเป็น Data URL สำหรับหน้าปัดร้านอาหาร (ขนาด 0.88w x 0.64h มน 24px)
  Future<void> _processPickedSwipeCardPhoto(XFile picked) async {
    try {
      final rawBytes = await picked.readAsBytes();
      if (!mounted) return;

      final screenSize = MediaQuery.of(context).size;
      final double cardWidth = screenSize.width > 0 ? screenSize.width * 0.88 : (390 * 0.88);
      final double cardHeight = screenSize.height > 0 ? screenSize.height * 0.64 : (844 * 0.64);
      final double swipeCardAspectRatio = cardWidth / cardHeight;

      final croppedBytes = await Navigator.push<Uint8List>(
        context,
        MaterialPageRoute(
          builder: (_) => ImageCropScreen(
            imageBytes: rawBytes,
            targetWidth: cardWidth,
            targetHeight: cardHeight,
            aspectRatio: swipeCardAspectRatio,
            cornerRadius: 24.0,
            subtitleTag: 'ขนาดเท่ากับหน้าปัดร้านอาหาร',
          ),
        ),
      );

      if (croppedBytes == null) return;

      // ขณะกรอกยังไม่ต้องบันทึกลง database หรือ storage ให้เก็บภาพใน Local State เพื่อแสดงผลเท่านั้น
      final convertedUrl = 'data:image/png;base64,${base64Encode(croppedBytes)}';

      setState(() {
        _bannerImageUrl = convertedUrl;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ครอบตัดและเลือกรูปสำหรับหน้าปัดร้านอาหารเรียบร้อยแล้ว'),
            backgroundColor: primaryBurgundy,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error processing picked swipe card photo: $e');
    }
  }

  /// ยืนยันลบรูปโปรไฟล์ร้าน
  Future<void> _confirmDeletePhoto() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('ยืนยันลบรูปภาพ', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('คุณต้องการลบรูปภาพร้านอาหารนี้ใช่หรือไม่?'),
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
        _logoImageUrl = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ลบรูปภาพเรียบร้อยแล้ว'),
          backgroundColor: primaryBurgundy,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  /// ยืนยันลบรูปสำหรับหน้าปัดร้าน
  Future<void> _confirmDeleteSwipeCardPhoto() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('ยืนยันลบรูปภาพ', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('คุณต้องการลบรูปภาพสำหรับหน้าปัดร้านอาหารนี้ใช่หรือไม่?'),
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
        _bannerImageUrl = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ลบรูปภาพเรียบร้อยแล้ว'),
          backgroundColor: primaryBurgundy,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  Widget _buildAvatarImage() {
    if (_logoImageUrl != null && _logoImageUrl!.isNotEmpty) {
      if (_logoImageUrl!.startsWith('data:image')) {
        try {
          final commaIndex = _logoImageUrl!.indexOf(',');
          final base64String = commaIndex != -1
              ? _logoImageUrl!.substring(commaIndex + 1)
              : _logoImageUrl!;
          final bytes = base64Decode(base64String);
          return Image.memory(
            bytes,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildFallbackStoreLogo(),
          );
        } catch (_) {
          return _buildFallbackStoreLogo();
        }
      }
      if (_logoImageUrl!.startsWith('assets/')) {
        return Image.asset(
          _logoImageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallbackStoreLogo(),
        );
      }
      return Image.network(
        _logoImageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallbackStoreLogo(),
      );
    }
    return _buildFallbackStoreLogo();
  }

  Widget _buildFallbackStoreLogo() {
    return Container(
      color: const Color(0xFFF9ECEF),
      child: const Center(
        child: Icon(
          Icons.storefront_rounded,
          color: primaryBurgundy,
          size: 40,
        ),
      ),
    );
  }

  // ==========================================================================
  // SWIPE CARD IMAGE SECTION (รูปสำหรับหน้าปัดร้านอาหาร เหมือน OwnerRestaurantInfoScreen)
  // ==========================================================================
  Widget _buildSwipeCardImageSection() {
    final hasImage = _bannerImageUrl != null && _bannerImageUrl!.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'รูปสำหรับหน้าปัดร้านอาหาร',
          style: TextStyle(
            fontSize: 16.5,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'รูปภาพร้านอาหารหรือเมนูแนะนำ เพื่อแสดงบนหน้าปัดหน้าร้านอาหาร',
          style: TextStyle(
            fontSize: 12.5,
            color: Colors.grey.shade600,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 12),

        // Preview or Upload Area
        GestureDetector(
          onTap: _showSwipeCardPhotoOptions,
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: hasImage ? Colors.grey.shade100 : const Color(0xFFFDF8F9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: hasImage ? const Color(0xFFE5E7EB) : primaryBurgundy.withOpacity(0.35),
                width: 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: hasImage
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        _buildSwipeCardImagePreview(),
                        // Action Button "แก้ไข" at bottom right
                        Positioned(
                          right: 12,
                          bottom: 12,
                          child: InkWell(
                            onTap: _showSwipeCardPhotoOptions,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.55),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.camera_alt, color: Colors.white, size: 13),
                                  SizedBox(width: 4),
                                  Text(
                                    'แก้ไข',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: primaryBurgundy.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.add_photo_alternate_rounded,
                                color: primaryBurgundy,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'เพิ่มรูปสำหรับหน้าปัดร้านอาหาร',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: primaryBurgundy,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'แตะเพื่อถ่ายรูป หรือเลือกจากคลัง (ครอบตัดได้)',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwipeCardImagePreview() {
    if (_bannerImageUrl != null && _bannerImageUrl!.isNotEmpty) {
      if (_bannerImageUrl!.startsWith('data:image')) {
        try {
          final commaIndex = _bannerImageUrl!.indexOf(',');
          final base64String = commaIndex != -1
              ? _bannerImageUrl!.substring(commaIndex + 1)
              : _bannerImageUrl!;
          final bytes = base64Decode(base64String);
          return Image.memory(
            bytes,
            fit: BoxFit.cover,
            width: double.infinity,
            errorBuilder: (_, __, ___) => _buildBannerPlaceholder(),
          );
        } catch (_) {
          return _buildBannerPlaceholder();
        }
      }
      if (_bannerImageUrl!.startsWith('assets/')) {
        return Image.asset(
          _bannerImageUrl!,
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (_, __, ___) => _buildBannerPlaceholder(),
        );
      }
      return Image.network(
        _bannerImageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, __, ___) => _buildBannerPlaceholder(),
      );
    }
    return _buildBannerPlaceholder();
  }

  /// Helper ในการแสดงรูปภาพเมนูอาหาร รองรับทั้ง Base64 Data URL และรูปภาพ Network ทั่วไป (เหมือน OwnerMenuScreen)
  Widget _buildMenuThumbnail(String? url, {double width = 54, double height = 54}) {
    if (url == null || url.trim().isEmpty) {
      return _fallbackNoMenuImage(width, height);
    }
    if (url.startsWith('data:image')) {
      try {
        final base64String = url.split(',').last;
        final bytes = base64Decode(base64String);
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            bytes,
            width: width,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _fallbackNoMenuImage(width, height),
          ),
        );
      } catch (_) {}
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallbackNoMenuImage(width, height),
      ),
    );
  }

  /// แสดงพื้นที่สีเทาพร้อมไอคอนกล้องถ่ายรูปกรณีเมนูไม่มีรูปภาพ (เหมือน OwnerMenuScreen)
  Widget _fallbackNoMenuImage(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 0.5),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              color: const Color(0xFF94A3B8),
              size: width * 0.38,
            ),
            const SizedBox(height: 2),
            const Text(
              'ไม่มีรูป',
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // MODAL BOTTOM SHEET: EDIT ADDRESS & CONTACT (Exact layout of Screenshot 4)
  // ==========================================================================
  void _openEditAddressBottomSheet() {
    final addressCtrl = TextEditingController(text: _address);
    final mapsCtrl = TextEditingController(text: _mapsUrl);
    final phoneCtrl = TextEditingController(text: _phone);
    final emailCtrl = TextEditingController(text: _email);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title from Screenshot 4
              const Text(
                'แก้ไขข้อมูลติดต่อและที่อยู่',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // ที่อยู่ร้านอาหาร (Outlined text area)
              TextField(
                controller: addressCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'ที่อยู่ร้านอาหาร',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryBurgundy, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ลิงก์ Google Maps (Outlined text field)
              TextField(
                controller: mapsCtrl,
                decoration: const InputDecoration(
                  labelText: 'ลิงก์ Google Maps',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryBurgundy, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // เบอร์โทรศัพท์ติดต่อ (Outlined text field)
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'เบอร์โทรศัพท์ติดต่อ',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryBurgundy, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // อีเมลร้านค้า (Outlined text field)
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'อีเมลร้านค้า',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryBurgundy, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Button "บันทึกข้อมูล" (Solid burgundy button from Screenshot 4)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBurgundy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _address = addressCtrl.text.trim();
                      _mapsUrl = mapsCtrl.text.trim();
                      _phone = phoneCtrl.text.trim();
                      _email = emailCtrl.text.trim();
                    });
                    Navigator.pop(ctx);
                  },
                  child: const Text(
                    'บันทึกข้อมูล',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // OPERATING HOURS EDITOR (Exact screen from Screenshot 3: OwnerEditOperatingHoursScreen)
  // ==========================================================================
  Future<void> _openEditOperatingHoursModal() async {
    final initialEntries = <OperatingHourEntry>[];
    for (final schedule in _schedules) {
      if (!schedule.isClosed && schedule.openTime.isNotEmpty && schedule.closeTime.isNotEmpty) {
        initialEntries.add(
          OperatingHourEntry(
            dayOfWeek: schedule.dayOfWeek,
            dayName: schedule.dayName,
            openTime: schedule.openTime,
            closeTime: schedule.closeTime,
          ),
        );
      }
    }

    final updated = await Navigator.push<List<OperatingHourEntry>>(
      context,
      MaterialPageRoute(
        builder: (_) => OwnerEditOperatingHoursScreen(
          restaurantId: null, // Draft registration mode
          initialHours: initialEntries.isNotEmpty ? initialEntries : null,
        ),
      ),
    );

    if (updated != null && mounted) {
      final Map<int, List<OperatingHourEntry>> byDay = {};
      for (final e in updated) {
        byDay.putIfAbsent(e.dayOfWeek, () => []).add(e);
      }

      setState(() {
        for (final s in _schedules) {
          if (byDay.containsKey(s.dayOfWeek) && byDay[s.dayOfWeek]!.isNotEmpty) {
            final dayList = byDay[s.dayOfWeek]!;
            s.isClosed = false;
            s.openTime = dayList.first.openTime;
            s.closeTime = dayList.first.closeTime;
          } else {
            s.isClosed = true;
            s.openTime = '';
            s.closeTime = '';
          }
        }
      });
    }
  }

  // ==========================================================================
  // AMENITIES EDITOR (Exact screen from Owner: OwnerEditAmenitiesScreen)
  // ==========================================================================
  Future<void> _openEditFacilitiesModal() async {
    final updated = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(
        builder: (_) => OwnerEditAmenitiesScreen(
          restaurantId: null,
          initialAmenities: _selectedFacilities.isNotEmpty
              ? _selectedFacilities
              : const [],
        ),
      ),
    );

    if (updated != null && mounted) {
      setState(() {
        _selectedFacilities.clear();
        _selectedFacilities.addAll(updated);
      });
    }
  }

  // ==========================================================================
  // QUICK POPULATE 3 PRESET MENUS (FOR SMOOTH TESTING)
  // ==========================================================================
  void _addSampleMenus() {
    setState(() {
      for (final sample in _foodPresets.take(3)) {
        if (!_menuItems.any((m) => m.name == sample['name'])) {
          _menuItems.add(
            RestaurantMenuItemDraft(
              name: sample['name']!,
              price: double.tryParse(sample['price']!) ?? 60.0,
              imageUrl: sample['url']!,
              categories: [sample['category'] ?? 'ข้าว'],
            ),
          );
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'เพิ่มเมนูอาหารตัวอย่าง 3 รายการแล้ว (${_menuItems.length} รายการ)',
          style: const TextStyle(fontFamily: 'Prompt'),
        ),
        backgroundColor: primaryBurgundy,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ==========================================================================
  // MENU ITEM EDITOR (Exact screen from Owner: OwnerEditMenuItemScreen)
  // ==========================================================================
  Future<void> _openAddMenuItemModal({int? editIndex}) async {
    final Map<String, dynamic>? itemToEdit = editIndex != null
        ? {
            'id': 'draft-$editIndex',
            'name': _menuItems[editIndex].name,
            'price': _menuItems[editIndex].price,
            'image_url': _menuItems[editIndex].imageUrl,
            'category': _menuItems[editIndex].categories.isNotEmpty
                ? _menuItems[editIndex].categories.first
                : 'ข้าว',
            'categories': _menuItems[editIndex].categories,
          }
        : null;

    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => OwnerEditMenuItemScreen(
          restaurantId: null, // Draft registration mode
          itemToEdit: itemToEdit,
          allCategories: const ['ข้าว', 'ของทอด', 'เมนูเส้น', 'เครื่องดื่ม', 'ของหวาน'],
        ),
      ),
    );

    if (result != null && result['saved'] == true && result['item'] != null) {
      final itemMap = result['item'] as Map<String, dynamic>;
      final name = itemMap['name']?.toString() ?? '';
      final price = (itemMap['price'] as num?)?.toDouble() ?? 0.0;
      final img = itemMap['image_url']?.toString() ?? itemMap['image']?.toString() ?? '';
      final categories = (itemMap['categories'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          (itemMap['category'] != null
              ? [itemMap['category'].toString()]
              : ['ข้าว']);

      setState(() {
        final draft = RestaurantMenuItemDraft(
          name: name,
          price: price,
          imageUrl: img.trim(),
          categories: categories,
        );
        if (editIndex != null) {
          _menuItems[editIndex] = draft;
        } else {
          _menuItems.add(draft);
        }
      });
    }
  }

  // ==========================================================================
  // SUBMIT FORM FOR APPROVAL
  // ==========================================================================
  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    // 1. Mandatory Name Validation
    if (_name.trim().isEmpty) {
      _showWarningSnackBar('กรุณาระบุชื่อร้านอาหาร');
      return;
    }

    // 2. Mandatory Cuisine Type
    if (_selectedCuisineTypeId == null) {
      _showWarningSnackBar('กรุณาเลือกประเภทอาหาร');
      return;
    }

    // 3. Mandatory Photos
    if (_logoImageUrl == null || _logoImageUrl!.trim().isEmpty) {
      _showWarningSnackBar('กรุณาเลือกรูปโปรไฟล์ร้านอาหาร');
      return;
    }
    if (_bannerImageUrl == null || _bannerImageUrl!.trim().isEmpty) {
      _showWarningSnackBar('กรุณาเลือกรูปสำหรับหน้าปัดร้านอาหาร');
      return;
    }

    // 4. Mandatory Address & Contact
    if (_address.trim().isEmpty) {
      _showWarningSnackBar('กรุณาระบุที่อยู่ร้านอาหาร');
      return;
    }
    if (_mapsUrl.trim().isEmpty) {
      _showWarningSnackBar('กรุณาระบุลิงก์ Google Maps ของร้านค้า');
      return;
    }
    if (_phone.trim().isEmpty || !_isValidThaiPhone(_phone.trim())) {
      _showWarningSnackBar('กรุณาระบุเบอร์โทรศัพท์ติดต่อให้ถูกต้อง (9-10 หลัก)');
      return;
    }
    if (_email.trim().isEmpty || !_isValidEmail(_email.trim())) {
      _showWarningSnackBar('กรุณาระบุอีเมลร้านค้าให้ถูกต้อง');
      return;
    }

    // 5. Mandatory Operating Hours (At least 1 day open)
    final hasOpenSchedule = _schedules.any((s) => !s.isClosed && s.openTime.isNotEmpty && s.closeTime.isNotEmpty);
    if (!hasOpenSchedule) {
      _showWarningSnackBar('กรุณาระบุเวลาเปิด-ปิดร้านอาหารอย่างน้อย 1 วัน');
      return;
    }

    // 6. Mandatory Facilities (At least 1 amenity)
    if (_selectedFacilities.isEmpty) {
      _showWarningSnackBar('กรุณาเลือกสิ่งอำนวยความสะดวกของร้านค้าอย่างน้อย 1 อย่าง');
      return;
    }

    // 7. Mandatory Menus (At least 3 items)
    if (_menuItems.length < 3) {
      _showWarningSnackBar('กรุณากรอกเมนูอาหารอย่างน้อย 3 อย่าง (ปัจจุบันมี ${_menuItems.length} อย่าง)');
      return;
    }

    setState(() => _isLoading = true);

    try {
      bool isSupabaseReady = false;
      try {
        isSupabaseReady = Supabase.instance.client != null;
      } catch (_) {
        isSupabaseReady = false;
      }

      String? newRestaurantId;

      if (isSupabaseReady) {
        final client = Supabase.instance.client;
        final user = client.auth.currentUser;
        String? ownerId = user?.id;
        if (ownerId == null || ownerId.isEmpty || !ownerId.contains('-')) {
          try {
            final providerUser = ref.read(authProvider);
            if (providerUser != null && providerUser.id.contains('-')) {
              ownerId = providerUser.id;
            }
          } catch (_) {}
        }
        if (ownerId == null || ownerId.isEmpty || !ownerId.contains('-')) {
          try {
            final uRow = await client.from('users').select('id').limit(1).maybeSingle();
            if (uRow != null && uRow['id'] != null) {
              ownerId = uRow['id'].toString();
            }
          } catch (_) {}
        }
        ownerId ??= '00000000-0000-0000-0000-000000000000';

        // 1. ตรวจสอบว่ามีร้านเดิมของ owner หรือ phone นี้ที่อยู่ในสถานะ 'pending' หรือไม่
        String? existingRestaurantId;
        try {
          final res = await client
              .from('restaurants')
              .select('id, status')
              .or('phone.eq.${_phone.trim()},owner_id.eq.$ownerId')
              .maybeSingle();
          if (res != null && res['id'] != null) {
            existingRestaurantId = res['id'].toString();
          }
        } catch (_) {}

        // 2. หากยังไม่มีร้านเดิม ให้สุ่มไอดีร้านอาหารอันใหม่ขึ้นมา (Random UUID v4)
        //    หากมีร้านเดิมที่เคยกรอกค้างไว้ ให้ใช้/อัปเดต ID เดิมเพื่อไม่ให้ชน Unique Constraint (409)
        final restaurantId = existingRestaurantId ?? _generateUuidV4();

        // 3. Insert หรือ Update เข้าตาราง `restaurants` ใน Supabase โดยสถานะเป็น 'pending'
        final insertData = <String, dynamic>{
          'id': restaurantId,
          'owner_id': ownerId,
          'name': _name.trim(),
          'address': _address.trim(),
          'phone': _phone.trim(),
          'google_maps_url': _mapsUrl.trim(),
          'status': 'pending', // สถานะรออนุมัติโดยแอดมิน
          'cuisine_type_id': _selectedCuisineTypeId,
          'crated_at': DateTime.now().toIso8601String(),
        };

        if (existingRestaurantId != null) {
          try {
            await client.from('restaurants').update({
              'name': _name.trim(),
              'address': _address.trim(),
              'phone': _phone.trim(),
              'google_maps_url': _mapsUrl.trim(),
              'status': 'pending',
              'cuisine_type_id': _selectedCuisineTypeId,
            }).eq('id', existingRestaurantId);
            newRestaurantId = existingRestaurantId;
          } catch (e) {
            debugPrint('Note: Supabase restaurants update info: $e');
          }
        } else {
          try {
            await client.from('restaurants').insert(insertData);
            newRestaurantId = restaurantId;
          } catch (e) {
            debugPrint('Note: Supabase restaurants insert info: $e');
            // หากเกิด 409 Conflict เนื่องจากเบอร์โทร ให้ fallback อัปเดตแถวที่มีเบอร์นี้
            try {
              final up = await client
                  .from('restaurants')
                  .update(Map<String, dynamic>.from(insertData)..remove('id'))
                  .eq('phone', _phone.trim())
                  .select('id')
                  .maybeSingle();
              if (up != null && up['id'] != null) {
                newRestaurantId = up['id'].toString();
              }
            } catch (e2) {
              debugPrint('Note: Supabase restaurants fallback insert/update info: $e2');
            }
          }
        }

        final effectiveRestaurantId = newRestaurantId ?? restaurantId;

        // ลบข้อมูลย่อยเดิมของร้านนี้ (หากเป็นการส่งซ้ำ/อัปเดต) เพื่อป้องกันข้อมูลซ้ำซ้อน
        try {
          await client.from('restaurant_images').delete().eq('restaurant_id', effectiveRestaurantId);
        } catch (_) {}
        try {
          await client.from('operating_hours').delete().eq('restaurant_id', effectiveRestaurantId);
        } catch (_) {}
        try {
          final existingMenus = await client.from('menu_items').select('id').eq('restaurant_id', effectiveRestaurantId);
          for (final m in existingMenus) {
            if (m['id'] != null) {
              await client.from('menu_item_categories').delete().eq('menu_item_id', m['id'].toString());
            }
          }
          await client.from('menu_items').delete().eq('restaurant_id', effectiveRestaurantId);
          await client.from('categories').delete().eq('restaurant_id', effectiveRestaurantId);
        } catch (_) {}

        // 3. รูปโปรไฟล์ร้านเข้า restaurant_images สถานะ is_logo = true
        //    รูปสำหรับหน้าปัดร้านอาหารเข้า restaurant_images สถานะ is_logo = false
        try {
          final List<Map<String, dynamic>> imageRows = [];
          if (_logoImageUrl != null && _logoImageUrl!.trim().isNotEmpty) {
            imageRows.add({
              'id': _generateUuidV4(),
              'restaurant_id': effectiveRestaurantId,
              'image_url': _logoImageUrl!.trim(),
              'is_logo': true,
              'sort_order': 0,
            });
          }
          if (_bannerImageUrl != null && _bannerImageUrl!.trim().isNotEmpty) {
            imageRows.add({
              'id': _generateUuidV4(),
              'restaurant_id': effectiveRestaurantId,
              'image_url': _bannerImageUrl!.trim(),
              'is_logo': false,
              'sort_order': 1,
            });
          }
          if (imageRows.isNotEmpty) {
            await client.from('restaurant_images').insert(imageRows);
          }
        } catch (e) {
          debugPrint('Note: Supabase restaurant_images insert note: $e');
        }

        // 4. เวลาเปิดปิดร้านเข้า operating_hours
        try {
          final List<Map<String, dynamic>> hoursRows = [];
          for (final s in _schedules) {
            if (!s.isClosed && s.openTime.isNotEmpty && s.closeTime.isNotEmpty) {
              final openTime = s.openTime.length == 5 ? '${s.openTime}:00' : s.openTime;
              final closeTime = s.closeTime.length == 5 ? '${s.closeTime}:00' : s.closeTime;
              hoursRows.add({
                'restaurant_id': effectiveRestaurantId,
                'day_of_week': s.dayOfWeek,
                'open_time': openTime,
                'close_time': closeTime,
                'is_closed': false,
              });
            }
          }
          if (hoursRows.isNotEmpty) {
            await client.from('operating_hours').insert(hoursRows);
          }
        } catch (e) {
          debugPrint('Note: Supabase operating_hours insert note: $e');
        }

        // 5. เมนูอาหารเข้า menu_items และประเภทอาหารของเมนูอิงตาม menu_item_categories
        try {
          final Map<String, String> categoryNameToId = {};

          for (int i = 0; i < _menuItems.length; i++) {
            final item = _menuItems[i];
            final menuItemId = _generateUuidV4();

            final menuPayload = {
              'id': menuItemId,
              'restaurant_id': effectiveRestaurantId,
              'name': item.name,
              'price': item.price,
              'image_url': item.imageUrl,
              'sort_order': i + 1,
              'created_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            };

            await client.from('menu_items').insert(menuPayload);

            // บันทึกประเภทอาหารของเมนูลงตาราง categories และ menu_item_categories
            final itemCats = item.categories.isNotEmpty ? item.categories : ['ข้าว'];
            for (final catName in itemCats) {
              String? catId = categoryNameToId[catName];
              if (catId == null) {
                catId = _generateUuidV4();
                try {
                  await client.from('categories').insert({
                    'id': catId,
                    'restaurant_id': effectiveRestaurantId,
                    'name': catName,
                    'sort_order': categoryNameToId.length + 1,
                  });
                  categoryNameToId[catName] = catId;
                } catch (_) {}
              }

              if (catId != null) {
                try {
                  await client.from('menu_item_categories').insert({
                    'menu_item_id': menuItemId,
                    'category_id': catId,
                  });
                } catch (_) {}
              }
            }
          }
        } catch (e) {
          debugPrint('Note: Supabase menu_items and categories insert note: $e');
        }

        // 6. เปลี่ยนสถานะ user_type เป็น 'owner' ทันทีตามที่ระบุ
        try {
          try {
            await client.from('users').update({
              'user_type': 'owner',
              'role': 'owner',
            }).eq('id', ownerId);
          } catch (_) {}

          try {
            await client.auth.updateUser(
              UserAttributes(data: {
                'user_type': 'owner',
                'role': 'owner',
              }),
            );
          } catch (_) {}

          // อัปเดต Riverpod auth state ภายในแอปให้เป็น owner ทันที
          try {
            final authNotifier = ref.read(authProvider.notifier);
            final currentUser = ref.read(authProvider);
            if (currentUser != null) {
              authNotifier.setUserFromMap({
                ...currentUser.toJson(),
                'user_type': 'owner',
                'role': 'owner',
              });
            }
          } catch (_) {}
        } catch (e) {
          debugPrint('Note: Update user to owner error: $e');
        }

        // 7. สั่งรีเฟรชข้อมูลฝั่งแอดมินให้เห็นร้านที่เพิ่งสมัครสถานะ pending ทันที
        try {
          ref.read(adminRestaurantProvider.notifier).refresh();
        } catch (_) {}
      }

      // 5. Navigate to the red pending review screen: "รอการตรวจสอบร้านประมาณ 2-3 วัน"
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => RestaurantPendingReviewScreen(
              restaurantName: _name,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showWarningSnackBar('เกิดข้อผิดพลาดในการลงทะเบียน: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showWarningSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontFamily: 'Prompt', fontSize: 13.5),
              ),
            ),
          ],
        ),
        backgroundColor: primaryBurgundy,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ==========================================================================
  // BUILD METHOD
  // ==========================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryBurgundy,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'ข้อมูลร้าน',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: primaryBurgundy),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 18),

                  // ==========================================================
                  // 1. TOP PROFILE ROW (Matching OwnerRestaurantInfoScreen)
                  // ==========================================================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Avatar Circle with Camera "📷 แก้ไข" overlay badge
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            GestureDetector(
                              onTap: _showPhotoOptions,
                              child: Container(
                                width: 76,
                                height: 76,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFFF2E6E8), width: 1.5),
                                  color: const Color(0xFFFBF6F7),
                                ),
                                child: ClipOval(
                                  child: _buildAvatarImage(),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: -4,
                              child: InkWell(
                                onTap: _showPhotoOptions,
                                borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.55),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.camera_alt, color: Colors.white, size: 10),
                                    SizedBox(width: 3),
                                    Text(
                                      'แก้ไข',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),

                      // Store Name & Cuisine Category
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: _openEditNameDialog,
                                    child: Text(
                                      _name.isNotEmpty ? _name : 'ระบุชื่อร้านอาหาร',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: _name.isNotEmpty ? Colors.black87 : Colors.grey.shade400,
                                        letterSpacing: -0.2,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_note_rounded,
                                    color: Color(0xFF6B7280),
                                    size: 22,
                                  ),
                                  onPressed: _openEditNameDialog,
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: _openCuisineTypePicker,
                              child: Text(
                                'ประเภทอาหาร : ${_selectedCuisineTypeName ?? 'แตะเพื่อเลือกประเภท'}',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  color: _selectedCuisineTypeName != null
                                      ? const Color(0xFF4B5563)
                                      : primaryBurgundy,
                                  fontWeight: _selectedCuisineTypeName != null
                                      ? FontWeight.w500
                                      : FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                  const SizedBox(height: 22),
                  const Divider(height: 1, color: Color(0xFFF3F4F6), thickness: 1),
                  const SizedBox(height: 16),

                  // ==========================================================
                  // 2. SWIPE CARD BANNER IMAGE (Matching OwnerRestaurantInfoScreen)
                  // ==========================================================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: _buildSwipeCardImageSection(),
                  ),

                  const SizedBox(height: 22),
                  const Divider(height: 1, color: Color(0xFFF3F4F6), thickness: 1),
                  const SizedBox(height: 16),

                  // ==========================================================
                  // 3. ADDRESS SECTION (Matching Screenshot 1 & 4)
                  // ==========================================================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Text(
                                'ที่อยู่',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: _openEditAddressBottomSheet,
                              child: const Text(
                                'แก้ไข',
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: primaryBurgundy,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Address + Map URL row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: primaryBurgundy,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _address.isNotEmpty
                                        ? _address
                                        : 'ยังไม่ได้ระบุที่อยู่ร้านอาหาร - แตะ "แก้ไข" เพื่อระบุ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: _address.isNotEmpty ? Colors.black87 : Colors.grey,
                                      height: 1.35,
                                    ),
                                  ),
                                  if (_mapsUrl.isNotEmpty) ...[
                                    const SizedBox(height: 3),
                                    Text(
                                      _mapsUrl,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF2563EB),
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Phone number row
                        Row(
                          children: [
                            const Icon(
                              Icons.phone_outlined,
                              color: primaryBurgundy,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _phone.isNotEmpty
                                    ? _phone
                                    : 'ยังไม่ได้ระบุเบอร์โทรศัพท์ติดต่อ',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _phone.isNotEmpty ? Colors.black87 : Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Email row
                        Row(
                          children: [
                            const Icon(
                              Icons.email_outlined,
                              color: primaryBurgundy,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _email.isNotEmpty
                                    ? _email
                                    : 'ยังไม่ได้ระบุอีเมลร้านค้า',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _email.isNotEmpty ? Colors.black87 : Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),
                  const Divider(height: 1, color: Color(0xFFF3F4F6), thickness: 1),
                  const SizedBox(height: 16),

                  // ==========================================================
                  // 4. OPERATING HOURS SECTION (Matching Screenshot 1 & 3)
                  // ==========================================================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Text(
                                'เวลาเปิด - ปิดร้าน',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: _openEditOperatingHoursModal,
                              child: const Text(
                                'แก้ไข',
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: primaryBurgundy,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // 7 Days List matching Screenshot 1
                        ..._schedules.map((schedule) {
                          final hasTime = !schedule.isClosed && schedule.openTime.isNotEmpty;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  schedule.dayName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF374151),
                                  ),
                                ),
                                Text(
                                  hasTime ? schedule.displayTime : 'ปิดร้าน',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: hasTime ? FontWeight.w600 : FontWeight.w400,
                                    color: hasTime ? Colors.black87 : Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),
                  const Divider(height: 1, color: Color(0xFFF3F4F6), thickness: 1),
                  const SizedBox(height: 16),

                  // ==========================================================
                  // 5. FACILITIES SECTION (Matching Screenshot 2)
                  // ==========================================================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Text(
                                'สิ่งอำนวยความสะดวก',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: _openEditFacilitiesModal,
                              child: const Text(
                                'แก้ไข',
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: primaryBurgundy,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        if (_selectedFacilities.isEmpty)
                          GestureDetector(
                            onTap: _openEditFacilitiesModal,
                            child: const Text(
                              'ยังไม่ได้เลือกสิ่งอำนวยความสะดวก - แตะ "แก้ไข" เพื่อเลือก',
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          )
                        else
                          ..._selectedFacilities.map((facility) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    _getIconForFacility(facility),
                                    color: primaryBurgundy,
                                    size: 19,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    facility,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF374151),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),
                  const Divider(height: 1, color: Color(0xFFF3F4F6), thickness: 1),
                  const SizedBox(height: 16),

                  // ==========================================================
                  // 6. FOOD MENUS SECTION (At least 3 items required)
                  // ==========================================================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'เมนูอาหาร (${_menuItems.length}/3 อย่าง) *',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_menuItems.length < 3)
                                  GestureDetector(
                                    onTap: _addSampleMenus,
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                      child: Text(
                                        'ใส่ 3 ตัวอย่าง',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF059669),
                                        ),
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () => _openAddMenuItemModal(),
                                  child: const Text(
                                    '+ เพิ่มเมนู',
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: primaryBurgundy,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'กรอกเมนูอาหารอย่างน้อย 3 อย่าง เพื่อใช้ในการพิจารณาอนุมัติเปิดร้าน',
                          style: TextStyle(fontSize: 12.5, color: Color(0xFF6B7280)),
                        ),
                        const SizedBox(height: 12),

                        if (_menuItems.isEmpty)
                          GestureDetector(
                            onTap: () => _openAddMenuItemModal(),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFDF6F7),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: primaryBurgundy.withOpacity(0.3),
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.restaurant_menu_rounded, color: primaryBurgundy.withOpacity(0.7), size: 36),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'ยังไม่มีเมนูอาหาร',
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.bold,
                                      color: primaryBurgundy,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'แตะที่นี่ หรือกด "+ เพิ่มเมนู" ด้านบน เพื่อใส่รายการอาหาร',
                                    style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _menuItems.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, idx) {
                              final item = _menuItems[idx];
                              return Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE5E7EB)),
                                ),
                                child: Row(
                                  children: [
                                    _buildMenuThumbnail(item.imageUrl, width: 54, height: 54),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.name,
                                            style: const TextStyle(
                                              fontSize: 14.5,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '฿${item.price.toStringAsFixed(0)} บาท',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: primaryBurgundy,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.grey),
                                      onPressed: () => _openAddMenuItemModal(editIndex: idx),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                                      onPressed: () {
                                        setState(() {
                                          _menuItems.removeAt(idx);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  // ==========================================================
                  // 7. SUBMIT BUTTON: "ส่งข้อมูลเพื่ออนุมัติ" (Exact text)
                  // ==========================================================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBurgundy,
                          foregroundColor: Colors.white,
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _isLoading ? null : _submit,
                        child: const Text(
                          'ส่งข้อมูลเพื่ออนุมัติ',
                          style: TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),
                ],
              ),
            ),
    );
  }

  Widget _buildBannerPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate_rounded, size: 44, color: primaryBurgundy.withOpacity(0.5)),
          const SizedBox(height: 8),
          const Text(
            'แตะเพื่อเลือกรูปสำหรับหน้าปัดร้านอาหาร',
            style: TextStyle(fontSize: 13.5, color: Color(0xFF6B7280), fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
