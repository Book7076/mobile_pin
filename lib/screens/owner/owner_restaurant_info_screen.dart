import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/operating_hours_model.dart';
import '../../widgets/image_crop_screen.dart';
import 'owner_edit_amenities_screen.dart';
import 'owner_edit_operating_hours_screen.dart';

const Color kOwnerPrimaryColor = Color(0xFF7C1431);
const Color kOwnerTealColor = Color(0xFF00BFA5);
const Color kOwnerMaroonColor = Color(0xFF9E3A52);
const Color kOwnerGreyBorder = Color(0xFF6B7280);
const Color kOwnerGreyBadge = Color(0xFF9CA3AF);
const Color kOwnerGreyLine = Color(0xFFD1D5DB);
const Color kOwnerRedColor = Color(0xFFE11D48);

enum _StepState { completed, active, inactive, rejected }

/// โมเดลช่วยจัดเก็บเวลาเปิด-ปิดแต่ละวันสำหรับหน้าจอแสดงผล
class DayScheduleItem {
  final int dayOfWeek; // 1=จันทร์ ... 7=อาทิตย์
  final String dayName;
  String openTime;
  String closeTime;
  bool isClosed;
  List<String> timeRanges;

  DayScheduleItem({
    required this.dayOfWeek,
    required this.dayName,
    required this.openTime,
    required this.closeTime,
    required this.isClosed,
    this.timeRanges = const [],
  });

  String get displayTime {
    if (isClosed) return 'หยุดทำการ';
    if (timeRanges.isNotEmpty) {
      return timeRanges.map((r) {
        final parts = r.split('-');
        if (parts.length == 2) {
          String clean(String t) {
            final sub = t.trim().split(':');
            if (sub.length >= 2) return '${sub[0].padLeft(2, '0')}.${sub[1].padLeft(2, '0')}';
            return t.trim().replaceAll(':', '.');
          }
          return '${clean(parts[0])} - ${clean(parts[1])}';
        }
        return r.replaceAll(':', '.');
      }).join(', ');
    }
    String clean(String t) {
      final parts = t.split(':');
      if (parts.length >= 2) return '${parts[0].padLeft(2, '0')}.${parts[1].padLeft(2, '0')}';
      return t.replaceAll(':', '.');
    }
    return '${clean(openTime)} - ${clean(closeTime)}';
  }
}

class OwnerRestaurantInfoScreen extends StatefulWidget {
  final String? restaurantId;
  final String restaurantName;
  final String? restaurantCategory;
  final String? restaurantImageUrl;
  final String? swipeCardImageUrl;
  final String? initialStatus;

  const OwnerRestaurantInfoScreen({
    super.key,
    this.restaurantId,
    this.restaurantName = 'THE CHICKEN',
    this.restaurantCategory,
    this.restaurantImageUrl,
    this.swipeCardImageUrl,
    this.initialStatus,
  });

  @override
  State<OwnerRestaurantInfoScreen> createState() => _OwnerRestaurantInfoScreenState();
}

class _OwnerRestaurantInfoScreenState extends State<OwnerRestaurantInfoScreen> {
  late String _name;
  late String _category;
  late String _storeCode;
  late String _address;
  late String _mapsUrl;
  late String _phone;
  late String _email;
  String? _currentImageUrl;
  String? _swipeCardImageUrl;
  late String _status;
  String? _rejectionReason;
  bool _isLoading = false;
  bool _isSaving = false;

  // รายการวันทั้ง 7 วัน เรียงตาม mockup: อาทิตย์, จันทร์, อังคาร, พุธ, พฤหัสบดี, ศุกร์, เสาร์
  late List<DayScheduleItem> _schedules;

  // สิ่งอำนวยความสะดวก
  List<String> _amenities = [
    'มีปลั๊กไฟ',
    'มีอินเทอร์เน็ต',
    'มีห้องน้ำ',
    'เครื่องปรับอากาศ',
    'เหมาะกับกลุ่ม',
  ];

  @override
  void initState() {
    super.initState();
    _name = widget.restaurantName;
    _category = widget.restaurantCategory ?? 'อาหารตามสั่ง';
    _storeCode = _generateStoreCode(widget.restaurantId);
    _address = '31/D ตำบลสุเทพ ซอยวัดอุโมงค์ หลังมอ';
    _mapsUrl = 'www.googlemap.com';
    _phone = '0991234567';
    _email = 'ITLOVER@GMAIL.COM';
    _currentImageUrl = widget.restaurantImageUrl;
    _swipeCardImageUrl = widget.swipeCardImageUrl ?? widget.restaurantImageUrl;
    _status = widget.initialStatus ?? 'pending';

    // เริ่มต้นเวลาเปิดปิดตาม Mockup
    _initDefaultSchedules();

    _loadRestaurantDetails();
  }

  String _generateStoreCode(String? id) {
    if (id == null || id.isEmpty) return 'FD3429';
    final clean = id.replaceAll('-', '');
    final suffix = clean.length >= 4 ? clean.substring(0, 4).toUpperCase() : '3429';
    return 'FD$suffix';
  }

  void _initDefaultSchedules() {
    _schedules = [
      DayScheduleItem(dayOfWeek: 7, dayName: 'อาทิตย์', openTime: '09:00', closeTime: '23:00', isClosed: false),
      DayScheduleItem(dayOfWeek: 1, dayName: 'จันทร์', openTime: '10:00', closeTime: '22:00', isClosed: true),
      DayScheduleItem(dayOfWeek: 2, dayName: 'อังคาร', openTime: '10:00', closeTime: '22:00', isClosed: false),
      DayScheduleItem(dayOfWeek: 3, dayName: 'พุธ', openTime: '10:00', closeTime: '22:00', isClosed: false),
      DayScheduleItem(dayOfWeek: 4, dayName: 'พฤหัสบดี', openTime: '10:00', closeTime: '22:00', isClosed: false),
      DayScheduleItem(dayOfWeek: 5, dayName: 'ศุกร์', openTime: '10:00', closeTime: '22:00', isClosed: false),
      DayScheduleItem(dayOfWeek: 6, dayName: 'เสาร์', openTime: '09:00', closeTime: '23:00', isClosed: false),
    ];
  }

