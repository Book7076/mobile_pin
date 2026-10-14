import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants.dart';
import '../../models/favorite_manager.dart';
import '../../models/restaurant_model.dart';
import '../../models/review_model.dart';
import '../../models/swipe_session_model.dart';
import '../../providers/restaurant_provider.dart';
import '../../services/review_service.dart';
import 'restaurant_all_menu_screen.dart';
import 'review_restaurant_screen.dart';
import '../../services/menu_availability_manager.dart';

/// Restaurant Detail Screen matching Mockup Image 4:
/// - Header: Back arrow (<) + "รายละเอียดร้านอาหาร" in Burgundy
/// - Restaurant card: Square thumbnail, name, category, bookmark button
/// - ที่อยู่ ช่องทางติดต่อ: Map pin, address, googlemap link, phone
/// - เวลาเปิด-ปิด: 7 days schedule (อาทิตย์ - เสาร์)
/// - สิ่งอำนวยความสะดวก: 4 feature cards (เหมาะกับกลุ่ม, เครื่องปรับอากาศ, รถจักรยานยนต์, มีห้องน้ำ)
/// - เมนูอาหาร: Square dishes (บุฟเฟต์ ฿249, กุ้งดอง, etc.)
/// - รีวิวร้านอาหาร: Star rating + Review cards (UserA, UserB) + Write review button
class RestaurantDetailScreen extends ConsumerStatefulWidget {
  final String? restaurantId;
  final Map<String, dynamic>? restaurantData;
  final int? rank;
  final String? name;
  final String? category;
  final int? likes;
  final String? imageUrl;
  final String? address;
  final String? phone;
  final String? openingHours;
  final String? description;
  final List<String>? signatureDishes;

  const RestaurantDetailScreen({
    super.key,
    this.restaurantId,
    this.restaurantData,
    this.rank,
    this.name,
    this.category,
    this.likes,
    this.imageUrl,
    this.address,
    this.phone,
    this.openingHours,
    this.description,
    this.signatureDishes,
  });

