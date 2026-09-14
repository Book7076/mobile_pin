import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class RestaurantDetailScreen extends StatelessWidget {
  final int rank;
  final String name;
  final String category;
  final int likes;
  final String? imageUrl;
  final String address;
  final String phone;
  final String openingHours;
  final String description;
  final List<String> signatureDishes;

  const RestaurantDetailScreen({
    super.key,
    required this.rank,
    required this.name,
    required this.category,
    required this.likes,
    this.imageUrl,
    this.address = '123 ถนนสุขุมวิท แขวงคลองเตย เขตคลองเตย กรุงเทพมหานคร 10110',
    this.phone = '081-234-5678',
    this.openingHours = '10:00 - 21:00 น. (ทุกวัน)',
    this.description = 'ร้านอาหารยอดนิยมที่ผ่านการคัดสรรวัตถุดิบคุณภาพ รสชาติเข้มข้นจัดจ้าน บริการเป็นกันเอง และมียอดผู้ปัดถูกใจสูงสุดในระบบ',
    this.signatureDishes = const [
      'เมนูซิกเนเจอร์ยอดฮิต',
      'ชุดอาหารพิเศษประจำวัน',
      'เครื่องดื่มและของหวาน',
    ],
  });

  static const Color primaryBurgundy = Color(0xFF700F2B);
  static const Color cardBorderColor = Color(0xFFF4E5EB);

  Future<void> _makePhoneCall(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: primaryBurgundy, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'รายละเอียดร้านค้า',
          style: GoogleFonts.notoSansThai(
            color: primaryBurgundy,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Image
            Stack(
              children: [
                Container(
                  height: 220,
                  width: double.infinity,
                  color: const Color(0xFFF0E4E8),
                  child: imageUrl != null && imageUrl!.isNotEmpty
                      ? Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                        )
                      : _buildPlaceholder(),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: primaryBurgundy,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'อันดับที่ $rank',
                          style: GoogleFonts.notoSansThai(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Likes Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: cardBorderColor, width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: primaryBurgundy.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: GoogleFonts.notoSansThai(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF1E1E1E),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9EEF2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  category,
                                  style: GoogleFonts.notoSansThai(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: primaryBurgundy,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '$likes',
                              style: GoogleFonts.notoSansThai(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: primaryBurgundy,
                              ),
                            ),
                            Text(
                              'จำนวนถูกใจ',
                              style: GoogleFonts.notoSansThai(
                                fontSize: 12,
                                color: const Color(0xFF757575),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: cardBorderColor, width: 1.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ข้อมูลร้านค้า',
                          style: GoogleFonts.notoSansThai(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: primaryBurgundy,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildInfoRow(
                          Icons.location_on_outlined,
                          'ที่อยู่',
                          address,
                        ),
                        const Divider(height: 24, color: Color(0xFFF5E8ED)),
                        _buildInfoRow(
                          Icons.phone_outlined,
                          'เบอร์โทรศัพท์',
                          phone,
                          trailing: TextButton.icon(
                            onPressed: () => _makePhoneCall(phone),
                            icon: const Icon(Icons.call, size: 16, color: primaryBurgundy),
                            label: Text(
                              'โทร',
                              style: GoogleFonts.notoSansThai(
                                color: primaryBurgundy,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFFF9EEF2),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const Divider(height: 24, color: Color(0xFFF5E8ED)),
                        _buildInfoRow(
                          Icons.access_time_rounded,
                          'เวลาทำการ',
                          openingHours,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Description Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: cardBorderColor, width: 1.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'รายละเอียดและเมนูแนะนำ',
                          style: GoogleFonts.notoSansThai(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: primaryBurgundy,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          description,
                          style: GoogleFonts.notoSansThai(
                            fontSize: 14,
                            color: const Color(0xFF555555),
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: signatureDishes.map((dish) {
                            return Chip(
                              backgroundColor: const Color(0xFFFBF2F5),
                              side: const BorderSide(color: Color(0xFFF4D8E2)),
                              label: Text(
                                dish,
                                style: GoogleFonts.notoSansThai(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: primaryBurgundy,
                                ),
                              ),
                              avatar: const Icon(Icons.restaurant_menu, size: 14, color: primaryBurgundy),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.restaurant_rounded,
        size: 70,
        color: primaryBurgundy.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value, {Widget? trailing}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: primaryBurgundy),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.notoSansThai(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF888888),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.notoSansThai(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF222222),
                ),
              ),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}
