import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../models/favorite_manager.dart';
import '../../models/restaurant_model.dart';
import '../../models/swipe_session_model.dart';
import '../../providers/restaurant_provider.dart';
import '../../widgets/meal_mate_logo.dart';
import '../restaurants/restaurant_detail_screen.dart';
import 'finish_transition_screen.dart';

/// Screen for swiping restaurants:
/// - Swipe right or tap green heart icon to LIKE
/// - Swipe left or tap red cross icon to DISLIKE/SKIP
/// - Tap middle "i" icon to view restaurant details
/// - Tap "ถัดไป >" to finish choosing and proceed to SelectedRestaurantsScreen
class FoodSwipeScreen extends ConsumerStatefulWidget {
  const FoodSwipeScreen({super.key});

  @override
  ConsumerState<FoodSwipeScreen> createState() => _FoodSwipeScreenState();
}

class _FoodSwipeScreenState extends ConsumerState<FoodSwipeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  Animation<Offset>? _flyAnimation;
  Animation<double>? _rotationAnimation;

  Offset _dragOffset = Offset.zero;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _animController.addListener(() {
      setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(restaurantsProvider.notifier).loadRestaurants();
      final session = ref.read(swipeSessionProvider);
      final criteria = ref.read(filterCriteriaProvider);
      if (session.currentSessionDbId != null) {
        // ดึงประเภทที่ผู้ใช้เลือกใน session นี้จากตาราง swipe_session_cuisines โดยกรองด้วย session_id
        await ref
            .read(swipeSessionProvider.notifier)
            .loadSessionCuisines(session.currentSessionDbId!);
      } else if (criteria.selectedCategories.isNotEmpty ||
          criteria.cuisineTypeId != null) {
        final cuisineTypeIds = criteria.selectedCategories
            .map((cat) => mapCategoryToCuisineTypeId(cat))
            .whereType<int>()
            .toSet()
            .toList();
        final cuisineTypeId = criteria.cuisineTypeId ??
            (cuisineTypeIds.isNotEmpty ? cuisineTypeIds.first : 1);
        if (cuisineTypeIds.isEmpty) {
          cuisineTypeIds.add(cuisineTypeId);
        }
        await ref.read(swipeSessionProvider.notifier).initSession(
          cuisineTypeId: cuisineTypeId,
          cuisineTypeIds: cuisineTypeIds,
          priceMin: criteria.minBudget,
          priceMax: criteria.maxBudget ?? 1000.0,
        );
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  List<RestaurantModel> _getSwipeList(List<RestaurantModel> allRestaurants) {
    final preferredKeys = [
      'rest_shabu_mouood',
      'rest_rawtruckr',
      'rest_teds_coffee',
      'rawtruckr',
      'teds coffee',
    ];

    final preferred = <RestaurantModel>[];
    final others = <RestaurantModel>[];

    for (final r in allRestaurants) {
      final nameLower = r.name.toLowerCase();
      final idLower = r.id.toLowerCase();
      final isPref = preferredKeys.any((k) => idLower == k || nameLower.contains(k));
      if (isPref) {
        preferred.add(r);
      } else {
        others.add(r);
      }
    }

    return [...preferred, ...others];
  }

  void _onSwipeLeft(RestaurantModel restaurant) {
    if (_isAnimating) return;
    HapticFeedback.lightImpact();
    _animateCard(const Offset(-500, 0), -0.3, onComplete: () {
      ref.read(swipeSessionProvider.notifier).pass(restaurant);
    });
  }

  void _onSwipeRight(RestaurantModel restaurant) {
    if (_isAnimating) return;
    HapticFeedback.lightImpact();
    _animateCard(const Offset(500, 0), 0.3, onComplete: () {
      ref.read(swipeSessionProvider.notifier).like(restaurant);
      final updatedLiked = ref.read(swipeSessionProvider).likedRestaurants;
      if (updatedLiked.length >= 5) {
        // Picked 5 complete restaurants! Trigger "จบแล้วจ้า 🛎️" transition
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const FinishTransitionScreen(),
          ),
        );
      }
    });
  }

  void _animateCard(Offset targetOffset, double targetRotation,
      {required VoidCallback onComplete}) {
    _isAnimating = true;
    final startOffset = _dragOffset;
    final startRotation = _dragOffset.dx / 400.0;

    _flyAnimation = Tween<Offset>(
      begin: startOffset,
      end: targetOffset,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _rotationAnimation = Tween<double>(
      begin: startRotation,
      end: targetRotation,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _animController.forward(from: 0.0).then((_) {
      onComplete();
      _animController.reset();
      setState(() {
        _dragOffset = Offset.zero;
        _isAnimating = false;
      });
    });
  }

  void _navigateToDetails(RestaurantModel restaurant) {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RestaurantDetailScreen(restaurantId: restaurant.id),
      ),
    );
  }

  void _navigateToSelectedRestaurants() {
    HapticFeedback.mediumImpact();
    final likedList = ref.read(swipeSessionProvider).likedRestaurants;
    if (likedList.isNotEmpty) {
      // Mark session as completed in Supabase & provider
      ref.read(swipeSessionProvider.notifier).finishSession();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const FinishTransitionScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'กรุณาปัดขวาเพื่อเลือกร้านอย่างน้อย 1 ร้านก่อนไปต่อจ้า',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: AppConstants.burgundyPrimary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(milliseconds: 2200),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final swipeSession = ref.watch(swipeSessionProvider);
    final swipedIds = {
      ...swipeSession.likedRestaurants.map((r) => r.id),
      ...swipeSession.passedRestaurants.map((r) => r.id),
    };

    // Only show restaurants that match the selected Category and Budget criteria
    final allFiltered = ref.watch(filteredRestaurantsProvider);
    final orderedList = _getSwipeList(allFiltered);

    // Filter out any restaurants that have already been swiped (left or right)
    final listToSwipe = orderedList
        .where((r) => !swipedIds.contains(r.id))
        .toList();

    final isEnd = listToSwipe.isEmpty;
    final currentRestaurant = isEnd ? null : listToSwipe.first;
    final nextRestaurant =
        (listToSwipe.length > 1) ? listToSwipe[1] : null;

    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppConstants.burgundyPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar (Back button & MealMate Branding)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 22),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  _buildMealMateLogo(),
                ],
              ),
            ),

            // Card Stack Area
            Expanded(
              child: isEnd
                  ? _buildEmptyOrFinishedState()
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        // Next Card (Behind)
                        if (nextRestaurant != null)
                          Transform.scale(
                            scale: 0.94,
                            child: _buildRestaurantCard(
                              nextRestaurant,
                              isInteractive: false,
                              screenSize: screenSize,
                            ),
                          ),

                        // Current Interactive Card
                        if (currentRestaurant != null)
                          _buildTopSwipeCard(currentRestaurant, screenSize),
                      ],
                    ),
            ),

            // Bottom Action Controls (Dislike, Info, Like) & "ถัดไป >"
            _buildBottomControls(currentRestaurant),
          ],
        ),
      ),
    );
  }

  /// MealMate Official Logo matching LoginScreen styling with vector rings, fork, spoon & heart
  Widget _buildMealMateLogo() {
    return const MealMateLogo(
      size: 42,
      textSize: 22,
      textSpacing: 2,
      showText: true,
      animateHeart: false,
      ringColor: Colors.white,
      iconColor: Colors.white,
    );
  }

  /// Interactive Top Card with Drag, Rotation, and Stamp Overlays
  Widget _buildTopSwipeCard(RestaurantModel restaurant, Size screenSize) {
    Offset currentOffset = _dragOffset;
    double currentAngle = (_dragOffset.dx / screenSize.width) * 0.25;

    if (_isAnimating && _flyAnimation != null && _rotationAnimation != null) {
      currentOffset = _flyAnimation!.value;
      currentAngle = _rotationAnimation!.value;
    }

    final double dragRatio = (currentOffset.dx / 120.0).clamp(-1.0, 1.0);

    return GestureDetector(
      onPanUpdate: (details) {
        if (_isAnimating) return;
        setState(() {
          _dragOffset += details.delta;
        });
      },
      onPanEnd: (details) {
        if (_isAnimating) return;
        final velocity = details.velocity.pixelsPerSecond.dx;
        if (_dragOffset.dx > 110 || velocity > 700) {
          _onSwipeRight(restaurant);
        } else if (_dragOffset.dx < -110 || velocity < -700) {
          _onSwipeLeft(restaurant);
        } else {
          // Snap back
          setState(() {
            _dragOffset = Offset.zero;
          });
        }
      },
      child: Transform.translate(
        offset: currentOffset,
        child: Transform.rotate(
          angle: currentAngle,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              _buildRestaurantCard(
                restaurant,
                isInteractive: true,
                screenSize: screenSize,
              ),

              // Green Heart Stamp Overlay (When dragging right)
              if (dragRatio > 0.15)
                Positioned(
                  top: 50,
                  right: 40,
                  child: Opacity(
                    opacity: (dragRatio * 1.2).clamp(0.0, 1.0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: Color(0xFF2E7D32),
                        size: 96,
                      ),
                    ),
                  ),
                ),

              // Red Cross Stamp Overlay (When dragging left)
              if (dragRatio < -0.15)
                Positioned(
                  top: 50,
                  left: 40,
                  child: Opacity(
                    opacity: ((-dragRatio) * 1.2).clamp(0.0, 1.0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFFC62828),
                        size: 110,
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

  /// Restaurant Card presentation matching mockup
  Widget _buildRestaurantCard(
    RestaurantModel restaurant, {
    required bool isInteractive,
    required Size screenSize,
  }) {
    final isFav =
        restaurant.isFavorite || FavoriteManager.isFavorite(restaurant.name);

    return Center(
      child: Container(
        width: screenSize.width * 0.88,
        height: screenSize.height * 0.64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image (Prioritizing is_logo == false food/menu photo from DB)
              restaurant.imageUrls.isNotEmpty
                  ? _buildCardImage(restaurant.imageUrls.first)
                  : _buildImagePlaceholder(),

              // Bookmark / Favorite Button (Top-Right) - only on top interactive card
              if (isInteractive)
                Positioned(
                  top: 16,
                  right: 16,
                  child: Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  elevation: 4,
                  child: InkWell(
                    key: isInteractive
                        ? const ValueKey('swipe_flag_button')
                        : null,
                    customBorder: const CircleBorder(),
                    onTap: isInteractive
                        ? () {
                            HapticFeedback.lightImpact();
                            final newFav = !isFav;
                            ref
                                .read(restaurantsProvider.notifier)
                                .toggleFavorite(restaurant.id);

                            if (newFav) {
                              FavoriteManager.addFavorite({
                                'id': restaurant.id,
                                'restaurant_id': restaurant.id,
                                'name': restaurant.name,
                                'category': _formatCategoryLabel(restaurant),
                                'price': restaurant.priceRange,
                                'rating': restaurant.rating,
                                'image': restaurant.imageUrls.isNotEmpty
                                    ? restaurant.imageUrls.first
                                    : 'assets/images/rawtruckr.jpg',
                                'isAsset': false,
                                'isBookmarked': true,
                                'isFavorite': true,
                              });
                            } else {
                              FavoriteManager.removeFavorite(
                                  restaurant.id.isNotEmpty
                                      ? restaurant.id
                                      : restaurant.name);
                            }

                            setState(() {});

                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Icon(
                                      newFav
                                          ? Icons.bookmark_rounded
                                          : Icons.bookmark_outline_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        newFav
                                            ? 'บันทึก "${restaurant.name}" เข้าสู่รายการโปรดแล้ว'
                                            : 'นำ "${restaurant.name}" ออกจากรายการโปรดแล้ว',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: AppConstants.burgundyPrimary,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                duration: const Duration(milliseconds: 1800),
                              ),
                            );
                          }
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        isFav
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_outline_rounded,
                        color: AppConstants.burgundyPrimary,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom Gradient Overlay & Details
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.85),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Restaurant Name
                      Text(
                        restaurant.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      // Category Badges (แสดงเฉพาะประเภทที่ ร้านนั้นมี และผู้ใช้เลือกไว้)
                      _buildCategoryBadges(restaurant),
                      const SizedBox(height: 8),

                      // Rating & Review Count
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Color(0xFFFFC107),
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            restaurant.reviewCount > 0
                                ? '${restaurant.rating.toStringAsFixed(1)} (${restaurant.reviewCount} รีวิว)'
                                : (restaurant.rating > 0
                                    ? '${restaurant.rating.toStringAsFixed(1)} (${restaurant.reviewCount} รีวิว)'
                                    : '0.0 (ยังไม่มีรีวิว)'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Price Range
                      Row(
                        children: [
                          Container(
                            width: 18,
                            height: 18,
                            decoration: const BoxDecoration(
                              color: Color(0xFF22C55E),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text(
                                '฿',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            restaurant.priceRange,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardImage(String imageUrl) {
    if (imageUrl.startsWith('data:image')) {
      try {
        final commaIndex = imageUrl.indexOf(',');
        final base64String = commaIndex != -1
            ? imageUrl.substring(commaIndex + 1)
            : imageUrl;
        final bytes = base64Decode(base64String.replaceAll(RegExp(r'\s+'), ''));
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildImagePlaceholder(),
        );
      } catch (_) {
        return _buildImagePlaceholder();
      }
    } else if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildImagePlaceholder(),
      );
    } else if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildImagePlaceholder(),
      );
    }
    return _buildImagePlaceholder();
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: const Color(0xFF2D3748),
      child: const Icon(Icons.restaurant, size: 64, color: Colors.white70),
    );
  }

  Widget _buildCategoryBadges(RestaurantModel restaurant) {
    final session = ref.watch(swipeSessionProvider);
    final criteria = ref.watch(filterCriteriaProvider);

    final matchedCategories = getMatchedCuisineLabelsForRestaurant(
      restaurant,
      sessionCuisineTypeIds: session.sessionCuisineTypeIds,
      selectedCategories: criteria.selectedCategories,
    );

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: matchedCategories.map((catName) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppConstants.burgundyPrimary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            catName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }

  String _formatCategoryLabel(RestaurantModel restaurant) {
    final session = ref.read(swipeSessionProvider);
    final selectedCategories =
        ref.read(filterCriteriaProvider).selectedCategories;
    final matchedList = getMatchedCuisineLabelsForRestaurant(
      restaurant,
      sessionCuisineTypeIds: session.sessionCuisineTypeIds,
      selectedCategories: selectedCategories,
    );
    return matchedList.join('/');
  }

  /// Bottom Controls: Dislike (X), Info (i), Like (Heart) and "ถัดไป >"
  Widget _buildBottomControls(RestaurantModel? currentRestaurant) {
    final likedCount =
        ref.watch(swipeSessionProvider).likedRestaurants.length;
    final canProceed = likedCount >= 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Red Cross Button (Dislike / Skip)
              _buildActionButton(
                key: const ValueKey('swipe_dislike_button'),
                size: 64,
                onTap: currentRestaurant != null
                    ? () => _onSwipeLeft(currentRestaurant)
                    : null,
                icon: const Icon(
                  Icons.close_rounded,
                  color: Color(0xFFC62828),
                  size: 34,
                ),
              ),

              const SizedBox(width: 24),

              // Info Button (i) -> Details
              _buildActionButton(
                key: const ValueKey('swipe_info_button'),
                size: 46,
                onTap: currentRestaurant != null
                    ? () => _navigateToDetails(currentRestaurant)
                    : null,
                icon: const Text(
                  'i',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'serif',
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),

              const SizedBox(width: 24),

              // Green Heart Button (Like / Select)
              _buildActionButton(
                key: const ValueKey('swipe_like_button'),
                size: 64,
                onTap: currentRestaurant != null
                    ? () => _onSwipeRight(currentRestaurant)
                    : null,
                icon: const Icon(
                  Icons.favorite_rounded,
                  color: Color(0xFF2E7D32),
                  size: 34,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // "ถัดไป >" Button (requires at least 1 restaurant liked)
          Align(
            alignment: Alignment.centerRight,
            child: Opacity(
              opacity: canProceed ? 1.0 : 0.45,
              child: TextButton(
                key: const ValueKey('swipe_next_button'),
                onPressed: _navigateToSelectedRestaurants,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'ถัดไป',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    Key? key,
    required double size,
    required VoidCallback? onTap,
    required Widget icon,
  }) {
    return Container(
      key: key,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Center(child: icon),
        ),
      ),
    );
  }

  /// Empty or finished state when all cards are swiped
  Widget _buildEmptyOrFinishedState() {
    final swipeSession = ref.watch(swipeSessionProvider);
    final likedCount = swipeSession.likedRestaurants.length;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 50,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'คุณปัดดูร้านอาหารครบแล้ว!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              likedCount > 0
                  ? 'คุณได้เลือกไว้ทั้งหมด $likedCount ร้าน\nกดปุ่มด้านล่างเพื่อดูร้านที่เลือก หรือสุ่มร้านเด็ด'
                  : 'คุณยังไม่ได้เลือกร้านใดเลย ลองเริ่มปัดใหม่อีกครั้ง',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14.5,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            if (likedCount > 0)
              ElevatedButton(
                onPressed: _navigateToSelectedRestaurants,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppConstants.burgundyPrimary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  'ดูร้านที่เลือกแล้ว',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                ref.read(swipeSessionProvider.notifier).reset();
              },
              child: const Text(
                'เริ่มปัดใหม่อีกครั้ง',
                style: TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
