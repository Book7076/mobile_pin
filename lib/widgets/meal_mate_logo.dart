import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MealMateLogo extends StatelessWidget {
  final double size;

  const MealMateLogo({
    super.key,
    this.size = 110,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/Logo_mm.png',
          width: size * 1.45,
          height: size * 0.92,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const SizedBox.shrink();
          },
        ),
        const SizedBox(height: 10),
        Text(
          'MealMate',
          style: GoogleFonts.playfairDisplay(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}
