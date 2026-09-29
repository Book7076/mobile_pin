import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';
import '../providers/auth_provider.dart';
import 'auth/login_screen.dart';
import 'home/home_screen.dart';
import 'admin/admin_dashboard.dart';
import '../widgets/meal_mate_logo.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();

    // Configure system UI for immersive edge-to-edge experience
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFF5E1323),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    _setupAnimations();
    _redirect();
  }

  void _setupAnimations() {
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    // Staggered logo fade & scale
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );

    _logoScale = Tween<double>(begin: 0.86, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.75, curve: Curves.easeOutBack),
      ),
    );

    // Text fade & gentle upward slide
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.4, 0.9, curve: Curves.easeIn),
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.4, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _redirect() async {
    // Show splash screen for at least 2.5 seconds for a premium brand feel
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    try {
      final session = supabase.auth.currentSession;
      if (session != null) {
        var userData = await supabase
            .from('users')
            .select()
            .eq('id', session.user.id)
            .maybeSingle();

        if (userData == null && session.user.email != null && session.user.email!.isNotEmpty) {
          userData = await supabase
              .from('users')
              .select()
              .eq('email', session.user.email!)
              .maybeSingle();
        }

        if (!mounted) return;

        if (userData != null) {
          ref.read(authProvider.notifier).setUserFromMap(userData);
        } else {
          await ref.read(authProvider.notifier).refreshUser();
        }

        final userType = (userData?['user_type'] ?? userData?['role'])?.toString().toLowerCase();
        if (userData != null && userType == 'admin') {
          _navigateTo(const AdminDashboard());
        } else {
          _navigateTo(const HomeScreen());
        }
      } else {
        _navigateTo(const LoginScreen());
      }
    } catch (_) {
      // Fallback gracefully to login screen on network error or unconfigured auth
      if (mounted) {
        _navigateTo(const LoginScreen());
      }
    }
  }

  void _navigateTo(Widget destination) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.1),
            radius: 1.15,
            colors: [
              Color(0xFF7D1C34), // Rich warm wine highlight center
              Color(0xFF6E162B), // Core brand burgundy (matches reference)
              Color(0xFF5A1121), // Deep edge vignette for luxury finish
            ],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Center Logo & Branding
              Center(
                child: AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoScale.value,
                      child: Opacity(
                        opacity: _logoOpacity.value,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Interlocking Vector Logo
                            const MealMateLogo(
                              width: 230,
                              height: 140,
                              showText: false,
                              animateHeart: true,
                            ),
                            const SizedBox(height: 32),
                            // Slide & Fade "MealMate" typography
                            SlideTransition(
                              position: _textSlide,
                              child: Opacity(
                                opacity: _textOpacity.value,
                                child: const Text(
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
                                        color: Color(0x7F000000),
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
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Bottom subtle indicator
              Positioned(
                bottom: 36,
                left: 0,
                right: 0,
                child: Center(
                  child: FadeTransition(
                    opacity: _textOpacity,
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withOpacity(0.65),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
