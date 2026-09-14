import 'dart:math';
import 'package:flutter/material.dart';
import '../../main.dart';
import '../home/home_screen.dart';
import 'edit_facilities_screen.dart';
import 'add_menu_screen.dart';

class ShopDetailsScreen extends StatefulWidget {
  final Map<String, dynamic>? shopData;

  const ShopDetailsScreen({
    super.key,
    this.shopData,
  });

  @override
  State<ShopDetailsScreen> createState() => _ShopDetailsScreenState();
}

class _ShopDetailsScreenState extends State<ShopDetailsScreen> {
  static const Color maroonColor = Color(0xFF82152B);
  static const Color accentPink = Color(0xFFB53852);

  bool _isInitialized = false;

  String? _restaurantId;
  late String _shopCode;
  late String _name;
  late String _category;
  late String _address;
  late String _phone;
  late String _email;
  late String _mapUrl;

  late Map<String, String> _openingHours;
  late List<String> _facilities;
  late List<Map<String, dynamic>> _menus;

  bool _isSubmitted = false;

  // 3 possible statuses: 'pending' (รอตรวจสอบ), 'approved' (ผ่านการตรวจสอบ), 'rejected' (ไม่ผ่านการตรวจสอบ)
  String _status = 'pending';
  String? _rejectionReason;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final routeArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final data = widget.shopData ?? routeArgs ?? {};

      _restaurantId = data['id']?.toString();

      // 1. Shop Code: Retain the passed shop code or generate once so it doesn't change on re-render
      if (data['shopCode'] != null && data['shopCode'].toString().isNotEmpty) {
        _shopCode = data['shopCode'].toString();
      } else {
        _shopCode = 'FD${1000 + Random().nextInt(9000)}';
      }

      // 2. Information from registration form
      _name = (data['name'] != null && data['name'].toString().isNotEmpty)
          ? data['name'].toString()
          : 'THE CHICKEN';

      _category = (data['category'] != null && data['category'].toString().isNotEmpty)
          ? data['category'].toString()
          : 'อาหารตามสั่ง';

      _address = (data['address'] != null && data['address'].toString().isNotEmpty)
          ? data['address'].toString()
          : '31/0 ตำบลสุเทพ ซอยวัดอุโมงค์ หลังมช';

      _phone = (data['phone'] != null && data['phone'].toString().isNotEmpty)
          ? data['phone'].toString()
          : '0991234567';

      _email = (data['email'] != null && data['email'].toString().isNotEmpty)
          ? data['email'].toString()
          : 'ITLOVER@GMAIL.COM';

      _mapUrl = (data['mapUrl'] != null && data['mapUrl'].toString().isNotEmpty)
          ? data['mapUrl'].toString()
          : 'www.googlemap.com';

      // 3. Opening Hours
      if (data['openingHours'] is Map<String, String>) {
        _openingHours = Map<String, String>.from(data['openingHours']);
      } else {
        _openingHours = {
          'อาทิตย์': '09.00 - 23.00',
          'จันทร์': 'หยุดทำการ',
          'อังคาร': '10.00 - 22.00',
          'พุธ': '10.00 - 22.00',
          'พฤหัสบดี': '10.00 - 22.00',
          'ศุกร์': '10.00 - 22.00',
          'เสาร์': '09.00 - 23.00',
        };
      }

      // 4. Facilities
      if (data['facilities'] is List) {
        _facilities = List<String>.from(data['facilities']);
      } else {
        _facilities = [
          'มีปลั๊กไฟ',
          'มีอินเทอร์เน็ต',
          'มีห้องน้ำ',
          'เครื่องปรับอากาศ',
          'เหมาะกับกลุ่ม',
        ];
      }

      // 5. Menus
      if (data['menus'] is List) {
        _menus = List<Map<String, dynamic>>.from(data['menus']);
      } else {
        _menus = [];
      }