  @override
  ConsumerState<RestaurantDetailScreen> createState() =>
      _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState
    extends ConsumerState<RestaurantDetailScreen> {
  bool? _isBookmarked;
  List<SignatureDish> _databaseDishes = [];
  String? _lastLoadedRestaurantId;
  List<ReviewModel>? _databaseReviews;
  String? _lastLoadedReviewRestaurantId;
  Map<int, String>? _databaseOperatingHours;
  String? _lastLoadedHoursRestaurantId;

  @override
  void initState() {
    super.initState();
    _initBookmarkState();
    _loadDishesFromDatabase();
    _loadReviewsFromDatabase();
    _loadOperatingHoursFromDatabase();
  }

  Future<void> _loadDishesFromDatabase([String? overrideId, String? overrideName]) async {
    final effectiveId = overrideId ??
        widget.restaurantId ??
        widget.restaurantData?['id']?.toString();
    final effectiveName = overrideName ??
        widget.name ??
        widget.restaurantData?['name']?.toString();

    if (effectiveId != null && effectiveId == _lastLoadedRestaurantId && _databaseDishes.isNotEmpty) {
      return;
    }
    _lastLoadedRestaurantId = effectiveId;

    String? targetRestaurantId = effectiveId;

    try {
      // 1. If targetRestaurantId is not a UUID, try to lookup restaurant id in Supabase by name
      if (targetRestaurantId == null || !targetRestaurantId.contains('-')) {
        if (effectiveName != null && effectiveName.isNotEmpty) {
          try {
            final resRows = await Supabase.instance.client
                .from('restaurants')
                .select('id')
                .ilike('name', '%$effectiveName%')
                .limit(1);
            if (resRows is List && resRows.isNotEmpty) {
              targetRestaurantId = resRows.first['id']?.toString();
            }
          } catch (_) {}
        }
      }

      // 2. Query top 3 menu items from menu_items table
      if (targetRestaurantId != null && targetRestaurantId.isNotEmpty) {
        final rows = await Supabase.instance.client
            .from('menu_items')
            .select()
            .eq('restaurant_id', targetRestaurantId)
            .order('sort_order', ascending: true)
            .limit(3);

        if (rows is List && rows.isNotEmpty) {
          final List<SignatureDish> loaded = [];
          for (final row in rows) {
            final name = row['name']?.toString() ?? '';
            final price = (row['price'] as num?)?.toInt() ?? 0;
            final img = row['image_url']?.toString();
            final isAvailable = MenuAvailabilityManager.parseFromRow(Map<String, dynamic>.from(row));
            if (name.isNotEmpty) {
              loaded.add(SignatureDish(
                name: name,
                price: price,
                imageUrl: (img != null && img.isNotEmpty) ? img : null,
                isAvailable: isAvailable,
              ));
            }
          }

          if (loaded.isNotEmpty && mounted) {
            setState(() {
              _databaseDishes = loaded;
            });
            return;
          }
        }
      }
    } catch (e) {
      debugPrint('Note: Error loading dishes from Supabase in RestaurantDetailScreen: $e');
    }
  }

  Future<void> _loadReviewsFromDatabase([String? overrideId, String? overrideName]) async {
    if (!ReviewService.isSupabaseAvailable) return;

    final effectiveId = overrideId ??
        widget.restaurantId ??
        widget.restaurantData?['id']?.toString();
    final effectiveName = overrideName ??
        widget.name ??
        widget.restaurantData?['name']?.toString();

    String? targetRestaurantId = effectiveId;

    try {
      if (targetRestaurantId == null || !targetRestaurantId.contains('-')) {
        if (effectiveName != null && effectiveName.isNotEmpty && ReviewService.isSupabaseAvailable) {
          try {
            final resRows = await Supabase.instance.client
                .from('restaurants')
                .select('id')
                .ilike('name', '%$effectiveName%')
                .limit(1);
            if (resRows is List && resRows.isNotEmpty) {
              targetRestaurantId = resRows.first['id']?.toString();
            }
          } catch (_) {}
        }
      }

      if (targetRestaurantId != null && targetRestaurantId.isNotEmpty) {
        final dbReviews =
            await ReviewService.fetchReviewsForRestaurant(targetRestaurantId);
        if (mounted) {
          setState(() {
            _databaseReviews = dbReviews;
            _lastLoadedReviewRestaurantId = targetRestaurantId;
          });
        }
      }
    } catch (e) {
      debugPrint('Note: Error loading reviews in RestaurantDetailScreen: $e');
    }
  }

  Future<void> _loadOperatingHoursFromDatabase([String? overrideId, String? overrideName]) async {
    final effectiveId = overrideId ??
        widget.restaurantId ??
        widget.restaurantData?['id']?.toString();
    final effectiveName = overrideName ??
        widget.name ??
        widget.restaurantData?['name']?.toString();

    if (effectiveId != null && effectiveId == _lastLoadedHoursRestaurantId && _databaseOperatingHours != null) {
      return;
    }
    _lastLoadedHoursRestaurantId = effectiveId;

    String? targetRestaurantId = effectiveId;

    try {
      if (targetRestaurantId == null || !targetRestaurantId.contains('-')) {
        if (effectiveName != null && effectiveName.isNotEmpty) {
          try {
            final resRows = await Supabase.instance.client
                .from('restaurants')
                .select('id')
                .ilike('name', '%$effectiveName%')
                .limit(1);
            if (resRows is List && resRows.isNotEmpty) {
              targetRestaurantId = resRows.first['id']?.toString();
            }
          } catch (_) {}
        }
      }

      if (targetRestaurantId != null && targetRestaurantId.isNotEmpty) {
        final rows = await Supabase.instance.client
            .from('operating_hours')
            .select()
            .eq('restaurant_id', targetRestaurantId)
            .order('day_of_week', ascending: true);

        if (rows is List && rows.isNotEmpty && mounted) {
          final Map<int, String> hoursMap = {};
          for (final row in rows) {
            final rawDay = (row['day_of_week'] as num?)?.toInt();
            if (rawDay != null) {
              final isClosed = row['is_closed'] as bool? ?? false;
              if (isClosed) {
                hoursMap[rawDay] = 'ปิดทำการ';
              } else {
                final o = row['open_time']?.toString() ?? '10:00';
                final c = row['close_time']?.toString() ?? '21:00';
                final cleanO = o.length >= 5 ? o.substring(0, 5) : o;
                final cleanC = c.length >= 5 ? c.substring(0, 5) : c;
                hoursMap[rawDay] = '$cleanO - $cleanC';
              }
            }
          }
          if (hoursMap.isNotEmpty && mounted) {
            setState(() {
              _databaseOperatingHours = hoursMap;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Note: Error loading operating_hours in RestaurantDetailScreen: $e');
    }
  }

  Future<void> _openReviewScreen(RestaurantModel restaurant) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ReviewRestaurantScreen(restaurant: restaurant),
      ),
    );
    if (result == true && mounted) {
      await _loadReviewsFromDatabase(restaurant.id, restaurant.name);
      ref.read(reviewsProvider.notifier).loadReviewsForRestaurant(restaurant.id);
    }
  }

  void _initBookmarkState() {
    final effectiveName = widget.name ??
        widget.restaurantData?['name']?.toString() ??
        '';
    final effectiveId = widget.restaurantId ??
        widget.restaurantData?['id']?.toString() ??
        widget.restaurantData?['restaurant_id']?.toString() ??
        '';

    bool initialFav = false;
    if (widget.restaurantData != null) {
      if (widget.restaurantData!['isBookmarked'] == true ||
          widget.restaurantData!['isFavorite'] == true) {
        initialFav = true;
      }
    }
    if (!initialFav && effectiveId.isNotEmpty) {
      initialFav = FavoriteManager.isFavorite(effectiveId);
    }
    if (!initialFav && effectiveName.isNotEmpty) {
      initialFav = FavoriteManager.isFavorite(effectiveName);
    }
    if (!initialFav && widget.restaurantId != null) {
      try {
        final list = ref.read(restaurantsProvider);
        final match = list.where((r) => r.id == widget.restaurantId);
        if (match.isNotEmpty && match.first.isFavorite) {
          initialFav = true;
        }
      } catch (_) {}
    }
    _isBookmarked = initialFav;

    if (effectiveId.isNotEmpty) {
      FavoriteManager.checkIsFavoriteInDb(effectiveId).then((isFav) {
        if (mounted && isFav != null && isFav != _isBookmarked) {
          setState(() {
            _isBookmarked = isFav;
          });
        }
      });
    }
  }

  void _toggleBookmark(RestaurantModel restaurant) {
    HapticFeedback.lightImpact();
    final newFav = !(_isBookmarked ?? false);
    setState(() {
      _isBookmarked = newFav;
    });

    final name = restaurant.name;
    final restId = restaurant.id.isNotEmpty
        ? restaurant.id
        : (widget.restaurantId ??
            widget.restaurantData?['id']?.toString() ??
            widget.restaurantData?['restaurant_id']?.toString() ??
            '');

    if (newFav) {
      final favItem = widget.restaurantData != null
          ? Map<String, dynamic>.from(widget.restaurantData!)
          : <String, dynamic>{};
      if (restId.isNotEmpty) {
        favItem['id'] = restId;
        favItem['restaurant_id'] = restId;
      }
      favItem['name'] = favItem['name'] ?? restaurant.name;
      favItem['category'] = favItem['category'] ??
          (restaurant.categories.isNotEmpty
              ? _getCategorySubtitle(restaurant)
              : 'อาหารทั่วไป');
      favItem['price'] = favItem['price'] ?? restaurant.priceRange ?? '฿ 100-300 บาท';
      favItem['rating'] = favItem['rating'] ?? restaurant.rating;
      favItem['image'] = favItem['image'] ??
          (restaurant.imageUrls.isNotEmpty
              ? restaurant.imageUrls.first
              : 'assets/images/rawtruckr.jpg');
      favItem['isAsset'] = favItem['isAsset'] ??
          (favItem['image']?.toString().startsWith('assets/') ?? false);
      favItem['isBookmarked'] = true;
      favItem['isFavorite'] = true;
      FavoriteManager.addFavorite(favItem);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('บันทึก "$name" ลงในรายการโปรดแล้ว'),
          duration: const Duration(seconds: 2),
          backgroundColor: AppConstants.burgundyPrimary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } else {
      FavoriteManager.removeFavorite(restId.isNotEmpty ? restId : name);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('นำ "$name" ออกจากรายการโปรดแล้ว'),
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFF4A4447),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }

    if (restaurant.id.isNotEmpty) {
      ref.read(restaurantsProvider.notifier).toggleFavorite(restaurant.id);
    }
  }

  Future<void> _openMap(String address, double lat, double lng, [String? googleMapsUrl]) async {
    Uri? targetUrl;
    if (googleMapsUrl != null && googleMapsUrl.isNotEmpty) {
      targetUrl = Uri.tryParse(googleMapsUrl);
    }
    targetUrl ??= Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    try {
      if (await canLaunchUrl(targetUrl)) {
        await launchUrl(targetUrl, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  Future<void> _callPhone(String phone) async {
    final cleanPhone = phone.replaceAll(' ', '').replaceAll('-', '');
    final telUrl = Uri.parse('tel:$cleanPhone');
    try {
      if (await canLaunchUrl(telUrl)) {
        await launchUrl(telUrl);
      }
    } catch (_) {}
  }

  RestaurantModel _createFallbackModel() {
    if (widget.restaurantData != null) {
      try {
        final parsed = RestaurantModel.fromJson(widget.restaurantData!);
        if (parsed.name.isNotEmpty) {
          return parsed;
        }
      } catch (_) {}
    }

    final effectiveName =
        widget.name ?? widget.restaurantData?['name']?.toString() ?? 'ร้านอาหารยอดนิยม';
    final effectiveCategory =
        widget.category ?? widget.restaurantData?['category']?.toString() ?? 'อาหารทั่วไป';
    final effectiveImage = widget.imageUrl ?? widget.restaurantData?['image']?.toString();
    final effectiveAddress = widget.address ??
        widget.restaurantData?['address']?.toString() ??
        '123 ถนนสุขุมวิท กรุงเทพมหานคร';
    final effectivePhone =
        widget.phone ?? widget.restaurantData?['phone']?.toString() ?? '081-234-5678';
    final effectiveHours = widget.openingHours ??
        widget.restaurantData?['open_hours']?.toString() ??
        '10:00 - 21:00 น.';
    final effectiveId = widget.restaurantId ??
        widget.restaurantData?['id']?.toString() ??
        'custom_${effectiveName.hashCode}';

    List<SignatureDish> effectiveDishes = [];
    if (widget.signatureDishes != null && widget.signatureDishes!.isNotEmpty) {
      effectiveDishes = widget.signatureDishes!
          .map((d) => SignatureDish(name: d, price: 150))
          .toList();
    } else if (widget.restaurantData?['signature_dishes'] != null &&
        widget.restaurantData?['signature_dishes'] is List) {
      effectiveDishes = (widget.restaurantData!['signature_dishes'] as List)
          .whereType<Map>()
          .map((d) => SignatureDish.fromJson(Map<String, dynamic>.from(d)))
          .toList();
    } else {
      effectiveDishes = [SignatureDish(name: 'เมนูซิกเนเจอร์', price: 150)];
    }

    return RestaurantModel(
      id: effectiveId,
      ownerId: widget.restaurantData?['owner_id']?.toString() ?? 'owner_1',
      name: effectiveName,
      address: effectiveAddress,
      lat: (widget.restaurantData?['lat'] as num?)?.toDouble() ?? 13.7563,
      lng: (widget.restaurantData?['lng'] as num?)?.toDouble() ?? 100.5018,
      phone: effectivePhone,
      status: widget.restaurantData?['status']?.toString() ?? 'approved',
      categories: [effectiveCategory],
      openHours: effectiveHours,
      imageUrls: effectiveImage != null ? [effectiveImage] : [],
      signatureDishes: effectiveDishes,
    );
  }

  @override
  Widget build(BuildContext context) {
    final restaurants = ref.watch(restaurantsProvider);
    RestaurantModel restaurant;
    final lookupId = widget.restaurantId ?? widget.restaurantData?['id']?.toString();
    final lookupName = widget.name ?? widget.restaurantData?['name']?.toString();

    if (lookupId != null && lookupId.isNotEmpty) {
      restaurant = restaurants.firstWhere(
        (r) => r.id == lookupId,
        orElse: () => restaurants.firstWhere(
          (r) =>
              lookupName != null &&
              r.name.toLowerCase().contains(lookupName.toLowerCase()),
          orElse: _createFallbackModel,
        ),
      );
    } else if (lookupName != null && lookupName.isNotEmpty) {
      restaurant = restaurants.firstWhere(
        (r) =>
            r.name.toLowerCase().contains(lookupName.toLowerCase()) ||
            lookupName.toLowerCase().contains(r.name.toLowerCase()),
        orElse: _createFallbackModel,
      );
    } else if (restaurants.isNotEmpty) {
      restaurant = restaurants.first;
    } else {
      restaurant = _createFallbackModel();
    }

    if (_databaseDishes.isEmpty && _lastLoadedRestaurantId != restaurant.id) {
      _loadDishesFromDatabase(restaurant.id, restaurant.name);
    }
    if (_databaseReviews == null && _lastLoadedReviewRestaurantId != restaurant.id) {
      _loadReviewsFromDatabase(restaurant.id, restaurant.name);
    }
    if (_databaseOperatingHours == null && _lastLoadedHoursRestaurantId != restaurant.id) {
      _loadOperatingHoursFromDatabase(restaurant.id, restaurant.name);
    }

    if (restaurant.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            key: const Key('restaurant_detail_back_button'),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppConstants.burgundyPrimary,
            ),
            onPressed: () => Navigator.of(context).pop(_isBookmarked),
          ),
          title: const Text(
            'รายละเอียดร้านอาหาร',
            style: TextStyle(
              color: AppConstants.burgundyPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(child: Text('ไม่พบข้อมูลร้านอาหารนี้')),
      );
    }

    final reviews = ref
        .watch(reviewsProvider.notifier)
        .getReviewsForRestaurant(restaurant.id);
    final isFav = _isBookmarked ?? restaurant.isFavorite;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pop(_isBookmarked);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            key: const Key('restaurant_detail_back_button'),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppConstants.burgundyPrimary,
              size: 20,
            ),
            onPressed: () => Navigator.of(context).pop(_isBookmarked),
          ),
          titleSpacing: 0,
          title: Text(
            widget.rank != null ? 'รายละเอียดร้านค้า' : 'รายละเอียดร้านอาหาร',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppConstants.burgundyPrimary,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: const Color(0xFFF1F5F9), height: 1),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.rank != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9EEF2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'อันดับที่ ${widget.rank}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.burgundyPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              // 1. Restaurant Header Card
              _buildRestaurantHeaderCard(context, restaurant, isFav),

              const SizedBox(height: 16),
              const Divider(color: Color(0xFFE2E8F0), thickness: 0.8),
            const SizedBox(height: 16),

            // 2. ที่อยู่ ช่องทางติดต่อ
            _buildContactSection(context, restaurant),

            const SizedBox(height: 16),
            const Divider(color: Color(0xFFE2E8F0), thickness: 0.8),
            const SizedBox(height: 16),

            // 3. เวลาเปิด-ปิด
            _buildOpeningHoursSection(restaurant),

            const SizedBox(height: 16),
            const Divider(color: Color(0xFFE2E8F0), thickness: 0.8),
            const SizedBox(height: 16),

            // 4. สิ่งอำนวยความสะดวก
            _buildAmenitiesSection(restaurant),

            const SizedBox(height: 16),
            const Divider(color: Color(0xFFE2E8F0), thickness: 0.8),
            const SizedBox(height: 16),

            // 5. เมนูอาหาร
            _buildMenuSection(restaurant),

            const SizedBox(height: 16),
            const Divider(color: Color(0xFFE2E8F0), thickness: 0.8),
            const SizedBox(height: 16),

            // 6. รีวิวร้านอาหาร
            _buildReviewsSection(context, restaurant, reviews),

            const SizedBox(height: 40),
          ],
        ),
      ),
    ),
  );
}

  /// 1. Top Restaurant Header Card matching Mockup
  Widget _buildRestaurantHeaderCard(
    BuildContext context,
    RestaurantModel restaurant,
    bool isFav,
  ) {
    final localImage = widget.restaurantData?['image']?.toString();
    final effectiveImage = (localImage != null && localImage.isNotEmpty)
        ? localImage
        : (restaurant.imageUrls.isNotEmpty ? restaurant.imageUrls.first : null);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Square Image
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 105,
            height: 105,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: (effectiveImage != null && effectiveImage.isNotEmpty)
                ? (effectiveImage.startsWith('assets/')
                    ? Image.asset(
                        effectiveImage,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Center(
                          child: Icon(
                            Icons.restaurant,
                            color: Color(0xFFCBD5E1),
                            size: 36,
                          ),
                        ),
                      )
                    : Image.network(
                        effectiveImage,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Center(
                          child: Icon(
                            Icons.restaurant,
                            color: Color(0xFFCBD5E1),
                            size: 36,
                          ),
                        ),
                      ))
                : const Center(
                    child: Icon(
                      Icons.restaurant,
                      color: Color(0xFFCBD5E1),
                      size: 36,
                    ),
                  ),
          ),
        ),

        const SizedBox(width: 16),

        // Name & Category
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                restaurant.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                'ประเภทร้านอาหาร: ${_getCategorySubtitle(restaurant)}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        // Bookmark Icon Button (Solid burgundy when saved, white with red border when unbookmarked)
        IconButton(
          key: const Key('restaurant_detail_bookmark_button'),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          splashRadius: 24,
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: animation,
              child: child,
            ),
            child: Icon(
              isFav ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              key: ValueKey<bool>(isFav),
              color: AppConstants.burgundyPrimary,
              size: 32,
            ),
          ),
          onPressed: () => _toggleBookmark(restaurant),
          tooltip: isFav ? 'ลบออกจากรายการโปรด' : 'บันทึกในรายการโปรด',
        ),
      ],
    );
  }

  String _getCategorySubtitle(RestaurantModel restaurant) {
    if (restaurant.id == 'rest_shabu_mouood') {
      return 'ชาบู, หมูกระทะ';
    }
    // ประเภทอาหารของแต่ละร้านคือ cuisine_type_id อิงตาม database (รูปที่ 2 และ 3)
    if (restaurant.cuisineTypeName != null && restaurant.cuisineTypeName!.isNotEmpty) {
      return restaurant.cuisineTypeName!;
    }
    if (restaurant.cuisineTypeId != null) {
      return mapCuisineTypeIdToName(restaurant.cuisineTypeId!);
    }
    if (restaurant.id == 'rest_rawtruckr') {
      return 'อาหารเกาหลี';
    }
    if (restaurant.id == 'rest_teds_coffee') {
      return 'กาแฟ, ขนมหวาน/เบเกอรี่';
    }
    if (restaurant.categories.isNotEmpty) {
      final names = restaurant.categories.map((catId) {
        for (final c in AppConstants.flowCategories) {
          if (c['id'] == catId) return c['name'] as String;
        }
        return catId;
      }).toList();
      return names.join(', ');
    }
    return 'อาหารทั่วไป';
  }

  /// 2. ที่อยู่ ช่องทางติดต่อ
  Widget _buildContactSection(
    BuildContext context,
    RestaurantModel restaurant,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ที่อยู่ ช่องทางติดต่อ',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),

        // Address & Google Map link
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.location_on_outlined,
              color: AppConstants.burgundyPrimary,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.address.isNotEmpty
                        ? restaurant.address
                        : '83 ถนน สุเทพ ตำบลสุเทพ อำเภอเมืองเชียงใหม่',
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFF334155),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 2),
                  InkWell(
                    onTap: () => _openMap(
                      restaurant.address,
                      restaurant.lat,
                      restaurant.lng,
                      restaurant.googleMapsUrl,
                    ),
                    child: Text(
                      (restaurant.googleMapsUrl != null && restaurant.googleMapsUrl!.isNotEmpty)
                          ? (restaurant.googleMapsUrl!.contains('google') ? 'www.googlemap.com' : restaurant.googleMapsUrl!)
                          : 'www.googlemap.com',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF1D4ED8),
                        decoration: TextDecoration.underline,
                        decorationColor: Color(0xFF1D4ED8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Phone
        Row(
          children: [
            const Icon(
              Icons.phone_outlined,
              color: AppConstants.burgundyPrimary,
              size: 20,
            ),
            const SizedBox(width: 10),
            InkWell(
              onTap: () => _callPhone(restaurant.phone),
              child: Text(
                restaurant.phone.isNotEmpty ? restaurant.phone : '095 446 1156',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF334155),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 3. เวลาเปิด-ปิด Schedule
  Widget _buildOpeningHoursSection(RestaurantModel restaurant) {
    // 0=Sun, 1=Mon, 2=Tue, 3=Wed, 4=Thu, 5=Fri, 6=Sat (also support 7=Sun)
    final scheduleDays = [
      {'name': 'อาทิตย์', 'dow': [0, 7]},
      {'name': 'จันทร์', 'dow': [1]},
      {'name': 'อังคาร', 'dow': [2]},
      {'name': 'พุธ', 'dow': [3]},
      {'name': 'พฤหัสบดี', 'dow': [4]},
      {'name': 'ศุกร์', 'dow': [5]},
      {'name': 'เสาร์', 'dow': [6]},
    ];

    final defaultHours = restaurant.openHours.isNotEmpty
        ? restaurant.openHours.replaceAll(' น.', '')
        : '11.00 - 23.00';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'เวลาเปิด-ปิด',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 10),
        Column(
          children: scheduleDays.map((item) {
            final dayName = item['name'] as String;
            final dows = item['dow'] as List<int>;
            String? dayHours;
            if (_databaseOperatingHours != null) {
              for (final d in dows) {
                if (_databaseOperatingHours!.containsKey(d)) {
                  dayHours = _databaseOperatingHours![d];
                  break;
                }
              }
            }
            final displayHours = dayHours ?? defaultHours;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dayName,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFF475569),
                    ),
                  ),
                  Text(
                    displayHours,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFF334155),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 4. สิ่งอำนวยความสะดวก (8 items in 2 rows of 4 matching Mockup Image 1)
  Widget _buildAmenitiesSection(RestaurantModel restaurant) {
    final List<Map<String, dynamic>> allAmenities = [
      {'icon': Icons.wifi_rounded, 'label': 'มีอินเทอร์เน็ต'},
      {'icon': Icons.directions_car_rounded, 'label': 'ที่จอดรถยนต์'},
      {'icon': Icons.two_wheeler_rounded, 'label': 'รถจักรยานยนต์'},
      {'icon': Icons.delivery_dining_rounded, 'label': 'เดลิเวอรี่'},
      {'icon': Icons.ac_unit_rounded, 'label': 'เครื่องปรับอากาศ'},
      {'icon': Icons.favorite_border_rounded, 'label': 'มีห้องน้ำ'},
      {'icon': Icons.groups_rounded, 'label': 'เหมาะกับกลุ่ม'},
      {'icon': Icons.child_care_rounded, 'label': 'เหมาะกับเด็ก'},
    ];

    final row1 = allAmenities.sublist(0, 4);
    final row2 = allAmenities.sublist(4, 8);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'สิ่งอำนวยความสะดวก',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: row1.map((item) => _buildAmenityCard(item)).toList(),
        ),
        const SizedBox(height: 10),
        Row(
          children: row2.map((item) => _buildAmenityCard(item)).toList(),
        ),
      ],
    );
  }

  Widget _buildAmenityCard(Map<String, dynamic> item) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 2,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFF1F5F9),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item['icon'] as IconData,
              color: AppConstants.burgundyPrimary,
              size: 26,
            ),
            const SizedBox(height: 6),
            Text(
              item['label'] as String,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// 5. เมนูอาหาร
  Widget _buildMenuSection(RestaurantModel restaurant) {
    final dishes = _databaseDishes.isNotEmpty
        ? _databaseDishes.take(3).toList()
        : (restaurant.signatureDishes.isNotEmpty
            ? restaurant.signatureDishes.take(3).toList()
            : [
                SignatureDish(
                  name: 'บุฟเฟต์',
                  price: 249,
                  imageUrl: restaurant.imageUrls.isNotEmpty
                      ? restaurant.imageUrls.first
                      : 'https://images.unsplash.com/photo-1547928576-a4a33237cbc3?w=400&q=80',
                ),
                SignatureDish(
                  name: 'กุ้งดอง',
                  price: 0,
                  imageUrl:
                      'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=400&q=80',
                ),
              ]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'เมนูอาหาร',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RestaurantAllMenuScreen(
                      restaurantId: restaurant.id,
                      restaurantName: restaurant.name,
                      initialDishes: _databaseDishes.isNotEmpty
                          ? _databaseDishes
                          : restaurant.signatureDishes,
                    ),
                  ),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'เมนูทั้งหมด',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppConstants.burgundyPrimary,
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: AppConstants.burgundyPrimary,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Column(
          children: dishes.map((dish) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 90,
                      height: 75,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: _buildDishPreview(dish.imageUrl),
                          ),
                          if (!dish.isAvailable)
                            Positioned.fill(
                              child: Container(
                                color: Colors.black.withOpacity(0.55),
                                child: const Center(
                                  child: Text(
                                    'สินค้าหมด',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dish.name,
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: dish.isAvailable
                                ? const Color(0xFF1E293B)
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                        if (dish.description != null &&
                            dish.description!.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            dish.description!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              dish.formattedPrice,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: dish.isAvailable
                                    ? const Color(0xFF1E293B)
                                    : const Color(0xFF94A3B8),
                              ),
                            ),
                            if (!dish.isAvailable) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEE2E2),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFFFCA5A5), width: 0.8),
                                ),
                                child: const Text(
                                  'สินค้าหมด',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFFDC2626),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 6. รีวิวร้านอาหาร
  Widget _buildReviewsSection(
    BuildContext context,
    RestaurantModel restaurant,
    List<ReviewModel> fallbackReviews,
  ) {
    // อิงตามรีวิวจริงใน database reviews table เท่านั้น ห้ามสมมติข้อมูล
    final reviews = _databaseReviews ?? fallbackReviews;
    final hasReviews = reviews.isNotEmpty;
    final avgRating = hasReviews
        ? ReviewService.calculateAverageRating(reviews, defaultRating: 0.0)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row: รีวิวร้านอาหาร ★ X.X (ตามรีวิวจริงใน database reviews table)
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          children: [
            const Text(
              'รีวิวร้านอาหาร',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: AppConstants.burgundyPrimary,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  avgRating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Reviews Cards (รูปที่ 1: การ์ดยังไม่มีรีวิวสำหรับร้านนี้)
        if (!hasReviews)
          Material(
            color: Colors.transparent,
            child: InkWell(
              key: const Key('empty_reviews_card'),
              borderRadius: BorderRadius.circular(16),
              onTap: () => _openReviewScreen(restaurant),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Text(
                  'ยังไม่มีรีวิวสำหรับร้านนี้ เป็นคนแรกที่รีวิวเลย!',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          )
        else
          Column(
            children: [
              for (final rev in reviews)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFF1F5F9),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: AppConstants.burgundyPrimary,
                            backgroundImage: rev.userAvatar != null &&
                                    rev.userAvatar!.isNotEmpty
                                ? NetworkImage(rev.userAvatar!)
                                : null,
                            child: rev.userAvatar == null || rev.userAvatar!.isEmpty
                                ? Text(
                                    rev.userName.isNotEmpty
                                        ? rev.userName[0].toUpperCase()
                                        : 'U',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  rev.userName,
                                  style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                Text(
                                  '${rev.createdAt.day}/${rev.createdAt.month}/${rev.createdAt.year}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Color(0xFFF59E0B),
                                size: 16,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                rev.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        rev.comment,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF475569),
                          height: 1.4,
                        ),
                      ),
                      if (rev.photoUrl != null && rev.photoUrl!.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            rev.photoUrl!,
                            height: 130,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  key: const Key('write_review_button'),
                  onPressed: () => _openReviewScreen(restaurant),
                  icon: const Icon(
                    Icons.edit_note_rounded,
                    color: AppConstants.burgundyPrimary,
                    size: 20,
                  ),
                  label: const Text(
                    'เขียนรีวิวร้านนี้',
                    style: TextStyle(
                      color: AppConstants.burgundyPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppConstants.burgundyPrimary, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildDishPreview(String? url) {
    if (url == null || url.trim().isEmpty) {
      return _buildNoDishPhoto();
    }
    if (url.startsWith('data:image')) {
      try {
        final base64String = url.split(',').last;
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          width: 90,
          height: 75,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildNoDishPhoto(),
        );
      } catch (_) {}
    }
    return Image.network(
      url,
      width: 90,
      height: 75,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _buildNoDishPhoto(),
    );
  }

  Widget _buildNoDishPhoto() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.camera_alt_outlined,
            color: Color(0xFF94A3B8),
            size: 26,
          ),
          SizedBox(height: 2),
          Text(
            'ไม่มีรูป',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}