  /// ดึงข้อมูลร้านค้าจริงจาก Supabase
  Future<void> _loadRestaurantDetails() async {
    if (widget.restaurantId == null) return;

    try {
      // 1. ดึงข้อมูลจากตาราง restaurants พร้อม join cuisine_types
      final res = await Supabase.instance.client
          .from('restaurants')
          .select('*, cuisine_types(id, name)')
          .eq('id', widget.restaurantId!)
          .maybeSingle();

      if (res != null && mounted) {
        setState(() {
          _name = res['name']?.toString() ?? _name;
          if (res['address'] != null && res['address'].toString().isNotEmpty) {
            _address = res['address'].toString();
          }
          if (res['phone'] != null && res['phone'].toString().isNotEmpty) {
            _phone = res['phone'].toString();
          }
          if (res['google_maps_url'] != null && res['google_maps_url'].toString().isNotEmpty) {
            _mapsUrl = res['google_maps_url'].toString();
          }
          if (res['status'] != null) {
            _status = res['status'].toString();
          }
          if (res['rejection_reason'] != null) {
            _rejectionReason = res['rejection_reason'].toString();
          }
          if (res['image_url'] != null && res['image_url'].toString().isNotEmpty) {
            _currentImageUrl = res['image_url'].toString();
          }
          if (res['cuisine_types'] != null && res['cuisine_types']['name'] != null) {
            _category = res['cuisine_types']['name'].toString();
          }
        });

        // ดึง email ของ owner ถ้ามี
        try {
          final currentUser = Supabase.instance.client.auth.currentUser;
          if (currentUser != null && currentUser.email != null && currentUser.email!.isNotEmpty) {
            setState(() {
              _email = currentUser.email!.toUpperCase();
            });
          }
        } catch (_) {}

        // 2. ถ้ายังไม่ได้ category ให้ดึงตรงจากตาราง cuisine_types ตาม cuisine_type_id
        final cuisineTypeId = res['cuisine_type_id'];
        if ((res['cuisine_types'] == null || res['cuisine_types']['name'] == null) && cuisineTypeId != null) {
          try {
            final cTypeId = (cuisineTypeId as num).toInt();
            final cType = await Supabase.instance.client
                .from('cuisine_types')
                .select('name')
                .eq('id', cTypeId)
                .maybeSingle();
            if (cType != null && cType['name'] != null && mounted) {
              setState(() {
                _category = cType['name'].toString();
              });
            }
          } catch (_) {}
        }
      }

      // 3. ดึงเวลาเปิด-ปิดจากตาราง operating_hours
      try {
        final hoursRows = await Supabase.instance.client
            .from('operating_hours')
            .select()
            .eq('restaurant_id', widget.restaurantId!)
            .order('day_of_week', ascending: true)
            .order('open_time', ascending: true);

        if (hoursRows is List && hoursRows.isNotEmpty && mounted) {
          final Map<int, List<Map<String, dynamic>>> dbMap = {};
          for (final row in hoursRows) {
            final rawDay = (row['day_of_week'] as num?)?.toInt();
            if (rawDay != null) {
              final d = rawDay == 0 ? 7 : rawDay;
              dbMap.putIfAbsent(d, () => []).add(Map<String, dynamic>.from(row as Map));
            }
          }

          setState(() {
            for (final item in _schedules) {
              if (dbMap.containsKey(item.dayOfWeek)) {
                final list = dbMap[item.dayOfWeek]!;
                final openList = list.where((x) => x['is_closed'] != true).toList();
                if (openList.isNotEmpty) {
                  item.isClosed = false;
                  item.openTime = openList.first['open_time']?.toString() ?? item.openTime;
                  item.closeTime = openList.first['close_time']?.toString() ?? item.closeTime;
                  item.timeRanges = openList.map((x) {
                    final o = x['open_time']?.toString() ?? '';
                    final c = x['close_time']?.toString() ?? '';
                    return '$o - $c';
                  }).toList();
                } else {
                  item.isClosed = true;
                  item.timeRanges = [];
                }
              } else {
                item.isClosed = true;
                item.timeRanges = [];
              }
            }
          });
        }
      } catch (_) {}

      // 4. ดึงรูปภาพโปรไฟล์จากตาราง restaurant_images (is_logo = true)
      try {
        final imgRows = await Supabase.instance.client
            .from('restaurant_images')
            .select('image_url, is_logo, sort_order')
            .eq('restaurant_id', widget.restaurantId!)
            .eq('is_logo', true)
            .maybeSingle();

        if (imgRows != null && imgRows['image_url'] != null && mounted) {
          setState(() {
            _currentImageUrl = imgRows['image_url'].toString();
          });
        }
      } catch (_) {}

      // 5. ดึงรูปภาพสำหรับหน้าปัดร้านอาหารจากตาราง restaurant_images (is_logo = false)
      try {
        final cardImgRows = await Supabase.instance.client
            .from('restaurant_images')
            .select('id, image_url, is_logo, sort_order')
            .eq('restaurant_id', widget.restaurantId!)
            .eq('is_logo', false)
            .order('sort_order', ascending: true);

        if (cardImgRows is List && cardImgRows.isNotEmpty && mounted) {
          final firstImg = cardImgRows.first;
          if (firstImg['image_url'] != null) {
            setState(() {
              _swipeCardImageUrl = firstImg['image_url'].toString();
            });
          }
        }
      } catch (_) {}
    } catch (e) {
      debugPrint('Error loading restaurant info from Supabase: $e');
    }
  }

