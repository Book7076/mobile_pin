import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/approval_restaurant.dart';
import 'revoke_reason_screen.dart';

class ConfirmRevokeScreen extends StatelessWidget {
  final ApprovalRestaurant restaurant;

  const ConfirmRevokeScreen({
    super.key,
    required this.restaurant,
  });

  static const Color primaryBurgundy = Color(0xFF700F2B);
  static const Color textDark = Color(0xFF1E1E1E);
  static const Color textMuted = Color(0xFF6B6B6B);

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
          'ยกเลิกการอนุมัติ',
          style: GoogleFonts.notoSansThai(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: primaryBurgundy,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Spacer(flex: 1),

              // Rejection Document Illustration
              _buildDocumentIllustration(),

              const SizedBox(height: 28),

              // Title: ยืนยันการยกเลิกอนุมัติ
              Text(
                'ยืนยันการยกเลิกอนุมัติ',
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSansThai(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 10),

              // Subtitle
              Text(
                'คุณกำลังจะยกเลิกการอนุมัติร้านนี้\nกรุณาตรวจสอบข้อมูลให้ถูกต้องก่อนดำเนินการ',
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSansThai(
                  fontSize: 13.5,
                  color: textMuted,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 28),

              // Restaurant Info Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFEFEFEF)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ข้อมูลร้าน',
                      style: GoogleFonts.notoSansThai(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'ชื่อร้าน : ${restaurant.name}',
                      style: GoogleFonts.notoSansThai(
                        fontSize: 13.5,
                        color: const Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'รหัสร้าน : ${restaurant.code}',
                      style: GoogleFonts.notoSansThai(
                        fontSize: 13.5,
                        color: const Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'วันที่ส่งคำขอ : ${restaurant.requestDate}',
                      style: GoogleFonts.notoSansThai(
                        fontSize: 13.5,
                        color: const Color(0xFF333333),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // Bottom Button: ยืนยันยกเลิกการอนุมัติ
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => RevokeReasonScreen(restaurant: restaurant),
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
                      'ยืนยันยกเลิกการอนุมัติ',
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
      ),
    );
  }

  Widget _buildDocumentIllustration() {
    return SizedBox(
      width: 130,
      height: 130,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Document Background
          Container(
            width: 90,
            height: 110,
            decoration: BoxDecoration(
              color: primaryBurgundy,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
                topRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryBurgundy.withValues(alpha: 0.22),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
          ),
          // Top-right folded corner cut
          Positioned(
            top: 10,
            right: 20,
            child: CustomPaint(
              size: const Size(26, 26),
              painter: _CornerFoldPainter(),
            ),
          ),
          // Rejection Badge (Circle with X at bottom-right)
          Positioned(
            bottom: 4,
            right: 12,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.close_rounded,
                  color: primaryBurgundy,
                  size: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CornerFoldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(0, 0)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
