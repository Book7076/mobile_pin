import 'package:flutter/material.dart';

/// Reusable vector logo widget for MealMate.
/// Displays the signature two interlocking rings with fork, spoon, and heart.
class MealMateLogo extends StatefulWidget {
  final double width;
  final double height;
  final bool showText;
  final bool animateHeart;
  final double textSize;
  final double? textSpacing;
  final Color primaryColor;
  final Color ringColor;
  final Color iconColor;
  final double? size;

  const MealMateLogo({
    super.key,
    this.width = 220,
    this.height = 130,
    this.showText = true,
    this.animateHeart = true,
    this.textSize = 36,
    this.textSpacing,
    this.primaryColor = const Color(0xFF70182E),
    this.ringColor = Colors.white,
    this.iconColor = Colors.white,
    this.size,
  });

  @override
  State<MealMateLogo> createState() => _MealMateLogoState();
}

class _MealMateLogoState extends State<MealMateLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _heartScale;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _heartScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.18)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.18, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 30,
      ),
    ]).animate(_pulseController);

    if (widget.animateHeart) {
      _pulseController.repeat();
    }
  }

  @override
  void didUpdateWidget(MealMateLogo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animateHeart != oldWidget.animateHeart) {
      if (widget.animateHeart) {
        _pulseController.repeat();
      } else {
        _pulseController.stop();
        _pulseController.value = 0;
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveWidth = widget.size != null ? widget.size! * 1.8 : widget.width;
    final effectiveHeight = widget.size != null ? widget.size! * 1.0 : widget.height;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return CustomPaint(
              size: Size(effectiveWidth, effectiveHeight),
              painter: MealMateLogoPainter(
                ringColor: widget.ringColor,
                iconColor: widget.iconColor,
                heartScale: widget.animateHeart ? _heartScale.value : 1.0,
              ),
            );
          },
        ),
        if (widget.showText) ...[
          SizedBox(height: widget.textSpacing ?? 28),
          Text(
            'MealMate',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: widget.textSize,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              letterSpacing: -0.5,
              color: widget.iconColor == Colors.white ? Colors.white : widget.iconColor,
              shadows: widget.iconColor == Colors.white
                  ? const [
                      Shadow(
                        color: Color(0x73000000),
                        offset: Offset(2, 3),
                        blurRadius: 5,
                      ),
                      Shadow(
                        color: Color(0x33000000),
                        offset: Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ]
                  : null,
            ),
          ),
        ],
      ],
    );
  }
}

/// Custom vector painter for the MealMate logo.
/// Renders two overlapping metallic rings, fork, spoon, and heart.
class MealMateLogoPainter extends CustomPainter {
  final Color ringColor;
  final Color iconColor;
  final double heartScale;

