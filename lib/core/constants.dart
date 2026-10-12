import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? 'https://mock.supabase.co';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? 'mock-key';

  // App Identity
  static const String appName = 'Mealmate';
  static const String appTagline = 'สุ่มร้านเด็ด ถูกใจทุกมื้อ';

  // Original Color Palette
  static const Color primaryColor = Color(0xFFFF5252); // Coral Red
  static const Color primaryDark = Color(0xFFE03838);
  static const Color primaryLight = Color(0xFFFFECEC);
  static const Color secondaryColor = Color(0xFFFF9800); // Warm Orange
  static const Color accentColor = Color(0xFF4CAF50); // Mint Green
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color dividerColor = Color(0xFFE2E8F0);

  // MealMate Flow 3-4 Theme Tokens (Burgundy & Blush Palette)
  static const Color burgundyPrimary = Color(0xFF800E2E); // Deep wine red / burgundy
  static const Color burgundyDark = Color(0xFF630A23);
  static const Color burgundyLight = Color(0xFF9E1B3E);
  static const Color backgroundWarm = Color(0xFFFFF9F8); // Soft warm blush background
  static const Color cardSelectedBg = Color(0xFFF9DADA); // Light rose/pink fill for selected card
  static const Color cardSelectedBorder = Color(0xFFE8B4B4); // Border for selected card
  static const Color cardBorderLight = Color(0xFFFFECE8); // Light border for unselected card
  static const Color sliderInactive = Color(0xFFF6DFDB); // Inactive track for slider
  static const Color sliderActive = Color(0xFF800E2E); // Active track for slider
  static const Color textBurgundy = Color(0xFF800E2E); // Header and accent text

  // 17 Food Categories for Flow 3 (Matching Database Table `cuisine_types` 1..17)
  static const List<Map<String, dynamic>> flowCategories = [
    {
      'id': 'thai',
      'cuisine_type_id': 1,
      'name': 'อาหารไทย',
      'emoji': '🍲',
      'icon': Icons.soup_kitchen,
      'imageUrl': 'https://images.unsplash.com/photo-1559847844-5315695dadae?w=300&q=80',
    },
    {
      'id': 'japanese',
      'cuisine_type_id': 2,
      'name': 'อาหารญี่ปุ่น',
      'emoji': '🍣',
      'icon': Icons.set_meal,
      'imageUrl': 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=300&q=80',
    },
    {
      'id': 'korean',
      'cuisine_type_id': 3,
      'name': 'อาหารเกาหลี',
      'emoji': '🥘',
      'icon': Icons.ramen_dining,
      'imageUrl': 'https://images.unsplash.com/photo-1590301157890-4810ed352733?w=300&q=80',
    },
    {
      'id': 'chinese',
      'cuisine_type_id': 4,
      'name': 'อาหารจีน',
      'emoji': '🥟',
      'icon': Icons.dinner_dining,
      'imageUrl': 'https://images.unsplash.com/photo-1563245372-f21724e3856d?w=300&q=80',
    },
    {
      'id': 'dessert_bakery',
      'cuisine_type_id': 5,
      'name': 'ของหวาน',
      'emoji': '🍧',
      'icon': Icons.cake,
      'imageUrl': 'https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=300&q=80',
    },
    {
      'id': 'italian_western',
      'cuisine_type_id': 6,
      'name': 'อาหารอิตาเลียน',
      'emoji': '🍕',
      'icon': Icons.local_pizza,
      'imageUrl': 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=300&q=80',
    },
    {
      'id': 'fast_food',
      'cuisine_type_id': 7,
      'name': 'อาหารฟาสฟู้ด',
      'emoji': '🍔',
      'icon': Icons.fastfood,
      'imageUrl': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=300&q=80',
    },
    {
      'id': 'healthy',
      'cuisine_type_id': 8,
      'name': 'อาหารฮาลาล',
      'emoji': '🍗',
      'icon': Icons.restaurant,
      'imageUrl': 'https://images.unsplash.com/photo-1544025162-d76694265947?w=300&q=80',
    },
    {
      'id': 'vegetarian',
      'cuisine_type_id': 9,
      'name': 'อาหารมังสวิรัติ',
      'emoji': '🥦',
      'icon': Icons.eco,
      'imageUrl': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=300&q=80',
    },
    {
      'id': 'noodles',
      'cuisine_type_id': 10,
      'name': 'ก๋วยเตี๋ยว',
      'emoji': '🍜',
      'icon': Icons.ramen_dining,
      'imageUrl': 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=300&q=80',
    },
    {
      'id': 'cafe_beverage',
      'cuisine_type_id': 11,
      'name': 'คาเฟ่',
      'emoji': '🧋',
      'icon': Icons.local_cafe,
      'imageUrl': 'https://images.unsplash.com/photo-1517256064527-09c73fc73e38?w=300&q=80',
    },
    {
      'id': 'shabu_hotpot',
      'cuisine_type_id': 12,
      'name': 'ปิ้งย่าง/ชาบู',
      'emoji': '🥩',
      'icon': Icons.outdoor_grill,
      'imageUrl': 'https://images.unsplash.com/photo-1547928576-a4a33237cbc3?w=300&q=80',
    },
    {
      'id': 'breakfast',
      'cuisine_type_id': 13,
      'name': 'อาหารเช้า',
      'emoji': '🥪',
      'icon': Icons.breakfast_dining,
      'imageUrl': 'https://images.unsplash.com/photo-1525351484163-7529414344d8?w=300&q=80',
    },
    {
      'id': 'somtum_isan',
      'cuisine_type_id': 14,
      'name': 'อาหารอีสาน',
      'emoji': '🌶️',
      'icon': Icons.local_fire_department,
      'imageUrl': 'https://images.unsplash.com/photo-1562967914-608f82629710?w=300&q=80',
    },
    {
      'id': 'northern_thai',
      'cuisine_type_id': 15,
      'name': 'อาหารเหนือ',
      'emoji': '🥣',
      'icon': Icons.soup_kitchen,
      'imageUrl': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=300&q=80',
    },
    {
      'id': 'southern_thai',
      'cuisine_type_id': 16,
      'name': 'อาหารใต้',
      'emoji': '🍛',
      'icon': Icons.dinner_dining,
      'imageUrl': 'https://images.unsplash.com/photo-1455619452474-d2be8b1e70cd?w=300&q=80',
    },
    {
      'id': 'a_la_carte',
      'cuisine_type_id': 17,
      'name': 'อาหารตามสั่ง',
      'emoji': '🍳',
      'icon': Icons.lunch_dining,
      'imageUrl': 'https://images.unsplash.com/photo-1562967914-608f82629710?w=300&q=80',
    },
  ];

  // Food Categories with Icons and Emojis (for General App Use)
  static const List<Map<String, dynamic>> foodCategories = [
    {'id': 'all', 'name': 'ทั้งหมด', 'emoji': '🍽️', 'icon': Icons.restaurant},
    {'id': 'thai', 'name': 'อาหารไทย', 'emoji': '🍲', 'icon': Icons.soup_kitchen},
    {'id': 'street_food', 'name': 'ตามสั่ง / สตรีทฟู้ด', 'emoji': '🍳', 'icon': Icons.lunch_dining},
    {'id': 'japanese', 'name': 'อาหารญี่ปุ่น', 'emoji': '🍣', 'icon': Icons.set_meal},
    {'id': 'korean', 'name': 'อาหารเกาหลี', 'emoji': '🥘', 'icon': Icons.ramen_dining},
    {'id': 'shabu_grill', 'name': 'ชาบู / ปิ้งย่าง / หมูกระทะ', 'emoji': '🥩', 'icon': Icons.outdoor_grill},
    {'id': 'noodles', 'name': 'ก๋วยเตี๋ยว / บะหมี่', 'emoji': '🍜', 'icon': Icons.dinner_dining},
    {'id': 'somtum_isan', 'name': 'ส้มตำ / ยำ / อาหารอีสาน', 'emoji': '🌶️', 'icon': Icons.local_fire_department},
    {'id': 'cafe_dessert', 'name': 'คาเฟ่ / ของหวาน', 'emoji': '☕', 'icon': Icons.local_cafe},
    {'id': 'fast_food', 'name': 'ฟาสต์ฟู้ด / เบอร์เกอร์', 'emoji': '🍔', 'icon': Icons.fastfood},
    {'id': 'healthy_clean', 'name': 'อาหารคลีน / สุขภาพ', 'emoji': '🥗', 'icon': Icons.eco},
    {'id': 'italian_western', 'name': 'อิตาเลียน / พิซซ่า', 'emoji': '🍕', 'icon': Icons.local_pizza},
  ];

  // Price Tiers
  static const List<Map<String, String>> priceTiers = [
    {'id': '1', 'symbol': '฿', 'label': 'ประหยัด (<100฿)'},
    {'id': '2', 'symbol': '฿฿', 'label': 'ปานกลาง (100-300฿)'},
    {'id': '3', 'symbol': '฿฿฿', 'label': 'พรีเมียม (>300฿)'},
  ];

  // Swipe Settings
  static const int maxSwipeCount = 5;
}
