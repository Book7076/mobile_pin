import 'package:flutter/material.dart';

/// Custom vector illustration for Splash Screen 2:
/// Displays the breakfast plate with fried egg, sausages, fries, sauce bottle, and iced drink.
class FoodPlateIllustration extends StatelessWidget {
  final double width;
  final double height;

  const FoodPlateIllustration({
    super.key,
    this.width = 300,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        size: Size(width, height),
        painter: FoodPlatePainter(),
      ),
    );
  }
}

class FoodPlatePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Reference coordinate canvas: 300 x 200
    final double scale = size.width / 300.0;
    canvas.save();
    canvas.scale(scale, scale);

    const double baselineY = 172.0;

    // Palette
    const Color burgundy = Color(0xFF6E162B);
    const Color darkCharcoal = Color(0xFF2B283A);
    const Color tableLineColor = Color(0xFF676476);
    const Color eggWhiteColor = Color(0xFFFFFFFF);
    const Color eggYolkColor = Color(0xFFF7BD38);
    const Color sausageColor = Color(0xFFEB8488);
    const Color sausageLineColor = Color(0xFFB55D61);
    const Color fryColor = Color(0xFFF6B942);
    const Color beanColor = Color(0xFFD46D73);

    // 1. Baseline Table Line
    final Paint linePaint = Paint()
      ..color = tableLineColor
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(const Offset(10, baselineY), const Offset(290, baselineY), linePaint);

    // 2. Left: Sauce Bottle (Center X ~ 45, Bottom ~ 172)
    _drawSauceBottle(canvas, 45, baselineY, darkCharcoal, burgundy);

    // 3. Right: Iced Drink Glass (Center X ~ 255, Bottom ~ 172)
    _drawIcedDrink(canvas, 255, baselineY, darkCharcoal, burgundy);

    // 4. Center: Big Plate (Center: 150, 126, Radius ~ 58)
    _drawFoodPlate(
      canvas,
      centerX: 150,
      centerY: 126,
      radius: 58,
      burgundy: burgundy,
      darkCharcoal: darkCharcoal,
      eggWhiteColor: eggWhiteColor,
      eggYolkColor: eggYolkColor,
      sausageColor: sausageColor,
      sausageLineColor: sausageLineColor,
      fryColor: fryColor,
      beanColor: beanColor,
    );

    canvas.restore();
  }

  void _drawSauceBottle(
    Canvas canvas,
    double cx,
    double baseY,
    Color charcoal,
    Color burgundy,
  ) {
    final Paint bottlePaint = Paint()..color = charcoal;
    final Paint saucePaint = Paint()..color = burgundy;

    // Bottle cap
    final RRect cap = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - 4.5, baseY - 88, 9, 8),
      const Radius.circular(2),
    );
    canvas.drawRRect(cap, Paint()..color = burgundy);

    // Bottle neck
    final Rect neck = Rect.fromLTWH(cx - 3.5, baseY - 80, 7, 18);
    canvas.drawRect(neck, bottlePaint);

    // Bottle body path
    final Path body = Path();
    body.moveTo(cx - 3.5, baseY - 62);
    body.lineTo(cx - 10.5, baseY - 46);
    body.lineTo(cx - 11.5, baseY);
    body.lineTo(cx + 11.5, baseY);
    body.lineTo(cx + 10.5, baseY - 46);
    body.lineTo(cx + 3.5, baseY - 62);
    body.close();
    canvas.drawPath(body, bottlePaint);

    // Sauce window / label inside bottle
    final Path sauce = Path();
    sauce.moveTo(cx - 8, baseY - 40);
    sauce.lineTo(cx - 9, baseY - 8);
    sauce.lineTo(cx + 9, baseY - 8);
    sauce.lineTo(cx + 8, baseY - 40);
    sauce.close();
    canvas.drawPath(sauce, saucePaint);
  }

  void _drawIcedDrink(
    Canvas canvas,
    double cx,
    double baseY,
    Color charcoal,
    Color burgundy,
  ) {
    final Paint drinkPaint = Paint()..color = charcoal;

    // Straw (burgundy with charcoal outline)
    final Path straw = Path();
    straw.moveTo(cx - 1.5, baseY - 90);
    straw.lineTo(cx + 1.5, baseY - 90);
    straw.lineTo(cx + 1.5, baseY - 40);
    straw.lineTo(cx - 1.5, baseY - 40);
    straw.close();
    canvas.drawPath(straw, Paint()..color = burgundy);

    // Glass body (trapezoid tapering to bottom)
    final Path glass = Path();
    const double topW = 28.0;
    const double botW = 22.0;
    const double glassH = 68.0;
    final double topY = baseY - glassH;

    glass.moveTo(cx - (topW / 2), topY);
    glass.lineTo(cx + (topW / 2), topY);
    glass.lineTo(cx + (botW / 2), baseY);
    glass.lineTo(cx - (botW / 2), baseY);
    glass.close();
    canvas.drawPath(glass, drinkPaint);

    // Ice cubes (floating white angled squares)
    final Paint icePaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.fill;

    _drawAngledCube(canvas, cx - 4, baseY - 50, 7, 0.2, icePaint);
    _drawAngledCube(canvas, cx + 5, baseY - 44, 6.5, -0.3, icePaint);
    _drawAngledCube(canvas, cx - 2, baseY - 32, 7.5, 0.4, icePaint);
    _drawAngledCube(canvas, cx + 4, baseY - 20, 6.5, -0.15, icePaint);
  }

  void _drawAngledCube(
    Canvas canvas,
    double x,
    double y,
    double size,
    double angle,
    Paint paint,
  ) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(angle);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: size, height: size),
        const Radius.circular(1.5),
      ),
      paint,
    );
    canvas.restore();
  }

  void _drawFoodPlate(
    Canvas canvas, {
    required double centerX,
    required double centerY,
    required double radius,
    required Color burgundy,
    required Color darkCharcoal,
    required Color eggWhiteColor,
    required Color eggYolkColor,
    required Color sausageColor,
    required Color sausageLineColor,
    required Color fryColor,
    required Color beanColor,
  }) {
    // 1. Outer Burgundy Plate Rim
    final Paint plateRimPaint = Paint()..color = burgundy;
    canvas.drawCircle(Offset(centerX, centerY), radius, plateRimPaint);

    // 2. Inner Dark Slate Plate
    final Paint innerPlatePaint = Paint()..color = darkCharcoal;
    canvas.drawCircle(Offset(centerX, centerY), radius - 10.0, innerPlatePaint);

    // 3. Sunny Side Up Egg (Top Right of inner plate)
    final double eggCenterX = centerX + 16.0;
    final double eggCenterY = centerY - 14.0;

    // Organic Egg White Shape
    final Path eggWhite = Path();
    eggWhite.addOval(
      Rect.fromCenter(
        center: Offset(eggCenterX, eggCenterY),
        width: 38.0,
        height: 35.0,
      ),
    );
    canvas.drawPath(eggWhite, Paint()..color = eggWhiteColor);

    // Egg Yolk
    canvas.drawCircle(
      Offset(eggCenterX + 4.0, eggCenterY + 1.0),
      8.0,
      Paint()..color = eggYolkColor,
    );

    // 4. Two Grilled Sausages (Left side of inner plate)
    _drawSausage(
      canvas,
      x: centerX - 25.0,
      y: centerY - 12.0,
      width: 14.0,
      height: 36.0,
      angle: 0.35,
      bodyColor: sausageColor,
      lineColor: sausageLineColor,
    );

    _drawSausage(
      canvas,
      x: centerX - 12.0,
      y: centerY - 8.0,
      width: 14.0,
      height: 36.0,
      angle: 0.35,
      bodyColor: sausageColor,
      lineColor: sausageLineColor,
    );

    // 5. French Fries (Bottom of inner plate)
    final Paint fryPaint = Paint()
      ..color = fryColor
      ..strokeCap = StrokeCap.round;

    final List<List<double>> fries = [
      [centerX - 18, centerY + 18, centerX + 4, centerY + 20, 3.8],
      [centerX - 16, centerY + 24, centerX + 7, centerY + 23, 3.8],
      [centerX - 10, centerY + 29, centerX + 12, centerY + 28, 3.8],
      [centerX - 14, centerY + 34, centerX - 1, centerY + 36, 3.8],
      [centerX - 5, centerY + 35, centerX + 15, centerY + 32, 3.8],
      [centerX + 2, centerY + 26, centerX + 18, centerY + 23, 3.8],
    ];

    for (final f in fries) {
      fryPaint.strokeWidth = f[4];
      canvas.drawLine(Offset(f[0], f[1]), Offset(f[2], f[3]), fryPaint);
    }

    // 6. Cherry Beans / Tomatoes Cluster (between egg and fries)
    final Paint beanPaint = Paint()..color = beanColor;
    canvas.drawCircle(Offset(centerX + 6.0, centerY + 6.0), 3.4, beanPaint);
    canvas.drawCircle(Offset(centerX + 13.0, centerY + 8.0), 3.2, beanPaint);
    canvas.drawCircle(Offset(centerX + 19.0, centerY + 5.0), 3.5, beanPaint);
    canvas.drawCircle(Offset(centerX + 11.0, centerY + 13.0), 3.3, beanPaint);
  }

  void _drawSausage(
    Canvas canvas, {
    required double x,
    required double y,
    required double width,
    required double height,
    required double angle,
    required Color bodyColor,
    required Color lineColor,
  }) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(angle);

    final RRect sausageRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: width, height: height),
      Radius.circular(width / 2),
    );
    canvas.drawRRect(sausageRect, Paint()..color = bodyColor);

    // Diagonal grill score marks
    final Paint markPaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(-width / 2 + 2, -9), Offset(width / 2 - 2, -6), markPaint);
    canvas.drawLine(Offset(-width / 2 + 2, -3), Offset(width / 2 - 2, 0), markPaint);
    canvas.drawLine(Offset(-width / 2 + 2, 3), Offset(width / 2 - 2, 6), markPaint);
    canvas.drawLine(Offset(-width / 2 + 2, 9), Offset(width / 2 - 2, 12), markPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
