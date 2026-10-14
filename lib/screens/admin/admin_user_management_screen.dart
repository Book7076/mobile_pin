import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/admin_restaurant_service.dart';
import '../../services/report_service.dart';
import 'admin_theme.dart';
import 'restaurant_detail_screen.dart';

/// โมเดลข้อมูลสำหรับรายงานปัญหาจากผู้ใช้งาน (Mockup Model)
class AdminProblemReport {
  final String id;
  final String userName;
  final String userEmail;
  final String userPhone;
  final String categoryId;
  final String categoryTitle;
  final IconData categoryIcon;
  final String restaurantName;
  final String? restaurantId;
  final String description;
  final String reportedAt;
  final DateTime? createAt; // อิงตามคอลัมน์ create_at ในตาราง reports
  String status; // 'pending' (รอดำเนินการ), 'in_progress' (กำลังตรวจสอบ), 'resolved' (แก้ไขแล้ว)
  String adminNote;

  AdminProblemReport({
    required this.id,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    required this.categoryId,
    required this.categoryTitle,
    required this.categoryIcon,
    required this.restaurantName,
    this.restaurantId,
    required this.description,
    required this.reportedAt,
    this.createAt,
    required this.status,
    this.adminNote = '',
  });
}

/// หน้าจอ "รายงานปัญหาจากผู้ใช้งาน" สำหรับผู้ดูแลระบบ (Admin)
/// ออกแบบอย่างมืออาชีพ พร้อมระบบค้นหา, คัดกรองตามสถานะ, ดูรายละเอียด และอัปเดตสถานะ
class AdminUserManagementScreen extends ConsumerStatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  ConsumerState<AdminUserManagementScreen> createState() => _AdminUserManagementScreenState();
}

/// Typedef สำหรับความชัดเจนและรองรับชื่อเรียกทั้งสองแบบ
typedef AdminProblemReportsScreen = AdminUserManagementScreen;

class _AdminUserManagementScreenState extends ConsumerState<AdminUserManagementScreen> {
  // สถานะฟิลเตอร์: 'all', 'pending', 'in_progress', 'resolved'
  String _selectedStatusFilter = 'all';

  // ค้นหา
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = false;

  // รายการรายงานปัญหาจากฐานข้อมูลจริง
  final List<AdminProblemReport> _reports = [];

