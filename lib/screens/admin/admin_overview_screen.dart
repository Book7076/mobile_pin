import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/admin_overview_service.dart';
import 'admin_theme.dart';

class AdminOverviewScreen extends ConsumerWidget {
  final VoidCallback onNavigateToRestaurants;
  final VoidCallback onNavigateToUsers;

  const AdminOverviewScreen({
    super.key,
    required this.onNavigateToRestaurants,
    required this.onNavigateToUsers,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(adminOverviewStatsProvider).asData?.value;

    final pendingCount = stats?.pendingRestaurants ?? 0;
    final approvedCount = stats?.approvedRestaurants ?? 0;
    final rejectedCount = stats?.rejectedRestaurants ?? 0;
    final totalUsers = stats?.totalUsers ?? 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 95),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'หน้าหลักแอดมิน',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AdminTheme.primaryMaroon,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'ภาพรวมระบบแอปพลิเคชัน Meaimate',
                          style: TextStyle(
                            fontSize: 13,
                            color: AdminTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: AdminTheme.accentPink,
                    child: const Icon(
                      Icons.security_rounded,
                      color: AdminTheme.primaryMaroon,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Alert Banner if there are pending requests
              if (pendingCount > 0)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7B182D), Color(0xFF9E233D)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7B182D).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications_active_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'มี $pendingCount ร้านรอการตรวจสอบ',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'กรุณาตรวจสอบและอนุมัติร้านค้าใหม่',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: onNavigateToRestaurants,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AdminTheme.primaryMaroon,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'ตรวจสอบ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),

              // Summary Metric Cards
              const Text(
                'สถิติร้านค้า',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AdminTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildMetricCard(
                    title: 'รอตรวจสอบ',
                    count: pendingCount,
                    icon: Icons.hourglass_top_rounded,
                    color: AdminTheme.statusPending,
                    onTap: onNavigateToRestaurants,
                  ),
                  const SizedBox(width: 12),
                  _buildMetricCard(
                    title: 'อนุมัติแล้ว',
                    count: approvedCount,
                    icon: Icons.check_circle_outline_rounded,
                    color: AdminTheme.statusApproved,
                    onTap: onNavigateToRestaurants,
                  ),
                  const SizedBox(width: 12),
                  _buildMetricCard(
                    title: 'ไม่อนุมัติ',
                    count: rejectedCount,
                    icon: Icons.cancel_outlined,
                    color: AdminTheme.statusRejected,
                    onTap: onNavigateToRestaurants,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Quick Actions
              const Text(
                'เมนูจัดการด่วน',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AdminTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _buildActionTile(
                title: 'จัดการร้านอาหาร',
                subtitle: 'ตรวจสอบ อนุมัติ และระงับร้านค้าในระบบ',
                icon: Icons.storefront_rounded,
                badgeText: '$pendingCount รอตรวจ',
                onTap: onNavigateToRestaurants,
              ),
              const SizedBox(height: 10),
              _buildActionTile(
                title: 'จัดการผู้ใช้งาน',
                subtitle: 'ดูรายชื่อและจัดการสิทธิ์การเข้าใช้งาน',
                icon: Icons.group_rounded,
                badgeText: '$totalUsers บัญชี',
                onTap: onNavigateToUsers,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
          decoration: BoxDecoration(
            color: AdminTheme.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AdminTheme.cardBorder),
            boxShadow: AdminTheme.cardShadow,
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: AdminTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required String badgeText,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AdminTheme.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AdminTheme.cardBorder),
      ),
      elevation: 0.5,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AdminTheme.accentPink,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AdminTheme.primaryMaroon, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AdminTheme.textSecondary),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AdminTheme.primaryMaroon.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badgeText,
                style: const TextStyle(
                  color: AdminTheme.primaryMaroon,
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
