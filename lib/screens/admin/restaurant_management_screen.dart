import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/restaurant_admin_model.dart';
import '../../services/admin_restaurant_service.dart';
import 'admin_theme.dart';
import 'restaurant_detail_screen.dart';
import 'widgets/admin_search_bar.dart';
import 'widgets/restaurant_card.dart';

class RestaurantManagementScreen extends ConsumerStatefulWidget {
  final int initialSubTabIndex;

  const RestaurantManagementScreen({
    super.key,
    this.initialSubTabIndex = 0,
  });

  @override
  ConsumerState<RestaurantManagementScreen> createState() => _RestaurantManagementScreenState();
}

class _RestaurantManagementScreenState extends ConsumerState<RestaurantManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // 3 แท็บ: รออนุมัติ (0), อนุมัติ (1), ไม่อนุมัติ (2)
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialSubTabIndex.clamp(0, 2),
    );
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    Future.microtask(() {
      if (mounted) {
        ref.read(adminRestaurantProvider.notifier).refresh();
      }
    });
  }

  @override
  void didUpdateWidget(covariant RestaurantManagementScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSubTabIndex != oldWidget.initialSubTabIndex) {
      _tabController.animateTo(widget.initialSubTabIndex.clamp(0, 2));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<RestaurantAdminModel> _filterRestaurants(
    List<RestaurantAdminModel> allRestaurants,
    String status,
  ) {
    return allRestaurants.where((restaurant) {
      final matchesStatus = restaurant.status == status;
      if (_searchQuery.isEmpty) {
        return matchesStatus;
      }
      final q = _searchQuery.toLowerCase();
      final matchesQuery = restaurant.name.toLowerCase().contains(q) ||
          (restaurant.category?.toLowerCase().contains(q) ?? false) ||
          restaurant.phone.contains(q);
      return matchesStatus && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final restaurants = ref.watch(adminRestaurantProvider);

    final pendingCount = _filterRestaurants(restaurants, 'pending').length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. หัวหน้าจอ (Header): จัดการร้านอาหาร & กระดิ่งแจ้งเตือน (ตามรูปที่ 2)
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'จัดการร้านอาหาร',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AdminTheme.primaryMaroon,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.notifications_none_rounded,
                          color: AdminTheme.primaryMaroon,
                          size: 28,
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('คุณมีคำขอเปิดร้านใหม่ที่รอการตรวจสอบ $pendingCount รายการ'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                      if (pendingCount > 0)
                        Positioned(
                          right: 12,
                          top: 10,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AdminTheme.statusRejected,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // 2. TabBar: รออนุมัติ | อนุมัติ | ไม่อนุมัติ พร้อมเส้นขีดล่างแดง (ตามรูปที่ 2)
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: AdminTheme.primaryMaroon,
                indicatorWeight: 2.5,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: AdminTheme.primaryMaroon,
                unselectedLabelColor: const Color(0xFF222222),
                labelStyle: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w500,
                ),
                tabs: const [
                  Tab(text: 'รออนุมัติ'),
                  Tab(text: 'อนุมัติ'),
                  Tab(text: 'ไม่อนุมัติ'),
                ],
              ),
            ),

            // 3. กล่องค้นหาทรงรีมน (Search Bar): "ค้นหาร้านค้า"
            AdminSearchBar(
              controller: _searchController,
              onChanged: (val) {
                setState(() => _searchQuery = val.trim());
              },
              onClear: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
            ),

            // 4. รายการการ์ดร้านค้า (Tab Bar View)
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // แท็บ 1: รออนุมัติ (Pending)
                  _buildRestaurantListView(
                    _filterRestaurants(restaurants, 'pending'),
                    emptyMessage: _searchQuery.isEmpty
                        ? 'ไม่มีคำขอเปิดร้านที่รอการตรวจสอบ'
                        : 'ไม่พบร้านค้าที่ตรงกับคำค้นหา',
                  ),
                  // แท็บ 2: อนุมัติ (Approved)
                  _buildRestaurantListView(
                    _filterRestaurants(restaurants, 'approved'),
                    emptyMessage: _searchQuery.isEmpty
                        ? 'ยังไม่มีร้านอาหารที่ได้รับการอนุมัติ'
                        : 'ไม่พบร้านค้าที่ตรงกับคำค้นหา',
                  ),
                  // แท็บ 3: ไม่อนุมัติ (Rejected)
                  _buildRestaurantListView(
                    _filterRestaurants(restaurants, 'rejected'),
                    emptyMessage: _searchQuery.isEmpty
                        ? 'ไม่มีรายการร้านค้าที่ถูกปฏิเสธ'
                        : 'ไม่พบร้านค้าที่ตรงกับคำค้นหา',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantListView(
    List<RestaurantAdminModel> list, {
    required String emptyMessage,
  }) {
    if (list.isEmpty) {
      return RefreshIndicator(
        color: AdminTheme.primaryMaroon,
        onRefresh: () => ref.read(adminRestaurantProvider.notifier).refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: 380,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.storefront_outlined,
                      size: 64,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      emptyMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.5,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AdminTheme.primaryMaroon,
      onRefresh: () => ref.read(adminRestaurantProvider.notifier).refresh(),
      child: ListView.builder(
        // เว้นขอบล่าง 90px เพื่อไม่ให้ Floating Bottom Navigation Bar บัง
        padding: const EdgeInsets.only(top: 4, bottom: 95),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final restaurant = list[index];
          return RestaurantCard(
            restaurant: restaurant,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => RestaurantDetailScreen(
                    restaurantId: restaurant.id,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
