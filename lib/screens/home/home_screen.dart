import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../main.dart';
import '../auth/login_screen.dart';
import '../restaurants/create_restaurant_screen.dart';
import 'discover_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentTab = 0; // 0: Home, 1: Favorites, 2: Profile
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Curated recommended restaurants matching the design
  final List<Map<String, dynamic>> _curatedRestaurants = [
    {
      'name': 'ข้าวซอยแม่สาย',
      'category': 'ประเภท: อาหารไทย, ก๋วยเตี๋ยว',
      'rating': 4.7,
      'image': 'assets/images/khao_soi.jpg',
      'isAsset': true,
      'isFavorite': true,
    },
    {
      'name': 'โกเผือกโกดำ',
      'category': 'ประเภท: อาหารไทย, อาหารเช้า',
      'rating': 4.7,
      'image': 'assets/images/go_puek.jpg',
      'isAsset': true,
      'isFavorite': true,
    },
    {
      'name': 'ข้าวมันไก่นันทาราม',
      'category': 'ประเภท: อาหารไทย',
      'rating': 4.8,
      'image': 'assets/images/khao_man_gai.jpg',
      'isAsset': true,
      'isFavorite': false,
    },
  ];

  @override
  void initState() {
    super.initState();
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
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color bgWarmColor = Color(0xFFFDF7F7); // Subtle blush background

    return Scaffold(
      backgroundColor: bgWarmColor,
      body: Stack(
        children: [
          // Main Body by active tab
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: IndexedStack(
                index: _currentTab,
                children: [
                  _buildHomeTab(),
                  _buildFavoritesTab(),
                  _buildProfileTab(),
                ],
              ),
            ),
          ),

          // Section 4: Floating Bottom Navigation Bar (3 Main Icons)
          Positioned(
            left: 24,
            right: 24,
            bottom: 22,
            child: _buildFloatingBottomBar(),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 0: HOME PAGE (4 Sections)
  // ==========================================
  Widget _buildHomeTab() {
    final filteredList = _curatedRestaurants.where((r) {
      final name = (r['name'] as String).toLowerCase();
      final cat = (r['category'] as String).toLowerCase();
      return name.contains(_searchQuery.toLowerCase()) ||
          cat.contains(_searchQuery.toLowerCase());
    }).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        top: 12.0,
        bottom: 110.0, // Room for floating bottom nav
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Branding: MealMate Logo
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              'MealMate',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 34,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                color: Color(0xFF6E162B), // Signature burgundy
                letterSpacing: -0.6,
              ),
            ),
          ),

          const SizedBox(height: 14),

          // SECTION 1: Search Bar (ค้นหาร้านอาหาร)
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFF1ECEF), // Soft grey pill
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF221F21),
                    ),
                    decoration: const InputDecoration(
                      hintText: 'ค้นหาร้านอาหาร',
                      hintStyle: TextStyle(
                        fontSize: 14.5,
                        color: Color(0xFF8E888B),
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF6E162B),
                    size: 26,
                  ),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 20,
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // SECTION 2: Swipe Gateway Card (ปัดหาร้านอาหาร)
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, anim, secAnim) =>
                        const DiscoverScreen(),
                    transitionsBuilder: (context, anim, secAnim, child) =>
                        FadeTransition(opacity: anim, child: child),
                    transitionDuration: const Duration(milliseconds: 300),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(24),
              child: Container(
                height: 125,
                decoration: BoxDecoration(
                  color: const Color(0xFF70182E), // Deep burgundy
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x386E162B),
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 26.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ปัดหาร้านอาหาร',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    // White Play / Forward Icon
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 42,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 26),

          // SECTION 3: Recommended Restaurants (แนะนำร้านอาหารสำหรับคุณ !)
          const Text(
            'แนะนำร้านอาหารสำหรับคุณ !',
            style: TextStyle(
              fontSize: 17.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF6E162B),
              letterSpacing: -0.2,
            ),
          ),

          const SizedBox(height: 8),

          // Delicate divider underline below section title
          Container(
            height: 1.2,
            width: double.infinity,
            color: const Color(0xFFD4B0B4),
          ),

          const SizedBox(height: 12),

          // Recommended Restaurants List
          if (filteredList.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 36.0),
              child: Center(
                child: Text(
                  'ไม่พบร้านอาหารที่ตรงกับการค้นหา',
                  style: TextStyle(color: Color(0xFF8E888B), fontSize: 14.5),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredList.length,
              separatorBuilder: (context, index) => const Divider(
                color: Color(0xFFE5CED1),
                thickness: 1.0,
                height: 28,
              ),
              itemBuilder: (context, index) {
                final restaurant = filteredList[index];
                return _buildRestaurantRow(restaurant);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildRestaurantRow(Map<String, dynamic> restaurant) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Restaurant Image
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            width: 76,
            height: 76,
            child: restaurant['isAsset'] == true
                ? Image.asset(
                    restaurant['image'] as String,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFEFECEF),
                      child: const Icon(
                        Icons.restaurant_rounded,
                        color: Color(0xFF6E162B),
                        size: 32,
                      ),
                    ),
                  )
                : Image.network(
                    restaurant['image'] as String,
                    fit: BoxFit.cover,
                  ),
          ),
        ),

        const SizedBox(width: 16),

        // Info: Name, Category, Rating
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                restaurant['name'] as String,
                style: const TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF6E162B),
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                restaurant['category'] as String,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF6B6568),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: Color(0xFF6E162B), // Burgundy star matching image
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${restaurant['rating']}',
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3F3B3E),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // SECTION 4: FLOATING BOTTOM NAVIGATION BAR
  // ==========================================
  Widget _buildFloatingBottomBar() {
    return Container(
      height: 66,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(33),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 22,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 1. หน้าหลัก (Home)
          _buildNavButton(
            index: 0,
            icon: Icons.home_rounded,
            activeColor: const Color(0xFF6E162B),
            inactiveColor: const Color(0xFFBCAEB2),
          ),

          // 2. หัวใจเป็นรายการโปรด (Favorites)
          _buildNavButton(
            index: 1,
            icon: Icons.favorite_border_rounded,
            activeIcon: Icons.favorite_rounded,
            activeColor: const Color(0xFF6E162B),
            inactiveColor: const Color(0xFFBCAEB2),
          ),

          // 3. โปรไฟล์ (Profile)
          _buildNavButton(
            index: 2,
            icon: Icons.account_circle_outlined,
            activeIcon: Icons.account_circle_rounded,
            activeColor: const Color(0xFF6E162B),
            inactiveColor: const Color(0xFFBCAEB2),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required int index,
    required IconData icon,
    IconData? activeIcon,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    final bool isSelected = _currentTab == index;
    return GestureDetector(
      onTap: () => setState(() => _currentTab = index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        child: Icon(
          isSelected ? (activeIcon ?? icon) : icon,
          color: isSelected ? activeColor : inactiveColor,
          size: 30,
        ),
      ),
    );
  }

  // ==========================================
  // TAB 1: FAVORITES (รายการโปรด)
  // ==========================================
  Widget _buildFavoritesTab() {
    final favorites = _curatedRestaurants.where((r) => r['isFavorite'] == true).toList();

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'รายการโปรดของคุณ',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF6E162B),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: favorites.length,
              separatorBuilder: (context, index) => const Divider(
                color: Color(0xFFE5CED1),
                height: 24,
              ),
              itemBuilder: (context, index) =>
                  _buildRestaurantRow(favorites[index]),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: PROFILE (โปรไฟล์)
  // ==========================================
  Widget _buildProfileTab() {
    final user = supabase.auth.currentUser;
    final email = user?.email ?? 'user@mealmate.com';

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          // User Avatar
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              color: const Color(0xFF6E162B).withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF6E162B), width: 2),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Color(0xFF6E162B),
              size: 52,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            email,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF221F21),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'สมาชิก MealMate',
            style: TextStyle(fontSize: 14, color: Color(0xFF8E888B)),
          ),
          const SizedBox(height: 32),

          // Manage restaurants option
          ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            tileColor: Colors.white,
            leading: const Icon(Icons.storefront_rounded, color: Color(0xFF6E162B)),
            title: const Text('เปิดร้านอาหารของคุณ', style: TextStyle(fontWeight: FontWeight.w700)),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CreateRestaurantScreen()),
              );
            },
          ),
          const SizedBox(height: 14),

          // Logout Button
          ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            tileColor: Colors.white,
            leading: const Icon(Icons.logout_rounded, color: Colors.red),
            title: const Text('ออกจากระบบ', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
            onTap: () async {
              await supabase.auth.signOut();
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
