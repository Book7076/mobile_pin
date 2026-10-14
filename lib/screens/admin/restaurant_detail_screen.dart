import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/restaurant_admin_model.dart';
import '../../models/approval_restaurant.dart';
import '../../providers/restaurant_approval_provider.dart';
import '../../services/admin_restaurant_service.dart';
import 'admin_theme.dart';
import 'cancel_rejection_screen.dart';
import 'confirm_revoke_screen.dart';
import 'reject_success_screen.dart';
import 'widgets/restaurant_logo_badge.dart';

class RestaurantDetailScreen extends ConsumerStatefulWidget {
  final String restaurantId;

  const RestaurantDetailScreen({
    super.key,
    required this.restaurantId,
  });

  @override
  ConsumerState<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends ConsumerState<RestaurantDetailScreen> {
  bool _isProcessing = false;

  // --- Image 2: Dialog ยืนยันการไม่อนุมัติ (Reject Confirmation Dialog) ---
  void _showRejectConfirmationDialog(RestaurantAdminModel restaurant) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. หัวข้อ Dialog
              const Text(
                'ยืนยันการไม่อนุมัติ',
                style: TextStyle(
                  fontSize: 18.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B0E17),
                  letterSpacing: -0.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),

              // 2. ไอคอนวงกลมสีแดงเข้มพร้อมกากบาทสีขาว (ตรงตามภาพที่ 2)
              Container(
                width: 66,
                height: 66,
                decoration: const BoxDecoration(
                  color: Color(0xFF8B0E17),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 3. ข้อความยืนยัน
              const Text(
                'คุณต้องการไม่อนุมัติตร้านนี้หรือไม่',
                style: TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF4A4A4A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                restaurant.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E1E),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // 4. ปุ่มกดยกเลิก และ ยืนยัน (ตรงตามภาพที่ 2)
              Row(
                children: [
                  // ปุ่มยกเลิก (พื้นสีชมพูอ่อน ตัวหนังสือสีแดงเข้ม)
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(dialogCtx).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF8E8E8),
                          foregroundColor: const Color(0xFF7B182D),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text(
                          'ยกเลิก',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // ปุ่มยืนยัน (พื้นสีแดงเข้ม ตัวหนังสือสีขาว) -> นำไปยัง Dialog ระบุเหตุผล
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogCtx).pop();
                          _showRejectReasonDialog(restaurant);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B0E17),
                          foregroundColor: Colors.white,
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text(
                          'ยืนยัน',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Image 2: Dialog ระบุเหตุผลในการไม่อนุมัติ (Reject Reason Dialog) ---
  void _showRejectReasonDialog(RestaurantAdminModel restaurant) {
    String? selectedReason;
    final additionalDetailsController = TextEditingController();
    String? errorMessage;

    final List<String> reasonOptions = [
      'ร้านค้าไม่มีอยู่จริง',
      'ไม่พบที่ตั้ง',
      'อื่นๆ',
    ];

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (reasonCtx) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
          backgroundColor: const Color(0xFFFAFAFA),
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. หัวข้อ Dialog: "ไม่อนุมัติร้าน"
                  const Center(
                    child: Text(
                      'ไม่อนุมัติร้าน',
                      style: TextStyle(
                        fontSize: 18.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B0E17),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 2. ป้ายกำกับ: "กรุณาระบุเหตุผลในการไม่อนุมัติ *"
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1E1E),
                      ),
                      children: [
                        TextSpan(text: 'กรุณาระบุเหตุผลในการไม่อนุมัติ '),
                        TextSpan(
                          text: '*',
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 3. กล่อง Dropdown เลือกเหตุผล (ตรงตามภาพใหม่)
                  Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: errorMessage != null ? Colors.red : const Color(0xFF8B0E17),
                        width: 1.2,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedReason,
                        isExpanded: true,
                        hint: const Text(
                          'เลือกเหตุผล',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF555555),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFF222222),
                          size: 24,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        items: reasonOptions.map((reason) {
                          return DropdownMenuItem<String>(
                            value: reason,
                            child: Text(
                              reason,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF222222),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setDialogState(() {
                            selectedReason = val;
                            errorMessage = null;
                          });
                        },
                      ),
                    ),
                  ),

                  // แสดง Error ถ้ายังไม่ได้เลือกเหตุผล
                  if (errorMessage != null) ...[
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 6.0),
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 11.5),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),

                  // 4. ป้ายกำกับ: "รายละเอียดเพิ่มเติม (ถ้ามี)"
                  const Text(
                    'รายละเอียดเพิ่มเติม (ถ้ามี)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 5. กล่องข้อความกรอกรายละเอียดเพิ่มเติม
                  Container(
                    height: 96,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF8B0E17),
                        width: 1.2,
                      ),
                    ),
                    child: TextField(
                      controller: additionalDetailsController,
                      maxLines: 4,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF222222)),
                      decoration: const InputDecoration(
                        hintText: 'ระบุรายละเอียดเพิ่มเติม...',
                        hintStyle: TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF9E9E9E),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 6. ปุ่มกดยกเลิก และ ยืนยัน
                  Row(
                    children: [
                      // ปุ่มยกเลิก
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(reasonCtx).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF8E8E8),
                              foregroundColor: const Color(0xFF7B182D),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: const Text(
                              'ยกเลิก',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // ปุ่มยืนยัน
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (selectedReason == null) {
                                setDialogState(() {
                                  errorMessage = 'กรุณาเลือกเหตุผลในการไม่อนุมัติ';
                                });
                                return;
                              }

                              final details = additionalDetailsController.text.trim();
                              final fullReason = details.isNotEmpty
                                  ? '$selectedReason ($details)'
                                  : selectedReason!;

                              Navigator.of(reasonCtx).pop();
                              setState(() => _isProcessing = true);

                              final success = await ref
                                  .read(adminRestaurantProvider.notifier)
                                  .rejectRestaurant(restaurant.id, fullReason);

                              if (mounted) {
                                setState(() => _isProcessing = false);
                                if (success && context.mounted) {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) => const RejectSuccessScreen(),
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8B0E17),
                              foregroundColor: Colors.white,
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: const Text(
                              'ยืนยัน',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Dialog ยืนยันการอนุมัติ (Confirm Approval Dialog) ---
  void _showApproveConfirmDialog(RestaurantAdminModel restaurant) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: const [
            Icon(Icons.check_circle_rounded, color: Color(0xFF1B5E38), size: 26),
            SizedBox(width: 8),
            Text(
              'ยืนยันการอนุมัติร้านค้า',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          'คุณต้องการอนุมัติร้าน "${restaurant.name}" ให้เปิดให้บริการบนแอปพลิเคชัน Meaimate ใช่หรือไม่?',
          style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              setState(() => _isProcessing = true);
              final success = await ref
                  .read(adminRestaurantProvider.notifier)
                  .approveRestaurant(restaurant.id);
              if (mounted) {
                setState(() => _isProcessing = false);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('อนุมัติร้าน "${restaurant.name}" เรียบร้อยแล้ว'),
                      backgroundColor: const Color(0xFF1B5E38),
                    ),
                  );
                  Navigator.of(context).pop();
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B5E38),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('ยืนยันอนุมัติ', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final restaurants = ref.watch(adminRestaurantProvider);
    final approvalList = ref.watch(restaurantApprovalProvider);
    final appMatch = approvalList.where((r) => r.id == widget.restaurantId).firstOrNull;
    final restaurant = restaurants.firstWhere(
      (r) => r.id == widget.restaurantId || (appMatch != null && r.name == appMatch.name),
      orElse: () => appMatch != null
          ? RestaurantAdminModel(
              id: appMatch.id,
              ownerId: '',
              name: appMatch.name,
              storeCode: appMatch.code,
              address: appMatch.address,
              phone: appMatch.phone,
              status: appMatch.status,
              createdAt: DateTime.now(),
              rejectionReason: appMatch.rejectionReason,
              category: appMatch.category,
              mapUrl: appMatch.mapUrl,
              imageUrl: appMatch.imageAsset,
            )
          : RestaurantAdminModel(
              id: '',
              ownerId: '',
              name: 'ไม่พบข้อมูล',
              address: '',
              phone: '',
              status: 'pending',
              createdAt: DateTime.now(),
            ),
    );

    if (restaurant.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('รายละเอียดร้านอาหาร')),
        body: const Center(child: Text('ไม่พบข้อมูลร้านค้านี้')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left_rounded,
            color: AdminTheme.primaryMaroon,
            size: 32,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'รายละเอียดร้านอาหาร',
          style: TextStyle(
            color: AdminTheme.primaryMaroon,
            fontWeight: FontWeight.bold,
            fontSize: 19,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1, color: Color(0xFFF2E6E8)),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 100),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. ส่วนหัวข้อมูลร้านค้า (ตรงตามภาพที่ 1)
                _buildRestaurantHeader(restaurant),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFF0E5E7)),
                const SizedBox(height: 16),

                // 2. ส่วน "ที่อยู่ ช่องทางติดต่อ" (ตรงตามภาพที่ 1)
                _buildAddressContactSection(restaurant),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFF0E5E7)),
                const SizedBox(height: 16),

                // 3. ส่วน "เวลาเปิด-ปิด" (ตรงตามภาพที่ 1)
                _buildOpeningHoursSection(restaurant),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFF0E5E7)),
                const SizedBox(height: 16),

                // 4. ส่วน "สิ่งอำนวยความสะดวก" (ตรงตามภาพที่ 1)
                _buildAmenitiesSection(restaurant),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFF0E5E7)),
                const SizedBox(height: 16),

                // 5. ส่วน "เมนูอาหาร" (ตรงตามภาพที่ 1)
                _buildMenuItemsSection(restaurant),

                // ส่วน "สาเหตุที่ไม่อนุมัติ" (แสดงเมื่อสถานะเป็น rejected ตามภาพที่ 1 ขวา)
                if (restaurant.status == 'rejected') ...[
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: Color(0xFFF0E5E7)),
                  const SizedBox(height: 16),
                  _buildRejectionReasonSection(restaurant),
                ],
              ],
            ),
          ),

          // 6. แถบปุ่มลอยด้านล่าง: "อนุมัติ" & "ไม่อนุมัติ" (ตรงตามภาพที่ 1)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomActionBar(restaurant),
          ),

          if (_isProcessing)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: AdminTheme.primaryMaroon),
              ),
            ),
        ],
      ),
    );
  }

  /// 1. ส่วนหัวร้านค้า: รูปร้าน, ชื่อร้าน, ประเภทร้าน, รหัสร้าน
  Widget _buildRestaurantHeader(RestaurantAdminModel restaurant) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // รูปร้านค้า
        RestaurantLogoBadge(
          name: restaurant.name,
          imageUrl: restaurant.imageUrl,
          size: 96,
        ),
        const SizedBox(width: 16),

        // ข้อมูลชื่อและรหัสร้าน
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                restaurant.name,
                style: const TextStyle(
                  fontSize: 18.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E1E),
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'ประเภทร้านอาหาร : ${restaurant.category ?? "เครื่องดื่ม/คาเฟ่"}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF333333),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'รหัสร้าน : ${restaurant.storeCode ?? "111U1103"}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF555555),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 2. ที่อยู่ ช่องทางติดต่อ: ไอคอนหมุดปัก ที่อยู่ เว็บไซต์ และเบอร์โทร
  Widget _buildAddressContactSection(RestaurantAdminModel restaurant) {
    final mapUrl = restaurant.mapUrl ?? 'www.googlemap.com';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ที่อยู่ ช่องทางติดต่อ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E1E1E),
          ),
        ),
        const SizedBox(height: 12),

        // แถวที่อยู่และแผนที่
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 2.0),
              child: Icon(
                Icons.location_on_outlined,
                color: AdminTheme.primaryMaroon,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.address,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF4A4A4A),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    mapUrl,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF1A73E8),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // แถวเบอร์โทรศัพท์
        Row(
          children: [
            const Icon(
              Icons.phone_outlined,
              color: AdminTheme.primaryMaroon,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              restaurant.phone,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF4A4A4A),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 3. เวลาเปิด-ปิด: แสดงครบ 7 วัน
  Widget _buildOpeningHoursSection(RestaurantAdminModel restaurant) {
    final hours = restaurant.openingHours ?? {
      'อาทิตย์': '08.00 - 21.00',
      'จันทร์': '08.00 - 21.00',
      'อังคาร': '08.00 - 21.00',
      'พุธ': '08.00 - 21.00',
      'พฤหัสบดี': '08.00 - 21.00',
      'ศุกร์': '08.00 - 21.00',
      'เสาร์': '08.00 - 21.00',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'เวลาเปิด-ปิด',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E1E1E),
          ),
        ),
        const SizedBox(height: 10),
        ...hours.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  entry.key,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF4A4A4A),
                  ),
                ),
                Text(
                  entry.value,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF4A4A4A),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  /// 4. สิ่งอำนวยความสะดวก: ที่จอดรถยนต์, รถจักรยานยนต์, มีอินเทอร์เน็ต, เครื่องปรับอากาศ (ตรงตามภาพที่ 1 ขวา)
  Widget _buildAmenitiesSection(RestaurantAdminModel restaurant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'สิ่งอำนวยความสะดวก',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E1E1E),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildAmenityCard(
                icon: Icons.directions_car_outlined,
                label: 'ที่จอดรถยนต์',
              ),
              const SizedBox(width: 12),
              _buildAmenityCard(
                icon: Icons.pedal_bike_outlined,
                label: 'รถจักรยานยนต์',
              ),
              const SizedBox(width: 12),
              _buildAmenityCard(
                icon: Icons.wifi_rounded,
                label: 'มีอินเทอร์เน็ต',
              ),
              const SizedBox(width: 12),
              _buildAmenityCard(
                icon: Icons.ac_unit_rounded,
                label: 'เครื่องปรับอากาศ',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmenityCard({required IconData icon, required String label}) {
    return Container(
      width: 82,
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E5EA), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AdminTheme.primaryMaroon, size: 26),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// 5. เมนูอาหาร: ชีสเค้ก, ชิโอะปัง, ทาร์ตไข่ หรือ เมนูเครื่องดื่ม
  Widget _buildMenuItemsSection(RestaurantAdminModel restaurant) {
    final menuItems = restaurant.menuItems.isNotEmpty
        ? restaurant.menuItems
        : [
            const RestaurantMenuItem(name: 'ชีสเค้ก', price: 50, description: 'มีส่วนประกอบของนมวัว, ไข่'),
            const RestaurantMenuItem(name: 'ชิโอะปัง', price: 35, description: 'มีส่วนประกอบของแป้งสาลี, นมวัว, ไข่'),
            const RestaurantMenuItem(name: 'ทาร์ตไข่', price: 20, description: 'มีส่วนประกอบของแป้งสาลี, นมวัว, ไข่'),
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'เมนูอาหาร',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E1E1E),
          ),
        ),
        const SizedBox(height: 14),
        ...menuItems.map((item) => _buildMenuItemTile(item)),
      ],
    );
  }

  Widget _buildMenuItemTile(RestaurantMenuItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // รูปเมนูอาหารทรงมน
          _buildFoodImageBadge(item.name, item.imageUrl),
          const SizedBox(width: 16),

          // รายละเอียดเมนูและราคา
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF222222),
                  ),
                ),
                if (item.description != null && item.description!.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    item.description!,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF757575),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  '฿${item.price}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// รูปภาพเมนูอาหารหรือเครื่องดื่ม
  Widget _buildFoodImageBadge(String name, String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Container(
        width: 78,
        height: 78,
        decoration: BoxDecoration(
          color: const Color(0xFFFBF4EB),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFEFE6DC)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.network(
          imageUrl,
          width: 78,
          height: 78,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildFallbackFoodBadge(name),
        ),
      );
    }
    return _buildFallbackFoodBadge(name);
  }

  Widget _buildFallbackFoodBadge(String name) {
    Color badgeBg = const Color(0xFFFBF4EB);
    IconData iconData = Icons.bakery_dining_rounded;
    Color iconColor = const Color(0xFF8D5B28);

    if (name.contains('Matcha') || name.contains('Earl Grey') || name.contains('Ocean')) {
      badgeBg = const Color(0xFFF1F8EE);
      iconData = Icons.local_cafe_rounded;
      iconColor = const Color(0xFF437A55);
    }

    return Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        color: badgeBg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Center(
        child: Icon(iconData, color: iconColor, size: 36),
      ),
    );
  }

  /// ส่วน "สาเหตุที่ไม่อนุมัติ" (ตรงตามภาพที่ 1 ขวา)
  Widget _buildRejectionReasonSection(RestaurantAdminModel restaurant) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'สาเหตุที่ไม่อนุมัติ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E1E1E),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          restaurant.rejectionReason ?? 'ที่อยู่ไม่ถูกต้อง',
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF4A4A4A),
            height: 1.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'ผู้รับผิดชอบ: ${restaurant.reviewerName ?? "ปนัสยา"}',
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF555555),
          ),
        ),
      ],
    );
  }

  /// 6. แถบปุ่มลอยด้านล่าง:
  /// - หากสถานะเป็น 'rejected': แสดงปุ่ม "ยกเลิกการไม่อนุมัติ" สีแดงเบอร์กันดี (ตรงตามภาพที่ 1 ขวา)
  /// - หากสถานะเป็น 'pending': แสดงปุ่มคู่ "อนุมัติ" & "ไม่อนุมัติ"
  Widget _buildBottomActionBar(RestaurantAdminModel restaurant) {
    // สถานะไม่อนุมัติ (Rejected) -> ปุ่ม "ยกเลิกการไม่อนุมัติ" ปุ่มเดี่ยวตรงตามภาพที่ 1
    if (restaurant.status == 'rejected') {
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CancelRejectionScreen(
                      restaurantId: restaurant.id,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF800F2F),
                foregroundColor: Colors.white,
                elevation: 2,
                shadowColor: Colors.black.withValues(alpha: 0.15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              child: const Text(
                'ยกเลิกการไม่อนุมัติ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // สถานะอนุมัติแล้ว (Approved) -> ปุ่ม "ยกเลิกการอนุมัติ"
    if (restaurant.status == 'approved') {
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                final allApproval = ref.read(restaurantApprovalProvider);
                final appMatch = allApproval
                    .where((a) => a.id == restaurant.id || a.name == restaurant.name)
                    .firstOrNull;
                final approvalRest = appMatch ?? ApprovalRestaurant.fromAdminModel(restaurant);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ConfirmRevokeScreen(restaurant: approvalRest),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF800F2F),
                foregroundColor: Colors.white,
                elevation: 2,
                shadowColor: Colors.black.withValues(alpha: 0.15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              child: const Text(
                'ยกเลิกการอนุมัติ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // สถานะรออนุมัติ (Pending) -> ปุ่มคู่ อนุมัติ & ไม่อนุมัติ
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // ปุ่ม "อนุมัติ" (พื้นเขียวมิ้นต์อ่อน ตัวหนังสือสีเขียวเข้ม)
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () => _showApproveConfirmDialog(restaurant),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD6F5E8),
                    foregroundColor: const Color(0xFF1B5E38),
                    elevation: 2,
                    shadowColor: Colors.black.withValues(alpha: 0.08),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: const Text(
                    'อนุมัติ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // ปุ่ม "ไม่อนุมัติ" (พื้นสีชมพูอ่อน ตัวหนังสือสีแดงเข้ม)
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () => _showRejectConfirmationDialog(restaurant),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFDE8E8),
                    foregroundColor: const Color(0xFF8B1826),
                    elevation: 2,
                    shadowColor: Colors.black.withValues(alpha: 0.08),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: const Text(
                    'ไม่อนุมัติ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
