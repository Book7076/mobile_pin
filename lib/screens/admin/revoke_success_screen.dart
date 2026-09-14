import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/approval_restaurant.dart';

class RevokeSuccessScreen extends StatelessWidget {
  final ApprovalRestaurant restaurant;

  const RevokeSuccessScreen({
    super.key,
    required this.restaurant,
  });

  static const Color primaryBurgundy = Color(0xFF700F2B);
  static const Color successGreen = Color(0xFF00C853);
  static const Color textDark = Color(0xFF1E1E1E);
  static const Color textMuted = Color(0xFF6B6B6B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Spacer(flex: 3),

              // Emerald Green Scalloped Badge with Checkmark
              Center(
                child: CustomPaint(
                  size: const Size(120, 120),
                  painter: _ScallopCheckPainter(),
                ),
              ),

              const SizedBox(height: 32),

              // Title: ยกเลิกการอนุมัติสำเร็จ
              Text(
                'ยกเลิกการอนุมัติสำเร็จ',
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSansThai(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle: คำขอของคุณได้ถูกยกเลิกการอนุมัติเรียบร้อยแล้ว
              Text(
                'คำขอของคุณได้ถูกยกเลิกการอนุมัติเรียบร้อยแล้ว',
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSansThai(
                  fontSize: 14,
                  color: textMuted,
                  height: 1.4,
                ),
              ),

              const Spacer(flex: 4),

              // Bottom Button: กลับหน้าจัดการร้านอาหาร
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate back to the admin dashboard
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBurgundy,
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shadowColor: primaryBurgundy.withValues(alpha: 0.35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(27),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScallopCheckPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius - 10;
    const numPoints = 12;

    final path = Path();
    for (int i = 0; i < numPoints * 2; i++) {
      final radius = (i % 2 == 0) ? outerRadius : innerRadius;
      final angle = (i * pi) / numPoints;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    // Outline stroke of the scalloped badge
    final borderPaint = Paint()
      ..color = const Color(0xFF00C853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, borderPaint);

    // Green Checkmark inside
    final checkPaint = Paint()
      ..color = const Color(0xFF00C853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final checkPath = Path();
    checkPath.moveTo(size.width * 0.35, size.height * 0.52);
    checkPath.lineTo(size.width * 0.48, size.height * 0.65);
    checkPath.lineTo(size.width * 0.68, size.height * 0.38);

    canvas.drawPath(checkPath, checkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
