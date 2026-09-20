import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants.dart';
import 'selected_restaurants_screen.dart';

/// Screen "User 4.Result" - "จบแล้วจ้า 🛎️"
/// Displayed as an interstitial transition when user finishes picking 5 restaurants.
class FinishTransitionScreen extends StatefulWidget {
  const FinishTransitionScreen({super.key});

  @override
  State<FinishTransitionScreen> createState() => _FinishTransitionScreenState();
}

class _FinishTransitionScreenState extends State<FinishTransitionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _autoProceedTimer;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );

    _animController.forward();

    // Auto proceed to result screen after 1.4 seconds
    _autoProceedTimer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) {
        _proceedToResult();
      }
    });
  }

  @override
  void dispose() {
    _autoProceedTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _proceedToResult() {
    _autoProceedTimer?.cancel();
    HapticFeedback.mediumImpact();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SelectedRestaurantsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.burgundyPrimary,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _proceedToResult,
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    key: const ValueKey('finish_pill_button'),
                    borderRadius: BorderRadius.circular(32),
                    onTap: _proceedToResult,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.28),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'จบแล้วจ้า',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: AppConstants.burgundyPrimary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppConstants.burgundyPrimary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.notifications_active_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
