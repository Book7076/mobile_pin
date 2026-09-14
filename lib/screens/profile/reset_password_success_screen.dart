import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ResetPasswordSuccessScreen extends StatefulWidget {
  const ResetPasswordSuccessScreen({super.key});

  @override
  State<ResetPasswordSuccessScreen> createState() => _ResetPasswordSuccessScreenState();
}

class _ResetPasswordSuccessScreenState extends State<ResetPasswordSuccessScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  void _returnToEditProfile() {
    // Pop back to EditUserProfileScreen
    int count = 0;
    Navigator.of(context).popUntil((route) {
      return count++ == 4 || route.isFirst;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              // Vertically Centered Content
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Green Scalloped Checkmark Badge
                      SizedBox(
                        width: 106,
                        height: 106,
                        child: CustomPaint(
                          painter: _ScallopedCheckPainter(
                            color: const Color(0xFF52B76E),
                            strokeWidth: 6.0,
                          ),
                        ),
                      ),

                      const SizedBox(height: 26),

                      // Success Title Text
                      const Text(
                        'แก้ไขรหัสผ่านสำเร็จ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E1E1E),
                          letterSpacing: -0.2,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Subtitle Text
                      const Text(
                        'รหัสผ่านของคุณถูกเปลี่ยนเรียบร้อยแล้ว\nใช้รหัสผ่านใหม่ในการเข้าสู่ระบบครั้งต่อไป',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.8,
                          color: Color(0xFF777777),
                          height: 1.45,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Button: กลับสู่หน้าโปรไฟล์ (returns to Edit Profile Screen)
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6E162B),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26), // Pill shape matching reference
                      ),
                      shadowColor: const Color(0x336E162B),
                    ),
                    onPressed: _returnToEditProfile,
                    child: const Text(
                      'กลับสู่หน้าโปรไฟล์',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
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

class _ScallopedCheckPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _ScallopedCheckPainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Draw 8-lobed scalloped badge outline
    const int lobes = 8;
    const double rOuter = 46.0;
    const double rInner = 38.0;
    final path = Path();

    for (int i = 0; i < lobes; i++) {
      final double angle1 = (i * 2 * math.pi / lobes) - (math.pi / 2);
      final double angleMid = angle1 + (math.pi / lobes);
      final double angle2 = angle1 + (2 * math.pi / lobes);

      final pStart = Offset(
        center.dx + rInner * math.cos(angle1),
        center.dy + rInner * math.sin(angle1),
      );
      final pControl = Offset(
        center.dx + (rOuter * 1.15) * math.cos(angleMid),
        center.dy + (rOuter * 1.15) * math.sin(angleMid),
      );
      final pEnd = Offset(
        center.dx + rInner * math.cos(angle2),
        center.dy + rInner * math.sin(angle2),
      );

      if (i == 0) {
        path.moveTo(pStart.dx, pStart.dy);
      }
      path.quadraticBezierTo(pControl.dx, pControl.dy, pEnd.dx, pEnd.dy);
    }
    path.close();
    canvas.drawPath(path, paint);

    // Draw Checkmark in the center
    final checkPath = Path();
    checkPath.moveTo(center.dx - 15, center.dy + 1);
    checkPath.lineTo(center.dx - 3, center.dy + 14);
    checkPath.lineTo(center.dx + 18, center.dy - 11);

    canvas.drawPath(checkPath, paint);
  }

  @override
  bool shouldRepaint(covariant _ScallopedCheckPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}
