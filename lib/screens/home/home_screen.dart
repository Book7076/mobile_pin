import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../main.dart';
import '../auth/login_screen.dart';
import '../flow/category_selection_screen.dart';
import '../flow/food_swipe_screen.dart';
import '../flow/selected_restaurants_screen.dart';
import '../restaurants/create_restaurant_screen.dart';
import 'discover_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return const DiscoverScreen();
      case 1:
        return _buildMyRestaurants();
      case 2:
        return const Center(child: Text('Profile Settings'));
      default:
        return const SizedBox();
    }
  }

  Widget _buildMyRestaurants() {
    final user = supabase.auth.currentUser;
    return Stack(
      children: [
        if (user == null)
          const Center(child: Text('Not logged in'))
        else
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: supabase
                .from('restaurants')
                .stream(primaryKey: ['id'])
                .eq('owner_id', user.id)
                .order('created_at', ascending: false),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              
              final restaurants = snapshot.data ?? [];
              if (restaurants.isEmpty) {
                return const Center(child: Text('You have not opened any restaurants yet.'));
              }

              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: restaurants.length,
                itemBuilder: (context, index) {
                  final restaurant = restaurants[index];
                  final status = restaurant['status'] as String;
                  
                  Color statusColor = Colors.orange;
                  if (status == 'approved') statusColor = Colors.green;
                  if (status == 'rejected') statusColor = Colors.red;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(restaurant['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(restaurant['address']),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: statusColor),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.extended(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CreateRestaurantScreen()),
              );
            },
            backgroundColor: AppConstants.burgundyPrimary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('Open Restaurant'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.restaurant_rounded,
                color: AppConstants.burgundyPrimary,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'MealMate',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        backgroundColor: AppConstants.burgundyPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.style_rounded, color: Colors.white),
            tooltip: 'ปัดเลือกร้านอาหาร (Food Swipe)',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const FoodSwipeScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite_rounded, color: Colors.white),
            tooltip: 'ร้านที่เลือกแล้ว (Selected)',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SelectedRestaurantsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: Colors.white),
            tooltip: 'เลือกประเภทอาหารและงบประมาณ (Flow 3-4)',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CategorySelectionScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'ออกจากระบบ',
            onPressed: () async {
              await supabase.auth.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppConstants.burgundyPrimary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.local_fire_department), label: 'Discover'),
          BottomNavigationBarItem(icon: Icon(Icons.storefront), label: 'My Restaurants'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

