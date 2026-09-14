import 'package:flutter/material.dart';
import '../../widgets/food_plate_illustration.dart';
import 'splash_screen_3.dart';
import '../home/home_screen.dart';
import '../admin/admin_dashboard.dart';

/// Splash Screen 2 (Onboarding Step 1): "ปัดหาร้านที่ ใช่"
class SplashScreen2 extends StatelessWidget {
  final String? userRole;
  final VoidCallback? onNext;
  final VoidCallback? onSkip;

  const SplashScreen2({
    super.key,
    this.userRole,
    this.onNext,
    this.onSkip,
  });

  void _handleNext(BuildContext context) {
    if (onNext != null) {
      onNext!();
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              SplashScreen3(userRole: userRole),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 350),
        ),
      );
    }
  }

  void _handleSkip(BuildContext context) {
    if (onSkip != null) {
      onSkip!();
    } else {
      final destination = userRole == 'admin'
          ? const AdminDashboard()
          : const HomeScreen();

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => destination),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Illustration
              const Center(
                child: FoodPlateIllustration(
                  width: 320,
                  height: 220,
                ),
              ),

              const SizedBox(height: 48),

              // Title: "ปัดหาร้านที่ ใช่"
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 27,
                    letterSpacing: -0.2,
                  ),
                  children: [
                    TextSpan(
                      text: 'ปัดหาร้านที่ ',
                      style: TextStyle(
                        color: Color(0xFFB59A9A), // Muted warm taupe-pink
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: 'ใช่',
                      style: TextStyle(
                        color: Color(0xFF6E162B), // Deep signature burgundy
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 3),

              // Dots indicator [● ⬝ ⬝]
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDot(isActive: true),
                  const SizedBox(width: 8),
                  _buildDot(isActive: false),
                  const SizedBox(width: 8),
                  _buildDot(isActive: false),
                ],
              ),

              const SizedBox(height: 28),

              // Primary Button: "ถัดไป"
              SizedBox(
                width: double.infinity,
                height: 54,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(27),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x3B6E162B),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => _handleNext(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6E162B),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(27),
                      ),
                    ),
                    child: const Text(
                      'ถัดไป',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Secondary Button: "ข้าม"
              SizedBox(
                height: 44,
                child: TextButton(
                  onPressed: () => _handleSkip(context),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF6E162B),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                  child: const Text(
                    'ข้าม',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6E162B),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDot({required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: isActive ? 7.5 : 6.0,
      height: isActive ? 7.5 : 6.0,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF6E162B) : const Color(0xFFD6C2C2),
        shape: BoxShape.circle,
      ),
    );
  }
}
