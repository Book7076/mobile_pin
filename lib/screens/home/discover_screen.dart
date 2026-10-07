import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants.dart';
import '../../main.dart';
import '../../models/restaurant_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/restaurant_provider.dart';
import '../flow/category_selection_screen.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  final AppinioSwiperController _swiperController = AppinioSwiperController();
  List<RestaurantModel> _restaurants = [];
  bool _isLoading = true;
  double _radiusKm = 10.0;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _fetchRestaurants();
  }

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  Future<void> _fetchRestaurants() async {
    setState(() => _isLoading = true);
    try {
      // 1. Get current location
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Use fallback location if service disabled
      } else {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission != LocationPermission.denied &&
            permission != LocationPermission.deniedForever) {
          _currentPosition = await Geolocator.getCurrentPosition();
        }
      }

      // 2. Fetch approved restaurants from Supabase
      dynamic response;
      try {
        response = await supabase
            .from('restaurants')
            .select('*, restaurant_images(*)')
            .eq('status', 'approved');
      } catch (_) {
        response = await supabase
            .from('restaurants')
            .select()
            .eq('status', 'approved');
      }

      final allRestaurants =
          (response as List).map((e) => RestaurantModel.fromJson(e)).toList();

      // 3. Filter by distance
      if (_currentPosition != null) {
        _restaurants = allRestaurants.where((restaurant) {
          final distanceInMeters = Geolocator.distanceBetween(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            restaurant.lat,
            restaurant.lng,
          );
          return (distanceInMeters / 1000) <= _radiusKm;
        }).toList();
      } else {
        _restaurants = allRestaurants;
      }

      // Apply Flow 3-4 filters if active
      final criteria = ref.read(filterCriteriaProvider);
      if (criteria.selectedCategories.isNotEmpty &&
          !criteria.selectedCategories.contains('all')) {
        _restaurants = _restaurants.where((r) {
          return criteria.selectedCategories
              .any((c) => r.categories.contains(c));
        }).toList();
      }
      if (criteria.maxBudget != null) {
        final budget = criteria.maxBudget!;
        _restaurants = _restaurants.where((r) {
          if (r.signatureDishes.isNotEmpty) {
            return r.signatureDishes.any((d) => d.price <= budget);
          }
          if (budget < 100 && r.priceLevel > 1) return false;
          if (budget < 300 && r.priceLevel > 2) return false;
          return true;
        }).toList();
      }
    } catch (_) {
      // Graceful fallback to mock filtered restaurants
      final filteredMock = ref.read(filteredRestaurantsProvider);
      _restaurants = List.from(filteredMock);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleSwipe(int index, dynamic direction) async {
    if (index >= _restaurants.length) return;
    final restaurant = _restaurants[index];

    if (direction.toString().contains('right')) {
      // Liked
      try {
        final userModel = await ref.read(authUserProvider.future);
        if (userModel == null) return;

        if (userModel.swipeCount >= 5) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('คุณใช้สิทธิ์กดชอบครบ 5 ครั้งแล้วสำหรับวันนี้!'),
              ),
            );
          }
          return;
        }

        // Increment swipe count
        await supabase.from('users').update({
          'swipe_count': userModel.swipeCount + 1,
        }).eq('id', userModel.id);

        // Refresh user model
        ref.invalidate(authUserProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('ถูกใจ ${restaurant.name} แล้ว! ❤️'),
              backgroundColor: AppConstants.burgundyPrimary,
            ),
          );
        }
      } catch (_) {
        // Handled silently or locally
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final criteria = ref.watch(filterCriteriaProvider);

    return Column(
      children: [
        // Flow 3-4 Preference Header Banner
        Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppConstants.burgundyPrimary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppConstants.burgundyPrimary.withValues(alpha: 0.25),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppConstants.burgundyPrimary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.restaurant_menu_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      criteria.selectedCategories.isEmpty ||
                              criteria.selectedCategories.contains('all')
                          ? 'ประเภทอาหาร: ทั้งหมด'
                          : 'เลือก ${criteria.selectedCategories.length} หมวดหมู่',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                        color: AppConstants.burgundyDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      criteria.maxBudget != null
                          ? 'งบประมาณ: ไม่เกิน ฿${criteria.maxBudget!.round()}'
                          : 'งบประมาณ: ยังไม่กำหนด',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context)
                      .push(
                    MaterialPageRoute(
                      builder: (_) => const CategorySelectionScreen(),
                    ),
                  )
                      .then((_) {
                    _fetchRestaurants();
                  });
                },
                icon: const Icon(Icons.tune_rounded, size: 14),
                label: const Text(
                  'ปรับแต่ง',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.burgundyPrimary,
                  foregroundColor: Colors.white,
                  elevation: 1,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: const Size(0, 34),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Radius Slider
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Row(
            children: [
              const Text(
                'ระยะทาง: ',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 6,
                    activeTrackColor: AppConstants.burgundyPrimary,
                    inactiveTrackColor: AppConstants.sliderInactive,
                    thumbColor: AppConstants.burgundyPrimary,
                    overlayColor:
                        AppConstants.burgundyPrimary.withValues(alpha: 0.15),
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 8),
                  ),
                  child: Slider(
                    value: _radiusKm,
                    min: 1,
                    max: 50,
                    divisions: 49,
                    label: '${_radiusKm.round()} km',
                    onChanged: (val) => setState(() => _radiusKm = val),
                    onChangeEnd: (_) => _fetchRestaurants(),
                  ),
                ),
              ),
              Text(
                '${_radiusKm.round()} กม.',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.burgundyPrimary,
                ),
              ),
            ],
          ),
        ),

        // Swiper Content
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation(AppConstants.burgundyPrimary),
                  ),
                )
              : _restaurants.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.search_off_rounded,
                            size: 64,
                            color: Color(0xFF94A3B8),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'ไม่พบร้านอาหารที่ตรงกับตัวกรองนี้',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF475569),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const CategorySelectionScreen(),
                                ),
                              )
                                  .then((_) => _fetchRestaurants());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.burgundyPrimary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text('ปรับเปลี่ยนประเภทอาหารหรืองบ'),
                          ),
                        ],
                      ),
                    )
                  : AppinioSwiper(
                      controller: _swiperController,
                      cardCount: _restaurants.length,
                      onSwipeEnd: (previousIndex, targetIndex, activity) {
                        if (activity is Swipe) {
                          _handleSwipe(previousIndex, activity.direction);
                        }
                      },
                      cardBuilder: (BuildContext context, int index) {
                        final restaurant = _restaurants[index];
                        final hasImage = restaurant.imageUrls.isNotEmpty;

                        return Container(
                          margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 18,
                                spreadRadius: 2,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Restaurant Image
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(22),
                                  ),
                                  child: hasImage
                                      ? Image.network(
                                          restaurant.imageUrls.first,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  _buildImagePlaceholder(),
                                        )
                                      : _buildImagePlaceholder(),
                                ),
                              ),

                              // Restaurant Information
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            restaurant.name,
                                            style: const TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1E293B),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.navigation_rounded,
                                            color: AppConstants.burgundyPrimary,
                                            size: 26,
                                          ),
                                          onPressed: () async {
                                            final url =
                                                'https://www.google.com/maps/dir/?api=1&destination=${restaurant.lat},${restaurant.lng}';
                                            if (await canLaunchUrl(
                                                Uri.parse(url))) {
                                              await launchUrl(Uri.parse(url));
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star_rounded,
                                          color: Color(0xFFFFB800),
                                          size: 18,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${restaurant.rating}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppConstants.burgundyPrimary
                                                .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            restaurant.priceRange,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color:
                                                  AppConstants.burgundyPrimary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      restaurant.address,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 13,
                                      ),
                                    ),
                                    if (restaurant.menu != null &&
                                        restaurant.menu!.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        'เมนูแนะนำ: ${restaurant.menu}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Color(0xFF64748B),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: const Color(0xFFF1F5F9),
      child: const Center(
        child: Icon(
          Icons.restaurant_rounded,
          size: 72,
          color: Color(0xFFCBD5E1),
        ),
      ),
    );
  }
}
