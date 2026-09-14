import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/approval_restaurant.dart';
import 'confirm_revoke_screen.dart';

class RestaurantApprovalDetailScreen extends StatelessWidget {
  final ApprovalRestaurant restaurant;

  const RestaurantApprovalDetailScreen({
    super.key,
    required this.restaurant,
  });

  static const Color primaryBurgundy = Color(0xFF700F2B);
  static const Color dividerColor = Color(0xFFF3E7EC);
  static const Color textDark = Color(0xFF1E1E1E);
  static const Color textMuted = Color(0xFF6B6B6B);

  Future<void> _launchMap(BuildContext context) async {
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(restaurant.address)}');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
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
                    // Header Card: Restaurant Image & basic info
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            restaurant.imageAsset,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 80,
                              height: 80,
                              color: const Color(0xFFF9EEF2),
                              child: const Icon(Icons.store_rounded, color: primaryBurgundy, size: 36),
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
                                  color: textMuted,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'รหัสร้าน : ${restaurant.code}',
                                style: GoogleFonts.notoSansThai(
                                  fontSize: 13,
                                  color: textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),
                    const Divider(color: dividerColor, height: 1),
                    const SizedBox(height: 18),

                    // Section: Address & Contact
                    Text(
                      'ที่อยู่ ช่องทางติดต่อ',
                      style: GoogleFonts.notoSansThai(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_outlined, color: primaryBurgundy, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                restaurant.address,
                                style: GoogleFonts.notoSansThai(
                                  fontSize: 13,
                                  color: textMuted,
                                  height: 1.45,
                                ),
                              ),
                              const SizedBox(height: 4),
                              GestureDetector(
                                onTap: () => _launchMap(context),
                                child: Text(
                                  restaurant.mapUrl,
                                  style: GoogleFonts.notoSansThai(
                                    fontSize: 13,
                                    color: const Color(0xFF3B82F6),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.phone_outlined, color: primaryBurgundy, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          restaurant.phone,
                          style: GoogleFonts.notoSansThai(
                            fontSize: 13,
                            color: textMuted,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),
                    const Divider(color: dividerColor, height: 1),
                    const SizedBox(height: 18),

                    // Section: Opening Hours
                    Text(
                      'เวลาเปิด-ปิด',
                      style: GoogleFonts.notoSansThai(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...restaurant.openingHours.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3.5),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 84,
                              child: Text(
                                entry.key,
                                style: GoogleFonts.notoSansThai(
                                  fontSize: 13,
                                  color: textMuted,
                                ),
                              ),
                            ),
                            Text(
                              entry.value,
                              style: GoogleFonts.notoSansThai(
                                fontSize: 13,
                                color: textMuted,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 18),
                    const Divider(color: dividerColor, height: 1),
                    const SizedBox(height: 18),

                    // Section: Amenities
                    Text(
                      'สิ่งอำนวยความสะดวก',
                      style: GoogleFonts.notoSansThai(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE8D3DC)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.two_wheeler_rounded, color: primaryBurgundy, size: 28),
                          const SizedBox(height: 4),
                          Text(
                            'รถจักรยานยนต์',
                            style: GoogleFonts.notoSansThai(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: textDark,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),
                    const Divider(color: dividerColor, height: 1),
                    const SizedBox(height: 18),

                    // Section: Menu items
                    Text(
                      'เมนูอาหาร',
                      style: GoogleFonts.notoSansThai(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...restaurant.menuItems.map((menu) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.asset(
                                menu.imageAsset,
                                width: 72,
                                height: 72,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: 72,
                                  height: 72,
                                  color: const Color(0xFFF9EEF2),
                                  child: const Icon(Icons.restaurant_rounded, color: primaryBurgundy),
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
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                      color: textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    menu.ingredients,
                                    style: GoogleFonts.notoSansThai(
                                      fontSize: 11.5,
                                      color: textMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    menu.price,
                                    style: GoogleFonts.notoSansThai(
                                      fontSize: 14.5,
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

            // Bottom Action Button: ยกเลิกการอนุมัติ
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
