import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/meal_mate_logo.dart';
import 'create_restaurant_screen.dart';

/// Screen displayed when the user taps "เริ่มลงทะเบียนร้าน"
/// Features the signature MealMate branding on a burgundy canvas,
/// transitioning the user into the restaurant owner registration flow.
class GoToOwnerScreen extends StatefulWidget {
  final Duration transitionDelay;

  const GoToOwnerScreen({
    super.key,
    this.transitionDelay = const Duration(milliseconds: 2200),
  });

  @override
  State<GoToOwnerScreen> createState() => _GoToOwnerScreenState();
}

class _GoToOwnerScreenState extends State<GoToOwnerScreen>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  int _dotCount = 0;
  Timer? _dotTimer;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFF6E162B),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();

    // Animated dots cycle (1, 2, 3)
    _dotTimer = Timer.periodic(const Duration(milliseconds: 450), (timer) {
      if (mounted) {
        setState(() {
          _dotCount = (_dotCount + 1) % 4;
        });
      }
    });

    // Auto-navigate to owner registration form after delay
    _timer = Timer(widget.transitionDelay, () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const CreateRestaurantScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _dotTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String dots = '.' * (_dotCount == 0 ? 3 : _dotCount);

    return Scaffold(
      backgroundColor: const Color(0xFF6E162B), // MealMate signature burgundy
      body: SafeArea(
        child: Stack(
          children: [
            // Top back button (in case user wants to return immediately)
            Positioned(
              top: 8,
              left: 10,
              child: IconButton(
                icon: const Icon(
                  Icons.chevron_left_rounded,
                  color: Colors.white70,
                  size: 32,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),

            // Center Branding & Transition Status
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 1. Signature MealMate Vector Logo with animated pulsing heart
                      const MealMateLogo(
                        width: 220,
                        height: 130,
                        showText: false,
                        animateHeart: true,
                        ringColor: Colors.white,
                        iconColor: Colors.white,
                      ),

                      const SizedBox(height: 24),

                      // 2. Bold Italic Georgia Typography: "MealMate"
                      const Text(
                        'MealMate',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                          letterSpacing: -0.6,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Color(0x66000000),
                              offset: Offset(2, 3),
                              blurRadius: 6,
                            ),
                            Shadow(
                              color: Color(0x33000000),
                              offset: Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // 3. Status Transition Message matching reference mockup
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          'ระบบกำลังเข้าสู่หน้าลงทะเบียนเจ้าของร้าน$dots',
                          key: ValueKey<int>(_dotCount),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            letterSpacing: -0.2,
                            height: 1.4,
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Subtle smooth loading progress indicator
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withOpacity(0.85),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