  void _launchMaps() async {
    String url = _mapsUrl.trim();
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    final uri = Uri.tryParse(url);
    if (uri != null) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: kOwnerPrimaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 34),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'ข้อมูลร้าน',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 0.3,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: TextButton(
              onPressed: _isSaving ? null : _saveAllRestaurantInfo,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.white.withOpacity(0.18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      'บันทึก',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ส่วนที่ 1: ส่วนหัวโปรไฟล์ร้าน (รูปทรงกลม + ชื่อร้าน + รหัสร้าน)
            _buildStoreProfileHeader(),

            const Divider(height: 1, thickness: 1, color: Color(0xFFF2E6E8)),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // รูปสำหรับหน้าปัดร้านอาหาร (is_logo: false)
                  _buildSwipeCardImageSection(),

                  const SizedBox(height: 16),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFF2E6E8)),
                  const SizedBox(height: 16),

                  // ส่วนที่ 2: ที่อยู่
                  _buildAddressSection(),

                  const SizedBox(height: 16),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFF2E6E8)),
                  const SizedBox(height: 16),

                  // ส่วนที่ 3: เวลาเปิด - ปิดร้าน
                  _buildOperatingHoursSection(),

                  const SizedBox(height: 16),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFF2E6E8)),
                  const SizedBox(height: 16),

                  // ส่วนที่ 4: สิ่งอำนวยความสะดวก
                  _buildAmenitiesSection(),

                  const SizedBox(height: 16),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFF2E6E8)),
                  const SizedBox(height: 16),

                  // ส่วนที่ 5: สถานะร้านค้า (Stepper 4 ขั้น + การ์ดผลการตรวจสอบ)
                  _buildStatusSection(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // 1. STORE PROFILE HEADER
  // ==========================================================================
  Widget _buildStoreProfileHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // รูปภาพโปรไฟล์ทรงกลม พร้อมปุ่มกล้อง "แก้ไข"
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

          // รายละเอียดชื่อร้าน ประเภทอาหาร และรหัสร้าน
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        _name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: _showEditNameDialog,
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.edit_note_rounded,
                          size: 19,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  'ประเภทอาหาร : $_category',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // SWIPE CARD IMAGE SECTION (รูปสำหรับหน้าปัดร้านอาหาร is_logo: false)
  // ==========================================================================
  Widget _buildSwipeCardImageSection() {
    final hasImage = _swipeCardImageUrl != null && _swipeCardImageUrl!.trim().isNotEmpty;

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
          'รูปภาพร้านอาหารหรือเมนูแนะนำ เพื่อแสดงบนหน้าปัดหาร้านอาหาร',
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
                color: hasImage ? const Color(0xFFE5E7EB) : kOwnerPrimaryColor.withOpacity(0.35),
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
                                color: kOwnerPrimaryColor.withOpacity(0.08),
                              ),
                              child: const Icon(
                                Icons.add_photo_alternate_rounded,
                                color: kOwnerPrimaryColor,
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
                                color: kOwnerPrimaryColor,
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
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: kOwnerRedColor.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                '⚠️ ถ้าไม่ได้ใส่รูปนี้ จะไม่อนุญาตให้กดบันทึกข้อมูล',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: kOwnerRedColor,
                                  fontWeight: FontWeight.w600,
                                ),
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
    if (_swipeCardImageUrl != null && _swipeCardImageUrl!.isNotEmpty) {
      if (_swipeCardImageUrl!.startsWith('data:image')) {
        try {
          final commaIndex = _swipeCardImageUrl!.indexOf(',');
          final base64String = commaIndex != -1
              ? _swipeCardImageUrl!.substring(commaIndex + 1)
              : _swipeCardImageUrl!;
          final bytes = base64Decode(base64String);
          return Image.memory(
            bytes,
            fit: BoxFit.cover,
            width: double.infinity,
            errorBuilder: (_, __, ___) => _buildFallbackSwipeCardImage(),
          );
        } catch (_) {
          return _buildFallbackSwipeCardImage();
        }
      }
      if (_swipeCardImageUrl!.startsWith('assets/')) {
        return Image.asset(
          _swipeCardImageUrl!,
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (_, __, ___) => _buildFallbackSwipeCardImage(),
        );
      }
      return Image.network(
        _swipeCardImageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, __, ___) => _buildFallbackSwipeCardImage(),
      );
    }
    return _buildFallbackSwipeCardImage();
  }

  Widget _buildFallbackSwipeCardImage() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.restaurant, size: 48, color: Colors.grey),
      ),
    );
  }

  // ==========================================================================
  // 2. ADDRESS SECTION
  // ==========================================================================
  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'ที่อยู่',
              style: TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            InkWell(
              onTap: _showEditAddressDialog,
              child: const Text(
                'แก้ไข',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kOwnerPrimaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // แถวที่ 1: ไอคอนหมุด + ที่อยู่ + ลิงก์แผนที่
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.location_on_outlined, color: kOwnerPrimaryColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _address,
                    style: const TextStyle(fontSize: 13.5, color: Colors.black87, height: 1.3),
                  ),
                  const SizedBox(height: 2),
                  InkWell(
                    onTap: _launchMaps,
                    child: Text(
                      _mapsUrl.isNotEmpty ? _mapsUrl : 'www.googlemap.com',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF2563EB),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // แถวที่ 2: ไอคอนโทรศัพท์ + เบอร์
        Row(
          children: [
            const Icon(Icons.phone_outlined, color: kOwnerPrimaryColor, size: 20),
            const SizedBox(width: 12),
            Text(
              _phone,
              style: const TextStyle(fontSize: 13.5, color: Colors.black87),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // แถวที่ 3: ไอคอนอีเมล + อีเมล
        Row(
          children: [
            const Icon(Icons.mail_outline_rounded, color: kOwnerPrimaryColor, size: 20),
            const SizedBox(width: 12),
            Text(
              _email,
              style: const TextStyle(fontSize: 13.5, color: Colors.black87),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================================================
  // 3. OPERATING HOURS SECTION
  // ==========================================================================
  Widget _buildOperatingHoursSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'เวลาเปิด - ปิดร้าน',
              style: TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            InkWell(
              onTap: _showEditOperatingHoursDialog,
              child: const Text(
                'แก้ไข',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kOwnerPrimaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ตารางทั้ง 7 วัน
        for (final item in _schedules) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.dayName,
                  style: TextStyle(fontSize: 13.5, color: Colors.grey[700]),
                ),
                Text(
                  item.displayTime,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: item.isClosed ? Colors.grey[600] : const Color(0xFF262626),
                    fontWeight: item.isClosed ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ==========================================================================
  // 4. AMENITIES SECTION
  // ==========================================================================
  Widget _buildAmenitiesSection() {
    IconData getAmenityIcon(String name) {
      for (final opt in kAllAmenityOptions) {
        if (opt.label == name) return opt.icon;
      }
      if (name.contains('ปลั๊ก')) return Icons.power_rounded;
      if (name.contains('เน็ต') || name.contains('wifi')) return Icons.wifi_rounded;
      if (name.contains('น้ำ') || name.contains('wc')) return Icons.favorite_border_rounded;
      if (name.contains('แอร์') || name.contains('ปรับอากาศ')) return Icons.ac_unit_rounded;
      if (name.contains('กลุ่ม')) return Icons.groups_rounded;
      if (name.contains('จอดรถยนต์')) return Icons.directions_car_rounded;
      if (name.contains('จักรยานยนต์')) return Icons.two_wheeler_rounded;
      if (name.contains('บัตรเครดิต')) return Icons.credit_card_rounded;
      if (name.contains('เดลิเวอรี่')) return Icons.delivery_dining_rounded;
      if (name.contains('เด็ก')) return Icons.child_care_rounded;
      if (name.contains('Pet') || name.contains('สัตว์')) return Icons.pets_rounded;
      if (name.contains('สังสรรค์')) return Icons.sports_bar_rounded;
      if (name.contains('เพลง')) return Icons.music_note_rounded;
      if (name.contains('สนทนา')) return Icons.record_voice_over_rounded;
      if (name.contains('พิการ')) return Icons.accessible_rounded;
      if (name.contains('ถ่ายรูป')) return Icons.photo_camera_rounded;
      return Icons.check_circle_outline_rounded;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'สิ่งอำนวยความสะดวก',
              style: TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            InkWell(
              onTap: () async {
                final updated = await Navigator.push<List<String>>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OwnerEditAmenitiesScreen(
                      restaurantId: widget.restaurantId,
                      initialAmenities: _amenities,
                    ),
                  ),
                );
                if (updated != null && mounted) {
                  setState(() {
                    _amenities = updated;
                  });
                }
              },
              child: const Text(
                'แก้ไข',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kOwnerPrimaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        for (final item in _amenities) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Icon(getAmenityIcon(item), color: kOwnerPrimaryColor, size: 20),
                const SizedBox(width: 12),
                Text(
                  item,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Color(0xFF262626),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ==========================================================================
  // 5. STATUS SECTION (STEPPER + RESULT CARD)
  // ==========================================================================
  String get _normalizedStatus {
    final s = _status.trim().toLowerCase();
    if (s == 'rejected' || s.contains('reject') || s.contains('ไม่ผ่าน')) {
      return 'rejected';
    }
    if (s == 'in_review' || s == 'reviewing' || s == 'checking' || s.contains('กำลังตรวจ')) {
      return 'in_review';
    }
    if (s == 'pending' || s == 'waiting' || s.contains('รอตรวจ') || s.contains('อยู่ระหว่าง')) {
      return 'pending';
    }
    return 'approved';
  }

  List<String> _getRejectionReasons() {
    if (_rejectionReason != null && _rejectionReason!.trim().isNotEmpty) {
      final lines = _rejectionReason!
          .split(RegExp(r'[\r\n]+'))
          .map((e) => e.replaceAll(RegExp(r'^[\s•\-\*]+'), '').trim())
          .where((e) => e.isNotEmpty)
          .toList();
      if (lines.isNotEmpty) return lines;
    }
    return const [
      'รูปภาพหน้าร้านไม่ชัดเจน',
      'เมนูอาหารบางรายการไม่ถูกต้อง',
      'ข้อมูลติดต่อร้านค้าไม่ครบถ้วน',
    ];
  }

  Widget _buildStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'สถานะร้านค้า',
          style: TextStyle(
            fontSize: 16.5,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),

        // 4-Step Stepper
        _buildStepperIndicator(),

        const SizedBox(height: 22),

        // การ์ดข้อความผลการตรวจสอบ
        _buildStatusResultCard(),
      ],
    );
  }

  Widget _buildStepperIndicator() {
    final status = _normalizedStatus;

    // กำหนดสถานะของแต่ละขั้นตอน
    _StepState step1State = _StepState.completed;
    _StepState step2State = _StepState.inactive;
    _StepState step3State = _StepState.inactive;
    _StepState step4State = _StepState.inactive;

    Color line1Color = kOwnerTealColor;
    Color line2Color = kOwnerGreyLine;
    Color line3Color = kOwnerGreyLine;

    if (status == 'pending') {
      // รูปที่ 2: ขั้นที่ 1 ส่งคำขอ (เขียว), ขั้นที่ 2 รอตรวจสอบ (แดงเลือดหมู), ขั้นที่ 3-4 สีเทา
      step1State = _StepState.completed;
      step2State = _StepState.active;
      step3State = _StepState.inactive;
      step4State = _StepState.inactive;
      line1Color = kOwnerTealColor;
      line2Color = kOwnerGreyLine;
      line3Color = kOwnerGreyLine;
    } else if (status == 'in_review') {
      // กำลังตรวจสอบ: ขั้นที่ 1-2 เขียว, ขั้นที่ 3 กำลังตรวจสอบ (แดงเลือดหมู), ขั้นที่ 4 สีเทา
      step1State = _StepState.completed;
      step2State = _StepState.completed;
      step3State = _StepState.active;
      step4State = _StepState.inactive;
      line1Color = kOwnerTealColor;
      line2Color = kOwnerTealColor;
      line3Color = kOwnerGreyLine;
    } else if (status == 'rejected') {
      // รูปที่ 3: ขั้นที่ 1-3 เขียว, ขั้นที่ 4 ไม่ผ่าน (แดง มีไอคอนกากบาท X)
      step1State = _StepState.completed;
      step2State = _StepState.completed;
      step3State = _StepState.completed;
      step4State = _StepState.rejected;
      line1Color = kOwnerTealColor;
      line2Color = kOwnerTealColor;
      line3Color = kOwnerTealColor;
    } else {
      // approved: ผ่านทุกขั้นตอน (สีเขียวทั้ง 4 ขั้น)
      step1State = _StepState.completed;
      step2State = _StepState.completed;
      step3State = _StepState.completed;
      step4State = _StepState.completed;
      line1Color = kOwnerTealColor;
      line2Color = kOwnerTealColor;
      line3Color = kOwnerTealColor;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepNode(
          num: '1',
          title: 'ส่งคำขอ',
          icon: Icons.description_outlined,
          state: step1State,
        ),
        _buildConnectorLine(line1Color),
        _buildStepNode(
          num: '2',
          title: 'รอตรวจสอบ',
          icon: Icons.hourglass_empty_rounded,
          state: step2State,
        ),
        _buildConnectorLine(line2Color),
        _buildStepNode(
          num: '3',
          title: 'กำลังตรวจสอบ',
          icon: Icons.manage_search_rounded,
          state: step3State,
        ),
        _buildConnectorLine(line3Color),
        _buildStepNode(
          num: '4',
          title: 'ผลการตรวจสอบ',
          icon: Icons.shopping_basket_outlined,
          state: step4State,
        ),
      ],
    );
  }

  Widget _buildConnectorLine(Color color) {
    return Container(
      width: 22,
      height: 2.2,
      margin: const EdgeInsets.only(top: 21),
      color: color,
    );
  }

  Widget _buildStepNode({
    required String num,
    required String title,
    required IconData icon,
    required _StepState state,
  }) {
    Color borderColor;
    Color iconColor;
    Color badgeColor;
    Color numColor;
    Color titleColor;
    Widget circleChild;

    switch (state) {
      case _StepState.completed:
        borderColor = kOwnerTealColor;
        iconColor = kOwnerTealColor;
        badgeColor = kOwnerTealColor;
        numColor = kOwnerTealColor;
        titleColor = kOwnerTealColor;
        circleChild = Center(
          child: Icon(icon, color: iconColor, size: 21),
        );
        break;
      case _StepState.active:
        borderColor = kOwnerMaroonColor;
        iconColor = kOwnerMaroonColor;
        badgeColor = kOwnerMaroonColor;
        numColor = kOwnerMaroonColor;
        titleColor = kOwnerMaroonColor;
        circleChild = Center(
          child: Icon(icon, color: iconColor, size: 21),
        );
        break;
      case _StepState.inactive:
        borderColor = kOwnerGreyBorder;
        iconColor = kOwnerGreyBorder;
        badgeColor = kOwnerGreyBadge;
        numColor = kOwnerGreyBorder;
        titleColor = const Color(0xFF1F2937); // ข้อความหัวข้อสีเข้มตามรูปที่ 2
        circleChild = Center(
          child: Icon(icon, color: iconColor, size: 21),
        );
        break;
      case _StepState.rejected:
        borderColor = kOwnerRedColor;
        iconColor = Colors.white;
        badgeColor = kOwnerRedColor;
        numColor = kOwnerRedColor;
        titleColor = kOwnerRedColor;
        circleChild = Container(
          margin: const EdgeInsets.all(2.5),
          decoration: const BoxDecoration(
            color: kOwnerRedColor,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(Icons.close_rounded, color: Colors.white, size: 22),
          ),
        );
        break;
    }

    return Expanded(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: borderColor,
                    width: 2.2,
                  ),
                ),
                child: circleChild,
              ),
              Positioned(
                bottom: -2,
                child: Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.check, color: Colors.white, size: 10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            num,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: numColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: titleColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusResultCard() {
    final status = _normalizedStatus;

    if (status == 'pending') {
      // รูปที่ 2: การ์ดสีเทา มีไอคอนนาฬิกา
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.access_time_rounded,
                  color: Color(0xFF111827),
                  size: 20,
                ),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'อยู่ระหว่างรอเจ้าหน้าที่ตรวจสอบ',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'โดยปกติใช้เวลาประมาณ 3-5 วันทำการ\n(ไม่รวมวันหยุดเสาร์-อาทิตย์ และวันหยุดนักขัตฤกษ์)',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF4B5563),
                fontWeight: FontWeight.w500,
                height: 1.45,
              ),
            ),
          ],
        ),
      );
    }

    if (status == 'in_review') {
      // กำลังตรวจสอบ: การ์ดสีเทา มีไอคอนตรวจสอบ คล้ายรูปที่ 2
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.manage_search_rounded,
                  color: Color(0xFF111827),
                  size: 22,
                ),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'เจ้าหน้าที่กำลังตรวจสอบข้อมูลร้านค้า',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'ระบบกำลังตรวจสอบความถูกต้องของข้อมูลร้านค้าและเมนูอาหาร\nคุณจะได้รับการแจ้งเตือนทันทีเมื่อการตรวจสอบเสร็จสิ้น',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF4B5563),
                fontWeight: FontWeight.w500,
                height: 1.45,
              ),
            ),
          ],
        ),
      );
    }

    if (status == 'rejected') {
      // รูปที่ 3: สองการ์ดสีชมพูอ่อน (การ์ดแจ้งไม่ผ่าน + การ์ดเหตุผล)
      final reasons = _getRejectionReasons();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // การ์ดที่ 1: สถานะไม่ผ่านการตรวจสอบ
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFFDF0F2),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE11D48), width: 2),
                  ),
                  padding: const EdgeInsets.all(3.5),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFE11D48),
                    ),
                    child: const Center(
                      child: Icon(Icons.close_rounded, color: Colors.white, size: 26),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'ไม่ผ่านการตรวจสอบ',
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF991B1B),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'กรุณาแก้ไขข้อมูลและส่งคำขอใหม่',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // การ์ดที่ 2: เหตุผลที่ไม่ผ่านการตรวจสอบ
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFDF0F2),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'เหตุผลที่ไม่ผ่านการตรวจสอบ',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 12),
                for (final reason in reasons)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '•  ',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF374151),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            reason,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151),
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      );
    }

    // approved: การ์ดสีเขียวมินต์
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFE2F7EE),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Color(0xFF34D399),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.storefront_outlined,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          SizedBox(height: 12),
          Text(
            'ผ่านการตรวจสอบ',
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF047857),
            ),
          ),
          SizedBox(height: 4),
          Text(
            'ร้านค้าของคุณได้รับการอนุมัติแล้ว',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          SizedBox(height: 4),
          Text(
            'ร้านค้าของคุณเปิดให้บริการแล้ว\nคุณสามารถจัดการร้านค้าและเมนูอาหารได้เลย',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF4B5563),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // HELPERS & EDIT DIALOGS
  // ==========================================================================
  Widget _buildAvatarImage() {
    if (_currentImageUrl != null && _currentImageUrl!.isNotEmpty) {
      if (_currentImageUrl!.startsWith('data:image')) {
        try {
          final commaIndex = _currentImageUrl!.indexOf(',');
          final base64String = commaIndex != -1
              ? _currentImageUrl!.substring(commaIndex + 1)
              : _currentImageUrl!;
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
      if (_currentImageUrl!.startsWith('assets/')) {
        return Image.asset(
          _currentImageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallbackStoreLogo(),
        );
      }
      return Image.network(
        _currentImageUrl!,
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
          color: kOwnerPrimaryColor,
          size: 40,
        ),
      ),
    );
  }

  /// แก้ไขชื่อร้านค้า
  void _showEditNameDialog() {
    final controller = TextEditingController(text: _name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('แก้ไขชื่อร้านค้า', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'ชื่อร้านค้า',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kOwnerPrimaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                setState(() => _name = newName);
                if (widget.restaurantId != null) {
                  try {
                    await Supabase.instance.client
                        .from('restaurants')
                        .update({'name': newName})
                        .eq('id', widget.restaurantId!);
                  } catch (_) {}
                }
              }
              if (mounted) Navigator.pop(ctx);
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }

  /// เมนูเลือกรูปภาพโปรไฟล์ร้านอาหาร (เฉพาะกล้อง และ คลังภาพ ไม่มี URL)
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
                    color: kOwnerPrimaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: kOwnerPrimaryColor),
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
                    color: kOwnerPrimaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: kOwnerPrimaryColor),
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
              if (_currentImageUrl != null && _currentImageUrl!.isNotEmpty) ...[
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

  Future<void> _processPickedPhoto(XFile picked) async {
    try {
      final rawBytes = await picked.readAsBytes();
      if (!mounted) return;

      // เปิดหน้าจอครอบตัดรูปภาพ (Image Crop Screen)
      final croppedBytes = await Navigator.push<Uint8List>(
        context,
        MaterialPageRoute(
          builder: (_) => ImageCropScreen(imageBytes: rawBytes),
        ),
      );

      if (croppedBytes == null) return;

      // แปลงรูปที่ครอบตัดเป็น Data URL เพื่อจัดเก็บเป็น URL
      String convertedUrl = 'data:image/png;base64,${base64Encode(croppedBytes)}';

      // พยายามอัปโหลดเข้า Supabase Storage ถ้ามี bucket รองรับ
      try {
        final fileName = 'restaurant_logo_${DateTime.now().millisecondsSinceEpoch}.png';
        await Supabase.instance.client.storage.from('restaurant-images').uploadBinary(
          fileName,
          croppedBytes,
          fileOptions: const FileOptions(contentType: 'image/png', upsert: true),
        );
        final pubUrl = Supabase.instance.client.storage.from('restaurant-images').getPublicUrl(fileName);
        if (pubUrl.isNotEmpty) {
          convertedUrl = pubUrl;
        }
      } catch (_) {
        // ใช้ Data URL บันทึกลงฐานข้อมูลได้อย่างสมบูรณ์
      }

      setState(() {
        _currentImageUrl = convertedUrl;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ครอบตัดและเลือกรูปภาพเรียบร้อยแล้ว'),
            backgroundColor: kOwnerPrimaryColor,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error processing picked restaurant photo: $e');
    }
  }

  /// ป็อปอัพยืนยันการลบรูปภาพ
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
        _currentImageUrl = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ลบรูปภาพเรียบร้อยแล้ว'),
          backgroundColor: kOwnerPrimaryColor,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  /// เมนูตัวเลือกรูปภาพสำหรับหน้าปัดร้านอาหาร (ถ่ายรูป / คลังรูป / ลบรูป)
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
                    const Text(
                      'รูปภาพสำหรับหน้าปัดร้านอาหาร',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
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
                    color: kOwnerPrimaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: kOwnerPrimaryColor),
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
                    color: kOwnerPrimaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: kOwnerPrimaryColor),
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
              if (_swipeCardImageUrl != null && _swipeCardImageUrl!.isNotEmpty) ...[
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

  /// ครอปรูปภาพและแปลงเป็น Data URL สำหรับหน้าปัดร้านอาหาร
  Future<void> _processPickedSwipeCardPhoto(XFile picked) async {
    try {
      final rawBytes = await picked.readAsBytes();
      if (!mounted) return;

      // คำนวณขนาดของการ์ดในหน้าปัดร้านอาหารตาม FoodSwipeScreen:
      // width = screenSize.width * 0.88, height = screenSize.height * 0.64
      final screenSize = MediaQuery.of(context).size;
      final double cardWidth = screenSize.width > 0 ? screenSize.width * 0.88 : (390 * 0.88);
      final double cardHeight = screenSize.height > 0 ? screenSize.height * 0.64 : (844 * 0.64);
      final double swipeCardAspectRatio = cardWidth / cardHeight;

      // เปิดหน้าจอครอบตัดรูปภาพ (Image Crop Screen) ให้มีขนาดและสัดส่วนเท่ากับหน้าปัดร้านอาหาร
      final croppedBytes = await Navigator.push<Uint8List>(
        context,
        MaterialPageRoute(
          builder: (_) => ImageCropScreen(
            imageBytes: rawBytes,
            targetWidth: cardWidth,
            targetHeight: cardHeight,
            aspectRatio: swipeCardAspectRatio,
            cornerRadius: 24.0, // มุมโค้งมน 24px เท่ากับการ์ดในหน้าปัดร้านอาหาร
            subtitleTag: 'ขนาดเท่ากับหน้าปัดร้านอาหาร',
          ),
        ),
      );

      if (croppedBytes == null) return;

      // แปลงรูปที่ครอบตัดเป็น Data URL เพื่อจัดเก็บลง database ในฟิลด์ image_url
      String convertedUrl = 'data:image/png;base64,${base64Encode(croppedBytes)}';

      // พยายามอัปโหลดเข้า Supabase Storage ถ้ามี bucket รองรับ
      try {
        final fileName = 'restaurant_card_${DateTime.now().millisecondsSinceEpoch}.png';
        await Supabase.instance.client.storage.from('restaurant-images').uploadBinary(
          fileName,
          croppedBytes,
          fileOptions: const FileOptions(contentType: 'image/png', upsert: true),
        );
        final pubUrl = Supabase.instance.client.storage.from('restaurant-images').getPublicUrl(fileName);
        if (pubUrl.isNotEmpty) {
          convertedUrl = pubUrl;
        }
      } catch (_) {}

      setState(() {
        _swipeCardImageUrl = convertedUrl;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ครอบตัดและเลือกรูปสำหรับหน้าปัดร้านอาหารเรียบร้อยแล้ว'),
            backgroundColor: kOwnerPrimaryColor,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error processing picked swipe card photo: $e');
    }
  }

  /// ป็อปอัพยืนยันการลบรูปภาพสำหรับหน้าปัดร้านอาหาร
  Future<void> _confirmDeleteSwipeCardPhoto() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('ยืนยันลบรูปภาพ', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('คุณต้องการลบรูปภาพสำหรับหน้าปัดร้านอาหารนี้ใช่หรือไม่?\n(หากลบรูปนี้ จะต้องใส่รูปใหม่ก่อนจึงจะสามารถกดบันทึกได้)'),
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
        _swipeCardImageUrl = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ลบรูปภาพเรียบร้อยแล้ว'),
          backgroundColor: kOwnerPrimaryColor,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  /// บันทึกข้อมูลร้านค้าทั้งหมดเข้า Database (ตาราง restaurants รูปที่ 4 และ restaurant_images รูปที่ 1)
  Future<void> _saveAllRestaurantInfo() async {
    final List<String> missing = [];

    // เงื่อนไข: ต้องมีรูปโปรไฟล์ร้านถึงจะกดบันทึกได้
    if (_currentImageUrl == null || _currentImageUrl!.trim().isEmpty) {
      missing.add('รูปภาพร้านอาหาร');
    }

    // เงื่อนไขสำคัญตามที่ user กำหนด: ต้องใส่รูปสำหรับหน้าปัดร้านอาหาร (is_logo = false) ถึงจะอนุญาตให้กดบันทึก
    if (_swipeCardImageUrl == null || _swipeCardImageUrl!.trim().isEmpty) {
      missing.add('รูปสำหรับหน้าปัดร้านอาหาร');
    }

    // เงื่อนไข: ชื่อร้าน
    if (_name.trim().isEmpty) {
      missing.add('ชื่อร้านอาหาร');
    }

    // เงื่อนไข: ที่อยู่
    if (_address.trim().isEmpty) {
      missing.add('ที่อยู่ร้านอาหาร');
    }

    // เงื่อนไข: เบอร์โทร
    if (_phone.trim().isEmpty) {
      missing.add('เบอร์โทรศัพท์');
    }

    // เงื่อนไข: เวลาเปิดปิด (อย่างน้อย 1 วัน)
    final hasOpenHours = _schedules.any((s) => !s.isClosed);
    if (!hasOpenHours) {
      missing.add('เวลาเปิด-ปิดร้านอาหาร (อย่างน้อย 1 วัน)');
    }

    // เงื่อนไข: สิ่งอำนวยความสะดวก (อย่างน้อย 1 อย่าง)
    if (_amenities.isEmpty) {
      missing.add('สิ่งอำนวยความสะดวก (อย่างน้อย 1 อย่าง)');
    }

    if (missing.isNotEmpty) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('กรุณากรอกข้อมูลให้ครบถ้วน: ${missing.join(', ')}'),
          backgroundColor: kOwnerRedColor,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (widget.restaurantId != null) {
        // 1. อัปเดตข้อมูลร้านเข้าตาราง restaurants (รูปที่ 4: name, address, google_maps_url, phone)
        await Supabase.instance.client.from('restaurants').update({
          'name': _name.trim(),
          'address': _address.trim(),
          'google_maps_url': _mapsUrl.trim(),
          'phone': _phone.trim(),
        }).eq('id', widget.restaurantId!);

        // 2. อัปเดต/บันทึกรูปภาพโปรไฟล์เข้าตาราง restaurant_images (is_logo = true)
        if (_currentImageUrl != null && _currentImageUrl!.isNotEmpty) {
          final existingLogo = await Supabase.instance.client
              .from('restaurant_images')
              .select('id')
              .eq('restaurant_id', widget.restaurantId!)
              .eq('is_logo', true)
              .maybeSingle();

          if (existingLogo != null && existingLogo['id'] != null) {
            await Supabase.instance.client.from('restaurant_images').update({
              'image_url': _currentImageUrl,
              'sort_order': 0,
            }).eq('id', existingLogo['id']);
          } else {
            await Supabase.instance.client.from('restaurant_images').insert({
              'restaurant_id': widget.restaurantId!,
              'image_url': _currentImageUrl,
              'is_logo': true,
              'sort_order': 0,
            });
          }
        }

        // 3. อัปเดต/บันทึกรูปสำหรับหน้าปัดร้านอาหารเข้าตาราง restaurant_images (รูปที่ 1: is_logo = false)
        if (_swipeCardImageUrl != null && _swipeCardImageUrl!.isNotEmpty) {
          final existingCardImg = await Supabase.instance.client
              .from('restaurant_images')
              .select('id')
              .eq('restaurant_id', widget.restaurantId!)
              .eq('is_logo', false)
              .maybeSingle();

          if (existingCardImg != null && existingCardImg['id'] != null) {
            await Supabase.instance.client.from('restaurant_images').update({
              'image_url': _swipeCardImageUrl,
              'is_logo': false,
              'sort_order': 1,
            }).eq('id', existingCardImg['id']);
          } else {
            await Supabase.instance.client.from('restaurant_images').insert({
              'restaurant_id': widget.restaurantId!,
              'image_url': _swipeCardImageUrl,
              'is_logo': false,
              'sort_order': 1,
            });
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('บันทึกข้อมูลร้านค้าเรียบร้อยแล้ว'),
            backgroundColor: kOwnerPrimaryColor,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving restaurant info: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาดในการบันทึก: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  /// แก้ไขที่อยู่, แผนที่, เบอร์โทร, อีเมล
  void _showEditAddressDialog() {
    final addressCtrl = TextEditingController(text: _address);
    final mapsCtrl = TextEditingController(text: _mapsUrl);
    final phoneCtrl = TextEditingController(text: _phone);
    final emailCtrl = TextEditingController(text: _email);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
              const Text(
                'แก้ไขข้อมูลติดต่อและที่อยู่',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addressCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'ที่อยู่ร้านอาหาร',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: mapsCtrl,
                decoration: const InputDecoration(
                  labelText: 'ลิงก์ Google Maps',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'เบอร์โทรศัพท์ติดต่อ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'อีเมลร้านค้า',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kOwnerPrimaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    setState(() {
                      _address = addressCtrl.text.trim();
                      _mapsUrl = mapsCtrl.text.trim();
                      _phone = phoneCtrl.text.trim();
                      _email = emailCtrl.text.trim();
                    });

                    if (widget.restaurantId != null) {
                      try {
                        await Supabase.instance.client
                            .from('restaurants')
                            .update({
                              'address': _address,
                              'google_maps_url': _mapsUrl,
                              'phone': _phone,
                            })
                            .eq('id', widget.restaurantId!);
                      } catch (_) {}
                    }

                    if (mounted) Navigator.pop(ctx);
                  },
                  child: const Text('บันทึกข้อมูล', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// แก้ไขเวลาเปิด-ปิดร้าน นำทางไปยังหน้าแก้ไขเวลาเปิด-ปิด (ภาพที่ 2)
  Future<void> _showEditOperatingHoursDialog() async {
    final initialEntries = <OperatingHourEntry>[];
    for (final schedule in _schedules) {
      if (!schedule.isClosed) {
        if (schedule.timeRanges.isNotEmpty) {
          for (final range in schedule.timeRanges) {
            final parts = range.split('-');
            if (parts.length == 2) {
              initialEntries.add(
                OperatingHourEntry(
                  dayOfWeek: schedule.dayOfWeek,
                  dayName: schedule.dayName,
                  openTime: parts[0].trim(),
                  closeTime: parts[1].trim(),
                ),
              );
            }
          }
        } else {
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
    }

    final updated = await Navigator.push<List<OperatingHourEntry>>(
      context,
      MaterialPageRoute(
        builder: (_) => OwnerEditOperatingHoursScreen(
          restaurantId: widget.restaurantId,
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
            s.timeRanges = dayList.map((e) => '${e.openTime} - ${e.closeTime}').toList();
          } else {
            s.isClosed = true;
            s.timeRanges = [];
          }
        }
      });

      _loadRestaurantDetails();
    }
  }

  /// แก้ไขสิ่งอำนวยความสะดวก
  void _showEditAmenitiesDialog() {
    final allOptions = [
      'มีปลั๊กไฟ',
      'มีอินเทอร์เน็ต',
      'มีห้องน้ำ',
      'เครื่องปรับอากาศ',
      'เหมาะกับกลุ่ม',
      'มีที่จอดรถ',
      'รับบัตรเครดิต',
      'อนุญาตให้นำสัตว์เลี้ยงเข้าได้',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'เลือกสิ่งอำนวยความสะดวก',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: allOptions.map((opt) {
                    final selected = _amenities.contains(opt);
                    return FilterChip(
                      label: Text(opt),
                      selected: selected,
                      selectedColor: kOwnerPrimaryColor.withOpacity(0.15),
                      checkmarkColor: kOwnerPrimaryColor,
                      labelStyle: TextStyle(
                        color: selected ? kOwnerPrimaryColor : Colors.black87,
                        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (val) {
                        setModalState(() {
                          if (val) {
                            _amenities.add(opt);
                          } else {
                            _amenities.remove(opt);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kOwnerPrimaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      setState(() {});
                      Navigator.pop(ctx);
                    },
                    child: const Text('บันทึก', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
