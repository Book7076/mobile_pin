import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'admin_overview_screen.dart';
import 'admin_settings_screen.dart';
import 'admin_theme.dart';
import 'admin_user_management_screen.dart';
import 'restaurant_management_screen.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  final int initialTabIndex;
  final int initialSubTabIndex;

  const AdminDashboard({
    super.key,
    this.initialTabIndex = 1, // ค่าเริ่มต้นคือหน้าจัดการร้านอาหาร (เหมือนภาพที่ 2)
    this.initialSubTabIndex = 0, // แท็บย่อยเริ่มต้น เช่น 0: รออนุมัติ, 2: ไม่อนุมัติ
  });

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // รายการหน้าจอตามสถาปัตยกรรม Flowchart
    final List<Widget> screens = [
      AdminOverviewScreen(
        onNavigateToRestaurants: () => _onTabSelected(1),
        onNavigateToUsers: () => _onTabSelected(2),
      ),
      RestaurantManagementScreen(
        initialSubTabIndex: widget.initialSubTabIndex,
      ), // หน้าจัดการร้านอาหาร (ภาพที่ 2)
      const AdminUserManagementScreen(),   // หน้าจัดการผู้ใช้งาน (ตาม Flowchart)
      const AdminSettingsScreen(),         // หน้าตั้งค่าระบบ
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // หน้าจอตามแท็บที่เลือก
          IndexedStack(
            index: _currentIndex,
            children: screens,
          ),

          // แถบ Floating Bottom Navigation Bar ขอบมนตามภาพที่ 2
          Positioned(
            left: 20,
            right: 20,
            bottom: 16,
            child: _buildFloatingBottomNav(),
          ),
        ],
      ),
    );
  }

  /// แถบเมนูด้านล่างแบบลอย (Floating Bottom Navigation Bar) 4 ไอคอนตรงตามภาพที่ 2
  Widget _buildFloatingBottomNav() {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: AdminTheme.navBarBg,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 1.2),
        boxShadow: AdminTheme.navShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 1. หน้าหลัก (Dashboard Grid)
          _buildNavItem(
            index: 0,
            icon: Icons.grid_view_rounded,
            activeIcon: Icons.grid_view_rounded,
            tooltip: 'หน้าหลัก',
          ),

          // 2. จัดการร้านอาหาร (Storefront - ตามภาพที่ 2)
          _buildNavItem(
            index: 1,
            icon: Icons.storefront_outlined,
            activeIcon: Icons.storefront_rounded,
            tooltip: 'จัดการร้านอาหาร',
          ),

          // 3. จัดการผู้ใช้งาน (Users Group)
          _buildNavItem(
            index: 2,
            icon: Icons.group_outlined,
            activeIcon: Icons.group_rounded,
            tooltip: 'จัดการผู้ใช้งาน',
          ),

          // 4. ตั้งค่าระบบ (Settings Gear)
          _buildNavItem(
            index: 3,
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings_rounded,
            tooltip: 'ตั้งค่า',
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String tooltip,
  }) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AdminTheme.navSelected : const Color(0xFFC7B1B6);

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onTabSelected(index),
          borderRadius: BorderRadius.circular(24),
          splashColor: AdminTheme.primaryMaroon.withValues(alpha: 0.1),
          highlightColor: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AdminTheme.accentPink.withValues(alpha: 0.5) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              isSelected ? activeIcon : icon,
              size: 27,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
