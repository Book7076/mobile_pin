import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../providers/restaurant_provider.dart';
import 'category_selection_screen.dart';
import 'selected_restaurants_screen.dart';

/// Screen "result - ปัดหมด ยังไม่ครบ 5 ร้าน"
/// Shown when all cards are swiped or user taps "ถัดไป" with fewer than 5 liked restaurants.
class IncompleteResultScreen extends ConsumerWidget {
  final int likedCount;

  const IncompleteResultScreen({
    super.key,
    required this.likedCount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundWarm,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Sad Face with Tear Icon (matching Mockup)
              CustomPaint(
                size: const Size(100, 100),
                painter: _SadFacePainter(color: AppConstants.burgundyPrimary),
              ),

              const SizedBox(height: 28),

              // Texts matching Mockup
              Text(
                'คุณเลือกได้ $likedCount ร้าน',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppConstants.burgundyPrimary,
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                'จากทั้งหมดที่มี',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.burgundyPrimary,
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 1),

              // Button 1: "ดูผลลัพธ์เลย"
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const SelectedRestaurantsScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.burgundyPrimary,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'ดูผลลัพธ์เลย',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Button 2: "ค้นหาร้านเพิ่มเติม 🔍"
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    // Reset swipe session and navigate to categories / budget to broaden filters
                    ref.read(swipeSessionProvider.notifier).reset();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const CategorySelectionScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.burgundyPrimary,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'ค้นหาร้านเพิ่มเติม',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.search_rounded, size: 22, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter to draw the circular sad face with tear matching mockup
class _SadFacePainter extends CustomPainter {
  final Color color;

  _SadFacePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Outer circle
    canvas.drawCircle(center, radius, strokePaint);

    // Two circle eyes
    final eyeRadius = 5.0;
    final leftEye = Offset(center.dx - 18, center.dy - 10);
    final rightEye = Offset(center.dx + 18, center.dy - 10);
    canvas.drawCircle(leftEye, eyeRadius, fillPaint);
    canvas.drawCircle(rightEye, eyeRadius, fillPaint);

    // Downward curved sad mouth
    final mouthRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy + 25),
      width: 32,
      height: 24,
    );
    canvas.drawArc(mouthRect, 3.14159, 3.14159, false, strokePaint);

    // Teardrop falling under right eye
    final tearPath = Path();
    final tearCenter = Offset(rightEye.dx + 6, rightEye.dy + 16);
    tearPath.moveTo(tearCenter.dx, tearCenter.dy - 5);
    tearPath.quadraticBezierTo(
      tearCenter.dx + 4,
      tearCenter.dy + 2,
      tearCenter.dx,
      tearCenter.dy + 6,
    );
    tearPath.quadraticBezierTo(
      tearCenter.dx - 4,
      tearCenter.dy + 2,
      tearCenter.dx,
      tearCenter.dy - 5,
    );
    canvas.drawPath(tearPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
