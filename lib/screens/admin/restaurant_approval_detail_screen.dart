import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/approval_restaurant.dart';
import '../../providers/restaurant_approval_provider.dart';
import '../../services/admin_restaurant_service.dart';
import 'approval_action_success_screen.dart';
import 'cancel_rejection_screen.dart';
import 'confirm_revoke_screen.dart';

class RestaurantApprovalDetailScreen extends ConsumerWidget {
  final ApprovalRestaurant restaurant;

  const RestaurantApprovalDetailScreen({
    super.key,
    required this.restaurant,
  });

  static const Color primaryBurgundy = Color(0xFF700F2B);
  static const Color burgundyDark = Color(0xFF8B0D23);
  static const Color dividerColor = Color(0xFFF3E7EC);
  static const Color textDark = Color(0xFF1E1E1E);
  static const Color textMuted = Color(0xFF6B6B6B);
  static const Color mintGreenBg = Color(0xFFD7F5E8);
  static const Color mintGreenText = Color(0xFF007A4D);
  static const Color pinkButtonBg = Color(0xFFFFEBEF);
  static const Color pinkButtonText = Color(0xFF8B0D23);

  Future<void> _launchMap(BuildContext context) async {
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(restaurant.address)}');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (_) {}
  }

  // ==================== 1. APPROVAL CONFIRM DIALOG ====================
  void _showApproveConfirmDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ยืนยันการอนุมัติ',
                  style: GoogleFonts.notoSansThai(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: primaryBurgundy,
                  ),
                ),
                const SizedBox(height: 20),
                // Circular Green Check Badge
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00B368),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'คุณต้องการอนุมัติร้านนี้หรือไม่',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSansThai(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF444444),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  restaurant.name,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSansThai(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF9EEF2),
                            foregroundColor: primaryBurgundy,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(23),
                            ),
                          ),
                          child: Text(
                            'ยกเลิก',
                            style: GoogleFonts.notoSansThai(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: primaryBurgundy,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(dialogContext); // Close dialog
                            ref.read(restaurantApprovalProvider.notifier).approveRestaurant(restaurant.id);
                            try {
                              final adminMatch = ref.read(adminRestaurantProvider).where((a) => a.id == restaurant.id || a.name == restaurant.name).firstOrNull;
                              if (adminMatch != null) {
                                ref.read(adminRestaurantProvider.notifier).approveRestaurant(adminMatch.id);
                              }
                            } catch (_) {}
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ApprovalActionSuccessScreen(isApproved: true),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: burgundyDark,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(23),
                            ),
                          ),
                          child: Text(
                            'ยืนยัน',
                            style: GoogleFonts.notoSansThai(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
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
        );
      },
    );
  }

  // ==================== 2. REJECT CONFIRM DIALOG ====================
  void _showRejectConfirmDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ยืนยันการไม่อนุมัติ',
                  style: GoogleFonts.notoSansThai(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: primaryBurgundy,
                  ),
                ),
                const SizedBox(height: 20),
                // Circular Red Close Badge
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFFA50B28),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'คุณต้องการไม่อนุมัติร้านนี้หรือไม่',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSansThai(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF444444),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  restaurant.name,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSansThai(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF9EEF2),
                            foregroundColor: primaryBurgundy,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(23),
                            ),
                          ),
                          child: Text(
                            'ยกเลิก',
                            style: GoogleFonts.notoSansThai(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: primaryBurgundy,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(dialogContext); // Close confirm dialog
                            // Open reason selection dialog
                            _showRejectReasonDialog(context, ref);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: burgundyDark,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(23),
                            ),
                          ),
                          child: Text(
                            'ยืนยัน',
                            style: GoogleFonts.notoSansThai(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
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
        );
      },
    );
  }

  // ==================== 3. REJECT REASON DIALOG ====================
  void _showRejectReasonDialog(BuildContext context, WidgetRef ref) {
    String? selectedReason;
    final detailsController = TextEditingController();
    final reasonsList = ['ร้านค้าไม่มีอยู่จริง', 'ไม่พบที่ตั้ง', 'อื่น ๆ'];

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isConfirmEnabled = selectedReason != null && selectedReason!.isNotEmpty;

            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 26, 22, 24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'ไม่อนุมัติร้าน',
                          style: GoogleFonts.notoSansThai(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: primaryBurgundy,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Label: กรุณาระบุเหตุผลในการไม่อนุมัติ *
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.notoSansThai(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E1E1E),
                          ),
                          children: const [
                            TextSpan(text: 'กรุณาระบุเหตุผลในการไม่อนุมัติ '),
                            TextSpan(text: '*', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Dropdown Menu Container
                      Container(
                        height: 46,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFB57082), width: 1.2),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: Text(
                              'เลือกเหตุผล',
                              style: GoogleFonts.notoSansThai(
                                fontSize: 13,
                                color: const Color(0xFF6B6B6B),
                              ),
                            ),
                            value: selectedReason,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF333333)),
                            items: reasonsList.map((reason) {
                              return DropdownMenuItem<String>(
                                value: reason,
                                child: Text(
                                  reason,
                                  style: GoogleFonts.notoSansThai(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF1E1E1E),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setDialogState(() {
                                selectedReason = val;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Label: รายละเอียดเพิ่มเติม (ถ้ามี)
                      Text(
                        'รายละเอียดเพิ่มเติม (ถ้ามี)',
                        style: GoogleFonts.notoSansThai(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E1E1E),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Multi-line TextField
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFB57082), width: 1.2),
                        ),
                        child: TextField(
                          controller: detailsController,
                          maxLines: 4,
                          style: GoogleFonts.notoSansThai(fontSize: 13, color: textDark),
                          decoration: InputDecoration(
                            hintText: 'ระบุรายละเอียดเพิ่มเติม...',
                            hintStyle: GoogleFonts.notoSansThai(
                              fontSize: 12.5,
                              color: const Color(0xFF9E9E9E),
                            ),
                            contentPadding: const EdgeInsets.all(12),
                            border: InputBorder.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 46,
                              child: ElevatedButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF9EEF2),
                                  foregroundColor: primaryBurgundy,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(23),
                                  ),
                                ),
                                child: Text(
                                  'ยกเลิก',
                                  style: GoogleFonts.notoSansThai(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: primaryBurgundy,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: SizedBox(
                              height: 46,
                              child: ElevatedButton(
                                onPressed: isConfirmEnabled
                                    ? () {
                                        Navigator.pop(dialogContext); // Close dialog
                                        ref.read(restaurantApprovalProvider.notifier).rejectRestaurant(
                                              restaurant.id,
                                              selectedReason!,
                                              details: detailsController.text.trim(),
                                            );
                                        try {
                                          final adminMatch = ref.read(adminRestaurantProvider).where((a) => a.id == restaurant.id || a.name == restaurant.name).firstOrNull;
                                          if (adminMatch != null) {
                                            ref.read(adminRestaurantProvider.notifier).rejectRestaurant(adminMatch.id, selectedReason!);
                                          }
                                        } catch (_) {}
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const ApprovalActionSuccessScreen(isApproved: false),
                                          ),
                                        );
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: burgundyDark,
                                  disabledBackgroundColor: burgundyDark.withValues(alpha: 0.5),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(23),
                                  ),
                                ),
                                child: Text(
                                  'ยืนยัน',
                                  style: GoogleFonts.notoSansThai(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
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
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPending = restaurant.status == 'pending';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: primaryBurgundy, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'รายละเอียดร้านอาหาร',
          style: GoogleFonts.notoSansThai(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: primaryBurgundy,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: dividerColor, height: 1),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Card: Restaurant Image & basic info matching Image 3
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: 80,
                            height: 80,
                            color: const Color(0xFFF9EEF2),
                            child: restaurant.imageAsset.startsWith('http')
                                ? Image.network(
                                    restaurant.imageAsset,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      width: 80,
                                      height: 80,
                                      color: const Color(0xFFF9EEF2),
                                      child: const Icon(Icons.storefront_rounded, color: primaryBurgundy, size: 36),
                                    ),
                                  )
                                : Image.asset(
                                    restaurant.imageAsset,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      width: 80,
                                      height: 80,
                                      color: const Color(0xFFF9EEF2),
                                      child: const Icon(Icons.storefront_rounded, color: primaryBurgundy, size: 36),
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                restaurant.name,
                                style: GoogleFonts.notoSansThai(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: textDark,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'ประเภทร้านอาหาร : ${restaurant.category}',
                                style: GoogleFonts.notoSansThai(
                                  fontSize: 13,
                                  color: const Color(0xFF4A4A4A),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'รหัสร้าน : ${restaurant.code}',
                                style: GoogleFonts.notoSansThai(
                                  fontSize: 13,
                                  color: const Color(0xFF4A4A4A),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Divider(color: dividerColor, height: 1),
                    const SizedBox(height: 16),

                    if (restaurant.rejectionReason != null &&
                        restaurant.rejectionReason!.trim().isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF2F4),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFFCD3D9)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.info_outline_rounded,
                                    color: primaryBurgundy, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'สาเหตุที่ไม่อนุมัติ',
                                  style: GoogleFonts.notoSansThai(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: primaryBurgundy,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              restaurant.rejectionReason!,
                              style: GoogleFonts.notoSansThai(
                                fontSize: 13,
                                color: const Color(0xFF333333),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Section: ที่อยู่ ช่องทางติดต่อ
                    Text(
                      'ที่อยู่ ช่องทางติดต่อ',
                      style: GoogleFonts.notoSansThai(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_outlined, size: 20, color: primaryBurgundy),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                restaurant.address,
                                style: GoogleFonts.notoSansThai(
                                  fontSize: 13,
                                  color: textMuted,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 2),
                              GestureDetector(
                                onTap: () => _launchMap(context),
                                child: Text(
                                  restaurant.mapUrl,
                                  style: GoogleFonts.notoSansThai(
                                    fontSize: 13,
                                    color: const Color(0xFF3868C6),
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
                    Row(
                      children: [
                        const Icon(Icons.phone_outlined, size: 20, color: primaryBurgundy),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _makePhoneCall(restaurant.phone),
                          child: Text(
                            restaurant.phone,
                            style: GoogleFonts.notoSansThai(
                              fontSize: 13,
                              color: textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Divider(color: dividerColor, height: 1),
                    const SizedBox(height: 16),

                    // Section: เวลาเปิด-ปิด
                    Text(
                      'เวลาเปิด-ปิด',
                      style: GoogleFonts.notoSansThai(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...restaurant.openingHours.entries.map((e) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              e.key,
                              style: GoogleFonts.notoSansThai(
                                fontSize: 13,
                                color: textMuted,
                              ),
                            ),
                            Text(
                              e.value,
                              style: GoogleFonts.notoSansThai(
                                fontSize: 13,
                                color: textMuted,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 16),
                    const Divider(color: dividerColor, height: 1),
                    const SizedBox(height: 16),

                    // Section: สิ่งอำนวยความสะดวก
                    Text(
                      'สิ่งอำนวยความสะดวก',
                      style: GoogleFonts.notoSansThai(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildAmenityBox(Icons.directions_bike_rounded, 'รถจักรยานยนต์'),
                        if (restaurant.amenities.contains('มีอินเทอร์เน็ต')) ...[
                          const SizedBox(width: 14),
                          _buildAmenityBox(Icons.wifi_rounded, 'มีอินเทอร์เน็ต'),
                        ],
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Divider(color: dividerColor, height: 1),
                    const SizedBox(height: 16),

                    // Section: เมนูอาหาร
                    Text(
                      'เมนูอาหาร',
                      style: GoogleFonts.notoSansThai(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...restaurant.menuItems.map((menu) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                width: 72,
                                height: 72,
                                color: const Color(0xFFF9EEF2),
                                child: menu.imageAsset.startsWith('http')
                                    ? Image.network(
                                        menu.imageAsset,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          width: 72,
                                          height: 72,
                                          color: const Color(0xFFF9EEF2),
                                          child: const Icon(Icons.fastfood_rounded, color: primaryBurgundy, size: 30),
                                        ),
                                      )
                                    : Image.asset(
                                        menu.imageAsset,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          width: 72,
                                          height: 72,
                                          color: const Color(0xFFF9EEF2),
                                          child: const Icon(Icons.fastfood_rounded, color: primaryBurgundy, size: 30),
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    menu.name,
                                    style: GoogleFonts.notoSansThai(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    menu.price,
                                    style: GoogleFonts.notoSansThai(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: textDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Bottom Action Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
              child: isPending
                  ? Row(
                      children: [
                        // Left button: อนุมัติ (Mint Green)
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () => _showApproveConfirmDialog(context, ref),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: mintGreenBg,
                                foregroundColor: mintGreenText,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: Text(
                                'อนุมัติ',
                                style: GoogleFonts.notoSansThai(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: mintGreenText,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Right button: ไม่อนุมัติ (Soft Pink)
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () => _showRejectConfirmDialog(context, ref),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: pinkButtonBg,
                                foregroundColor: pinkButtonText,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: Text(
                                'ไม่อนุมัติ',
                                style: GoogleFonts.notoSansThai(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: pinkButtonText,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : (restaurant.status == 'rejected'
                      ? SizedBox(
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
                              backgroundColor: primaryBurgundy,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(26),
                              ),
                            ),
                            child: Text(
                              'ยกเลิกการไม่อนุมัติ',
                              style: GoogleFonts.notoSansThai(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      : SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ConfirmRevokeScreen(restaurant: restaurant),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryBurgundy,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(26),
                              ),
                            ),
                            child: Text(
                              'ยกเลิกการอนุมัติ',
                              style: GoogleFonts.notoSansThai(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmenityBox(IconData icon, String label) {
    return Container(
      constraints: const BoxConstraints(minWidth: 84, minHeight: 64),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3E7EC), width: 1.2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: primaryBurgundy),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.notoSansThai(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: textDark,
            ),
          ),
        ],
      ),
    );
  }
}
