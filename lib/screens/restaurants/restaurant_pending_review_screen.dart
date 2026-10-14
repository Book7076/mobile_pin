import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../home/home_screen.dart';

/// Screen displayed immediately after restaurant registration submission.
/// Solid red/burgundy background (#6E162B) with review notification and
/// a button to return to the user's settings/profile tab.
class RestaurantPendingReviewScreen extends StatelessWidget {
  final String? restaurantName;

  const RestaurantPendingReviewScreen({
    super.key,
    this.restaurantName,
  });

  static const Color burgundyColor = Color(0xFF6E162B);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: burgundyColor,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: burgundyColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              // Top Bar with optional back button
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(
                    Icons.chevron_left_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const HomeScreen(initialTab: 2),
                      ),
                      (route) => false,
                    );
                  },
                ),
              ),

              const Spacer(flex: 1),

              // Central Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.hourglass_top_rounded,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Main Status Header (Exact text requested by user)
              const Text(
                'รอการตรวจสอบร้านประมาณ 2-3 วัน',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.3,
                  fontFamily: 'Prompt',
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 14),

              // Restaurant Name if provided
              if (restaurantName != null && restaurantName!.trim().isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    restaurantName!,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: 'Prompt',
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Descriptive Body Text
              Text(
                'ข้อมูลร้านอาหารและเมนูของคุณถูกส่งเรียบร้อยแล้ว\n'
                'ทีมงาน MealMate กำลังตรวจสอบความถูกต้อง\n'
                'โดยใช้เวลาประมาณ 2-3 วันทำการ\n'
                'เมื่อผ่านการอนุมัติแล้ว คุณจะสามารถเข้าใช้งาน\n'
                '"แดชบอร์ดเจ้าของร้าน" ได้ทันที',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.5,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.6,
                  fontFamily: 'Prompt',
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 28),

              // Status Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'สถานะ: อยู่ระหว่างรอเจ้าหน้าที่ตรวจสอบ',
                            style: TextStyle(
                              fontSize: 13.5,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Prompt',
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Pending',
                            style: TextStyle(
                              fontSize: 11,
                              color: burgundyColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // Back to User Settings Button (Exact action requested by user)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: burgundyColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    // Navigate back to the user's settings / profile page in HomeScreen
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const HomeScreen(initialTab: 2),
                      ),
                      (route) => false,
                    );
                  },
                  child: const Text(
                    'กลับสู่หน้าการตั้งค่า',
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Prompt',
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
