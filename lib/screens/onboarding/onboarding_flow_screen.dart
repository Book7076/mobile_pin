import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'splash_screen_2.dart';
import 'splash_screen_3.dart';
import '../home/home_screen.dart';
import '../admin/admin_dashboard.dart';

/// Hosts the interactive onboarding flow for Splash Screen 2 and Splash Screen 3.
/// Supports both swipe gestures and programmatic "ถัดไป" navigation.
class OnboardingFlowScreen extends StatefulWidget {
  final String? userRole;

  const OnboardingFlowScreen({
    super.key,
    this.userRole,
  });

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // Configure system UI for light screen background
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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  void _finishOnboarding() {
    final destination = widget.userRole == 'admin'
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView(
        controller: _pageController,
        physics: const ClampingScrollPhysics(),
        children: [
          SplashScreen2(
            userRole: widget.userRole,
            onNext: _goToNextPage,
            onSkip: _finishOnboarding,
          ),
          SplashScreen3(
            userRole: widget.userRole,
            onNext: _finishOnboarding,
            onSkip: _finishOnboarding,
          ),
        ],
      ),
    );
  }
}
