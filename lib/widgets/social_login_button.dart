import 'dart:math' as math;
import 'package:flutter/material.dart';

class SocialLoginButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  final Color backgroundColor;
  final BoxBorder? border;

  const SocialLoginButton({
    super.key,
    required this.onTap,
    required this.child,
    this.backgroundColor = Colors.white,
    this.border,
  });

  factory SocialLoginButton.facebook({
    Key? key,
    required VoidCallback onTap,
  }) {
    return SocialLoginButton(
      key: key,
      onTap: onTap,
      backgroundColor: const Color(0xFF1877F2),
      child: const CustomPaint(
        size: Size(26, 26),
        painter: _FacebookIconPainter(),
      ),
    );
  }

  factory SocialLoginButton.google({
    Key? key,
    required VoidCallback onTap,
  }) {
    return SocialLoginButton(
      key: key,
      onTap: onTap,
      backgroundColor: Colors.white,
      border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
      child: const CustomPaint(
        size: Size(26, 26),
        painter: _GoogleIconPainter(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            border: border,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}

class _FacebookIconPainter extends CustomPainter {
  const _FacebookIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final w = size.width;
    final h = size.height;

    // Classic bold lowercase 'f'
    final path = Path();
    path.moveTo(w * 0.55, h * 0.95);
    path.lineTo(w * 0.55, h * 0.52);
    path.lineTo(w * 0.70, h * 0.52);
    path.lineTo(w * 0.73, h * 0.36);
    path.lineTo(w * 0.55, h * 0.36);
    path.lineTo(w * 0.55, h * 0.25);
    path.cubicTo(w * 0.55, h * 0.17, w * 0.60, h * 0.13, w * 0.72, h * 0.13);
    path.lineTo(w * 0.78, h * 0.13);
    path.lineTo(w * 0.78, 0.0);
    path.cubicTo(w * 0.70, 0.0, w * 0.58, 0.02, w * 0.47, 0.08);
    path.cubicTo(w * 0.38, 0.13, w * 0.36, 0.23, w * 0.36, 0.33);
    path.lineTo(w * 0.36, h * 0.36);
    path.lineTo(w * 0.22, h * 0.36);
    path.lineTo(w * 0.22, h * 0.52);
    path.lineTo(w * 0.36, h * 0.52);
    path.lineTo(w * 0.36, h * 0.95);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GoogleIconPainter extends CustomPainter {
  const _GoogleIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = size.width / 2;
    final strokeWidth = size.width * 0.21;

    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius - strokeWidth / 2);

    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt
      ..isAntiAlias = true;

    final greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt
      ..isAntiAlias = true;

    final yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt
      ..isAntiAlias = true;

    final redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt
      ..isAntiAlias = true;

    // Draw Google arcs:
    // Red: Top arc (from 215 to 330 deg approx)
    canvas.drawArc(rect, -math.pi * 0.85, math.pi * 0.60, false, redPaint);

    // Yellow: Left arc (from 135 to 215 deg approx)
    canvas.drawArc(rect, math.pi * 0.75, math.pi * 0.40, false, yellowPaint);

    // Green: Bottom arc (from 35 to 135 deg approx)
    canvas.drawArc(rect, math.pi * 0.15, math.pi * 0.60, false, greenPaint);

    // Blue: Right arc (from -25 to 35 deg approx)
    canvas.drawArc(rect, -math.pi * 0.15, math.pi * 0.30, false, bluePaint);

    // Blue horizontal bar
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final barRect = Rect.fromLTRB(
      cx - 1,
      cy - strokeWidth / 2,
      cx + radius,
      cy + strokeWidth / 2,
    );
    canvas.drawRRect(RRect.fromRectAndRadius(barRect, const Radius.circular(1)), barPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
