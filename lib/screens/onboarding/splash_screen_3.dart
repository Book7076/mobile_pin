import 'package:flutter/material.dart';
import '../../widgets/budget_slider_illustration.dart';
import '../home/home_screen.dart';
import '../admin/admin_dashboard.dart';

/// Splash Screen 3 (Onboarding Step 2): "เลือกประเภทอาหาร และงบที่พอดี"
class SplashScreen3 extends StatelessWidget {
  final String? userRole;
  final VoidCallback? onNext;
  final VoidCallback? onSkip;

  const SplashScreen3({
    super.key,
    this.userRole,
    this.onNext,
    this.onSkip,
  });

  void _handleFinish(BuildContext context) {
    if (onNext != null) {
      onNext!();
    } else {
      final destination = userRole == 'admin'
          ? const AdminDashboard()
          : const HomeScreen();

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => destination,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    }
  }

  void _handleSkip(BuildContext context) {
    if (onSkip != null) {
      onSkip!();
    } else {
      _handleFinish(context);
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
                child: BudgetSliderIllustration(
                  width: 320,
                  height: 230,
                ),
              ),

              const SizedBox(height: 48),

              // Title: "เลือกประเภทอาหาร \nและงบที่พอดี"
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 27,
                    height: 1.35,
                    letterSpacing: -0.2,
                  ),
                  children: [
                    TextSpan(
                      text: 'เลือก',
                      style: TextStyle(
                        color: Color(0xFFB59A9A),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: 'ประเภทอาหาร\n',
                      style: TextStyle(
                        color: Color(0xFF6E162B),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    TextSpan(
                      text: 'และ',
                      style: TextStyle(
                        color: Color(0xFFB59A9A),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: 'งบ',
                      style: TextStyle(
                        color: Color(0xFF6E162B),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    TextSpan(
                      text: 'ที่พอดี',
                      style: TextStyle(
                        color: Color(0xFFB59A9A),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 3),

              // Dots indicator [⬝ ● ⬝]
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDot(isActive: false),
                  const SizedBox(width: 8),
                  _buildDot(isActive: true),
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
                    onPressed: () => _handleFinish(context),
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
