import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin_dashboard.dart';

class ApprovalActionSuccessScreen extends StatelessWidget {
  final bool isApproved; // true for อนุมัติสำเร็จ, false for ไม่อนุมัติสำเร็จ

  const ApprovalActionSuccessScreen({
    super.key,
    required this.isApproved,
  });

  static const Color primaryBurgundy = Color(0xFF700F2B);
  static const Color emeraldGreen = Color(0xFF00B368);

  @override
  Widget build(BuildContext context) {
    final title = isApproved ? 'อนุมัติสำเร็จ' : 'ไม่อนุมัติสำเร็จ';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Authentic Green Scalloped Seal with Checkmark
              CustomPaint(
                size: const Size(120, 120),
                painter: _ScallopedCheckmarkPainter(),
              ),

              const SizedBox(height: 28),

              // Title
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSansThai(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1A1A),
                  letterSpacing: -0.2,
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle
              Text(
                'คำขอของคุณเรียบร้อยแล้ว',
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSansThai(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF757575),
                ),
              ),

              const Spacer(),

              // Bottom Button: กลับหน้าจัดการร้านอาหาร
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate back to AdminDashboard with Store Management Tab (index 1)
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const AdminDashboard(initialTabIndex: 1),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBurgundy,
                    foregroundColor: Colors.white,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: Text(
                    'กลับหน้าจัดการร้านอาหาร',
                    style: GoogleFonts.notoSansThai(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

/// CustomPainter drawing the green scalloped seal with white checkmark
class _ScallopedCheckmarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.44;

    final sealPaint = Paint()
      ..color = const Color(0xFF00B368)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Draw 8-petal / scalloped circle
    final path = Path();
    const int numPetals = 8;
    const double step = (math.pi * 2) / numPetals;

    for (int i = 0; i < numPetals; i++) {
      final double angle = i * step;
      final double nextAngle = (i + 1) * step;
      final double midAngle = angle + step / 2;

      final double outerR = r * 1.06;
      final double innerR = r * 0.88;

      final double x0 = cx + math.cos(angle) * innerR;
      final double y0 = cy + math.sin(angle) * innerR;

      final double cx1 = cx + math.cos(midAngle) * outerR;
      final double cy1 = cy + math.sin(midAngle) * outerR;

      final double x1 = cx + math.cos(nextAngle) * innerR;
      final double y1 = cy + math.sin(nextAngle) * innerR;

      if (i == 0) {
        path.moveTo(x0, y0);
      }
      path.quadraticBezierTo(cx1, cy1, x1, y1);
    }
    path.close();
    canvas.drawPath(path, sealPaint);

    // Draw White Checkmark
    final checkPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    final checkPath = Path();
    checkPath.moveTo(cx - r * 0.36, cy + r * 0.02);
    checkPath.lineTo(cx - r * 0.08, cy + r * 0.32);
    checkPath.lineTo(cx + r * 0.40, cy - r * 0.28);

    canvas.drawPath(checkPath, checkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
