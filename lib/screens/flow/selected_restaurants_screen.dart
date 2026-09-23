import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../models/restaurant_model.dart';
import '../../providers/restaurant_provider.dart';
import '../restaurants/restaurant_detail_screen.dart';
import 'final_winner_screen.dart';

/// Screen "result - เลือกครบ 5 ร้าน" (ผลลัพธ์ ร้านไหน...ถูกใจคุณ)
/// Matches Figma Mockup Image 3:
/// - Header: "ผลลัพธ์ \n ร้านไหน...ถูกใจคุณ"
/// - List of cards with rose border and selection highlight
/// - Tapping chevron arrow (>) in upper-right navigates to RestaurantDetailScreen
/// - Bottom circular cutlery button (🍴) opens FinalWinnerScreen ("ร้านที่ใช่ โดนใจคุณ")
class SelectedRestaurantsScreen extends ConsumerStatefulWidget {
  const SelectedRestaurantsScreen({super.key});

  @override
  ConsumerState<SelectedRestaurantsScreen> createState() =>
      _SelectedRestaurantsScreenState();
}

class _SelectedRestaurantsScreenState
    extends ConsumerState<SelectedRestaurantsScreen> {
  int _selectedIndex = 0;

  void _openWinnerScreen(List<RestaurantModel> liked) {
    if (liked.isEmpty) return;
    HapticFeedback.mediumImpact();
    final index = _selectedIndex.clamp(0, liked.length - 1);
    final winner = liked[index];

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FinalWinnerScreen(restaurant: winner),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final swipeSession = ref.watch(swipeSessionProvider);
    final allRestaurants = ref.watch(restaurantsProvider);

    // Fallback: If session has liked restaurants, use them.
    // If empty (direct preview), show the 5 default mockup restaurants for immediate demonstration!
    final likedList = swipeSession.likedRestaurants.isNotEmpty
        ? swipeSession.likedRestaurants
        : _getDefaultMockupRestaurants(allRestaurants);

    return Scaffold(
      backgroundColor: AppConstants.backgroundWarm,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppConstants.burgundyPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header: "ผลลัพธ์ \n ร้านไหน...ถูกใจคุณ" (Matching Mockup)
            const Text(
              'ผลลัพธ์',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: AppConstants.burgundyPrimary,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            const Text(
              'ร้านไหน...ถูกใจคุณ',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppConstants.burgundyPrimary,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 18),

            // 5 Restaurant Cards List
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 100),
                itemCount: likedList.length,
                separatorBuilder: (_, _) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final restaurant = likedList[index];
                  return _buildMockupRestaurantCard(context, restaurant, index);
                },
              ),
            ),
          ],
        ),
      ),

      // Floating Circular Cutlery Button (🍴) matching Mockup
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 12),
        width: 66,
        height: 66,
        decoration: BoxDecoration(
          color: AppConstants.burgundyPrimary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppConstants.burgundyPrimary.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            key: const ValueKey('random_pick_fab'),
            customBorder: const CircleBorder(),
            onTap: () => _openWinnerScreen(likedList),
            child: const Center(
              child: Icon(
                Icons.restaurant_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Restaurant card matching Figma Mockup Image 3
  Widget _buildMockupRestaurantCard(
      BuildContext context, RestaurantModel restaurant, int index) {
    final hasImage = restaurant.imageUrls.isNotEmpty;
    final isSelected = index == _selectedIndex;

    return InkWell(
      key: ValueKey('restaurant_item_$index'),
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF1D5D5) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFF9DADA),
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Square Rounded Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                ),
                child: hasImage
                    ? Image.network(
                        restaurant.imageUrls.first,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.restaurant,
                          color: Color(0xFFCBD5E1),
                          size: 28,
                        ),
                      )
                    : const Icon(
                        Icons.restaurant,
                        color: Color(0xFFCBD5E1),
                        size: 28,
                      ),
              ),
            ),

            const SizedBox(width: 14),

            // Info (Name, Subcategory, Price)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _formatCategoryLabel(restaurant),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatPriceLabel(restaurant),
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                    ),
                  ),
                ],
              ),
            ),

            // Right column: Chevron > and Burgundy Star Rating
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  key: ValueKey('card_arrow_$index'),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            RestaurantDetailScreen(restaurantId: restaurant.id),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: AppConstants.burgundyPrimary,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: AppConstants.burgundyPrimary,
                      size: 17,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      restaurant.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppConstants.burgundyPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatCategoryLabel(RestaurantModel restaurant) {
    if (restaurant.id == 'rest_rawtruckr') return 'อาหารเกาหลี';
    if (restaurant.id == 'rest_krua_pinjieng') return 'อาหารไทย/อาหารตามสั่ง';
    if (restaurant.id == 'rest_kuay_tiew_khun_thep') return 'อาหารไทย/ก๋วยเตี๋ยว';
    if (restaurant.id == 'rest_teds_coffee') return 'ร้านกาแฟ/เบเกอรี่';
    if (restaurant.id == 'rest_khao_soi_mae_sai') return 'อาหารไทย';
    if (restaurant.categories.isNotEmpty) {
      final names = restaurant.categories.map((c) {
        for (final fc in AppConstants.flowCategories) {
          if (fc['id'] == c) return fc['name'] as String;
        }
        return c;
      }).toList();
      return names.join('/');
    }
    return 'อาหารทั่วไป';
  }

  String _formatPriceLabel(RestaurantModel restaurant) {
    String p = restaurant.priceRange.trim();
    p = p.replaceAll(RegExp(r'^฿+\s*'), '').trim();
    return '฿ $p';
  }

  List<RestaurantModel> _getDefaultMockupRestaurants(
      List<RestaurantModel> all) {
    final ids = [
      'rest_rawtruckr',
      'rest_krua_pinjieng',
      'rest_kuay_tiew_khun_thep',
      'rest_teds_coffee',
      'rest_khao_soi_mae_sai',
    ];
    final found = all.where((r) => ids.contains(r.id)).toList();
    if (found.isNotEmpty) {
      found.sort((a, b) => ids.indexOf(a.id).compareTo(ids.indexOf(b.id)));
      return found;
    }
    return all.take(5).toList();
  }
}
