import 'dart:math' as math;
import 'package:flutter/material.dart';

/// ตราสัญลักษณ์ขอบหยักมนสีเขียวมรกต พร้อมเครื่องหมายถูกสีขาว
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