  MealMateLogoPainter({
    this.ringColor = Colors.white,
    this.iconColor = Colors.white,
    this.heartScale = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Coordinate scaling based on base design size (220 x 130)
    final double scale = size.height / 130.0;
    canvas.save();
    canvas.scale(scale, scale);

    // Geometry parameters (at base height 130)
    const double circleRadius = 54.0;
    const double circleStrokeWidth = 5.2;
    const double centerY = 65.0;
    const double centerDistance = 72.0;

    // Center X of the whole canvas is (size.width / scale) / 2
    final double totalWidthAtBase = size.width / scale;
    final double midX = totalWidthAtBase / 2.0;

    final double leftCenterX = midX - (centerDistance / 2.0); // e.g. 110 - 36 = 74
    final double rightCenterX = midX + (centerDistance / 2.0); // e.g. 110 + 36 = 146

    final bool isDarkTheme = iconColor == Colors.white;

    // Drop shadow for the rings
    if (isDarkTheme) {
      final Paint shadowPaint = Paint()
        ..color = const Color(0x40000000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = circleStrokeWidth + 1.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5);

      canvas.drawCircle(Offset(leftCenterX + 1.0, centerY + 2.0), circleRadius, shadowPaint);
      canvas.drawCircle(Offset(rightCenterX + 1.0, centerY + 2.0), circleRadius, shadowPaint);
    }

    // Outer metallic sheen gradient for rings
    final Rect ringBounds = Rect.fromCenter(
      center: Offset(midX, centerY),
      width: centerDistance + (circleRadius * 2) + 20,
      height: circleRadius * 2 + 20,
    );

    final Paint ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = circleStrokeWidth
      ..strokeCap = StrokeCap.round;

    if (ringColor == Colors.white) {
      ringPaint.shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFFFFFF),
          Color(0xFFF6F6F8),
          Color(0xFFE4E4E8),
          Color(0xFFFFFFFF),
        ],
        stops: [0.0, 0.4, 0.7, 1.0],
      ).createShader(ringBounds);
    } else {
      ringPaint.color = ringColor;
    }

    // Draw the two intersecting rings
    canvas.drawCircle(Offset(leftCenterX, centerY), circleRadius, ringPaint);
    canvas.drawCircle(Offset(rightCenterX, centerY), circleRadius, ringPaint);

    // Icon paint (Fork, Spoon, Heart)
    final Paint iconShadowPaint = Paint()
      ..color = const Color(0x45000000)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);

    final Paint iconPaint = Paint()..style = PaintingStyle.fill;

    if (iconColor == Colors.white) {
      iconPaint.shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFFFFFF),
          Color(0xFFF8F8FA),
          Color(0xFFECECEF),
        ],
        stops: [0.0, 0.6, 1.0],
      ).createShader(ringBounds);
    } else {
      iconPaint.color = iconColor;
    }

    // ==========================================
    // 1. FORK (in left circle)
    // ==========================================
    final double forkCenterX = midX - 54.0; // Centered in the left crescent
    final Path forkPath = _buildForkPath(forkCenterX, centerY);

    // Draw fork shadow
    if (isDarkTheme) {
      canvas.save();
      canvas.translate(1.0, 2.0);
      canvas.drawPath(forkPath, iconShadowPaint);
      canvas.restore();
    }

    // Draw fork
    canvas.drawPath(forkPath, iconPaint);

    // ==========================================
    // 2. SPOON (in right circle)
    // ==========================================
    final double spoonCenterX = midX + 54.0; // Centered in the right crescent
    final Path spoonPath = _buildSpoonPath(spoonCenterX, centerY);

    // Draw spoon shadow
    if (isDarkTheme) {
      canvas.save();
      canvas.translate(1.0, 2.0);
      canvas.drawPath(spoonPath, iconShadowPaint);
      canvas.restore();
    }

    // Draw spoon
    canvas.drawPath(spoonPath, iconPaint);

    // Subtle 3D convex highlight on spoon bowl
    if (isDarkTheme) {
      final Path spoonHighlight = Path();
      spoonHighlight.addOval(
        Rect.fromCenter(
          center: Offset(spoonCenterX - 1.2, centerY - 25.0),
          width: 8.5,
          height: 18.0,
        ),
      );
      final Paint highlightPaint = Paint()
        ..style = PaintingStyle.fill
        ..shader = RadialGradient(
          center: const Alignment(-0.2, -0.3),
          radius: 0.9,
          colors: [
            Colors.white.withOpacity(0.65),
            Colors.white.withOpacity(0.0),
          ],
        ).createShader(
          Rect.fromCenter(
            center: Offset(spoonCenterX - 1.2, centerY - 25.0),
            width: 8.5,
            height: 18.0,
          ),
        );
      canvas.drawPath(spoonHighlight, highlightPaint);
    }

    // ==========================================
    // 3. HEART (in center intersection)
    // ==========================================
    canvas.save();
    canvas.translate(midX, centerY);
    if (heartScale != 1.0) {
      canvas.scale(heartScale, heartScale);
    }

    final Path heartPath = _buildHeartPath(0, 0, 24.0, 22.0);

    // Heart shadow
    if (isDarkTheme) {
      canvas.save();
      canvas.translate(1.0, 2.0);
      canvas.drawPath(heartPath, iconShadowPaint);
      canvas.restore();
    }

    // Heart body
    canvas.drawPath(heartPath, iconPaint);
    canvas.restore();

    canvas.restore();
  }

  /// Builds a smooth 4-tine fork path centered around (cx, cy)
  Path _buildForkPath(double cx, double cy) {
    final Path path = Path();
    const double totalHeight = 76.0;
    final double topY = cy - (totalHeight / 2.0); // e.g. 65 - 38 = 27
    const double tineWidth = 2.1;
    const double tineGap = 2.5;
    const double tineDepth = 19.0;
    const double forkWidth = 19.5;

    // Top tines outer left x = cx - (forkWidth / 2)
    final double leftX = cx - (forkWidth / 2.0);
    final double rightX = cx + (forkWidth / 2.0);
    final double slotBottomY = topY + tineDepth;
    final double neckY = topY + 28.0;
    const double neckHalfWidth = 2.7;
    final double bottomY = topY + totalHeight;

    // Outer contour start at top-left tine
    path.moveTo(leftX, topY + 1.0);
    path.quadraticBezierTo(leftX, topY, leftX + (tineWidth / 2.0), topY);
    path.quadraticBezierTo(leftX + tineWidth, topY, leftX + tineWidth, topY + 1.0);
    path.lineTo(leftX + tineWidth, slotBottomY - 1.5);
    path.quadraticBezierTo(
      leftX + tineWidth + (tineGap / 2.0),
      slotBottomY,
      leftX + tineWidth + tineGap,
      slotBottomY - 1.5,
    );

    // Second tine
    final double t2Left = leftX + tineWidth + tineGap;
    path.lineTo(t2Left, topY + 1.0);
    path.quadraticBezierTo(t2Left, topY, t2Left + (tineWidth / 2.0), topY);
    path.quadraticBezierTo(t2Left + tineWidth, topY, t2Left + tineWidth, topY + 1.0);
    path.lineTo(t2Left + tineWidth, slotBottomY - 1.5);
    path.quadraticBezierTo(
      t2Left + tineWidth + (tineGap / 2.0),
      slotBottomY,
      t2Left + tineWidth + tineGap,
      slotBottomY - 1.5,
    );

    // Third tine
    final double t3Left = t2Left + tineWidth + tineGap;
    path.lineTo(t3Left, topY + 1.0);
    path.quadraticBezierTo(t3Left, topY, t3Left + (tineWidth / 2.0), topY);
    path.quadraticBezierTo(t3Left + tineWidth, topY, t3Left + tineWidth, topY + 1.0);
    path.lineTo(t3Left + tineWidth, slotBottomY - 1.5);
    path.quadraticBezierTo(
      t3Left + tineWidth + (tineGap / 2.0),
      slotBottomY,
      t3Left + tineWidth + tineGap,
      slotBottomY - 1.5,
    );

    // Fourth (rightmost) tine
    path.lineTo(rightX - tineWidth, topY + 1.0);
    path.quadraticBezierTo(rightX - tineWidth, topY, rightX - (tineWidth / 2.0), topY);
    path.quadraticBezierTo(rightX, topY, rightX, topY + 1.0);

    // Right outer edge curves into neck
    path.lineTo(rightX, slotBottomY);
    path.cubicTo(
      rightX,
      slotBottomY + 5.0,
      cx + neckHalfWidth + 2.0,
      neckY - 3.0,
      cx + neckHalfWidth,
      neckY,
    );

    // Handle going down (right side)
    path.cubicTo(
      cx + neckHalfWidth - 0.4,
      neckY + 14.0,
      cx + 4.2,
      bottomY - 10.0,
      cx + 4.2,
      bottomY - 4.5,
    );

    // Bottom rounded end
    path.quadraticBezierTo(cx + 4.2, bottomY, cx, bottomY);
    path.quadraticBezierTo(cx - 4.2, bottomY, cx - 4.2, bottomY - 4.5);

    // Handle going up (left side)
    path.cubicTo(
      cx - 4.2,
      bottomY - 10.0,
      cx - neckHalfWidth + 0.4,
      neckY + 14.0,
      cx - neckHalfWidth,
      neckY,
    );

    // Left outer edge curves up to outer left tine
    path.cubicTo(
      cx - neckHalfWidth - 2.0,
      neckY - 3.0,
      leftX,
      slotBottomY + 5.0,
      leftX,
      slotBottomY,
    );

    path.close();
    return path;
  }

  /// Builds a smooth oval spoon path centered around (cx, cy)
  Path _buildSpoonPath(double cx, double cy) {
    final Path path = Path();
    const double totalHeight = 76.0;
    final double topY = cy - (totalHeight / 2.0); // e.g. 27
    const double bowlWidth = 20.0;
    const double bowlHeight = 29.0;
    final double bowlBottomY = topY + bowlHeight;
    final double neckY = topY + 28.0;
    const double neckHalfWidth = 2.7;
    final double bottomY = topY + totalHeight;

    // Spoon bowl top center
    path.moveTo(cx, topY);

    // Right side of bowl
    path.cubicTo(
      cx + (bowlWidth / 2.0) + 1.0,
      topY,
      cx + (bowlWidth / 2.0),
      topY + (bowlHeight * 0.55),
      cx + (bowlWidth * 0.35),
      bowlBottomY - 3.0,
    );

    // Transition from bowl to neck (right side)
    path.cubicTo(
      cx + 4.5,
      bowlBottomY + 1.0,
      cx + neckHalfWidth + 0.8,
      neckY - 1.5,
      cx + neckHalfWidth,
      neckY,
    );

    // Handle going down (right side)
    path.cubicTo(
      cx + neckHalfWidth - 0.4,
      neckY + 14.0,
      cx + 4.2,
      bottomY - 10.0,
      cx + 4.2,
      bottomY - 4.5,
    );

    // Bottom rounded end
    path.quadraticBezierTo(cx + 4.2, bottomY, cx, bottomY);
    path.quadraticBezierTo(cx - 4.2, bottomY, cx - 4.2, bottomY - 4.5);

    // Handle going up (left side)
    path.cubicTo(
      cx - 4.2,
      bottomY - 10.0,
      cx - neckHalfWidth + 0.4,
      neckY + 14.0,
      cx - neckHalfWidth,
      neckY,
    );

    // Transition from neck to bowl (left side)
    path.cubicTo(
      cx - neckHalfWidth - 0.8,
      neckY - 1.5,
      cx - 4.5,
      bowlBottomY + 1.0,
      cx - (bowlWidth * 0.35),
      bowlBottomY - 3.0,
    );

    // Left side of bowl
    path.cubicTo(
      cx - (bowlWidth / 2.0),
      topY + (bowlHeight * 0.55),
      cx - (bowlWidth / 2.0) - 1.0,
      topY,
      cx,
      topY,
    );

    path.close();
    return path;
  }

  /// Builds a symmetrical, smooth heart path centered around (cx, cy)
  Path _buildHeartPath(double cx, double cy, double width, double height) {
    final Path path = Path();
    final double halfW = width / 2.0;
    final double halfH = height / 2.0;

    // Top cleft of heart
    path.moveTo(cx, cy - (halfH * 0.35));

    // Left lobe
    path.cubicTo(
      cx - (halfW * 0.25),
      cy - (halfH * 0.95),
      cx - halfW,
      cy - (halfH * 0.85),
      cx - halfW,
      cy - (halfH * 0.2),
    );

    // Left side down to bottom tip
    path.cubicTo(
      cx - halfW,
      cy + (halfH * 0.35),
      cx - (halfW * 0.35),
      cy + (halfH * 0.75),
      cx,
      cy + halfH,
    );

    // Right side up from bottom tip
    path.cubicTo(
      cx + (halfW * 0.35),
      cy + (halfH * 0.75),
      cx + halfW,
      cy + (halfH * 0.35),
      cx + halfW,
      cy - (halfH * 0.2),
    );

    // Right lobe
    path.cubicTo(
      cx + halfW,
      cy - (halfH * 0.85),
      cx + (halfW * 0.25),
      cy - (halfH * 0.95),
      cx,
      cy - (halfH * 0.35),
    );

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant MealMateLogoPainter oldDelegate) {
    return oldDelegate.heartScale != heartScale ||
        oldDelegate.ringColor != ringColor ||
        oldDelegate.iconColor != iconColor;
  }
}