      // 6. Status initialization: 'pending', 'approved', or 'rejected'
      final rawStatus = data['status']?.toString().toLowerCase();
      if (rawStatus == 'approved' || rawStatus == 'ผ่านการตรวจสอบ') {
        _status = 'approved';
        _isSubmitted = true;
      } else if (rawStatus == 'rejected' || rawStatus == 'ไม่ผ่านการตรวจสอบ') {
        _status = 'rejected';
        _rejectionReason = data['rejectionReason']?.toString() ??
            'เอกสารหรือข้อมูลที่อยู่ร้านอาหารไม่ถูกต้องครบถ้วน กรุณาแก้ไขข้อมูลและส่งคำขอใหม่อีกครั้ง';
        _isSubmitted = true;
      } else {
        _status = 'pending';
        _isSubmitted = data['isSubmitted'] == true || _menus.isNotEmpty;
      }

      _isInitialized = true;
    }
  }

  IconData _getIconForFacility(String facility) {
    if (facility.contains('ปลั๊ก')) return Icons.power;
    if (facility.contains('เน็ต') || facility.contains('wifi') || facility.contains('Wifi')) return Icons.wifi;
    if (facility.contains('ห้องน้ำ')) return Icons.wc;
    if (facility.contains('ปรับอากาศ') || facility.contains('แอร์')) return Icons.ac_unit;
    if (facility.contains('กลุ่ม')) return Icons.people_alt_outlined;
    if (facility.contains('จอดรถ')) return Icons.local_parking;
    if (facility.contains('ส่งอาหาร')) return Icons.delivery_dining;
    if (facility.contains('บัตร') || facility.contains('สแกน')) return Icons.payment;
    if (facility.contains('จอง')) return Icons.book_online;
    if (facility.contains('ดนตรี')) return Icons.music_note;
    return Icons.check_circle_outline;
  }

  // Edit Shop Name & Category Dialog
  void _showEditShopInfoDialog() {
    final nameCtrl = TextEditingController(text: _name);
    final catCtrl = TextEditingController(text: _category);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'แก้ไขข้อมูลร้าน',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'ชื่อร้าน',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: catCtrl,
              decoration: const InputDecoration(
                labelText: 'ประเภทอาหาร',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: maroonColor),
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty) {
                setState(() {
                  _name = nameCtrl.text.trim();
                  _category = catCtrl.text.trim();
                });
              }
              Navigator.pop(ctx);
            },
            child: const Text('บันทึก', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Edit Address Dialog
  void _showEditAddressDialog() {
    final addressCtrl = TextEditingController(text: _address);
    final mapCtrl = TextEditingController(text: _mapUrl);
    final phoneCtrl = TextEditingController(text: _phone);
    final emailCtrl = TextEditingController(text: _email);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'แก้ไขที่อยู่และการติดต่อ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: addressCtrl,
              decoration: const InputDecoration(
                labelText: 'ที่อยู่ร้านอาหาร',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: mapCtrl,
              decoration: const InputDecoration(
                labelText: 'ลิงก์แผนที่ (Google Maps)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'เบอร์โทรศัพท์',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'อีเมล',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: maroonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _address = addressCtrl.text.trim();
                    _mapUrl = mapCtrl.text.trim();
                    _phone = phoneCtrl.text.trim();
                    _email = emailCtrl.text.trim();
                  });
                  Navigator.pop(ctx);
                },
                child: const Text(
                  'บันทึก',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Edit Opening Hours Dialog
  void _showEditHoursDialog() {
    final days = _openingHours.keys.toList();
    String selectedDay = days.first;
    final timeCtrl = TextEditingController(text: _openingHours[selectedDay]);
    bool isClosed = _openingHours[selectedDay] == 'หยุดทำการ';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'แก้ไขเวลาเปิด - ปิดร้าน',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedDay,
                  decoration: const InputDecoration(
                    labelText: 'เลือกวัน',
                    border: OutlineInputBorder(),
                  ),
                  items: days.map((day) {
                    return DropdownMenuItem(value: day, child: Text(day));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setModalState(() {
                        selectedDay = val;
                        isClosed = _openingHours[val] == 'หยุดทำการ';
                        timeCtrl.text = _openingHours[val] ?? '10.00 - 22.00';
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('หยุดทำการในวันนี้'),
                  value: isClosed,
                  activeColor: maroonColor,
                  onChanged: (val) {
                    setModalState(() {
                      isClosed = val;
                      if (isClosed) {
                        timeCtrl.text = 'หยุดทำการ';
                      } else {
                        timeCtrl.text = '10.00 - 22.00';
                      }
                    });
                  },
                ),
                if (!isClosed) ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: timeCtrl,
                    decoration: const InputDecoration(
                      labelText: 'เวลาเปิด - ปิด (เช่น 09.00 - 23.00)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: maroonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _openingHours[selectedDay] = isClosed ? 'หยุดทำการ' : timeCtrl.text.trim();
                      });
                      Navigator.pop(ctx);
                    },
                    child: const Text(
                      'บันทึก',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Open separate EditFacilitiesScreen
  Future<void> _openEditFacilitiesScreen() async {
    final updated = await Navigator.of(context).push<List<String>>(
      MaterialPageRoute(
        builder: (_) => EditFacilitiesScreen(initialFacilities: _facilities),
      ),
    );

    if (updated != null) {
      setState(() {
        _facilities = updated;
      });
    }
  }

  // Re-submit flow for Rejected status -> Pending
  Future<void> _reSubmitRequest() async {
    setState(() {
      _status = 'pending';
      _rejectionReason = null;
    });

    // Update status in Supabase if restaurantId exists
    if (_restaurantId != null) {
      try {
        await supabase
            .from('restaurants')
            .update({'status': 'pending'})
            .eq('id', _restaurantId!);
      } catch (_) {}
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ส่งคำขอตรวจสอบร้านใหม่อีกครั้งเรียบร้อยแล้ว สถานะเปลี่ยนเป็น "รอตรวจสอบ"'),
          backgroundColor: maroonColor,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  // Bottom button pressed handler
  Future<void> _onBottomButtonPressed() async {
    if (!_isSubmitted) {
      // Condition: Navigate to Add Menu Screen before request can be submitted
      final newMenu = await Navigator.of(context).push<Map<String, dynamic>>(
        MaterialPageRoute(
          builder: (_) => AddMenuScreen(shopData: {
            'shopCode': _shopCode,
            'name': _name,
            'category': _category,
          }),
        ),
      );

      if (newMenu != null) {
        setState(() {
          _menus.add(newMenu);
          _isSubmitted = true;
          _status = 'pending';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('เพิ่มเมนูอาหารเรียบร้อยแล้ว เข้าสู่สถานะ "รอตรวจสอบ"'),
            backgroundColor: maroonColor,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      // When status is rejected, primary bottom button re-submits the request
      if (_status == 'rejected') {
        await _reSubmitRequest();
        return;
      }

      // When status is pending or approved, save to Supabase (if needed) and return to Owner Dashboard
      final currentUser = supabase.auth.currentUser;
      if (currentUser != null && _restaurantId == null) {
        try {
          final res = await supabase.from('restaurants').insert({
            'owner_id': currentUser.id,
            'name': _name,
            'address': _address,
            'phone': _phone,
            'email': _email,
            'menu': _menus.isNotEmpty ? _menus.map((m) => m['name']).join(', ') : null,
            'lat': 18.7883, // default Chiang Mai lat/lng
            'lng': 98.9853,
            'status': _status,
          }).select().single();
          _restaurantId = res['id']?.toString();
        } catch (_) {}
      }

      // Navigate back to Shop Owner Dashboard (HomeScreen)
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    }
  }

  // Stepper Widget dynamically supporting 3 statuses (pending, approved, rejected)
  Widget _buildStatusStepper() {
    // 1. Step 1: Always completed once submitted
    // 2. Step 2 (รอตรวจสอบ):
    //    - pending: Active (maroon)
    //    - approved: Completed (green)
    //    - rejected: Completed (green)
    // 3. Step 3 (กำลังตรวจสอบ):
    //    - pending: Pending (grey)
    //    - approved: Completed (green)
    //    - rejected: Completed (green)
    // 4. Step 4 (ผลการตรวจสอบ):
    //    - pending: Pending (grey)
    //    - approved: Completed (green)
    //    - rejected: Failed (red with 'X' icon)

    final String step2State = _status == 'pending' ? 'active' : 'completed';
    final String step3State = (_status == 'approved' || _status == 'rejected') ? 'completed' : 'pending';
    final String step4State = _status == 'approved'
        ? 'completed'
        : (_status == 'rejected' ? 'failed' : 'pending');

    final Color line1to2Color = const Color(0xFF10B981); // Green
    final Color line2to3Color = (_status == 'approved' || _status == 'rejected')
        ? const Color(0xFF10B981)
        : const Color(0xFFD1D5DB);
    final Color line3to4Color = _status == 'approved'
        ? const Color(0xFF10B981)
        : (_status == 'rejected' ? const Color(0xFFEF4444) : const Color(0xFFD1D5DB));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'สถานะร้านค้า',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            // Status Switcher Menu (For development / testing preview of all 3 states)
            PopupMenuButton<String>(
              tooltip: 'สลับดูสถานะ (Preview)',
              icon: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _status == 'approved'
                      ? const Color(0xFFECFDF5)
                      : (_status == 'rejected' ? const Color(0xFFFEF2F2) : const Color(0xFFF3F4F6)),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _status == 'approved'
                        ? const Color(0xFF10B981)
                        : (_status == 'rejected' ? const Color(0xFFEF4444) : const Color(0xFFD1D5DB)),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _status == 'approved'
                          ? 'ผ่านแล้ว'
                          : (_status == 'rejected' ? 'ไม่ผ่าน' : 'รอตรวจ'),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _status == 'approved'
                            ? const Color(0xFF059669)
                            : (_status == 'rejected' ? const Color(0xFFDC2626) : maroonColor),
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.arrow_drop_down, size: 16, color: Colors.grey),
                  ],
                ),
              ),
              onSelected: (val) {
                setState(() {
                  _status = val;
                  if (val == 'rejected' && _rejectionReason == null) {
                    _rejectionReason =
                        'เอกสารหรือข้อมูลที่อยู่ร้านอาหารไม่ถูกต้องครบถ้วน กรุณาแก้ไขข้อมูลและส่งคำขอใหม่อีกครั้ง';
                  }
                });
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'pending', child: Text('1. PENDING (รอตรวจสอบ)')),
                PopupMenuItem(value: 'approved', child: Text('2. APPROVED (ผ่านการตรวจสอบ)')),
                PopupMenuItem(value: 'rejected', child: Text('3. REJECTED (ไม่ผ่านการตรวจสอบ)')),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Stepper Horizontal Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step 1: ส่งคำขอ
            _buildStepItem(
              stepNumber: 1,
              title: 'ส่งคำขอ',
              icon: Icons.description_outlined,
              state: 'completed',
            ),

            // Line 1 -> 2
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 24),
                height: 2.5,
                color: line1to2Color,
              ),
            ),

            // Step 2: รอตรวจสอบ
            _buildStepItem(
              stepNumber: 2,
              title: 'รอตรวจสอบ',
              icon: Icons.hourglass_empty,
              state: step2State,
            ),

            // Line 2 -> 3
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 24),
                height: 2.0,
                color: line2to3Color,
              ),
            ),

            // Step 3: กำลังตรวจสอบ
            _buildStepItem(
              stepNumber: 3,
              title: 'กำลังตรวจสอบ',
              icon: Icons.update,
              state: step3State,
            ),

            // Line 3 -> 4
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 24),
                height: 2.0,
                color: line3to4Color,
              ),
            ),

            // Step 4: ผลการตรวจสอบ
            _buildStepItem(
              stepNumber: 4,
              title: _status == 'rejected' ? 'ไม่ผ่าน' : 'ผลการตรวจสอบ',
              icon: _status == 'rejected'
                  ? Icons.close_rounded
                  : Icons.shopping_basket_outlined,
              state: step4State,
            ),
          ],
        ),
        const SizedBox(height: 22),

        // Notice Box matching Figma for each of the 3 statuses
        _buildStatusNoticeBox(),
      ],
    );
  }

  // Dynamic Notice Box based on status (pending, approved, rejected)
  Widget _buildStatusNoticeBox() {
    if (_status == 'approved') {
      // APPROVED: Green box
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFA7F3D0), width: 1.2),
        ),
        child: Column(
          children: const [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 22,
                  color: Color(0xFF059669),
                ),
                SizedBox(width: 8),
                Text(
                  'ร้านค้าผ่านการตรวจสอบเรียบร้อยแล้ว',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF065F46),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'ยินดีด้วย! ร้านของคุณผ่านการอนุมัติและพร้อมเปิดให้บริการบน MealMate แล้ว\nลูกค้าสามารถค้นหาและสั่งอาหารจากร้านของคุณได้ทันที',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: Color(0xFF047857),
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    } else if (_status == 'rejected') {
      // REJECTED: Red box
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFECACA), width: 1.2),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.cancel_rounded,
                  size: 22,
                  color: Color(0xFFDC2626),
                ),
                SizedBox(width: 8),
                Text(
                  'ร้านค้าไม่ผ่านการตรวจสอบ',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF991B1B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'เหตุผล: ${_rejectionReason ?? "ข้อมูลร้านค้าหรือเอกสารไม่ถูกต้องครบถ้วน กรุณาแก้ไขข้อมูลและส่งคำขอใหม่อีกครั้ง"}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF7F1D1D),
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    } else {
      // PENDING: Grey box (default)
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: const [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 20,
                  color: Colors.black87,
                ),
                SizedBox(width: 8),
                Text(
                  'อยู่ระหว่างรอเจ้าหน้าที่ตรวจสอบ',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'โดยปกติใช้เวลาประมาณ 3-5 วันทำการ\n(ไม่รวมวันหยุดเสาร์-อาทิตย์ และวันหยุดนักขัตฤกษ์)',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: Color(0xFF4B5563),
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildStepItem({
    required int stepNumber,
    required String title,
    required IconData icon,
    required String state, // 'completed', 'active', 'pending', 'failed'
  }) {
    Color circleBorderColor;
    Color iconColor;
    Color badgeColor;
    Color numberColor;
    Color textColor;
    IconData badgeIcon = Icons.check;

    if (state == 'completed') {
      circleBorderColor = const Color(0xFF10B981);
      iconColor = const Color(0xFF10B981);
      badgeColor = const Color(0xFF10B981);
      numberColor = const Color(0xFF10B981);
      textColor = const Color(0xFF10B981);
    } else if (state == 'active') {
      circleBorderColor = maroonColor;
      iconColor = maroonColor;
      badgeColor = maroonColor;
      numberColor = maroonColor;
      textColor = maroonColor;
    } else if (state == 'failed') {
      circleBorderColor = const Color(0xFFEF4444);
      iconColor = const Color(0xFFEF4444);
      badgeColor = const Color(0xFFEF4444);
      numberColor = const Color(0xFFEF4444);
      textColor = const Color(0xFFDC2626);
      badgeIcon = Icons.close;
    } else {
      circleBorderColor = const Color(0xFF9CA3AF);
      iconColor = const Color(0xFF6B7280);
      badgeColor = const Color(0xFF9CA3AF);
      numberColor = const Color(0xFF6B7280);
      textColor = const Color(0xFF4B5563);
    }

    return SizedBox(
      width: 70,
      child: Column(
        children: [
          // Circle with Icon & Checkmark / X Badge
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: circleBorderColor, width: 2),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              Positioned(
                bottom: -5,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    badgeIcon,
                    color: Colors.white,
                    size: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Step Number
          Text(
            '$stepNumber',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: numberColor,
            ),
          ),
          const SizedBox(height: 2),

          // Step Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: state == 'active' || state == 'completed' || state == 'failed'
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Header title: "ข้อมูลร้าน" when submitted, otherwise "รายละเอียดร้านอาหาร"
    final headerTitle = _isSubmitted ? 'ข้อมูลร้าน' : 'รายละเอียดร้านอาหาร';

    // Button text:
    // If not submitted: "ถัดไป"
    // If submitted and rejected: "แก้ไขข้อมูลและส่งคำขอใหม่"
    // If submitted and pending/approved: "ตกลง"
    String buttonText = 'ถัดไป';
    if (_isSubmitted) {
      if (_status == 'rejected') {
        buttonText = 'แก้ไขข้อมูลและส่งคำขอใหม่';
      } else {
        buttonText = 'ตกลง';
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          headerTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: maroonColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- 1. ข้อมูลร้าน (Shop Profile Info) ---
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Shop Avatar with Camera Badge
                        Stack(
                          alignment: Alignment.bottomCenter,
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 86,
                              height: 86,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFFFF1F2),
                                border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
                              ),
                              child: ClipOval(
                                child: Image.network(
                                  'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=300',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            'THE',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black54,
                                            ),
                                          ),
                                          Text(
                                            _name.toUpperCase(),
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: maroonColor,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -4,
                              child: GestureDetector(
                                onTap: _showEditShopInfoDialog,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.55),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(Icons.camera_alt, color: Colors.white, size: 10),
                                      SizedBox(width: 3),
                                      Text(
                                        'แก้ไข',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 9.5,
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
                        const SizedBox(width: 20),

                        // Shop Name, Category, Code
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
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  GestureDetector(
                                    onTap: _showEditShopInfoDialog,
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey.shade400, width: 1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Icon(
                                        Icons.edit_note,
                                        size: 15,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'ประเภทอาหาร : $_category',
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  color: Color(0xFF4A4A4A),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'รหัสร้าน : $_shopCode',
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  color: Color(0xFF4A4A4A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                    const Divider(color: Color(0xFFECECEC), thickness: 1, height: 32),

                    // --- 2. ที่อยู่ ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'ที่อยู่',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        GestureDetector(
                          onTap: _showEditAddressDialog,
                          child: const Text(
                            'แก้ไข',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: accentPink,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Address + Map
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2.0),
                          child: Icon(
                            Icons.location_on_outlined,
                            color: maroonColor,
                            size: 19,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _address,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  color: Color(0xFF4A4A4A),
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _mapUrl,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  color: Color(0xFF2563EB),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Phone
                    Row(
                      children: [
                        const Icon(
                          Icons.phone_outlined,
                          color: maroonColor,
                          size: 19,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _phone,
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: Color(0xFF4A4A4A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Email
                    Row(
                      children: [
                        const Icon(
                          Icons.mail_outline,
                          color: maroonColor,
                          size: 19,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _email,
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: Color(0xFF4A4A4A),
                          ),
                        ),
                      ],
                    ),

                    const Divider(color: Color(0xFFECECEC), thickness: 1, height: 32),

                    // --- 3. เวลาเปิด - ปิดร้าน ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'เวลาเปิด - ปิดร้าน',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        GestureDetector(
                          onTap: _showEditHoursDialog,
                          child: const Text(
                            'แก้ไข',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: accentPink,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Opening Hours Table
                    ..._openingHours.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key,
                              style: const TextStyle(
                                fontSize: 13.5,
                                color: Color(0xFF4A4A4A),
                              ),
                            ),
                            Text(
                              entry.value,
                              style: const TextStyle(
                                fontSize: 13.5,
                                color: Color(0xFF4A4A4A),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const Divider(color: Color(0xFFECECEC), thickness: 1, height: 32),

                    // --- 4. สิ่งอำนวยความสะดวก ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'สิ่งอำนวยความสะดวก',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        GestureDetector(
                          onTap: _openEditFacilitiesScreen,
                          child: const Text(
                            'แก้ไข',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: accentPink,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Facilities List
                    if (_facilities.isEmpty)
                      const Text(
                        'ไม่มีข้อมูลสิ่งอำนวยความสะดวก (กดแก้ไขเพื่อเพิ่ม)',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      )
                    else
                      ..._facilities.map((fac) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Icon(
                                _getIconForFacility(fac),
                                color: maroonColor,
                                size: 18,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                fac,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  color: Color(0xFF4A4A4A),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                    // --- 5. สถานะร้านค้า (Shown in "ข้อมูลร้าน" with 3 distinct visual states) ---
                    if (_isSubmitted) ...[
                      const Divider(color: Color(0xFFECECEC), thickness: 1, height: 32),
                      _buildStatusStepper(),
                    ],

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // --- 6. ปุ่ม “ถัดไป” / “ตกลง” / “แก้ไขข้อมูลและส่งคำขอใหม่” ---
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _onBottomButtonPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: maroonColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        buttonText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  if (_isSubmitted && _status == 'rejected') ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                          (route) => false,
                        );
                      },
                      child: const Text(
                        'กลับสู่หน้าหลัก',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
