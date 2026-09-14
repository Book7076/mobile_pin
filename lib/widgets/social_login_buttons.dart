import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Clean, professional circular buttons for Facebook and Google social login.
class SocialLoginButtons extends StatelessWidget {
  final VoidCallback onFacebookTap;
  final VoidCallback onGoogleTap;
  final bool isLoading;

  const SocialLoginButtons({
    super.key,
    required this.onFacebookTap,
    required this.onGoogleTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Facebook Button
        _SocialCircleButton(
          onTap: isLoading ? null : onFacebookTap,
          backgroundColor: const Color(0xFF1877F2),
          child: const CustomPaint(
            size: Size(26, 26),
            painter: FacebookLogoPainter(),
          ),
        ),

        const SizedBox(width: 24),

        // Google Button
        _SocialCircleButton(
          onTap: isLoading ? null : onGoogleTap,
          backgroundColor: Colors.white,
          border: Border.all(color: const Color(0xFFE5E5EB), width: 1.2),
          child: const CustomPaint(
            size: Size(26, 26),
            painter: GoogleLogoPainter(),
          ),
        ),
      ],
    );
  }
}

class _SocialCircleButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Color backgroundColor;
  final BoxBorder? border;
  final Widget child;

  const _SocialCircleButton({
    required this.onTap,
    required this.backgroundColor,
    this.border,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            border: border,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
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

/// Custom vector painter for the Facebook "f" logo
class FacebookLogoPainter extends CustomPainter {
  const FacebookLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Center coordinates for 26x26 canvas
    final Path fPath = Path();
    fPath.moveTo(17.5, 26);
    fPath.lineTo(17.5, 15.2);
    fPath.lineTo(21.1, 15.2);
    fPath.lineTo(21.7, 10.9);
    fPath.lineTo(17.5, 10.9);
    fPath.lineTo(17.5, 8.2);
    fPath.cubicTo(17.5, 6.9, 18.2, 5.7, 20.3, 5.7);
    fPath.lineTo(22.2, 5.7);
    fPath.lineTo(22.2, 2.0);
    fPath.cubicTo(21.8, 1.9, 20.6, 1.8, 19.2, 1.8);
    fPath.cubicTo(16.3, 1.8, 14.3, 3.6, 14.3, 6.8);
    fPath.lineTo(14.3, 10.9);
    fPath.lineTo(10.5, 10.9);
    fPath.lineTo(10.5, 15.2);
    fPath.lineTo(14.3, 15.2);
    fPath.lineTo(14.3, 26);
    fPath.close();

    canvas.drawPath(fPath, whitePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom vector painter for the 4-color official Google "G" logo
class GoogleLogoPainter extends CustomPainter {
  const GoogleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double midX = size.width / 2.0;
    final double midY = size.height / 2.0;
    final double outerR = size.width * 0.46;
    final double innerR = size.width * 0.23;

    // Palette
    const Color googleBlue = Color(0xFF4285F4);
    const Color googleGreen = Color(0xFF34A853);
    const Color googleYellow = Color(0xFFFBBC05);
    const Color googleRed = Color(0xFFEA4335);

    final Rect outerRect = Rect.fromCircle(center: Offset(midX, midY), radius: outerR);
    final Rect innerRect = Rect.fromCircle(center: Offset(midX, midY), radius: innerR);

    // 1. Blue Bar & Arc (starts at 0 radians = 3 o'clock)
    final Path bluePath = Path();
    bluePath.moveTo(midX, midY - innerR);
    bluePath.lineTo(midX + outerR, midY - innerR);
    bluePath.lineTo(midX + outerR, midY);
    bluePath.arcTo(outerRect, 0, math.pi / 4, false);
    bluePath.lineTo(midX + (innerR * math.cos(math.pi / 4)), midY + (innerR * math.sin(math.pi / 4)));
    bluePath.arcTo(innerRect, math.pi / 4, -math.pi / 4, false);
    bluePath.lineTo(midX, midY);
    bluePath.close();
    canvas.drawPath(bluePath, Paint()..color = googleBlue);

    // 2. Green Arc (bottom section: 45 to 135 degrees)
    final Path greenPath = Path();
    greenPath.arcTo(outerRect, math.pi / 4, math.pi / 2, false);
    greenPath.arcTo(innerRect, 3 * math.pi / 4, -math.pi / 2, false);
    greenPath.close();
    canvas.drawPath(greenPath, Paint()..color = googleGreen);

    // 3. Yellow Arc (left section: 135 to 225 degrees)
    final Path yellowPath = Path();
    yellowPath.arcTo(outerRect, 3 * math.pi / 4, math.pi / 2, false);
    yellowPath.arcTo(innerRect, 5 * math.pi / 4, -math.pi / 2, false);
    yellowPath.close();
    canvas.drawPath(yellowPath, Paint()..color = googleYellow);

    // 4. Red Arc (top section: 225 to 315 degrees)
    final Path redPath = Path();
    redPath.arcTo(outerRect, 5 * math.pi / 4, math.pi / 2, false);
    redPath.arcTo(innerRect, 7 * math.pi / 4, -math.pi / 2, false);
    redPath.close();
    canvas.drawPath(redPath, Paint()..color = googleRed);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
