import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart';
import '../auth/login_screen.dart';
import '../profile/user_profile_screen.dart';
import '../profile/settings_screen.dart';
import '../profile/help_center_screen.dart';
import '../profile/report_problem_screen.dart';
import '../restaurants/open_restaurant_intro_screen.dart';
import '../restaurants/restaurant_detail_screen.dart';
import '../restaurants/restaurant_pending_review_screen.dart';
import '../owner/owner_dashboard_screen.dart';
import '../owner/select_restaurant_screen.dart';
import '../flow/category_selection_screen.dart';
import '../admin/admin_dashboard.dart';
import '../../models/favorite_manager.dart';
import '../../providers/auth_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final int initialTab;
  final int? initialIndex;
  const HomeScreen({
    super.key,
    this.initialTab = 0,
    this.initialIndex,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late int _currentTab;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  bool _isSearchFocused = false;
  String? _currentUserType;

  bool get _isOwner {
    final riverpodRole = ref.watch(authProvider)?.role?.trim().toLowerCase();
    if (riverpodRole == 'owner') return true;
    return _currentUserType?.trim().toLowerCase() == 'owner';
  }

  bool get _isAdmin {
    final riverpodRole = ref.watch(authProvider)?.role?.trim().toLowerCase();
    if (riverpodRole == 'admin') return true;
    return _currentUserType?.trim().toLowerCase() == 'admin';
  }

  // Favorites Tab Search Controller & Data
  final TextEditingController _favoriteSearchController = TextEditingController();
  final FocusNode _favoriteFocusNode = FocusNode();
  String _favoriteSearchQuery = '';
  bool _isFavoriteFocused = false;
  bool _isLoadingFavorites = false;

  // Favorite Restaurants synced with FavoriteManager
  List<Map<String, dynamic>> get _favoriteRestaurants => FavoriteManager.favorites;

  Future<void> _loadFavoritesFromSupabase() async {
    if (!mounted) return;
    setState(() => _isLoadingFavorites = true);
    try {
      await FavoriteManager.fetchFavorites();
    } catch (_) {}
    if (mounted) {
      setState(() => _isLoadingFavorites = false);
    }
  }

  // Curated recommended & searchable restaurants matching the design
  final List<Map<String, dynamic>> _curatedRestaurants = [
    {
      'name': 'ข้าวซอยแม่สาย',
      'category': 'ประเภท: อาหารไทย, ก๋วยเตี๋ยว',
      'price': '฿ 50-80 บาท',
      'rating': 4.7,
      'image': 'assets/images/khao_soi.jpg',
      'isAsset': true,
      'isFavorite': true,
      'tags': ['ข้าวซอย', 'ก๋วยเตี๋ยว', 'อาหารไทย', 'khao soi', 'thai'],
    },
    {
      'name': 'โกเผือกโกดำ',
      'category': 'ประเภท: อาหารไทย, อาหารเช้า',
      'price': '฿ 40-70 บาท',
      'rating': 4.7,
      'image': 'assets/images/go_puek.jpg',
      'isAsset': true,
      'isFavorite': true,
      'tags': ['โกเผือกโกดำ', 'อาหารเช้า', 'ขนมปัง', 'ชาไทย', 'breakfast', 'toast'],
    },
    {
      'name': 'ข้าวมันไก่นันทาราม',
      'category': 'ประเภท: อาหารไทย',
      'price': '฿ 50-80 บาท',
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
      'price': '฿ 219-276 บาท',
      'rating': 4.8,
      'image': 'assets/images/shabu_teenoi.jpg',
      'isAsset': true,
      'isFavorite': true,
      'tags': ['shabu', 'ชาบู', 'สุกี้', 'ตี๋น้อย', 'teenoi', 'บุฟเฟต์', 'หม้อไฟ'],
    },
    {
      'name': 'Mo-Mo-Paradise',
      'category': 'ประเภท: ชาบู, สุกี้ยากี้ญี่ปุ่น',
      'price': '฿ 599-799 บาท',
      'rating': 4.9,
      'image': 'assets/images/shabu_momo.jpg',
      'isAsset': true,
      'isFavorite': true,
      'tags': ['shabu', 'ชาบู', 'momo', 'โมโม', 'สุกี้', 'ญี่ปุ่น', 'บุฟเฟต์'],
    },
    {
      'name': 'Shabushi (ชาบูชิ)',
      'category': 'ประเภท: ชาบู, บุฟเฟต์สายพาน',
      'price': '฿ 399-499 บาท',
      'rating': 4.7,
      'image': 'assets/images/shabushi.jpg',
      'isAsset': true,
      'isFavorite': false,
      'tags': ['shabu', 'ชาบู', 'ชาบูชิ', 'shabushi', 'สายพาน', 'บุฟเฟต์'],
    },
    {
      'name': 'ดังเจริญ',
      'category': 'ประเภทร้านอาหาร: อาหารญี่ปุ่น',
      'rating': 4.8,
      'image': 'assets/images/dang_jaroen.jpg',
      'isAsset': true,
      'isFavorite': false,
      'isBookmarked': false,
      'price': '฿ 89-109 บาท',
      'address': '84/2 ม.14 ถ.สุเทพ ต.สุเทพ อ.เมือง เมืองเชียงใหม่ เชียงใหม่',
      'phone': '0951409878',
      'mapUrl': 'www.googlemap.com',
      'tags': ['ดังเจริญ', 'อาหารญี่ปุ่น', 'ญี่ปุ่น', 'japanese', 'ข้าวหน้าเนื้อ', 'แกงกะหรี่', 'dang jaroen'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _currentTab = (widget.initialIndex ?? widget.initialTab).clamp(0, 2);
    _fetchUserType();
    _loadFavoritesFromSupabase();
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

  Future<void> _fetchUserType() async {
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        // 1. ตรวจสอบสิทธิ์ Admin ก่อนเป็นลำดับแรก
        final userData = await supabase
            .from('users')
            .select('user_type, role')
            .eq('id', user.id)
            .maybeSingle();

        final dbType = (userData?['user_type'] ?? userData?['role'])
            ?.toString()
            .trim()
            .toLowerCase();
        final metaType = (user.userMetadata?['user_type'] ??
                user.userMetadata?['role'] ??
                user.appMetadata['user_type'] ??
                user.appMetadata['role'])
            ?.toString()
            .trim()
            .toLowerCase();
        final lowerEmail = (user.email ?? '').trim().toLowerCase();

        if (dbType == 'admin' || metaType == 'admin' || lowerEmail == 'admin@mealmate.com' || lowerEmail == 'admin@test.com') {
          if (mounted) {
            setState(() {
              _currentUserType = 'admin';
            });
          }
          return;
        }

        // 2. ตรวจสอบสถานะร้านอาหารในระบบ
        try {
          final anyRestaurants = await supabase
              .from('restaurants')
              .select('id, status')
              .eq('owner_id', user.id);

          if (anyRestaurants is List && anyRestaurants.isNotEmpty) {
            // เมื่อผู้ใช้ส่งข้อมูลสมัครร้านแล้ว มีร้านในระบบ ให้เป็น owner ทันที (แม้จะยังรออนุมัติ pending)
            try {
              await supabase
                  .from('users')
                  .update({'user_type': 'owner', 'role': 'owner'})
                  .eq('id', user.id);
            } catch (_) {}

            try {
              await supabase.auth.updateUser(
                UserAttributes(data: {'user_type': 'owner', 'role': 'owner'}),
              );
            } catch (_) {}

            if (mounted) {
              setState(() {
                _currentUserType = 'owner';
              });
            }
            return;
          }
        } catch (_) {}

        if (metaType != null && mounted) {
          setState(() {
            _currentUserType = metaType;
          });
        }

        if (dbType != null && mounted) {
          setState(() {
            _currentUserType = dbType;
          });
        }
      }
    } catch (e) {
      debugPrint("Note: User type fetch skipped or table unavailable: $e");
    }
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
                top: _currentTab != 2,
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
      final name = (r['name']?.toString() ?? '').toLowerCase();
      final cat = (r['category']?.toString() ?? '').toLowerCase();
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
                  MaterialPageRoute(
                    builder: (_) => const CategorySelectionScreen(isStandalone: true),
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
                    const Expanded(
                      child: Text(
                        'ปัดหาร้านอาหาร',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
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
              Expanded(
                child: Text(
                  query.isEmpty
                      ? 'แนะนำร้านอาหารสำหรับคุณ !'
                      : 'ร้านอาหารประเภท "$_searchQuery"',
                  style: const TextStyle(
                    fontSize: 17.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF6E162B),
                    letterSpacing: -0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
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
      onTap: () async {
        final bool? isBookmarked = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => RestaurantDetailScreen(restaurantData: restaurant),
          ),
        );
        if (mounted) {
          setState(() {
            if (isBookmarked != null) {
              restaurant['isBookmarked'] = isBookmarked;
              restaurant['isFavorite'] = isBookmarked;
            }
          });
        }
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
            child: () {
              final imgStr = restaurant['image']?.toString() ?? '';
              final isAsset = restaurant['isAsset'] == true || imgStr.startsWith('assets/');
              if (isAsset && imgStr.isNotEmpty) {
                return Image.asset(
                  imgStr,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFFEFECEF),
                    child: const Icon(
                      Icons.restaurant_rounded,
                      color: Color(0xFF6E162B),
                      size: 32,
                    ),
                  ),
                );
              } else if (imgStr.isNotEmpty) {
                return Image.network(
                  imgStr,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFFEFECEF),
                    child: const Icon(
                      Icons.restaurant_rounded,
                      color: Color(0xFF6E162B),
                      size: 32,
                    ),
                  ),
                );
              } else {
                return Container(
                  color: const Color(0xFFEFECEF),
                  child: const Icon(
                    Icons.restaurant_rounded,
                    color: Color(0xFF6E162B),
                    size: 32,
                  ),
                );
              }
            }(),
          ),
        ),

        const SizedBox(width: 16),

        // Info: Name, Category, Rating
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                restaurant['name']?.toString() ?? 'ร้านอาหาร',
                style: const TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF6E162B),
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                restaurant['category']?.toString() ?? 'อาหารทั่วไป',
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
      onTap: () {
        setState(() => _currentTab = index);
        if (index == 1) {
          _loadFavoritesFromSupabase();
        }
      },
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
      final name = (r['name']?.toString() ?? '').toLowerCase();
      final cat = (r['category']?.toString() ?? '').toLowerCase();
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
          child: _isLoadingFavorites && list.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF6E162B),
                  ),
                )
              : RefreshIndicator(
                  color: const Color(0xFF6E162B),
                  onRefresh: _loadFavoritesFromSupabase,
                  child: list.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.15,
                            ),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 76,
                                    height: 76,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF7EFF1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.favorite_border_rounded,
                                      size: 40,
                                      color: Color(0xFF6E162B),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _favoriteSearchQuery.isNotEmpty
                                        ? 'ไม่พบร้านค้าที่ค้นหา'
                                        : 'ยังไม่มีร้านอาหารในรายการโปรด',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF221F21),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _favoriteSearchQuery.isNotEmpty
                                        ? 'ลองค้นหาด้วยคำอื่น หรือชื่อประเภทอาหาร'
                                        : 'กดบันทึกร้านอาหารที่คุณชอบเพื่อดูที่นี่ได้ตลอดเวลา',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF8E888B),
                                    ),
                                  ),
                                  if (_favoriteSearchQuery.isEmpty) ...[
                                    const SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() => _currentTab = 0);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF6E162B),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 22,
                                          vertical: 11,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                      child: const Text(
                                        'สำรวจร้านอาหาร',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
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
        ),
      ],
    );
  }

  String _formatPrice(dynamic raw) {
    String str = raw?.toString().trim() ?? '฿ 100-300 บาท';
    while (str.startsWith('฿฿')) {
      str = str.substring(1).trimLeft();
    }
    if (!str.startsWith('฿')) {
      str = '฿ $str';
    }
    return str;
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
          onTap: () async {
            final bool? isBookmarked = await Navigator.of(context).push<bool>(
              MaterialPageRoute(
                builder: (_) => RestaurantDetailScreen(
                  restaurantData: item,
                  restaurantId: item['id']?.toString() ??
                      item['restaurant_id']?.toString(),
                ),
              ),
            );
            if (mounted) {
              setState(() {
                if (isBookmarked != null) {
                  item['isBookmarked'] = isBookmarked;
                  item['isFavorite'] = isBookmarked;
                  if (!isBookmarked) {
                    FavoriteManager.removeFavorite(
                        item['restaurant_id']?.toString() ??
                            item['id']?.toString() ??
                            item['name']?.toString() ??
                            '');
                  } else {
                    FavoriteManager.addFavorite(item);
                  }
                }
              });
            }
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
                    child: () {
                      final imageStr = item['image']?.toString() ??
                          item['image_url']?.toString() ??
                          '';
                      final isAsset = item['isAsset'] == true ||
                          imageStr.startsWith('assets/');
                      if (isAsset && imageStr.isNotEmpty) {
                        return Image.asset(
                          imageStr,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            color: const Color(0xFFEFECEF),
                            child: const Icon(
                              Icons.restaurant_rounded,
                              color: Color(0xFF6E162B),
                              size: 34,
                            ),
                          ),
                        );
                      } else if (imageStr.isNotEmpty) {
                        return Image.network(
                          imageStr,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            color: const Color(0xFFEFECEF),
                            child: const Icon(
                              Icons.restaurant_rounded,
                              color: Color(0xFF6E162B),
                              size: 34,
                            ),
                          ),
                        );
                      } else {
                        return Container(
                          color: const Color(0xFFEFECEF),
                          child: const Icon(
                            Icons.restaurant_rounded,
                            color: Color(0xFF6E162B),
                            size: 34,
                          ),
                        );
                      }
                    }(),
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
                              item['name']?.toString() ?? 'ร้านอาหาร',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF221F21),
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              final name = item['name']?.toString() ?? '';
                              final restId = (item['restaurant_id'] ??
                                      item['id'])
                                  ?.toString();
                              FavoriteManager.removeFavorite(restId ?? name);
                              setState(() {});
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'นำ "$name" ออกจากรายการโปรดแล้ว'),
                                  backgroundColor: const Color(0xFF4A4447),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  action: SnackBarAction(
                                    label: 'เลิกทำ',
                                    textColor: const Color(0xFFFFB4AB),
                                    onPressed: () {
                                      FavoriteManager.addFavorite(item);
                                      setState(() {});
                                    },
                                  ),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                Icons.bookmark_rounded,
                                color: Color(0xFF6E162B),
                                size: 26,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 2),

                      // Category
                      Text(
                        item['category']?.toString() ?? 'อาหารทั่วไป',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B6568),
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      const SizedBox(height: 3),

                      // Price Range
                      Text(
                        _formatPrice(item['price']),
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
                                '${item['rating'] ?? '4.5'}',
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
  // TAB 2: PROFILE (ผู้ใช้งาน - User - Profiles)
  // ==========================================
  Widget _buildProfileTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Solid Burgundy Header with Title "ผู้ใช้งาน"
        Container(
          color: const Color(0xFF6E162B),
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 34,
            left: 24,
            right: 24,
            bottom: 24,
          ),
          alignment: Alignment.bottomLeft,
          child: const Text(
            'ผู้ใช้งาน',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
        ),

        // 2. White Body with 5 Menu Action Cards and Sign Out Button
        Expanded(
          child: Container(
            color: Colors.white,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 26,
                bottom: 110, // Room for floating bottom dock
              ),
              child: Column(
                children: [
                  // 1. โปรไฟล์
                  _buildProfileMenuCard(
                    icon: Icons.people_outline_rounded,
                    title: 'โปรไฟล์',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const UserProfileScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // 2. การตั้งค่า
                  _buildProfileMenuCard(
                    icon: Icons.settings_outlined,
                    title: 'การตั้งค่า',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // 3. ศูนย์ช่วยเหลือ
                  _buildProfileMenuCard(
                    icon: Icons.search_rounded,
                    title: 'ศูนย์ช่วยเหลือ',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const HelpCenterScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // 4. รายงานปัญหา
                  _buildProfileMenuCard(
                    icon: Icons.error_outline_rounded,
                    title: 'รายงานปัญหา',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ReportProblemScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // 4.1 แดชบอร์ดผู้ดูแลระบบ (สำหรับ Admin)
                  if (_isAdmin) ...[
                    _buildProfileMenuCard(
                      icon: Icons.admin_panel_settings_outlined,
                      title: 'แดชบอร์ดผู้ดูแลระบบ (Admin)',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AdminDashboard(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                  ],

                  // 5. เปิดร้านอาหาร / แดชบอร์ดเจ้าของร้าน (เช็คตาม user_type / role)
                  _buildProfileMenuCard(
                    icon: _isOwner
                        ? Icons.dashboard_customize_outlined
                        : Icons.storefront_outlined,
                    title: _isOwner ? 'แดชบอร์ดเจ้าของร้าน' : 'เปิดร้านอาหาร',
                    onTap: () async {
                      if (!_isOwner) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const OpenRestaurantIntroScreen(),
                          ),
                        );
                        return;
                      }

                      // เมื่อเป็น owner: ตรวจสอบสถานะการอนุมัติร้าน
                      // แอดมินอนุมัติแล้ว (approved) เท่านั้น ถึงจะเข้าหน้าเลือกร้านอาหาร (รูปที่ 1)
                      // ถ้ายังรออนุมัติ (pending) ให้ขึ้นหน้าสีแดงที่เป็นหน้ารอตรวจสอบ
                      try {
                        final user = supabase.auth.currentUser;
                        final currentUid = user?.id;
                        List<dynamic> myRests = [];
                        if (currentUid != null && currentUid.isNotEmpty) {
                          myRests = await supabase
                              .from('restaurants')
                              .select('id, name, status')
                              .eq('owner_id', currentUid);
                        }

                        if (myRests.isNotEmpty) {
                          final hasApprovedOrRejected = myRests.any(
                              (r) => r['status'] == 'approved' || r['status'] == 'rejected');
                          if (hasApprovedOrRejected) {
                            if (context.mounted) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const SelectRestaurantScreen(),
                                ),
                              );
                            }
                            return;
                          }

                          final pendingRest = myRests.firstWhere(
                            (r) => r['status'] == 'pending',
                            orElse: () => myRests.first,
                          );
                          if (context.mounted) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => RestaurantPendingReviewScreen(
                                  restaurantName: pendingRest['name']?.toString() ?? 'ร้านอาหารของคุณ',
                                ),
                              ),
                            );
                          }
                          return;
                        }
                      } catch (e) {
                        debugPrint('Note: Error checking owner restaurant status: $e');
                      }

                      if (context.mounted) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SelectRestaurantScreen(),
                          ),
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 36),

                  // ปุ่ม ลงชื่อออก
                  _buildSignOutButton(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileMenuCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF6E162B),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: const Color(0xFF6E162B),
                  size: 25,
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6E162B),
                    letterSpacing: -0.2,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF6E162B),
                  size: 26,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignOutButton() {
    return Container(
      height: 46,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF6E162B),
          width: 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _showSignOutConfirmDialog,
          child: const Center(
            child: Text(
              'ลงชื่อออก',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6E162B),
                letterSpacing: -0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }


  void _showSignOutConfirmDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (BuildContext dialogContext) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 275,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFD4ADB5),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 26),
                    child: Text(
                      'ต้องการลงชื่อออกจากระบบ?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF221F21),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  Container(height: 1.0, color: const Color(0xFFD4ADB5)),
                  SizedBox(
                    height: 48,
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(18),
                            ),
                            onTap: () => Navigator.of(dialogContext).pop(),
                            child: const Center(
                              child: Text(
                                'ยกเลิก',
                                style: TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF221F21),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(width: 1.0, height: double.infinity, color: const Color(0xFFD4ADB5)),
                        Expanded(
                          child: InkWell(
                            borderRadius: const BorderRadius.only(
                              bottomRight: Radius.circular(18),
                            ),
                            onTap: () async {
                              Navigator.of(dialogContext).pop();
                              await supabase.auth.signOut();
                              if (mounted) {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                                );
                              }
                            },
                            child: const Center(
                              child: Text(
                                'ยืนยัน',
                                style: TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF6E162B),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
