import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/restaurant_admin_model.dart';
import '../../services/admin_restaurant_service.dart';
import 'admin_theme.dart';
import 'restaurant_detail_screen.dart';

class AdminUserManagementScreen extends ConsumerStatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  ConsumerState<AdminUserManagementScreen> createState() => _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends ConsumerState<AdminUserManagementScreen> {
  // รายชื่อผู้ใช้งาน 4 ท่านตรงตามภาพที่ 1 เป๊ะ
  final List<Map<String, dynamic>> _users = [
    {
      'id': 'user-01',
      'name': 'Kodomo',
      'email': 'kodomo@gmail.com',
      'phone': '081-244-3984',
      'isActive': true,
      'restaurantId': 'res-01', // Kohatsu Matcha
    },
    {
      'id': 'user-02',
      'name': 'Harry Potter',
      'email': 'jkrolling@gmail.com',
      'phone': '081-234-5678',
      'isActive': false,
      'restaurantId': 'res-04', // Haru Sushi Bar
    },
    {
      'id': 'user-03',
      'name': 'Deku Kung',
      'email': 'gobeyondplus@gmail.com',
      'phone': '067-676-6767',
      'isActive': true,
      'restaurantId': 'res-02', // ข้าวบ้านก๋ง
    },
    {
      'id': 'user-04',
      'name': 'Levi S. Kennedy',
      'email': 'titanraccooncity@gmail.com',
      'phone': '089-785-6767',
      'isActive': true,
      'restaurantId': 'res-03', // Potto Hot Pot
    },
  ];

  /// แสดง Modal ดูรายละเอียดร้านค้าตามสถานะ (รอตรวจสอบ / อนุมัติ / ไม่อนุมัติ)
  void _showUserRestaurantsBottomSheet(Map<String, dynamic> user, List<RestaurantAdminModel> allRestaurants) {
    // ดึงร้านค้าของผู้ใช้ท่านนี้
    final userRestaurants = allRestaurants.where((r) {
      return r.ownerId == user['id'] || r.id == user['restaurantId'];
    }).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _UserRestaurantsSheet(
        userName: user['name'] as String,
        userEmail: user['email'] as String,
        restaurants: userRestaurants,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final restaurants = ref.watch(adminRestaurantProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. ส่วนหัว (Header): จัดการผู้ใช้งาน & ไอคอนกระดิ่ง (ตรงตามภาพที่ 1)
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 18, bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'จัดการผู้ใช้งาน',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AdminTheme.primaryMaroon,
                      letterSpacing: -0.3,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: AdminTheme.primaryMaroon,
                      size: 28,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('คุณมีการแจ้งเตือนผู้ใช้งานใหม่'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // 2. รายการการ์ดผู้ใช้งาน 4 การ์ด (ตรงตามภาพที่ 1)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 4, bottom: 95),
                physics: const BouncingScrollPhysics(),
                itemCount: _users.length,
                itemBuilder: (context, index) {
                  final user = _users[index];
                  final name = user['name'] as String;
                  final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
                  final email = user['email'] as String;
                  final phone = user['phone'] as String;
                  final isActive = user['isActive'] as bool;

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFF3E7E8), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => _showUserRestaurantsBottomSheet(user, restaurants),
                        splashColor: AdminTheme.primaryMaroon.withOpacity(0.05),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              // อวาตาร์วงกลมสีแดงเบอร์กันดี พร้อมตัวอักษรแรกสีขาว (ตรงตามภาพที่ 1)
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: const Color(0xFF800F2F),
                                child: Text(
                                  initial,
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),

                              // ข้อมูลผู้ใช้งาน
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // 1. ชื่อผู้ใช้
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E1E1E),
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 5),

                                    // 2. อีเมล
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.email_outlined,
                                          size: 14,
                                          color: Color(0xFF757575),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          email,
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            color: Color(0xFF757575),
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),

                                    // 3. เบอร์โทรศัพท์
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.phone_outlined,
                                          size: 14,
                                          color: Color(0xFF757575),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          phone,
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            color: Color(0xFF757575),
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),

                                    // 4. สถานะการใช้งาน (จุดเขียว / เทา)
                                    Row(
                                      children: [
                                        Container(
                                          width: 7,
                                          height: 7,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isActive
                                                ? const Color(0xFF2E7D32)
                                                : const Color(0xFF757575),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          isActive ? 'ใช้งานอยู่' : 'ไม่ได้ใช้งาน',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF757575),
                                            fontWeight: FontWeight.w400,
                                          ),
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sheet สำหรับดูรายละเอียดร้านค้าของผู้ใช้ แยกตามสถานะ: รอตรวจสอบ / อนุมัติ / ไม่อนุมัติ
class _UserRestaurantsSheet extends StatefulWidget {
  final String userName;
  final String userEmail;
  final List<RestaurantAdminModel> restaurants;

  const _UserRestaurantsSheet({
    required this.userName,
    required this.userEmail,
    required this.restaurants,
  });

  @override
  State<_UserRestaurantsSheet> createState() => _UserRestaurantsSheetState();
}

class _UserRestaurantsSheetState extends State<_UserRestaurantsSheet> {
  String _selectedFilter = 'all'; // 'all', 'pending', 'approved', 'rejected'

  @override
  Widget build(BuildContext context) {
    final filtered = widget.restaurants.where((r) {
      if (_selectedFilter == 'all') return true;
      return r.status == _selectedFilter;
    }).toList();

    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 28),
        child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ร้านค้าของ ${widget.userName}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AdminTheme.primaryMaroon,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.userEmail,
                      style: const TextStyle(fontSize: 12.5, color: Colors.grey),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.grey),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ฟิลเตอร์เลือกสถานะ: ทั้งหมด / รอตรวจสอบ / อนุมัติ / ไม่อนุมัติ
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('ทั้งหมด', 'all'),
                _buildFilterChip('รอตรวจสอบ', 'pending'),
                _buildFilterChip('อนุมัติ', 'approved'),
                _buildFilterChip('ไม่อนุมัติ', 'rejected'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),

          // รายการร้านค้า
          if (filtered.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
              child: Center(
                child: Column(
                  children: const [
                    Icon(Icons.storefront_outlined, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'ไม่พบร้านค้าในสถานะที่เลือก',
                      style: TextStyle(color: Colors.grey, fontSize: 13.5),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final restaurant = filtered[index];

                Color badgeColor;
                String badgeText;
                switch (restaurant.status) {
                  case 'approved':
                    badgeColor = const Color(0xFF1B5E38);
                    badgeText = 'อนุมัติแล้ว';
                    break;
                  case 'rejected':
                    badgeColor = const Color(0xFF8B0E17);
                    badgeText = 'ไม่อนุมัติ';
                    break;
                  case 'pending':
                  default:
                    badgeColor = const Color(0xFFF59E0B);
                    badgeText = 'รอการตรวจสอบ';
                    break;
                }

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          restaurant.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            color: badgeColor,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    'สมัครเมื่อ: ${restaurant.formattedThaiDate} • ${restaurant.address}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                  onTap: () {
                    Navigator.of(context).pop();
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
        ],
      ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: AdminTheme.primaryMaroon,
        backgroundColor: const Color(0xFFF6ECEE),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AdminTheme.primaryMaroon,
          fontSize: 12.5,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
        onSelected: (selected) {
          if (selected) {
            setState(() => _selectedFilter = value);
          }
        },
      ),
    );
  }
}
