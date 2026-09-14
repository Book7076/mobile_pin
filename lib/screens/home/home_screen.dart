import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../main.dart';
import '../auth/login_screen.dart';
import '../restaurants/create_restaurant_screen.dart';
import '../restaurants/restaurant_detail_screen.dart';
import 'discover_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentTab = 0; // 0: Home, 1: Favorites, 2: Profile
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  bool _isSearchFocused = false;

  // Favorites Tab Search Controller & Data
  final TextEditingController _favoriteSearchController = TextEditingController();
  final FocusNode _favoriteFocusNode = FocusNode();
  String _favoriteSearchQuery = '';
  bool _isFavoriteFocused = false;

  // Favorite Restaurants matching User - Favorite reference design
  final List<Map<String, dynamic>> _favoriteRestaurants = [
    {
      'name': 'RawTruckr',
      'category': 'อาหารเกาหลี',
      'price': '฿฿ 150-350 บาท',
      'rating': 4.4,
      'image': 'assets/images/rawtruckr.jpg',
      'isAsset': true,
      'isBookmarked': true,
    },
    {
      'name': 'ครัวปันเจียง',
      'category': 'อาหารไทย/อาหารตามสั่ง',
      'price': '฿฿ 60-90 บาท',
      'rating': 4.7,
      'image': 'assets/images/krua_pan_jiang.jpg',
      'isAsset': true,
      'isBookmarked': true,
    },
    {
      'name': 'ก๋วยเตี๋ยวเรือขั้นเทพ',
      'category': 'อาหารไทย/ก๋วยเตี๋ยว',
      'price': '฿฿ 50-80 บาท',
      'rating': 4.3,
      'image': 'assets/images/boat_noodles.jpg',
      'isAsset': true,
      'isBookmarked': true,
    },
    {
      'name': 'TEDS Coffee & Eatery',
      'category': 'ร้านกาแฟ/ขนมหวาน',
      'price': '฿฿ 60-150 บาท',
      'rating': 4.9,
      'image': 'assets/images/teds_coffee.jpg',
      'isAsset': true,
      'isBookmarked': true,
    },
  ];

  // Curated recommended & searchable restaurants matching the design
  final List<Map<String, dynamic>> _curatedRestaurants = [
    {
      'name': 'ข้าวซอยแม่สาย',
      'category': 'ประเภท: อาหารไทย, ก๋วยเตี๋ยว',
      'rating': 4.7,
      'image': 'assets/images/khao_soi.jpg',
      'isAsset': true,
      'isFavorite': true,
      'tags': ['ข้าวซอย', 'ก๋วยเตี๋ยว', 'อาหารไทย', 'khao soi', 'thai'],
    },
    {
      'name': 'โกเผือกโกดำ',
      'category': 'ประเภท: อาหารไทย, อาหารเช้า',
      'rating': 4.7,
      'image': 'assets/images/go_puek.jpg',
      'isAsset': true,
      'isFavorite': true,
      'tags': ['โกเผือกโกดำ', 'อาหารเช้า', 'ขนมปัง', 'ชาไทย', 'breakfast', 'toast'],
    },
    {
      'name': 'ข้าวมันไก่นันทาราม',
      'category': 'ประเภท: อาหารไทย',
      'rating': 4.8,
      'image': 'assets/images/khao_man_gai.jpg',
      'isAsset': true,
      'isFavorite': false,
      'tags': ['ข้าวมันไก่', 'อาหารไทย', 'ไก่ตอน', 'chicken rice'],
    },
    // Shabu Category Restaurants
    {
      'name': 'สุกี้ตี๋น้อย (Suki Teenoi)',
      'category': 'ประเภท: ชาบู, สุกี้, บุฟเฟต์',
      'rating': 4.8,
      'image': 'assets/images/shabu_teenoi.jpg',
      'isAsset': true,
      'isFavorite': true,
      'tags': ['shabu', 'ชาบู', 'สุกี้', 'ตี๋น้อย', 'teenoi', 'บุฟเฟต์', 'หม้อไฟ'],
    },
    {
      'name': 'Mo-Mo-Paradise',
      'category': 'ประเภท: ชาบู, สุกี้ยากี้ญี่ปุ่น',
      'rating': 4.9,
      'image': 'assets/images/shabu_momo.jpg',
      'isAsset': true,
      'isFavorite': true,
      'tags': ['shabu', 'ชาบู', 'momo', 'โมโม', 'สุกี้', 'ญี่ปุ่น', 'บุฟเฟต์'],
    },
    {
      'name': 'Shabushi (ชาบูชิ)',
      'category': 'ประเภท: ชาบู, บุฟเฟต์สายพาน',
      'rating': 4.7,
      'image': 'assets/images/shabushi.jpg',
      'isAsset': true,
      'isFavorite': false,
      'tags': ['shabu', 'ชาบู', 'ชาบูชิ', 'shabushi', 'สายพาน', 'บุฟเฟต์'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      if (mounted) {
        setState(() {
          _isSearchFocused = _searchFocusNode.hasFocus;
        });
      }
    });
    _favoriteFocusNode.addListener(() {
      if (mounted) {
        setState(() {
          _isFavoriteFocused = _favoriteFocusNode.hasFocus;
        });
      }
    });
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
    _searchFocusNode.dispose();
    _favoriteSearchController.dispose();
    _favoriteFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color bgWarmColor = Color(0xFFFDF7F7); // Subtle blush background
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final bool isKeyboardVisible = keyboardHeight > 0;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (_searchFocusNode.hasFocus) {
          _searchFocusNode.unfocus();
        }
        if (_favoriteFocusNode.hasFocus) {
          _favoriteFocusNode.unfocus();
        }
      },
      child: Scaffold(
        backgroundColor: bgWarmColor,
        resizeToAvoidBottomInset: true,
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
            // Seamlessly hide when keyboard pops up, smoothly reappear when keyboard closes
            if (!isKeyboardVisible)
              Positioned(
                left: 24,
                right: 24,
                bottom: 22,
                child: _buildFloatingBottomBar(),
              ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 0: HOME PAGE (4 Sections)
  // ==========================================
  Widget _buildHomeTab() {
    final String query = _searchQuery.trim().toLowerCase();
    final filteredList = _curatedRestaurants.where((r) {
      if (query.isEmpty) {
        return (r['tags'] as List<String>?)?.contains('khao soi') == true ||
            (r['tags'] as List<String>?)?.contains('breakfast') == true ||
            (r['tags'] as List<String>?)?.contains('chicken rice') == true;
      }
      final name = (r['name'] as String).toLowerCase();
      final cat = (r['category'] as String).toLowerCase();
      final tags = (r['tags'] as List<String>?)?.map((t) => t.toLowerCase()).toList() ?? [];
      return name.contains(query) ||
          cat.contains(query) ||
          tags.any((t) => t.contains(query));
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
              border: Border.all(
                color: _isSearchFocused
                    ? const Color(0xFF6E162B).withOpacity(0.35)
                    : Colors.transparent,
                width: 1.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isSearchFocused
                      ? const Color(0xFF6E162B).withOpacity(0.08)
                      : Colors.black.withOpacity(0.03),
                  blurRadius: 10,
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
                    focusNode: _searchFocusNode,
                    cursorColor: const Color(0xFF6E162B),
                    cursorWidth: 2.2,
                    cursorRadius: const Radius.circular(2),
                    showCursor: true,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _searchFocusNode.unfocus(),
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF221F21),
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: (_isSearchFocused && _searchQuery.isEmpty)
                          ? ''
                          : 'ค้นหาร้านอาหาร',
                      hintStyle: const TextStyle(
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
                if (_searchQuery.isNotEmpty)
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF8E888B),
                      size: 22,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 20,
                  )
                else
                  IconButton(
                    icon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF6E162B),
                      size: 26,
                    ),
                    onPressed: () {
                      if (!_searchFocusNode.hasFocus) {
                        _searchFocusNode.requestFocus();
                      }
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 20,
                  ),
              ],
            ),
          ),

          // Quick category chips
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildQuickCategoryChip('ชาบู (Shabu)', 'Shabu'),
                const SizedBox(width: 8),
                _buildQuickCategoryChip('ก๋วยเตี๋ยว', 'ก๋วยเตี๋ยว'),
                const SizedBox(width: 8),
                _buildQuickCategoryChip('อาหารเช้า', 'อาหารเช้า'),
                const SizedBox(width: 8),
                _buildQuickCategoryChip('ข้าวมันไก่', 'ข้าวมันไก่'),
                const SizedBox(width: 8),
                _buildQuickCategoryChip('บุฟเฟต์', 'บุฟเฟต์'),
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

          // SECTION 3: Recommended Restaurants or Dynamic Search Results
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                query.isEmpty
                    ? 'แนะนำร้านอาหารสำหรับคุณ !'
                    : 'ร้านอาหารประเภท "$_searchQuery"',
                style: const TextStyle(
                  fontSize: 17.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF6E162B),
                  letterSpacing: -0.2,
                ),
              ),
              if (query.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                    _searchFocusNode.unfocus();
                  },
                  child: const Text(
                    'ดูทั้งหมด',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6E162B),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
            ],
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
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RestaurantDetailScreen(restaurantData: restaurant),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Row(
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
    ),
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
    final query = _favoriteSearchQuery.trim().toLowerCase();
    final list = _favoriteRestaurants.where((r) {
      if (query.isEmpty) return true;
      final name = (r['name'] as String).toLowerCase();
      final cat = (r['category'] as String).toLowerCase();
      return name.contains(query) || cat.contains(query);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: "รายการโปรด" and burgundy heart icon
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'รายการโปรด',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF6E162B),
                  letterSpacing: -0.4,
                ),
              ),
              Icon(
                Icons.favorite_rounded,
                color: Color(0xFF6E162B),
                size: 32,
              ),
            ],
          ),
        ),

        // Thin divider line
        Container(
          height: 1.2,
          width: double.infinity,
          color: const Color(0xFFE5CED1),
        ),

        // Search Bar: "ค้นหาร้านค้า"
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF1ECEF),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _isFavoriteFocused
                    ? const Color(0xFF6E162B).withOpacity(0.35)
                    : Colors.transparent,
                width: 1.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isFavoriteFocused
                      ? const Color(0xFF6E162B).withOpacity(0.08)
                      : Colors.black.withOpacity(0.02),
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
                    controller: _favoriteSearchController,
                    focusNode: _favoriteFocusNode,
                    cursorColor: const Color(0xFF6E162B),
                    cursorWidth: 2.2,
                    cursorRadius: const Radius.circular(2),
                    showCursor: true,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _favoriteFocusNode.unfocus(),
                    onChanged: (val) =>
                        setState(() => _favoriteSearchQuery = val),
                    style: const TextStyle(
                      fontSize: 14.5,
                      color: Color(0xFF221F21),
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText:
                          (_isFavoriteFocused && _favoriteSearchQuery.isEmpty)
                              ? ''
                              : 'ค้นหาร้านค้า',
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8E888B),
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (_favoriteSearchQuery.isNotEmpty)
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF8E888B),
                      size: 20,
                    ),
                    onPressed: () {
                      _favoriteSearchController.clear();
                      setState(() => _favoriteSearchQuery = '');
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 18,
                  )
                else
                  IconButton(
                    icon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF221F21),
                      size: 22,
                    ),
                    onPressed: () {
                      if (!_favoriteFocusNode.hasFocus) {
                        _favoriteFocusNode.requestFocus();
                      }
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    splashRadius: 18,
                  ),
              ],
            ),
          ),
        ),

        // Favorite Cards List
        Expanded(
          child: list.isEmpty
              ? const Center(
                  child: Text(
                    'ไม่พบร้านค้าในรายการโปรด',
                    style: TextStyle(color: Color(0xFF8E888B), fontSize: 14.5),
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 2,
                    bottom: 100, // Room for bottom dock
                  ),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    return _buildFavoriteCard(list[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFavoriteCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => RestaurantDetailScreen(restaurantData: item),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Restaurant Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: 86,
                    height: 86,
                    child: item['isAsset'] == true
                        ? Image.asset(
                            item['image'] as String,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: const Color(0xFFEFECEF),
                              child: const Icon(
                                Icons.restaurant_rounded,
                                color: Color(0xFF6E162B),
                                size: 34,
                              ),
                            ),
                          )
                        : Image.network(
                            item['image'] as String,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),

                const SizedBox(width: 14),

                // Information Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and Bookmark Ribbon
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item['name'] as String,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF221F21),
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.bookmark_rounded,
                            color: Color(0xFF6E162B),
                            size: 26,
                          ),
                        ],
                      ),

                      const SizedBox(height: 2),

                      // Category
                      Text(
                        item['category'] as String,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B6568),
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      const SizedBox(height: 3),

                      // Price Range
                      Text(
                        item['price'] as String,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B6568),
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Rating & Detail Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Color(0xFF6E162B),
                                size: 17,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${item['rating']}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF3F3B3E),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                'รายละเอียด',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF221F21),
                                ),
                              ),
                              SizedBox(width: 2),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 16,
                                color: Color(0xFF221F21),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // TAB 2: PROFILE (โปรไฟล์)
  // ==========================================
  Widget _buildProfileTab() {
    final user = supabase.auth.currentUser;
    final email = user?.email ?? 'test@test.com';

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

  Widget _buildQuickCategoryChip(String label, String categoryKey) {
    final bool isSelected =
        _searchQuery.toLowerCase() == categoryKey.toLowerCase();
    return GestureDetector(
      onTap: () {
        if (isSelected) {
          _searchController.clear();
          setState(() => _searchQuery = '');
        } else {
          _searchController.text = categoryKey;
          setState(() => _searchQuery = categoryKey);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6E162B) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF6E162B)
                : const Color(0xFFE5CED1),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF5A5255),
          ),
        ),
      ),
    );
  }
}
