import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../main.dart';
import '../../models/restaurant_model.dart';
import '../../providers/auth_provider.dart';

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
      if (!serviceEnabled) throw Exception('Location services are disabled.');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw Exception('Location permissions are denied');
      }

      _currentPosition = await Geolocator.getCurrentPosition();

      // 2. Fetch approved restaurants
      final response = await supabase
          .from('restaurants')
          .select()
          .eq('status', 'approved');

      final allRestaurants = response.map((e) => RestaurantModel.fromJson(e)).toList();

      // 3. Filter by distance
      _restaurants = allRestaurants.where((restaurant) {
        final distanceInMeters = Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          restaurant.lat,
          restaurant.lng,
        );
        return (distanceInMeters / 1000) <= _radiusKm;
      }).toList();

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleSwipe(int index, dynamic direction) async {
    final restaurant = _restaurants[index];
    
    if (direction.toString().contains('right')) {
      // Liked
      try {
        final userModel = await ref.read(authUserProvider.future);
        if (userModel == null) return;
        
        if (userModel.swipeCount >= 5) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You have reached your limit of 5 likes!')),
          );
          return;
        }

        // Increment swipe count
        await supabase.from('users').update({
          'swipe_count': userModel.swipeCount + 1,
        }).eq('id', userModel.id);
        
        // Refresh user model
        ref.invalidate(authUserProvider);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Liked ${restaurant.name}!')),
        );
      } catch (e) {
        print('Error updating swipe count: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              const Text('Radius (km): '),
              Expanded(
                child: Slider(
                  value: _radiusKm,
                  min: 1,
                  max: 50,
                  divisions: 49,
                  label: _radiusKm.round().toString(),
                  activeColor: const Color(0xFFFF5252),
                  onChanged: (val) => setState(() => _radiusKm = val),
                  onChangeEnd: (_) => _fetchRestaurants(),
                ),
              ),
              Text('${_radiusKm.round()} km'),
            ],
          ),
        ),
        Expanded(
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : _restaurants.isEmpty
              ? const Center(child: Text('No restaurants found in this area.'))
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
                    return Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              child: Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.restaurant, size: 100, color: Colors.grey),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(restaurant.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.navigation, color: Colors.blue),
                                      onPressed: () async {
                                        final url = 'https://www.google.com/maps/dir/?api=1&destination=${restaurant.lat},${restaurant.lng}';
                                        if (await canLaunchUrl(Uri.parse(url))) {
                                          await launchUrl(Uri.parse(url));
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(restaurant.address, style: TextStyle(color: Colors.grey[700])),
                                const SizedBox(height: 8),
                                if (restaurant.menu != null)
                                  Text('Menu: ${restaurant.menu}', maxLines: 2, overflow: TextOverflow.ellipsis),
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
}