  // ข้อมูลตั้งต้นสำหรับ Offline / Test Environment
  static final List<AdminProblemReport> _mockFallbackReports = [
    AdminProblemReport(
      id: 'REP-2026-001',
      userName: 'Kodomo',
      userEmail: 'kodomo@gmail.com',
      userPhone: '081-244-3984',
      categoryId: 'store_info',
      categoryTitle: 'ข้อมูลร้านค้าไม่ถูกต้อง',
      categoryIcon: Icons.storefront_outlined,
      restaurantName: 'Kohatsu Matcha',
      restaurantId: 'res-01',
      description: 'เวลาทำการในแอปแจ้งว่าเปิด 10:00 - 20:00 น. แต่ร้านจริงเปลี่ยนเวลาเป็น 11:00 - 21:00 น. และมีเมนู Matcha Soft Cream เพิ่มเติมในร้านแต่ในแอปยังไม่มี',
      reportedAt: '12 ต.ค. 2026 • 14:20 น.',
      status: 'pending',
      adminNote: '',
    ),
    AdminProblemReport(
      id: 'REP-2026-002',
      userName: 'Harry Potter',
      userEmail: 'jkrolling@gmail.com',
      userPhone: '081-234-5678',
      categoryId: 'store_closed',
      categoryTitle: 'ร้านค้าปิดหรือไม่พบร้าน',
      categoryIcon: Icons.location_off_outlined,
      restaurantName: 'Haru Sushi Bar',
      restaurantId: 'res-04',
      description: 'เดินทางไปตามหมุดในแผนที่แล้วพบว่าร้านปิดกิจการถาวรแล้ว มีป้ายให้เช่าพื้นที่ติดอยู่หน้าร้าน รบกวนตรวจสอบและอัปเดตสถานะร้านด้วยครับ',
      reportedAt: '11 ต.ค. 2026 • 18:45 น.',
      status: 'in_progress',
      adminNote: 'ทีมงานกำลังติดต่อเจ้าของพื้นที่เพื่อยืนยันการปิดกิจการ',
    ),
    AdminProblemReport(
      id: 'REP-2026-003',
      userName: 'Deku Kung',
      userEmail: 'gobeyondplus@gmail.com',
      userPhone: '067-676-6767',
      categoryId: 'app_issue',
      categoryTitle: 'ปัญหาการใช้งานแอปพลิเคชัน',
      categoryIcon: Icons.phone_android_rounded,
      restaurantName: 'ข้าวบ้านก๋ง',
      restaurantId: 'res-02',
      description: 'เวลากดปัดขวาบันทึกร้านข้าวบ้านก๋งในหน้าปัดหาร้านอาหารแล้วแอปค้างไปประมาณ 3-5 วินาที ก่อนจะเด้งกลับมาหน้าแรก เป็นเฉพาะตอนที่ต่อเน็ตมือถือ',
      reportedAt: '10 ต.ค. 2026 • 20:15 น.',
      status: 'in_progress',
      adminNote: 'แจ้งทีม Dev ตรวจสอบ payload การบันทึก swipe match',
    ),
    AdminProblemReport(
      id: 'REP-2026-004',
      userName: 'Levi S. Kennedy',
      userEmail: 'titanraccooncity@gmail.com',
      userPhone: '089-785-6767',
      categoryId: 'store_info',
      categoryTitle: 'ข้อมูลร้านค้าไม่ถูกต้อง',
      categoryIcon: Icons.storefront_outlined,
      restaurantName: 'ชาบูหมูอู๊ด',
      restaurantId: 'res-03',
      description: 'เบอร์โทรศัพท์ของร้านในหน้าข้อมูลติดต่อผิด เบอร์เดิมเป็นเบอร์เจ้าของเก่า รบกวนแก้ไขเป็นเบอร์ 089-999-8888 ครับ',
      reportedAt: '09 ต.ค. 2026 • 11:30 น.',
      status: 'resolved',
      adminNote: 'แก้ไขเบอร์โทรศัพท์ในระบบและแจ้งเจ้าของร้านเรียบร้อยแล้ว',
    ),
    AdminProblemReport(
      id: 'REP-2026-005',
      userName: 'Somchai Dee',
      userEmail: 'somchai.d@gmail.com',
      userPhone: '085-111-2233',
      categoryId: 'other',
      categoryTitle: 'อื่นๆ',
      categoryIcon: Icons.more_horiz_rounded,
      restaurantName: '-',
      restaurantId: null,
      description: 'อยากให้เพิ่มฟิลเตอร์ตัวกรองค้นหาร้านอาหารที่เป็นมิตรกับสัตว์เลี้ยง (Pet-friendly) และร้านที่มีที่จอดรถในหน้าปัดร้านอาหารครับ',
      reportedAt: '08 ต.ค. 2026 • 16:05 น.',
      status: 'pending',
      adminNote: '',
    ),
  ];

  @override
  void initState() {
    super.initState();
    if (!ReportService.isSupabaseAvailable) {
      _reports.addAll(_mockFallbackReports);
    } else {
      _loadReportsFromDatabase();
    }
  }

