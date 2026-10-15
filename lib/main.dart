import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/constants.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/terms_policy_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/flow/category_selection_screen.dart';
import 'screens/restaurants/create_restaurant_screen.dart';
import 'screens/restaurants/shop_registration_screen.dart';
import 'screens/restaurants/shop_details_screen.dart';
import 'screens/restaurants/add_menu_screen.dart';
import 'screens/restaurants/owner_dashboard_screen.dart';
import 'screens/restaurants/menu_management_screen.dart';
import 'screens/owner/owner_stats_screen.dart';
import 'screens/owner/owner_messages_screen.dart';
import 'screens/owner/owner_reviews_screen.dart';
import 'screens/owner/owner_help_center_screen.dart';
import 'screens/owner/select_restaurant_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/admin/admin_login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Note: .env file loading error or missing: $e");
  }

  if (AppConstants.supabaseUrl.isNotEmpty &&
      AppConstants.supabaseAnonKey.isNotEmpty) {
    try {
      await Supabase.initialize(
        url: AppConstants.supabaseUrl,
        anonKey: AppConstants.supabaseAnonKey,
      );
    } catch (e) {
      debugPrint("Supabase initialization failed: $e");
    }
  }

  runApp(const ProviderScope(child: MyApp()));
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
          seedColor: AppConstants.burgundyPrimary,
          primary: AppConstants.burgundyPrimary,
          secondary: AppConstants.burgundyLight,
        ),
        useMaterial3: true,
        fontFamily: 'Kanit',
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/category-selection': (context) =>
            const CategorySelectionScreen(isStandalone: false),
        '/shop-registration': (context) => const CreateRestaurantScreen(),
        '/create-restaurant': (context) => const CreateRestaurantScreen(),
        '/shop-details': (context) => const ShopDetailsScreen(),
        '/add-menu': (context) => const AddMenuScreen(),
        '/owner-dashboard': (context) => const SelectRestaurantScreen(),
        '/select-restaurant': (context) => const SelectRestaurantScreen(),
        '/owner-statistics': (context) => const OwnerStatsScreen(),
        '/menu-management': (context) => const MenuManagementScreen(),
        '/owner-messages': (context) => const OwnerMessagesScreen(),
        '/owner-reviews': (context) => const OwnerReviewsScreen(),
        '/owner-support': (context) => const OwnerHelpCenterScreen(),
        '/admin-dashboard': (context) => const AdminDashboard(),
        '/admin-login': (context) => const AdminLoginScreen(),
        '/terms-policy': (context) => const TermsPolicyScreen(),
      },
    );
  }
}
