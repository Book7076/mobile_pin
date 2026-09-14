import 'package:flutter/material.dart';

/// Custom vector illustration for Splash Screen 3:
/// Displays a modern character adjusting 3 category & budget sliders with icons.
class BudgetSliderIllustration extends StatelessWidget {
  final double width;
  final double height;

  const BudgetSliderIllustration({
    super.key,
    this.width = 300,
    this.height = 220,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        size: Size(width, height),
        painter: BudgetSliderPainter(),
      ),
    );
  }
}

class BudgetSliderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Reference canvas: 300 x 220
    final double scale = size.width / 300.0;
    canvas.save();
    canvas.scale(scale, scale);

    // Color palette
    const Color burgundy = Color(0xFF6E162B);
    const Color darkNavy = Color(0xFF10121C);
    const Color skinColor = Color(0xFFEFA899);
    const Color blouseColor = Color(0xFFE9E8EE);
    const Color sliderTrackColor = Color(0xFFECEBEF);
    const Color dollarColor = Color(0xFF9E9CA8);
    const Color iconColor = Color(0xFF1B1B26);

    // 1. Right Side: 3 Vertical Sliders with Icons
    // Slider 1: Store/Home
    _drawVerticalSlider(
      canvas,
      centerX: 215,
      topY: 55,
      width: 17,
      height: 105,
      fillRatio: 0.65,
      trackColor: sliderTrackColor,
      fillColor: burgundy,
      dollarColor: dollarColor,
    );
    _drawStoreIcon(canvas, 215, 172, iconColor);

    // Slider 2: Cocktail / Drink
    _drawVerticalSlider(
      canvas,
      centerX: 242,
      topY: 55,
      width: 17,
      height: 105,
      fillRatio: 0.36,
      trackColor: sliderTrackColor,
      fillColor: burgundy,
      dollarColor: dollarColor,
    );
    _drawGlassIcon(canvas, 242, 172, iconColor);

    // Slider 3: Food Bowl / Meal
    _drawVerticalSlider(
      canvas,
      centerX: 269,
      topY: 55,
      width: 17,
      height: 105,
      fillRatio: 0.82,
      trackColor: sliderTrackColor,
      fillColor: burgundy,
      dollarColor: dollarColor,
    );
    _drawBowlIcon(canvas, 269, 172, iconColor);

    // 2. Left Side: Character reaching out to slider
    _drawCharacter(
      canvas,
      darkNavy: darkNavy,
      skinColor: skinColor,
      blouseColor: blouseColor,
    );

    canvas.restore();
  }

  void _drawVerticalSlider(
    Canvas canvas, {
    required double centerX,
    required double topY,
    required double width,
    required double height,
    required double fillRatio,
    required Color trackColor,
    required Color fillColor,
    required Color dollarColor,
  }) {
    final double left = centerX - (width / 2);
    final RRect trackRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, topY, width, height),
      Radius.circular(width / 2),
    );

    // Track Background
    canvas.drawRRect(trackRRect, Paint()..color = trackColor);

    // Filled Progress Bar (from bottom up)
    final double fillH = height * fillRatio;
    final double fillTopY = topY + (height - fillH);
    final RRect fillRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, fillTopY, width, fillH),
      Radius.circular(width / 2),
    );

    // Clip to track to keep rounded corners
    canvas.save();
    canvas.clipRRect(trackRRect);
    canvas.drawRRect(fillRRect, Paint()..color = fillColor);
    canvas.restore();

    // Small "$" symbol inside the unfilled track at the top
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: '\$',
        style: TextStyle(
          color: dollarColor,
          fontSize: 8.5,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(centerX - (textPainter.width / 2), topY + 6.0),
    );
  }

  void _drawStoreIcon(Canvas canvas, double cx, double cy, Color color) {
    final Paint paint = Paint()..color = color;

    // Roof / Triangle
    final Path roof = Path();
    roof.moveTo(cx, cy - 4.5);
    roof.lineTo(cx + 4.5, cy - 1.0);
    roof.lineTo(cx - 4.5, cy - 1.0);
    roof.close();
    canvas.drawPath(roof, paint);

    // Base house
    canvas.drawRect(Rect.fromLTWH(cx - 3.5, cy - 1.0, 7.0, 5.0), paint);

    // Door cutout
    canvas.drawRect(
      Rect.fromLTWH(cx - 1.2, cy + 1.2, 2.4, 2.8),
      Paint()..color = Colors.white,
    );
  }

  void _drawGlassIcon(Canvas canvas, double cx, double cy, Color color) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1.3
      ..style = PaintingStyle.stroke;

    // Triangle Cocktail Glass
    final Path glass = Path();
    glass.moveTo(cx - 3.5, cy - 4.0);
    glass.lineTo(cx + 3.5, cy - 4.0);
    glass.lineTo(cx, cy);
    glass.close();
    canvas.drawPath(glass, paint);

    // Stem and Base
    canvas.drawLine(Offset(cx, cy), Offset(cx, cy + 3.5), paint);
    canvas.drawLine(Offset(cx - 2.5, cy + 3.5), Offset(cx + 2.5, cy + 3.5), paint);
  }

  void _drawBowlIcon(Canvas canvas, double cx, double cy, Color color) {
    final Paint paint = Paint()..color = color;

    // Bowl arc
    final Path bowl = Path();
    bowl.moveTo(cx - 4.0, cy - 1.0);
    bowl.lineTo(cx + 4.0, cy - 1.0);
    bowl.arcToPoint(
      Offset(cx - 4.0, cy - 1.0),
      radius: const Radius.circular(4.0),
      clockwise: false,
    );
    bowl.close();
    canvas.drawPath(bowl, paint);

    // Chopsticks / spoon angle
    final Paint stickPaint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx - 2.0, cy - 4.2), Offset(cx + 3.5, cy - 1.0), stickPaint);
  }

  void _drawCharacter(
    Canvas canvas, {
    required Color darkNavy,
    required Color skinColor,
    required Color blouseColor,
  }) {
    // 1. Head & Hair
    // Hair Bun at back
    canvas.drawCircle(const Offset(130, 89), 5.5, Paint()..color = darkNavy);

    // Head base (Skin)
    canvas.drawCircle(const Offset(140, 88), 9.0, Paint()..color = skinColor);

    // Hair Cap over head
    final Path hair = Path();
    hair.moveTo(133, 86);
    hair.cubicTo(133, 76, 147, 76, 149, 86);
    hair.cubicTo(149, 90, 140, 91, 133, 86);
    hair.close();
    canvas.drawPath(hair, Paint()..color = darkNavy);

    // Neck
    canvas.drawRect(const Rect.fromLTWH(138, 95, 6, 8), Paint()..color = skinColor);

    // 2. Skirt (Dark Navy)
    final Path skirt = Path();
    skirt.moveTo(127, 144);
    skirt.lineTo(151, 144);
    skirt.lineTo(154, 178);
    skirt.lineTo(123, 178);
    skirt.close();
    canvas.drawPath(skirt, Paint()..color = darkNavy);

    // 3. Torso / Blouse (Light Cream/Grey)
    final Path torso = Path();
    torso.moveTo(135, 102);
    torso.lineTo(149, 102);
    torso.lineTo(151, 144);
    torso.lineTo(127, 144);
    torso.lineTo(118, 114);
    torso.close();
    canvas.drawPath(torso, Paint()..color = blouseColor);

    // Left folded arm at side
    final Path leftArm = Path();
    leftArm.moveTo(122, 110);
    leftArm.lineTo(117, 136);
    leftArm.lineTo(127, 136);
    leftArm.lineTo(129, 118);
    leftArm.close();
    canvas.drawPath(leftArm, Paint()..color = blouseColor);

    // Left hand hint
    canvas.drawCircle(const Offset(122, 138), 3.5, Paint()..color = skinColor);

    // 4. Right Arm reaching out to the slider
    final Path rightArm = Path();
    rightArm.moveTo(148, 104);
    rightArm.lineTo(178, 120);
    rightArm.lineTo(213, 90);
    rightArm.lineTo(214, 83);
    rightArm.lineTo(176, 110);
    rightArm.lineTo(148, 98);
    rightArm.close();
    canvas.drawPath(rightArm, Paint()..color = blouseColor);

    // Right Hand touching the slider
    final Path hand = Path();
    hand.moveTo(212, 85);
    hand.lineTo(220, 82);
    hand.lineTo(221, 91);
    hand.lineTo(213, 92);
    hand.close();
    canvas.drawPath(hand, Paint()..color = skinColor);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
