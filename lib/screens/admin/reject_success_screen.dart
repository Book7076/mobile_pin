import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'admin_dashboard.dart';

class RejectSuccessScreen extends StatelessWidget {
  const RejectSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // 1. ตราสัญลักษณ์ขอบหยักมนสีเขียวมรกต พร้อมเครื่องหมายถูกสีขาว (ตรงตามภาพที่ 1)
              const Center(
                child: ScallopedCheckBadge(size: 116),
              ),
              const SizedBox(height: 28),

              // 2. หัวข้อ "ไม่อนุมัติสำเร็จ"
              const Text(
                'ไม่อนุมัติสำเร็จ',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E1E),
                  letterSpacing: -0.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // 3. คำอธิบาย "คำขอของคุณเรียบร้อยแล้ว"
              const Text(
                'คำขอของคุณเรียบร้อยแล้ว',
                style: TextStyle(
                  fontSize: 14.5,
                  color: Color(0xFF666666),
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 3),

              // 4. ปุ่ม "กลับหน้าจัดการร้านอาหาร" สีแดงเบอร์กันดีเข้ม (ตรงตามภาพที่ 1)
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    // นำทางกลับสู่หน้าจัดการร้านอาหาร (แท็บรออนุมัติ)
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const AdminDashboard(initialTabIndex: 1),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF800F2F),
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shadowColor: Colors.black.withOpacity(0.18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'กลับหน้าจัดการร้านอาหาร',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.2,
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

/// ตราสัญลักษณ์ขอบหยักมนสีเขียว (Scalloped Badge) ตรงตามภาพที่ 1
class ScallopedCheckBadge extends StatelessWidget {
  final double size;

  const ScallopedCheckBadge({
    super.key,
    this.size = 116,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _ScallopedBadgePainter(
              color: const Color(0xFF00C269),
              petals: 10,
            ),
          ),
          Icon(
            Icons.check_rounded,
            color: Colors.white,
            size: size * 0.52,
          ),
        ],
      ),
    );
  }
}

class _ScallopedBadgePainter extends CustomPainter {
  final Color color;
  final int petals;

  _ScallopedBadgePainter({
    required this.color,
    this.petals = 10,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width / 2;
    final rOuter = baseRadius * 0.98;
    final rInner = baseRadius * 0.84;

    final path = Path();
    final double step = (math.pi * 2) / (petals * 2);

    for (int i = 0; i < petals * 2; i++) {
      final double angle = i * step;
      final double nextAngle = (i + 1) * step;
      final double midAngle = (angle + nextAngle) / 2;

      final double rCurrent = (i % 2 == 0) ? rOuter : rInner;
      final double rNext = ((i + 1) % 2 == 0) ? rOuter : rInner;

      final pCurrent = Offset(
        center.dx + rCurrent * math.cos(angle),
        center.dy + rCurrent * math.sin(angle),
      );

      final pNext = Offset(
        center.dx + rNext * math.cos(nextAngle),
        center.dy + rNext * math.sin(nextAngle),
      );

      // ควบคุมความโค้งมนของกลีบดอกไม้ (Scallop)
      final rControl = (rCurrent + rNext) / 2 * 1.06;
      final pControl = Offset(
        center.dx + rControl * math.cos(midAngle),
        center.dy + rControl * math.sin(midAngle),
      );

      if (i == 0) {
        path.moveTo(pCurrent.dx, pCurrent.dy);
      }
      path.quadraticBezierTo(pControl.dx, pControl.dy, pNext.dx, pNext.dy);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ScallopedBadgePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.petals != petals;
  }
}
