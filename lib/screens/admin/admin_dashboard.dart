import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/approval_restaurant.dart';
import '../../providers/restaurant_approval_provider.dart';
import '../../services/admin_overview_service.dart';
import '../../services/admin_restaurant_service.dart';
import 'restaurant_approval_detail_screen.dart';
import 'restaurant_detail_screen.dart' as admin_detail;
import 'admin_user_management_screen.dart';
import 'admin_settings_screen.dart';
import '../../widgets/app_adaptive_image.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  final int initialTabIndex;
  final int initialSubTabIndex;
  final int initialApprovalTabIndex;

  const AdminDashboard({
    super.key,
    this.initialTabIndex = 0,
    this.initialSubTabIndex = 0,
    this.initialApprovalTabIndex = 0,
  });

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late int _selectedTabIndex;
  late TabController _approvalTabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  static const Color primaryBurgundy = Color(0xFF700F2B);
  static const Color cardBorderColor = Color(0xFFF4E5EB);
  static const Color unselectedNavColor = Color(0xFFC7A8B4);

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex;
    final effectiveSubTab = widget.initialSubTabIndex != 0
        ? widget.initialSubTabIndex
        : widget.initialApprovalTabIndex;
    _approvalTabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: effectiveSubTab.clamp(0, 2),
    );
  }

  @override
  void didUpdateWidget(covariant AdminDashboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTabIndex != oldWidget.initialTabIndex) {
      setState(() {
        _selectedTabIndex = widget.initialTabIndex;
      });
    }
    final sub = widget.initialSubTabIndex != 0
        ? widget.initialSubTabIndex
        : widget.initialApprovalTabIndex;
    final oldSub = oldWidget.initialSubTabIndex != 0
        ? oldWidget.initialSubTabIndex
        : oldWidget.initialApprovalTabIndex;
    if (sub != oldSub) {
      _approvalTabController.animateTo(sub.clamp(0, 2));
    }
  }

  @override
  void dispose() {
    _approvalTabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onRestaurantCardTapped(ApprovalRestaurant restaurant) {
    if (restaurant.status == 'rejected' ||
        (restaurant.id == 'res-rejected-01' && restaurant.status == 'rejected') ||
        (restaurant.name == 'เตาอุ่น' && restaurant.status == 'rejected')) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => admin_detail.RestaurantDetailScreen(
            restaurantId: restaurant.id,
          ),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              RestaurantApprovalDetailScreen(restaurant: restaurant),
        ),
      );
    }
  }

  Widget _buildCurrentTab() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildDashboardTab();
      case 1:
        return _buildStoreManagementTab();
      case 2:
        return const AdminUserManagementScreen();
      case 3:
        return const AdminSettingsScreen();
      default:
        return _buildDashboardTab();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(child: _buildCurrentTab()),
      bottomNavigationBar: _buildFloatingBottomNav(),
    );
  }

  // ==================== TAB 0: DASHBOARD ====================
  Widget _buildDashboardTab() {
    final stats = ref.watch(adminOverviewStatsProvider);

    return RefreshIndicator(
      color: primaryBurgundy,
      onRefresh: () => ref.refresh(adminOverviewStatsProvider.future),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ภาพรวมระบบ',
                      style: GoogleFonts.notoSansThai(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: primaryBurgundy,
                      ),
                    ),
                    Text(
                      'ข้อมูลล่าสุดจาก Supabase',
                      style: GoogleFonts.notoSansThai(
                        fontSize: 12,
                        color: const Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  key: const Key('refresh_admin_overview_button'),
                  tooltip: 'รีเฟรชข้อมูล',
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: primaryBurgundy,
                    size: 28,
                  ),
                  onPressed: () => ref.invalidate(adminOverviewStatsProvider),
                ),
              ],
            ),
            const SizedBox(height: 20),
            stats.when(
              loading: _buildOverviewLoading,
              error: (error, stackTrace) {
                debugPrint('Admin overview stats error: $error\n$stackTrace');
                return _buildOverviewError();
              },
              data: _buildOverviewMetrics,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewMetrics(AdminOverviewStats stats) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'ร้านที่อนุมัติ',
                value: stats.approvedRestaurants.toString(),
                unit: 'ร้าน',
                icon: Icons.check_circle_outline_rounded,
                color: const Color(0xFF15803D),
                onTap: () => _openRestaurantStatusTab(1),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildMetricCard(
                title: 'ร้านที่ปฏิเสธ',
                value: stats.rejectedRestaurants.toString(),
                unit: 'ร้าน',
                icon: Icons.cancel_outlined,
                color: const Color(0xFFB42318),
                onTap: () => _openRestaurantStatusTab(2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'ร้านรออนุมัติ',
                value: stats.pendingRestaurants.toString(),
                unit: 'ร้าน',
                icon: Icons.hourglass_top_rounded,
                color: const Color(0xFFB45309),
                onTap: () => _openRestaurantStatusTab(0),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildMetricCard(
                title: 'ผู้ใช้ทั้งหมด',
                value: stats.totalUsers.toString(),
                unit: 'คน',
                icon: Icons.people_outline_rounded,
                color: primaryBurgundy,
                onTap: () => setState(() => _selectedTabIndex = 2),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOverviewLoading() {
    return const SizedBox(
      height: 238,
      child: Center(child: CircularProgressIndicator(color: primaryBurgundy)),
    );
  }

  Widget _buildOverviewError() {
    return Container(
      key: const Key('admin_overview_error'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorderColor),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded, color: primaryBurgundy, size: 36),
          const SizedBox(height: 10),
          Text(
            'โหลดข้อมูลภาพรวมไม่สำเร็จ',
            style: GoogleFonts.notoSansThai(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF222222),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'กรุณาตรวจสอบการเชื่อมต่อหรือสิทธิ์การอ่านข้อมูล',
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSansThai(
              fontSize: 12,
              color: const Color(0xFF757575),
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () => ref.invalidate(adminOverviewStatsProvider),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('ลองอีกครั้ง'),
          ),
        ],
      ),
    );
  }

  void _openRestaurantStatusTab(int tabIndex) {
    setState(() => _selectedTabIndex = 1);
    _approvalTabController.animateTo(tabIndex);
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 132,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cardBorderColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: primaryBurgundy.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.notoSansThai(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF222222),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: GoogleFonts.notoSansThai(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    unit,
                    style: GoogleFonts.notoSansThai(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== TAB 1: STORE MANAGEMENT ====================
  Widget _buildStoreManagementTab() {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'จัดการร้านอาหาร',
                    style: GoogleFonts.notoSansThai(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: primaryBurgundy,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              TabBar(
                controller: _approvalTabController,
                labelColor: primaryBurgundy,
                unselectedLabelColor: const Color(0xFF222222),
                indicatorColor: primaryBurgundy,
                indicatorWeight: 3.0,
                indicatorSize: TabBarIndicatorSize.tab,
                labelStyle: GoogleFonts.notoSansThai(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: GoogleFonts.notoSansThai(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                tabs: const [
                  Tab(text: 'รออนุมัติ'),
                  Tab(text: 'อนุมัติ'),
                  Tab(text: 'ไม่อนุมัติ'),
                ],
              ),
            ],
          ),
        ),
        Container(color: const Color(0xFFF0E2E7), height: 1),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE2E2E2)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) =>
                        setState(() => _searchQuery = val.trim()),
                    style: GoogleFonts.notoSansThai(
                      fontSize: 14,
                      color: const Color(0xFF1E1E1E),
                    ),
                    decoration: InputDecoration(
                      hintText: 'ค้นหาร้านค้า',
                      hintStyle: GoogleFonts.notoSansThai(
                        color: const Color(0xFF9E9E9E),
                        fontSize: 13.5,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.grey,
                      size: 18,
                    ),
                  )
                else
                  const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF222222),
                    size: 22,
                  ),
              ],
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _approvalTabController,
            children: [
              _buildApprovalList('pending'),
              _buildApprovalList('approved'),
              _buildApprovalList('rejected'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildApprovalList(String targetStatus) {
    final allApproval = ref.watch(restaurantApprovalProvider);
    final allAdmin = ref.watch(adminRestaurantProvider);

    // Compute effective status for each ApprovalRestaurant
    final List<ApprovalRestaurant> list = [];
    final Set<String> seenIds = {};
    final Set<String> seenNames = {};

    for (final r in allApproval) {
      final adminMatch = allAdmin
          .where((a) => a.id == r.id || a.name == r.name)
          .firstOrNull;

      String status = r.status;
      String? reason = r.rejectionReason;

      // Effective status calculation:
      if (adminMatch?.status == 'approved' && r.status == 'approved') {
        status = 'approved';
        reason = null;
      } else if (adminMatch?.status == 'approved' && r.status != 'approved') {
        // e.g. updated to approved via cancelRejection in admin provider
        status = 'approved';
        reason = null;
      } else if (r.status == 'approved' && adminMatch?.status != 'approved') {
        // e.g. updated to approved in approval provider
        status = 'approved';
        reason = null;
      } else if (r.status == 'rejected' || adminMatch?.status == 'rejected') {
        status = 'rejected';
        reason = (r.rejectionReason != null && r.rejectionReason!.trim().isNotEmpty)
            ? r.rejectionReason
            : adminMatch?.rejectionReason;
      } else if (adminMatch != null && adminMatch.status == 'pending') {
        status = 'pending';
        reason = null;
      } else if (r.status == 'pending') {
        status = 'pending';
        reason = null;
      }

      final item = r.copyWith(
        status: status,
        rejectionReason: reason,
      );

      seenIds.add(item.id);
      seenNames.add(item.name);

      if (status == targetStatus) {
        list.add(item);
      }
    }

    // Also include any restaurants present in allAdmin but missing from allApproval
    for (final a in allAdmin) {
      if (!seenIds.contains(a.id) && !seenNames.contains(a.name)) {
        final converted = ApprovalRestaurant.fromAdminModel(a);
        if (converted.status == targetStatus) {
          list.add(converted);
        }
      }
    }

    var filtered = list;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered
          .where(
            (r) =>
                r.name.toLowerCase().contains(q) ||
                r.category.toLowerCase().contains(q) ||
                r.phone.contains(q),
          )
          .toList();
    }

    if (filtered.isEmpty) {
      return RefreshIndicator(
        color: primaryBurgundy,
        onRefresh: () async {
          await ref.read(restaurantApprovalProvider.notifier).loadFromSupabase();
          await ref.read(adminRestaurantProvider.notifier).refresh();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: 380,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.storefront_outlined,
                    size: 56,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    targetStatus == 'approved'
                        ? (_searchQuery.isNotEmpty
                              ? 'ไม่พบร้านอาหารที่ค้นหา'
                              : 'ไม่มีร้านอาหารที่อนุมัติแล้ว')
                        : (targetStatus == 'pending'
                              ? 'ไม่มีคำขอรออนุมัติ'
                              : 'ไม่มีร้านอาหารที่ไม่อนุมัติ'),
                    style: GoogleFonts.notoSansThai(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: primaryBurgundy,
      onRefresh: () async {
        await ref.read(restaurantApprovalProvider.notifier).loadFromSupabase();
        await ref.read(adminRestaurantProvider.notifier).refresh();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 95),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        child: Column(
          children: [
            for (final restaurant in filtered)
              _buildRestaurantApprovalCard(restaurant),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantApprovalCard(ApprovalRestaurant restaurant) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFDEEF2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF700F2B).withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onRestaurantCardTapped(restaurant),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AppAdaptiveImage(
                    imageUrl: restaurant.imageAsset,
                    width: 82,
                    height: 82,
                    fit: BoxFit.cover,
                    fallback: Container(
                      width: 82,
                      height: 82,
                      color: const Color(0xFFF9EEF2),
                      child: const Icon(
                        Icons.storefront_rounded,
                        color: primaryBurgundy,
                        size: 36,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        restaurant.name,
                        style: GoogleFonts.notoSansThai(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E1E1E),
                        ),
                      ),
                      if (restaurant.status == 'pending') ...[
                        Text(
                          'วันที่สมัคร',
                          style: GoogleFonts.notoSansThai(
                            fontSize: 12,
                            color: const Color(0xFF757575),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          restaurant.requestDate,
                          style: GoogleFonts.notoSansThai(
                            fontSize: 12.5,
                            color: const Color(0xFF333333),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ] else ...[
                        Text(
                          'อัปเดตล่าสุด',
                          style: GoogleFonts.notoSansThai(
                            fontSize: 12,
                            color: const Color(0xFF757575),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          restaurant.lastUpdated,
                          style: GoogleFonts.notoSansThai(
                            fontSize: 12,
                            color: const Color(0xFF757575),
                          ),
                        ),
                      ],
                      if (restaurant.rejectionReason != null &&
                          restaurant.rejectionReason!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'เหตุผล: ${restaurant.rejectionReason}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.notoSansThai(
                            fontSize: 11,
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'รายละเอียด',
                              style: GoogleFonts.notoSansThai(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1E1E1E),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 11,
                              color: Color(0xFF1E1E1E),
                            ),
                          ],
                        ),
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
  }

  // ==================== FLOATING BOTTOM NAV BAR ====================
  Widget _buildFloatingBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(28, 0, 28, 20),
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.grid_view_rounded),
          _buildNavItem(1, Icons.storefront_outlined),
          _buildNavItem(2, Icons.people_outline_rounded),
          _buildNavItem(3, Icons.settings_outlined),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon) {
    final isSelected = _selectedTabIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedTabIndex = index),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: isSelected
            ? BoxDecoration(
                color: const Color(0xFFF9EEF2),
                borderRadius: BorderRadius.circular(16),
              )
            : null,
        child: Icon(
          icon,
          color: isSelected ? primaryBurgundy : unselectedNavColor,
          size: 26,
        ),
      ),
    );
  }
}
