import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../models/restaurant_model.dart';
import '../../providers/restaurant_provider.dart';
import '../restaurants/restaurant_detail_screen.dart';

/// Screen "ร้านที่ใช่ โดนใจคุณ" (Final Winner Screen)
/// Matches Figma Mockup Image 2:
/// - Header: "ร้านที่ใช่ \n โดนใจคุณ" in Kanit typography, deep burgundy
/// - Large Card: Food photo with location chip ("ถ.นิมมานเหมินท์ ต.สุเทพ"),
///   Name ("RawTruckr"), Category pill ("อาหารเกาหลี"),
///   Rating ⭐ 4.5 (120 รีวิว), and Price ฿ 150-350 บาท
/// - Tapping the card opens RestaurantDetailScreen
/// - Bottom circular burgundy button with white "X" to dismiss and return
class FinalWinnerScreen extends ConsumerWidget {
  final RestaurantModel restaurant;
  final String? categoryLabel;

  const FinalWinnerScreen({
    super.key,
    required this.restaurant,
    this.categoryLabel,
  });

  String _getLocationBadge(RestaurantModel r) {
    if (r.locationBadge != null && r.locationBadge!.isNotEmpty) {
      return r.locationBadge!;
    }
    if (r.id == 'rest_rawtruckr') return 'ถ.นิมมานเหมินท์ ต.สุเทพ';
    if (r.id == 'rest_krua_pinjieng') return 'ต.สุเทพ อ.เมืองเชียงใหม่';
    if (r.id == 'rest_kuay_tiew_khun_thep') return 'ถ.สุเทพ เชียงใหม่';
    if (r.id == 'rest_teds_coffee') return 'ถ.ศิริมังคลาจารย์';
    if (r.id == 'rest_khao_soi_mae_sai') return 'ถ.ราชพฤกษ์ ช้างเผือก';
    return 'อำเภอเมืองเชียงใหม่';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.of(context).size;
    final hasImage = restaurant.imageUrls.isNotEmpty;
    final selectedCategories =
        ref.watch(filterCriteriaProvider).selectedCategories;
    final effectiveCategoryLabel = categoryLabel ??
        formatRestaurantCategory(
          restaurant,
          selectedCategories: selectedCategories,
        );
    final locationBadge = _getLocationBadge(restaurant);

    return Scaffold(
      backgroundColor: AppConstants.backgroundWarm,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 12),

              // Header: "ร้านที่ใช่ \n โดนใจคุณ"
              const Text(
                'ร้านที่ใช่',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: AppConstants.burgundyPrimary,
                  letterSpacing: 0.3,
                  height: 1.15,
                ),
                textAlign: TextAlign.center,
              ),
              const Text(
                'โดนใจคุณ',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppConstants.burgundyPrimary,
                  letterSpacing: 0.2,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Large Result Card matching Mockup Image 2
              Expanded(
                child: Center(
                  child: GestureDetector(
                    key: const ValueKey('winner_restaurant_card'),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => RestaurantDetailScreen(
                            restaurantId: restaurant.id,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        maxWidth: 380,
                        maxHeight: screenSize.height * 0.64,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Top Image Section with Location Badge
                            Expanded(
                              flex: 7,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  hasImage
                                      ? Image.network(
                                          restaurant.imageUrls.first,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, _, _) => Container(
                                            color: const Color(0xFFE2E8F0),
                                            child: const Icon(
                                              Icons.restaurant,
                                              size: 64,
                                              color: Color(0xFF94A3B8),
                                            ),
                                          ),
                                        )
                                      : Container(
                                          color: const Color(0xFFE2E8F0),
                                          child: const Icon(
                                            Icons.restaurant,
                                            size: 64,
                                            color: Color(0xFF94A3B8),
                                          ),
                                        ),

                                  // Location & Brand Badges overlay matching Mockup Image 2
                                  Positioned(
                                    bottom: 12,
                                    left: 16,
                                    right: 16,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Orange Pill: Location
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF59E0B),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(
                                                    alpha: 0.2),
                                                blurRadius: 6,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            locationBadge,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Bottom Card Info matching Mockup Image 2
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 12,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    // Row: Name + Category Pill
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            restaurant.name,
                                            style: const TextStyle(
                                              fontSize: 21,
                                              fontWeight: FontWeight.w900,
                                              color: Color(0xFF0F172A),
                                              letterSpacing: 0.2,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppConstants.burgundyPrimary,
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                          child: Text(
                                            effectiveCategoryLabel,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Star Rating
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star_rounded,
                                          color: Color(0xFFFBBF24),
                                          size: 22,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${restaurant.rating.toStringAsFixed(1)}  (${restaurant.reviewCount} รีวิว)',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF334155),
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Price Range with Green Coin Icon
                                    Row(
                                      children: [
                                        Container(
                                          width: 20,
                                          height: 20,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF2E7D32),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Center(
                                            child: Text(
                                              '฿',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          restaurant.priceRange,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF334155),
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
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Bottom Circular "X" Button matching Mockup Image 2
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  color: AppConstants.burgundyPrimary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color:
                          AppConstants.burgundyPrimary.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    key: const ValueKey('winner_close_button'),
                    customBorder: const CircleBorder(),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: const Center(
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
