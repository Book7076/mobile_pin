import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../main.dart';
import '../../providers/auth_provider.dart';
import '../admin/admin_dashboard.dart';
import '../home/home_screen.dart';

/// Terms and Privacy Policy Screen:
/// Displays full-screen Privacy Policy according to PDPA compliance.
/// Requires the user to scroll to the bottom (~24px from end) before the "ยอมรับ" button becomes active.
/// If content fits without scrolling (large screen), the button activates immediately.
/// Saves current timestamp into `terms_accepted_at` column in Supabase upon acceptance.
/// Includes an "ออกจากระบบ" (Logout) fallback button so users are not trapped if they refuse.
class TermsPolicyScreen extends ConsumerStatefulWidget {
  final String? targetRoute;

  const TermsPolicyScreen({
    super.key,
    this.targetRoute,
  });

  @override
  ConsumerState<TermsPolicyScreen> createState() => _TermsPolicyScreenState();
}

class _TermsPolicyScreenState extends ConsumerState<TermsPolicyScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _hasReachedBottom = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Check if scrolling is required once layout is rendered (for large screens/tablets)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkScrollability();
    });

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _checkScrollability() {
    if (!mounted || !_scrollController.hasClients) return;
    final position = _scrollController.position;
    // If the content is short and doesn't require scrolling (maxScrollExtent <= 24)
    if (position.maxScrollExtent <= 24) {
      if (!_hasReachedBottom && mounted) {
        setState(() {
          _hasReachedBottom = true;
        });
      }
    } else {
      _onScroll();
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    // When scrolled to near the end (margin of ~24px from bottom)
    if (position.pixels >= (position.maxScrollExtent - 24)) {
      if (!_hasReachedBottom && mounted) {
        setState(() {
          _hasReachedBottom = true;
        });
      }
    }
  }

  Future<void> _handleAccept() async {
    if (!_hasReachedBottom || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      final nowIso = now.toUtc().toIso8601String();
      final currentUser = supabase.auth.currentUser;
      final userId = currentUser?.id ?? ref.read(authProvider)?.id;

      if (userId != null && userId.isNotEmpty) {
        try {
          await supabase.from('users').update({
            'terms_accepted_at': nowIso,
          }).eq('id', userId);
        } catch (dbErr) {
          debugPrint('Error updating terms_accepted_at in users table: $dbErr');
        }
      }

      await ref.read(authProvider.notifier).acceptTerms();

      if (!mounted) return;

      // Navigate to main application
      final user = ref.read(authProvider);
      final role = user?.role?.trim().toLowerCase();
      final email = (user?.email ?? currentUser?.email ?? '').trim().toLowerCase();
      final isAdmin = role == 'admin' ||
          email == 'admin@mealmate.com' ||
          email == 'admin@test.com';

      if (widget.targetRoute != null && widget.targetRoute!.isNotEmpty) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          widget.targetRoute!,
          (route) => false,
        );
      } else if (isAdmin) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AdminDashboard()),
          (route) => false,
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: AppConstants.burgundyPrimary,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'ออกจากระบบ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D1D24),
            ),
          ),
          content: const Text(
            'หากคุณไม่อนุญาตและไม่กดยอมรับนโยบายความเป็นส่วนตัว คุณจะไม่สามารถเข้าใช้งานแอปได้ ต้องการออกจากระบบหรือไม่?',
            style: TextStyle(fontSize: 14.5, color: Color(0xFF555555)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(false),
              child: const Text(
                'ยกเลิก',
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.burgundyPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.of(dialogCtx).pop(true),
              child: const Text('ออกจากระบบ'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await ref.read(authProvider.notifier).logout();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const burgundy = AppConstants.burgundyPrimary;
    const disabledBg = Color(0xFFE2D6D9);
    const disabledFg = Color(0xFF9E8B90);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        // Prevent hardware back navigation - user must accept or logout
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F7F8),
        appBar: AppBar(
          backgroundColor: burgundy,
          foregroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text(
            'นโยบายความเป็นส่วนตัว',
            style: TextStyle(
              fontSize: 18.5,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, size: 21, color: Colors.white),
              tooltip: 'ออกจากระบบ',
              onPressed: _handleLogout,
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Main Scrollable Policy Content
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification.metrics.maxScrollExtent <= 24 ||
                        notification.metrics.pixels >= notification.metrics.maxScrollExtent - 24) {
                      if (!_hasReachedBottom && mounted) {
                        setState(() {
                          _hasReachedBottom = true;
                        });
                      }
                    }
                    return false;
                  },
                  child: SingleChildScrollView(
                    key: const Key('terms_scroll_view'),
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0F000000),
                            blurRadius: 16,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header Badge & Title
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: burgundy.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.security,
                                  color: burgundy,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'MealMate Privacy Policy',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: burgundy,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'นโยบายความเป็นส่วนตัว',
                                      style: TextStyle(
                                        fontSize: 17.5,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF1D1D24),
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Effective Date Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7EFF2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFEAD5DB)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.event_available, size: 17, color: burgundy),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'วันที่มีผลบังคับใช้: 16 ตุลาคม 2569',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: burgundy,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Preamble
                          const Text(
                            'MealMate ให้ความสำคัญกับความเป็นส่วนตัวของผู้ใช้งาน นโยบายฉบับนี้อธิบายว่าเราเก็บ ใช้ เปิดเผย และรักษาความปลอดภัยของข้อมูลส่วนบุคคลของคุณอย่างไร รวมถึงสิทธิของคุณตามกฎหมายคุ้มครองข้อมูลส่วนบุคคล',
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.6,
                              color: Color(0xFF333333),
                            ),
                          ),

                          const SizedBox(height: 20),
                          const Divider(height: 1, color: Color(0xFFECECEC)),
                          const SizedBox(height: 20),

                          // Section 1
                          _buildSectionTitle('1. ข้อมูลที่เราเก็บรวบรวม'),
                          const SizedBox(height: 8),
                          _buildBulletPoint(
                            'ข้อมูลระบุตัวตนและข้อมูลติดต่อ',
                            'ชื่อ นามสกุล อีเมล และหมายเลขโทรศัพท์ รวมถึงข้อมูลโปรไฟล์พื้นฐานที่ได้รับจาก Google หรือ Facebook ในกรณีที่คุณสมัครหรือเข้าสู่ระบบด้วยบัญชีเหล่านั้น',
                          ),
                          _buildBulletPoint(
                            'ข้อมูลร้านค้า',
                            'หากคุณสมัครเป็นร้านค้า เราจะเก็บข้อมูลร้านค้าของคุณ รวมถึงที่อยู่ของร้านค้า (เก็บเฉพาะผู้ที่สมัครเป็นร้านค้าเท่านั้น)',
                          ),
                          _buildBulletPoint(
                            'ข้อมูลบัญชี',
                            'ชื่อผู้ใช้และข้อมูลที่จำเป็นต่อการเข้าสู่ระบบ',
                          ),
                          _buildBulletPoint(
                            'ข้อมูลการใช้งาน',
                            'ประวัติการใช้งานและการตั้งค่าภายในแอป',
                          ),
                          _buildBulletPoint(
                            'ข้อมูลทางเทคนิค',
                            'ประเภทอุปกรณ์ ระบบปฏิบัติการ และบันทึกการใช้งานระบบ',
                          ),
                          _buildBulletPoint(
                            'ข้อมูลการยอมรับนโยบาย',
                            'วันและเวลาที่คุณกดยอมรับนโยบายฉบับนี้',
                          ),

                          const SizedBox(height: 22),

                          // Section 2
                          _buildSectionTitle('2. วัตถุประสงค์ในการใช้ข้อมูล'),
                          const SizedBox(height: 8),
                          _buildSimpleBullet('เพื่อสร้างและจัดการบัญชี และให้บริการตามฟังก์ชันของแอป'),
                          _buildSimpleBullet('เพื่อใช้หมายเลขโทรศัพท์ในการติดต่อ ยืนยันตัวตน และแจ้งข้อมูลที่เกี่ยวข้องกับการใช้บริการ'),
                          _buildSimpleBullet('เพื่อใช้ข้อมูลร้านค้าและที่อยู่ในการเปิดและบริหารจัดการร้านค้าของคุณบนแอป'),
                          _buildSimpleBullet('เพื่อยืนยันตัวตนและรักษาความปลอดภัยของระบบ'),
                          _buildSimpleBullet('เพื่อปรับปรุงประสิทธิภาพและประสบการณ์การใช้งาน'),
                          _buildSimpleBullet('เพื่อแจ้งข่าวสารที่เกี่ยวข้องกับบริการ'),
                          _buildSimpleBullet('เพื่อป้องกันการใช้งานที่ผิดกฎหมายหรือฝ่าฝืนข้อกำหนด'),
                          _buildSimpleBullet('เพื่อปฏิบัติตามกฎหมายและคำสั่งของหน่วยงานที่มีอำนาจ'),

                          const SizedBox(height: 22),

                          // Section 3
                          _buildSectionTitle('3. การเปิดเผยข้อมูล'),
                          const SizedBox(height: 8),
                          _buildParagraph(
                            'เราไม่ขายข้อมูลส่วนบุคคลของคุณ เราอาจเปิดเผยข้อมูลเท่าที่จำเป็นแก่ผู้ให้บริการที่ช่วยดำเนินงานของแอป เช่น ผู้ให้บริการระบบจัดเก็บข้อมูลและผู้ให้บริการยืนยันตัวตน (Google/Facebook) รวมถึงหน่วยงานที่มีอำนาจตามกฎหมายเมื่อมีเหตุจำเป็น ทั้งนี้ ข้อมูลร้านค้าและที่อยู่ร้านอาจแสดงให้ผู้ใช้งานอื่นเห็นตามฟังก์ชันของแอป',
                          ),

                          const SizedBox(height: 22),

                          // Section 4
                          _buildSectionTitle('4. ระยะเวลาในการเก็บรักษาข้อมูล'),
                          const SizedBox(height: 8),
                          _buildParagraph(
                            'เราเก็บข้อมูลของคุณตราบเท่าที่บัญชียังใช้งานอยู่ หรือเท่าที่จำเป็นตามวัตถุประสงค์ข้างต้นและตามที่กฎหมายกำหนด เมื่อหมดความจำเป็น เราจะลบหรือทำให้ข้อมูลไม่สามารถระบุตัวบุคคลได้',
                          ),

                          const SizedBox(height: 22),

                          // Section 5
                          _buildSectionTitle('5. การรักษาความมั่นคงปลอดภัย'),
                          const SizedBox(height: 8),
                          _buildParagraph(
                            'เราใช้มาตรการทางเทคนิคและการบริหารจัดการที่เหมาะสมเพื่อป้องกันการเข้าถึง ใช้ แก้ไข หรือเปิดเผยข้อมูลโดยไม่ได้รับอนุญาต อย่างไรก็ตาม การส่งข้อมูลผ่านอินเทอร์เน็ตไม่อาจรับประกันความปลอดภัยได้อย่างสมบูรณ์',
                          ),

                          const SizedBox(height: 22),

                          // Section 6
                          _buildSectionTitle('6. สิทธิของเจ้าของข้อมูล'),
                          const SizedBox(height: 8),
                          _buildParagraph(
                            'ภายใต้เงื่อนไขของกฎหมาย คุณมีสิทธิขอเข้าถึงและขอสำเนาข้อมูล ขอแก้ไขให้ถูกต้อง ขอให้ลบหรือทำลายข้อมูล ขอให้ระงับหรือคัดค้านการใช้ข้อมูลในบางกรณี ขอโอนย้ายข้อมูล ถอนความยินยอม (โดยไม่กระทบการประมวลผลที่ทำไปแล้วโดยชอบ) และร้องเรียนต่อหน่วยงานที่มีอำนาจ โดยติดต่อเราได้ตามช่องทางในข้อ 8',
                          ),

                          const SizedBox(height: 22),

                          // Section 7
                          _buildSectionTitle('7. การเปลี่ยนแปลงนโยบาย'),
                          const SizedBox(height: 8),
                          _buildParagraph(
                            'เราอาจปรับปรุงนโยบายนี้เป็นครั้งคราว และจะแจ้งให้ทราบผ่านช่องทางที่เหมาะสมพร้อมระบุวันที่มีผลบังคับใช้ของฉบับใหม่',
                          ),

                          const SizedBox(height: 22),

                          // Section 8
                          _buildSectionTitle('8. ช่องทางติดต่อ'),
                          const SizedBox(height: 8),
                          _buildParagraph('หากมีข้อสงสัยหรือต้องการใช้สิทธิเกี่ยวกับข้อมูลส่วนบุคคล ติดต่อได้ที่'),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFBF8F9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFEFE4E7)),
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.business, size: 16, color: burgundy),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'ผู้ให้บริการ: ทีมพัฒนา MealMate',
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF222222),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.email_outlined, size: 16, color: burgundy),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'อีเมล: MealMate@gmail.com',
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w600,
                                          color: burgundy,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Closing Statement
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F7F8),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'การใช้งานแอปและการประมวลผลข้อมูลส่วนบุคคลเป็นไปตามนโยบายฉบับนี้และกฎหมายที่เกี่ยวข้อง',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF444444),
                                height: 1.5,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom Sticky Action Bar
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x18000000),
                      blurRadius: 16,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Hint when button is not yet unlocked
                    if (!_hasReachedBottom) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_downward,
                            size: 14,
                            color: Colors.orange.shade800,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'กรุณาเลื่อนอ่านจนถึงท้ายเนื้อหาเพื่อกดยอมรับ',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange.shade800,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],

                    // Accept Button: disabled until reached bottom
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        key: const Key('terms_accept_button'),
                        onPressed: (_hasReachedBottom && !_isLoading) ? _handleAccept : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: burgundy,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: disabledBg,
                          disabledForegroundColor: disabledFg,
                          elevation: _hasReachedBottom ? 4 : 0,
                          shadowColor: const Color(0x40800E2E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.2,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _hasReachedBottom ? Icons.check_circle : Icons.lock_outline,
                                    size: 19,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'ยอมรับ',
                                    style: TextStyle(
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Logout Escape Hatch Button
                    SizedBox(
                      height: 44,
                      width: double.infinity,
                      child: OutlinedButton(
                        key: const Key('terms_logout_button'),
                        onPressed: _isLoading ? null : _handleLogout,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF666666),
                          side: const BorderSide(color: Color(0xFFD6D6D6)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout, size: 17, color: Color(0xFF666666)),
                            SizedBox(width: 6),
                            Text(
                              'ออกจากระบบ',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: Color(0xFF1D1D24),
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13.5,
        height: 1.6,
        color: Color(0xFF444444),
      ),
    );
  }

  Widget _buildBulletPoint(String label, String detail) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6.0, right: 8.0),
            child: Icon(Icons.circle, size: 6, color: AppConstants.burgundyPrimary),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.55,
                  color: Color(0xFF444444),
                  fontFamily: 'Kanit',
                ),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF222222),
                    ),
                  ),
                  TextSpan(text: detail),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6.0, right: 8.0),
            child: Icon(Icons.circle, size: 6, color: AppConstants.burgundyPrimary),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.55,
                color: Color(0xFF444444),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper modal to show privacy policy from registration screens
void showPrivacyPolicyDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (dialogCtx) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(dialogCtx).size.height * 0.82,
            maxWidth: 600,
          ),
          child: Column(
            children: [
              Container(
                color: AppConstants.burgundyPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'นโยบายความเป็นส่วนตัว',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 20),
                      onPressed: () => Navigator.of(dialogCtx).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'วันที่มีผลบังคับใช้: 16 ตุลาคม 2569',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppConstants.burgundyPrimary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'MealMate ให้ความสำคัญกับความเป็นส่วนตัวของผู้ใช้งาน นโยบายฉบับนี้อธิบายว่าเราเก็บ ใช้ เปิดเผย และรักษาความปลอดภัยของข้อมูลส่วนบุคคลของคุณอย่างไร รวมถึงสิทธิของคุณตามกฎหมายคุ้มครองข้อมูลส่วนบุคคล',
                        style: TextStyle(fontSize: 13.5, height: 1.55),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        '1. ข้อมูลที่เราเก็บรวบรวม',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '- ข้อมูลระบุตัวตนและข้อมูลติดต่อ: ชื่อ นามสกุล อีเมล และหมายเลขโทรศัพท์ รวมถึงข้อมูลโปรไฟล์พื้นฐานที่ได้รับจาก Google หรือ Facebook ในกรณีที่คุณสมัครหรือเข้าสู่ระบบด้วยบัญชีเหล่านั้น\n'
                        '- ข้อมูลร้านค้า: หากคุณสมัครเป็นร้านค้า เราจะเก็บข้อมูลร้านค้าของคุณ รวมถึงที่อยู่ของร้านค้า (เก็บเฉพาะผู้ที่สมัครเป็นร้านค้าเท่านั้น)\n'
                        '- ข้อมูลบัญชี: ชื่อผู้ใช้และข้อมูลที่จำเป็นต่อการเข้าสู่ระบบ\n'
                        '- ข้อมูลการใช้งาน: ประวัติการใช้งานและการตั้งค่าภายในแอป\n'
                        '- ข้อมูลทางเทคนิค: ประเภทอุปกรณ์ ระบบปฏิบัติการ และบันทึกการใช้งานระบบ\n'
                        '- ข้อมูลการยอมรับนโยบาย: วันและเวลาที่คุณกดยอมรับนโยบายฉบับนี้',
                        style: TextStyle(fontSize: 13, height: 1.5),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        '2. วัตถุประสงค์ในการใช้ข้อมูล',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '- เพื่อสร้างและจัดการบัญชี และให้บริการตามฟังก์ชันของแอป\n'
                        '- เพื่อใช้หมายเลขโทรศัพท์ในการติดต่อ ยืนยันตัวตน และแจ้งข้อมูลที่เกี่ยวข้องกับการใช้บริการ\n'
                        '- เพื่อใช้ข้อมูลร้านค้าและที่อยู่ในการเปิดและบริหารจัดการร้านค้าของคุณบนแอป\n'
                        '- เพื่อยืนยันตัวตนและรักษาความปลอดภัยของระบบ\n'
                        '- เพื่อปรับปรุงประสิทธิภาพและประสบการณ์การใช้งาน\n'
                        '- เพื่อแจ้งข่าวสารที่เกี่ยวข้องกับบริการ\n'
                        '- เพื่อป้องกันการใช้งานที่ผิดกฎหมายหรือฝ่าฝืนข้อกำหนด\n'
                        '- เพื่อปฏิบัติตามกฎหมายและคำสั่งของหน่วยงานที่มีอำนาจ',
                        style: TextStyle(fontSize: 13, height: 1.5),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        '3. การเปิดเผยข้อมูล',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'เราไม่ขายข้อมูลส่วนบุคคลของคุณ เราอาจเปิดเผยข้อมูลเท่าที่จำเป็นแก่ผู้ให้บริการที่ช่วยดำเนินงานของแอป เช่น ผู้ให้บริการระบบจัดเก็บข้อมูลและผู้ให้บริการยืนยันตัวตน (Google/Facebook) รวมถึงหน่วยงานที่มีอำนาจตามกฎหมายเมื่อมีเหตุจำเป็น ทั้งนี้ ข้อมูลร้านค้าและที่อยู่ร้านอาจแสดงให้ผู้ใช้งานอื่นเห็นตามฟังก์ชันของแอป',
                        style: TextStyle(fontSize: 13, height: 1.5),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        '4. ระยะเวลาในการเก็บรักษาข้อมูล',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'เราเก็บข้อมูลของคุณตราบเท่าที่บัญชียังใช้งานอยู่ หรือเท่าที่จำเป็นตามวัตถุประสงค์ข้างต้นและตามที่กฎหมายกำหนด เมื่อหมดความจำเป็น เราจะลบหรือทำให้ข้อมูลไม่สามารถระบุตัวบุคคลได้',
                        style: TextStyle(fontSize: 13, height: 1.5),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        '5. การรักษาความมั่นคงปลอดภัย',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'เราใช้มาตรการทางเทคนิคและการบริหารจัดการที่เหมาะสมเพื่อป้องกันการเข้าถึง ใช้ แก้ไข หรือเปิดเผยข้อมูลโดยไม่ได้รับอนุญาต อย่างไรก็ตาม การส่งข้อมูลผ่านอินเทอร์เน็ตไม่อาจรับประกันความปลอดภัยได้อย่างสมบูรณ์',
                        style: TextStyle(fontSize: 13, height: 1.5),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        '6. สิทธิของเจ้าของข้อมูล',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'ภายใต้เงื่อนไขของกฎหมาย คุณมีสิทธิขอเข้าถึงและขอสำเนาข้อมูล ขอแก้ไขให้ถูกต้อง ขอให้ลบหรือทำลายข้อมูล ขอให้ระงับหรือคัดค้านการใช้ข้อมูลในบางกรณี ขอโอนย้ายข้อมูล ถอนความยินยอม (โดยไม่กระทบการประมวลผลที่ทำไปแล้วโดยชอบ) และร้องเรียนต่อหน่วยงานที่มีอำนาจ โดยติดต่อเราได้ตามช่องทางในข้อ 8',
                        style: TextStyle(fontSize: 13, height: 1.5),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        '7. การเปลี่ยนแปลงนโยบาย',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'เราอาจปรับปรุงนโยบายนี้เป็นครั้งคราว และจะแจ้งให้ทราบผ่านช่องทางที่เหมาะสมพร้อมระบุวันที่มีผลบังคับใช้ของฉบับใหม่',
                        style: TextStyle(fontSize: 13, height: 1.5),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        '8. ช่องทางติดต่อ',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'หากมีข้อสงสัยหรือต้องการใช้สิทธิเกี่ยวกับข้อมูลส่วนบุคคล ติดต่อได้ที่\n'
                        '- ผู้ให้บริการ: ทีมพัฒนา MealMate\n'
                        '- อีเมล: MealMate@gmail.com\n\n'
                        'การใช้งานแอปและการประมวลผลข้อมูลส่วนบุคคลเป็นไปตามนโยบายฉบับนี้และกฎหมายที่เกี่ยวข้อง',
                        style: TextStyle(fontSize: 13, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.burgundyPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.of(dialogCtx).pop(),
                    child: const Text('ปิด', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