  /// โหลดข้อมูลรายงานปัญหาจริงจาก Supabase
  Future<void> _loadReportsFromDatabase() async {
    if (!ReportService.isSupabaseAvailable) return;
    if (mounted) setState(() => _isLoading = true);

    try {
      final dbReports = await ReportService.fetchReports();
      if (mounted) {
        setState(() {
          _reports.clear();
          for (final r in dbReports) {
            final categoryTitle = r.categoryDisplayTitle;
            final icon = r.categoryIcon;

            final dateStr = r.createAt != null
                ? _formatThaiDateTime(r.createAt!)
                : 'ไม่ระบุเวลา';

            _reports.add(AdminProblemReport(
              id: r.id,
              userName: r.userName ?? (r.contactEmail?.isNotEmpty == true ? r.contactEmail! : 'ผู้ใช้งาน'),
              userEmail: r.contactEmail ?? '',
              userPhone: r.userPhone ?? '-',
              categoryId: r.category,
              categoryTitle: categoryTitle,
              categoryIcon: icon,
              restaurantName: r.restaurantName ?? '-',
              restaurantId: r.restaurantId,
              description: r.description,
              reportedAt: dateStr,
              createAt: r.createAt,
              status: r.status,
              adminNote: r.adminNote ?? '',
            ));
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Note: Error loading reports from DB: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  static String _formatThaiDateTime(DateTime dt) {
    const months = [
      'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
      'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'
    ];
    final thaiYear = dt.year > 2500 ? dt.year : dt.year + 543;
    final monthName = (dt.month >= 1 && dt.month <= 12) ? months[dt.month - 1] : '';
    final timeStr =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} น.';
    return '${dt.day} $monthName $thaiYear • $timeStr';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // คำนวณจำนวนตามสถานะ
  int get _countAll => _reports.length;
  int get _countPending => _reports.where((r) => r.status == 'pending').length;
  int get _countInProgress => _reports.where((r) => r.status == 'in_progress').length;
  int get _countResolved => _reports.where((r) => r.status == 'resolved').length;

  /// จำนวนการแจ้งเตือนรายงานใหม่ที่ยังไม่ได้กดดู อิงตามฐานข้อมูลตาราง reports จากรูปที่ 1
  /// แจ้งเตือนเมื่อมีรายงานเข้ามาใหม่เท่านั้น และเมื่อกดดูแล้วจะหายไป
  int get _newIncomingReportsCount =>
      _reports.where((r) => r.status == 'pending' && !ReportNotificationManager.isSeen(r.id)).length;

  // กรองรายการตามฟิลเตอร์สถานะและการค้นหา
  List<AdminProblemReport> get _filteredReports {
    return _reports.where((report) {
      // 1. ฟิลเตอร์สถานะ
      if (_selectedStatusFilter != 'all' && report.status != _selectedStatusFilter) {
        return false;
      }

      // 2. ค้นหา
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchUser = report.userName.toLowerCase().contains(query);
        final matchEmail = report.userEmail.toLowerCase().contains(query);
        final matchRestaurant = report.restaurantName.toLowerCase().contains(query);
        final matchDesc = report.description.toLowerCase().contains(query);
        final matchCat = report.categoryTitle.toLowerCase().contains(query);
        final matchId = report.id.toLowerCase().contains(query);
        return matchUser || matchEmail || matchRestaurant || matchDesc || matchCat || matchId;
      }

      return true;
    }).toList();
  }

  /// แสดง Modal Bottom Sheet รายการแจ้งเตือนรายงานปัญหาทั้งหมดเมื่อกดกระดิ่ง
  void _showNotificationsSheet() {
    // เมื่อกดดูกระดิ่งแจ้งเตือน ถือว่าแอดมินเห็นรายงานเหล่านี้แล้ว ตัวเลขการแจ้งเตือนจึงหายไป
    if (_newIncomingReportsCount > 0) {
      setState(() {
        ReportNotificationManager.markAllAsSeen(_reports.map((r) => r.id));
      });
    } else {
      ReportNotificationManager.markAllAsSeen(_reports.map((r) => r.id));
    }

    final pendingReports = _reports.where((r) => r.status == 'pending').toList();
    final inProgressReports = _reports.where((r) => r.status == 'in_progress').toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Material(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 24),
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
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9EEF2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.notifications_active_rounded,
                                  color: AdminTheme.primaryMaroon,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'การแจ้งเตือนรายงานปัญหา',
                                      style: TextStyle(
                                        fontSize: 17.5,
                                        fontWeight: FontWeight.bold,
                                        color: AdminTheme.primaryMaroon,
                                      ),
                                    ),
                                    Text(
                                      'รอดำเนินการ ${pendingReports.length} รายการ • กำลังตรวจสอบ ${inProgressReports.length} รายการ',
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        color: Color(0xFF757575),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          key: const Key('close_notifications_sheet_button'),
                          icon: const Icon(Icons.close_rounded, color: Colors.grey),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),

                  // รายการการแจ้งเตือน
                  if (pendingReports.isEmpty && inProgressReports.isEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.all(36.0),
                      child: Center(
                        child: Column(
                          children: const [
                            Icon(Icons.check_circle_outline_rounded, size: 48, color: Color(0xFF10B981)),
                            SizedBox(height: 10),
                            Text(
                              'ไม่มีรายงานปัญหารอดำเนินการ',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'รายงานปัญหาทั้งหมดได้รับการแก้ไขเรียบร้อยแล้ว',
                              style: TextStyle(fontSize: 12.5, color: Color(0xFF757575)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        children: [
                          if (pendingReports.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFD97706),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'รอดำเนินการ (${pendingReports.length})',
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFD97706),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ...pendingReports.map((report) => _buildNotificationTile(ctx, report, isPending: true)),
                          ],
                          if (inProgressReports.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF2563EB),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'กำลังตรวจสอบ (${inProgressReports.length})',
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2563EB),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ...inProgressReports.map((report) => _buildNotificationTile(ctx, report, isPending: false)),
                          ],
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            setState(() {
                              _selectedStatusFilter = 'pending';
                              _searchQuery = '';
                              _searchController.clear();
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AdminTheme.primaryMaroon),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            foregroundColor: AdminTheme.primaryMaroon,
                          ),
                          icon: const Icon(Icons.filter_list_rounded, size: 18),
                          label: const Text(
                            'กรองเฉพาะรายการรอดำเนินการ',
                            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationTile(BuildContext modalContext, AdminProblemReport report, {required bool isPending}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: isPending ? const Color(0xFFFEF3C7) : const Color(0xFFEFF6FF),
        child: Icon(
          isPending ? Icons.warning_amber_rounded : Icons.sync_rounded,
          color: isPending ? const Color(0xFFD97706) : const Color(0xFF2563EB),
          size: 20,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              '${report.userName} แจ้ง${report.categoryTitle}',
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1E1E),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          report.restaurantName != '-' && report.restaurantName.isNotEmpty
              ? 'ร้าน: ${report.restaurantName} • ${report.reportedAt}'
              : report.reportedAt,
          style: const TextStyle(fontSize: 11.5, color: Color(0xFF757575)),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
      onTap: () {
        Navigator.of(modalContext).pop();
        _showReportDetailSheet(report);
      },
    );
  }

  /// แสดง Bottom Sheet รายละเอียดรายงานปัญหาและการจัดการสถานะ
  void _showReportDetailSheet(AdminProblemReport report) {
    if (!ReportNotificationManager.isSeen(report.id)) {
      setState(() {
        ReportNotificationManager.markAsSeen(report.id);
      });
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ReportDetailModalSheet(
        report: report,
        onStatusChanged: (newStatus, newNote) {
          setState(() {
            report.status = newStatus;
            report.adminNote = newNote;
          });
          ReportService.updateReportStatus(
            reportId: report.id,
            status: newStatus,
            adminNote: newNote,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredReports;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. ส่วนหัว (Header): รายงานปัญหาจากผู้ใช้งาน & ไอคอนกระดิ่งพร้อม Badge
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 18, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'รายงานปัญหาจากผู้ใช้งาน',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AdminTheme.primaryMaroon,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ทั้งหมด $_countAll รายการ • รอดำเนินการ $_countPending รายการ',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF757575),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  Stack(
                    children: [
                      IconButton(
                        key: const Key('admin_bell_button'),
                        icon: const Icon(
                          Icons.notifications_none_rounded,
                          color: AdminTheme.primaryMaroon,
                          size: 28,
                        ),
                        onPressed: _showNotificationsSheet,
                      ),
                      if (_newIncomingReportsCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: IgnorePointer(
                            child: Container(
                              key: const Key('admin_bell_badge'),
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFFE53935),
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                '$_newIncomingReportsCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // 2. แถบค้นหา (Search Bar) สไตล์เรียบหรู
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFE5E5EA)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded, color: Color(0xFF757575), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val.trim()),
                        style: const TextStyle(fontSize: 13.5, color: Color(0xFF1E1E1E)),
                        decoration: const InputDecoration(
                          hintText: 'ค้นหาผู้รายงาน, ร้านค้า, หรือรายละเอียดปัญหา...',
                          hintStyle: TextStyle(
                            color: Color(0xFF9E9E9E),
                            fontSize: 12.5,
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
                        child: const Icon(Icons.close_rounded, color: Colors.grey, size: 18),
                      ),
                  ],
                ),
              ),
            ),

            // 3. ฟิลเตอร์ชิปสถานะ (Status Filter Chips)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              child: Row(
                children: [
                  _buildStatusChip('ทั้งหมด', 'all', _countAll),
                  _buildStatusChip('รอดำเนินการ', 'pending', _countPending, const Color(0xFFF59E0B)),
                  _buildStatusChip('กำลังตรวจสอบ', 'in_progress', _countInProgress, const Color(0xFF2563EB)),
                  _buildStatusChip('แก้ไขแล้ว', 'resolved', _countResolved, const Color(0xFF10B981)),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // 4. รายการการ์ดรายงานปัญหา (Report Cards List)
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AdminTheme.primaryMaroon,
                      ),
                    )
                  : filtered.isEmpty
                      ? RefreshIndicator(
                          color: AdminTheme.primaryMaroon,
                          onRefresh: _loadReportsFromDatabase,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            children: [
                              SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.assignment_turned_in_outlined,
                                      size: 56,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'ไม่พบรายงานปัญหาในหมวดหมู่นี้',
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        color: Color(0xFF757575),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    if (_searchQuery.isNotEmpty)
                                      TextButton(
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() {
                                            _searchQuery = '';
                                            _selectedStatusFilter = 'all';
                                          });
                                        },
                                        child: const Text('ล้างการค้นหา'),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          color: AdminTheme.primaryMaroon,
                          onRefresh: _loadReportsFromDatabase,
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 4, bottom: 95),
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final report = filtered[index];
                          return _buildReportCard(report);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// ชิปฟิลเตอร์สถานะพร้อมตัวเลขกำกับ
  Widget _buildStatusChip(String label, String value, int count, [Color? dotColor]) {
    final isSelected = _selectedStatusFilter == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        onTap: () => setState(() => _selectedStatusFilter = value),
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? AdminTheme.primaryMaroon : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AdminTheme.primaryMaroon : const Color(0xFFE5E5EA),
              width: 1,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: AdminTheme.primaryMaroon.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (dotColor != null && !isSelected) ...[
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF424242),
                ),
              ),
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withOpacity(0.22) : const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : const Color(0xFF616161),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// การ์ดรายงานปัญหาแต่ละรายการ (ออกแบบอย่างมืออาชีพ)
  Widget _buildReportCard(AdminProblemReport report) {
    final initial = report.userName.isNotEmpty ? report.userName[0].toUpperCase() : 'U';

    // การตั้งค่าสีและข้อความของสถานะ
    Color statusColor;
    Color statusBgColor;
    String statusText;
    IconData statusIcon;

    switch (report.status) {
      case 'resolved':
        statusColor = const Color(0xFF059669);
        statusBgColor = const Color(0xFFECFDF5);
        statusText = 'แก้ไขแล้ว';
        statusIcon = Icons.check_circle_outline_rounded;
        break;
      case 'in_progress':
        statusColor = const Color(0xFF2563EB);
        statusBgColor = const Color(0xFFEFF6FF);
        statusText = 'กำลังตรวจสอบ';
        statusIcon = Icons.sync_rounded;
        break;
      case 'pending':
      default:
        statusColor = const Color(0xFFD97706);
        statusBgColor = const Color(0xFFFEF3C7);
        statusText = 'รอดำเนินการ';
        statusIcon = Icons.schedule_rounded;
        break;
    }

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
          onTap: () => _showReportDetailSheet(report),
          splashColor: AdminTheme.primaryMaroon.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // แถวบน: ข้อมูลผู้ใช้ + Badge สถานะ
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // อวาตาร์ผู้แจ้ง
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: const Color(0xFF800F2F),
                      child: Text(
                        initial,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // ชื่อผู้แจ้ง + เวลาที่รายงาน
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            report.userName,
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E1E1E),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            report.reportedAt,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF888888),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Badge สถานะ
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 13, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // แถวหมวดหมู่ปัญหา และร้านค้าที่เกี่ยวข้อง
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    // ชิปหมวดหมู่ปัญหา
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9EEF2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(report.categoryIcon, size: 13, color: AdminTheme.primaryMaroon),
                          const SizedBox(width: 4),
                          Text(
                            report.categoryTitle,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: AdminTheme.primaryMaroon,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ชิปร้านค้าที่เกี่ยวข้อง (ถ้ามี)
                    if (report.restaurantName != '-' && report.restaurantName.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.storefront_outlined, size: 13, color: Color(0xFF4B5563)),
                            const SizedBox(width: 4),
                            Text(
                              report.restaurantName,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF374151),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // รายละเอียดปัญหาแบบย่อ (1 บรรทัด)
                Text(
                  report.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF555555),
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(height: 1, color: Color(0xFFF5EBEF)),
                const SizedBox(height: 6),

                // แถวล่าง: ปุ่มดูรายละเอียด
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    Text(
                      'ดูรายละเอียด',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AdminTheme.primaryMaroon,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 10,
                      color: AdminTheme.primaryMaroon,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Modal Bottom Sheet แสดงรายละเอียดรายงานปัญหาและให้ Admin จัดการสถานะ / เพิ่มบันทึก
class _ReportDetailModalSheet extends ConsumerStatefulWidget {
  final AdminProblemReport report;
  final void Function(String newStatus, String newNote) onStatusChanged;

  const _ReportDetailModalSheet({
    required this.report,
    required this.onStatusChanged,
  });

  @override
  ConsumerState<_ReportDetailModalSheet> createState() => _ReportDetailModalSheetState();
}

class _ReportDetailModalSheetState extends ConsumerState<_ReportDetailModalSheet> {
  late String _currentStatus;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.report.status;
    _noteController = TextEditingController(text: widget.report.adminNote);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    widget.onStatusChanged(_currentStatus, _noteController.text.trim());
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('อัปเดตสถานะรายงานปัญหาเรียบร้อยแล้ว'),
        backgroundColor: Color(0xFF10B981),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final restaurants = ref.watch(adminRestaurantProvider);

    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
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

              // Header Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'รายละเอียดรายงานปัญหา',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AdminTheme.primaryMaroon,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'แจ้งเมื่อ: ${widget.report.reportedAt}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.grey),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),

              // ข้อมูลผู้แจ้ง (Reporter Details)
              const Text(
                'ข้อมูลผู้แจ้ง',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9F9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFF3E7E8)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFF800F2F),
                      child: Text(
                        widget.report.userName.isNotEmpty ? widget.report.userName[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.report.userName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E1E1E),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.email_outlined, size: 14, color: Color(0xFF757575)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  widget.report.userEmail,
                                  style: const TextStyle(fontSize: 12.5, color: Color(0xFF757575)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(Icons.phone_outlined, size: 14, color: Color(0xFF757575)),
                              const SizedBox(width: 6),
                              Text(
                                widget.report.userPhone,
                                style: const TextStyle(fontSize: 12.5, color: Color(0xFF757575)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ข้อมูลปัญหาและร้านค้าที่เกี่ยวข้อง (Problem Details)
              const Text(
                'รายละเอียดปัญหาที่พบ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // หมวดหมู่ปัญหา
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9EEF2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(widget.report.categoryIcon, size: 14, color: AdminTheme.primaryMaroon),
                          const SizedBox(width: 4),
                          Text(
                            widget.report.categoryTitle,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AdminTheme.primaryMaroon,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ร้านค้าที่เกี่ยวข้อง
                    if (widget.report.restaurantName != '-' && widget.report.restaurantName.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.storefront_rounded, size: 16, color: AdminTheme.primaryMaroon),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'ร้านค้าที่เกี่ยวข้อง: ${widget.report.restaurantName}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E1E1E),
                              ),
                            ),
                          ),
                          // ลิงก์ดูร้านค้าถ้ามีในระบบ
                          if (widget.report.restaurantId != null)
                            InkWell(
                              onTap: () {
                                final resId = widget.report.restaurantId!;
                                Navigator.of(context).pop();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => RestaurantDetailScreen(restaurantId: resId),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AdminTheme.primaryMaroon.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'ดูข้อมูลร้าน',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AdminTheme.primaryMaroon,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 10),
                    const Divider(height: 1, color: Color(0xFFE5E7EB)),
                    const SizedBox(height: 10),

                    // ข้อความอธิบายปัญหา
                    Text(
                      widget.report.description,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF374151),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // การจัดการสถานะ (Status Updater)
              const Text(
                'อัปเดตสถานะการดำเนินการ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildStatusSelectorButton(
                      label: 'รอดำเนินการ',
                      value: 'pending',
                      icon: Icons.schedule_rounded,
                      activeColor: const Color(0xFFD97706),
                      activeBgColor: const Color(0xFFFEF3C7),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatusSelectorButton(
                      label: 'กำลังตรวจสอบ',
                      value: 'in_progress',
                      icon: Icons.sync_rounded,
                      activeColor: const Color(0xFF2563EB),
                      activeBgColor: const Color(0xFFEFF6FF),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatusSelectorButton(
                      label: 'แก้ไขแล้ว',
                      value: 'resolved',
                      icon: Icons.check_circle_outline_rounded,
                      activeColor: const Color(0xFF059669),
                      activeBgColor: const Color(0xFFECFDF5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // บันทึกของแอดมิน (Admin Remarks)
              const Text(
                'บันทึกเพิ่มเติมของแอดมิน',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _noteController,
                maxLines: 2,
                style: const TextStyle(fontSize: 13.5, color: Color(0xFF1E1E1E)),
                decoration: InputDecoration(
                  hintText: 'บันทึกการแก้ไขหรือข้อความถึงทีมงาน เช่น แก้ไขข้อมูลแล้ว...',
                  hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 13),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AdminTheme.primaryMaroon, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 20),

              // ปุ่มบันทึกการเปลี่ยนแปลง
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminTheme.primaryMaroon,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.check_rounded, size: 20),
                  label: const Text(
                    'บันทึกการเปลี่ยนแปลง',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusSelectorButton({
    required String label,
    required String value,
    required IconData icon,
    required Color activeColor,
    required Color activeBgColor,
  }) {
    final isSelected = _currentStatus == value;

    return InkWell(
      onTap: () => setState(() => _currentStatus = value),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeBgColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? activeColor : const Color(0xFFE5E7EB),
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? activeColor : const Color(0xFF9E9E9E),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? activeColor : const Color(0xFF616161),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
