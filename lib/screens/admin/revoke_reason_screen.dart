import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/approval_restaurant.dart';
import '../../providers/restaurant_approval_provider.dart';
import 'revoke_success_screen.dart';

class RevokeReasonScreen extends ConsumerStatefulWidget {
  final ApprovalRestaurant restaurant;

  const RevokeReasonScreen({
    super.key,
    required this.restaurant,
  });

  @override
  ConsumerState<RevokeReasonScreen> createState() => _RevokeReasonScreenState();
}

class _RevokeReasonScreenState extends ConsumerState<RevokeReasonScreen> {
  final TextEditingController _reasonController = TextEditingController();
  bool _hasError = false;

  static const Color primaryBurgundy = Color(0xFF700F2B);
  static const Color textDark = Color(0xFF1E1E1E);
  static const Color textMuted = Color(0xFF6B6B6B);

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _submitReason() {
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      setState(() => _hasError = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'กรุณาระบุเหตุผลในการยกเลิกอนุมัติ',
            style: GoogleFonts.notoSansThai(),
          ),
          backgroundColor: primaryBurgundy,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    // Update state to revoked in Riverpod provider
    ref.read(restaurantApprovalProvider.notifier).revokeApproval(
          widget.restaurant.id,
          reason,
        );

    // Navigate to success screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => RevokeSuccessScreen(restaurant: widget.restaurant),
      ),
    );
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
          'กรอกเหตุผล',
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Chat bubble with star graphic
              _buildChatBubbleIllustration(),

              const SizedBox(height: 24),

              // Title: กรุณาระบุเหตุผล
              Text(
                'กรุณาระบุเหตุผล',
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSansThai(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                'เพื่อแจ้งให้เจ้าของร้านทราบถึงเหตุผล\nของการยกเลิกอนุมัติ',
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSansThai(
                  fontSize: 13.5,
                  color: textMuted,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 28),

              // Reason Label
              Align(
                alignment: Alignment.centerLeft,
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.notoSansThai(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: textDark,
                    ),
                    children: const [
                      TextSpan(text: 'เหตุผลในการยกเลิกอนุมัติ '),
                      TextSpan(text: '*', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Text Area Input
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _reasonController,
                  maxLines: 4,
                  minLines: 4,
                  onChanged: (val) {
                    if (_hasError && val.trim().isNotEmpty) {
                      setState(() => _hasError = false);
                    }
                  },
                  style: GoogleFonts.notoSansThai(fontSize: 14, color: textDark),
                  decoration: InputDecoration(
                    hintText: 'ระบุรายละเอียดเพิ่มเติม...',
                    hintStyle: GoogleFonts.notoSansThai(fontSize: 13, color: const Color(0xFF9E9E9E)),
                    contentPadding: const EdgeInsets.all(16),
                    filled: true,
                    fillColor: Colors.white,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: _hasError ? Colors.red : const Color(0xFF9E2A4B).withValues(alpha: 0.5),
                        width: 1.2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: primaryBurgundy,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Button 1: ส่งเหตุผล
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submitReason,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBurgundy,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: Text(
                    'ส่งเหตุผล',
                    style: GoogleFonts.notoSansThai(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Button 2: ยกเลิก
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBurgundy,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: Text(
                    'ยกเลิก',
                    style: GoogleFonts.notoSansThai(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatBubbleIllustration() {
    return SizedBox(
      width: 130,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pastel Pink Speech Bubble
          Container(
            width: 96,
            height: 84,
            decoration: BoxDecoration(
              color: const Color(0xFFFDECEF),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFDECEF).withValues(alpha: 0.8),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
          ),
          // Chat bubble bottom tail
          Positioned(
            bottom: 12,
            left: 20,
            child: Transform.rotate(
              angle: 0.4,
              child: Container(
                width: 18,
                height: 18,
                color: const Color(0xFFFDECEF),
              ),
            ),
          ),
          // Sparkle 4-point star at top-right
          Positioned(
            top: 4,
            right: 12,
            child: CustomPaint(
              size: const Size(36, 36),
              painter: _SparkleStarPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SparkleStarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFCDDE3)
      ..style = PaintingStyle.fill;

    final path = Path();
    final cx = size.width / 2;
    final cy = size.height / 2;
    final w = size.width;
    final h = size.height;

    path.moveTo(cx, 0);
    path.quadraticBezierTo(cx, cy, w, cy);
    path.quadraticBezierTo(cx, cy, cx, h);
    path.quadraticBezierTo(cx, cy, 0, cy);
    path.quadraticBezierTo(cx, cy, cx, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
