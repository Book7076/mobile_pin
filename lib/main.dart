import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/constants.dart';
import 'screens/splash_screen.dart';
import 'screens/restaurants/shop_registration_screen.dart';
import 'screens/restaurants/shop_details_screen.dart';
import 'screens/restaurants/add_menu_screen.dart';
import 'screens/restaurants/owner_dashboard_screen.dart';
import 'screens/restaurants/menu_management_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Note: .env file loading error or missing: $e");
  }
  
  if (AppConstants.supabaseUrl.isNotEmpty && AppConstants.supabaseAnonKey.isNotEmpty) {
    try {
      await Supabase.initialize(
        url: AppConstants.supabaseUrl,
        anonKey: AppConstants.supabaseAnonKey,
      );
    } catch (e) {
      debugPrint("Supabase initialization failed: $e");
    }
  }
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MealMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF70182E), // MealMate signature wine red
          primary: const Color(0xFF70182E),
          secondary: const Color(0xFF9E2A47),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
      routes: {
        '/shop-registration': (context) => const ShopRegistrationScreen(),
        '/shop-details': (context) => const ShopDetailsScreen(),
        '/add-menu': (context) => const AddMenuScreen(),
        '/owner-dashboard': (context) => const OwnerDashboardScreen(),
        '/owner-statistics': (context) => const OwnerPlaceholderScreen(title: 'สถิติ'),
        '/menu-management': (context) => const MenuManagementScreen(),
        '/owner-messages': (context) => const OwnerPlaceholderScreen(title: 'ข้อความ'),
        '/owner-reviews': (context) => const OwnerPlaceholderScreen(title: 'รีวิว'),
        '/owner-support': (context) => const OwnerPlaceholderScreen(title: 'ศูนย์ช่วยเหลือติดต่อฝ่ายบริการลูกค้า'),
      },
    );
  }
}
