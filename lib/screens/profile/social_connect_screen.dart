import 'package:flutter/material.dart';
import '../../core/social_link_manager.dart';
import '../../widgets/social_login_buttons.dart';

class SocialConnectScreen extends StatefulWidget {
  final String email;

  const SocialConnectScreen({
    super.key,
    this.email = 'Emma.carter@gmail.com',
  });

  @override
  State<SocialConnectScreen> createState() => _SocialConnectScreenState();
}

class _SocialConnectScreenState extends State<SocialConnectScreen> {
  bool _isLoading = false;

  void _handleConnect(String provider) async {
    final isFb = provider == 'facebook';
    final providerName = isFb ? 'Facebook' : 'Google';

    // Verify condition: If one is already linked, cannot link the other
    if (!SocialLinkManager.canLink(provider)) {
      final other = isFb ? 'Google' : 'Facebook';
      _showWarningDialog(
        title: 'ไม่สามารถเชื่อมต่อได้',
        message: 'บัญชีนี้ได้เชื่อมต่อกับ $other อยู่แล้ว ไม่สามารถเชื่อมต่อกับ $providerName ได้\n\nหากต้องการเชื่อมต่อกับ $providerName กรุณายกเลิกการเชื่อมต่อกับ $other ก่อน',
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 300));

    final success = SocialLinkManager.linkProvider(
      provider,
      name: 'Emma Carter',
      email: widget.email,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('เชื่อมต่อบัญชี $providerName สำเร็จแล้ว'),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _handleUnlink(String provider) {
    final providerName = provider == 'facebook' ? 'Facebook' : 'Google';

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFC2185B), size: 26),
            const SizedBox(width: 8),
            const Text(
              'ยืนยันการยกเลิก',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF6E162B),
              ),
            ),
          ],
        ),
        content: Text(
          'คุณต้องการยกเลิกการเชื่อมต่อกับ $providerName ใช่หรือไม่?\n\nเมื่อยกเลิกแล้ว คุณจะสามารถเลือกเชื่อมต่อกับบัญชีอื่นได้',
          style: const TextStyle(fontSize: 14, color: Color(0xFF4A4447), height: 1.45),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('ยกเลิก', style: TextStyle(color: Color(0xFF7E777B), fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC2185B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              SocialLinkManager.unlinkProvider();
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('ยกเลิกการเชื่อมต่อกับ $providerName แล้ว'),
                  backgroundColor: const Color(0xFF6E162B),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('ยืนยันยกเลิก', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showWarningDialog({required String title, required String message}) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: Color(0xFF6E162B), size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF6E162B),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 14, color: Color(0xFF4A4447), height: 1.45),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6E162B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('เข้าใจแล้ว'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFbLinked = SocialLinkManager.isFacebookLinked;
    final isGgLinked = SocialLinkManager.isGoogleLinked;
    final hasAnyLinked = SocialLinkManager.hasAnyLinked;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F7),
      body: Column(
        children: [
          // ==========================================
          // 1. TOP SOLID BURGUNDY HEADER
          // ==========================================
          Container(
            color: const Color(0xFF6E162B),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 14,
              bottom: 16,
              left: 14,
              right: 14,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.chevron_left_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const Expanded(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(right: 34),
                      child: Text(
                        'เชื่อมต่อ Facebook / Google',
                        style: TextStyle(
                          fontSize: 18.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ==========================================
          // 2. SCROLLABLE CONTENT
          // ==========================================
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Account Summary Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF2DDE1), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.025),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAF0F3),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFE8CCD3)),
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: Color(0xFF6E162B),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'บัญชี MealMate ของคุณ',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: Color(0xFF8B8286),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.email,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF221F21),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Overall Status Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: hasAnyLinked ? const Color(0xFFE8F5E9) : const Color(0xFFF5F3F4),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: hasAnyLinked ? const Color(0xFFC8E6C9) : const Color(0xFFE2DCDE),
                            ),
                          ),
                          child: Text(
                            hasAnyLinked ? 'เชื่อมต่อแล้ว' : 'ยังไม่เชื่อมต่อ',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: hasAnyLinked ? const Color(0xFF2E7D32) : const Color(0xFF7E777B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Policy / Rule Information Alert Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF9EB),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFFFE0B2), width: 1.1),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(Icons.info_rounded, color: Color(0xFFE65100), size: 20),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'เงื่อนไขความปลอดภัย: บัญชีนี้สามารถเชื่อมต่อกับ Facebook หรือ Google ได้เพียง 1 บัญชีเท่านั้น หากเชื่อมต่ออันใดอันหนึ่งแล้ว จะไม่สามารถเชื่อมต่ออีกอันได้',
                            style: TextStyle(
                              fontSize: 12.8,
                              color: Color(0xFF795548),
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Section Title
                  const Text(
                    'ช่องทางการเชื่อมต่อ',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF6E162B),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ==========================================
                  // CARD 1: FACEBOOK
                  // ==========================================
                  _buildSocialCard(
                    provider: 'facebook',
                    title: 'Facebook',
                    isLinked: isFbLinked,
                    isBlocked: isGgLinked, // Blocked if Google is linked
                    blockedReason: 'บัญชีนี้เชื่อมต่อกับ Google อยู่แล้ว (ไม่สามารถเชื่อมต่อ Facebook ได้)',
                    activeDescription: 'บัญชีของคุณผูกกับ Facebook เรียบร้อยแล้ว สามารถเข้าสู่ระบบด้วย Facebook ได้ทันที',
                    idleDescription: 'เชื่อมต่อบัญชี Facebook เพื่อความสะดวกและรวดเร็วในการเข้าสู่ระบบครั้งถัดไป',
                    brandColor: const Color(0xFF1877F2),
                    iconWidget: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1877F2),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const SizedBox(
                        width: 24,
                        height: 24,
                        child: CustomPaint(painter: FacebookLogoPainter()),
                      ),
                    ),
                    onConnect: () => _handleConnect('facebook'),
                    onUnlink: () => _handleUnlink('facebook'),
                    connectKey: const Key('social_connect_facebook_btn'),
                    unlinkKey: const Key('social_unlink_facebook_btn'),
                  ),

                  const SizedBox(height: 16),

                  // ==========================================
                  // CARD 2: GOOGLE
                  // ==========================================
                  _buildSocialCard(
                    provider: 'google',
                    title: 'Google',
                    isLinked: isGgLinked,
                    isBlocked: isFbLinked, // Blocked if Facebook is linked
                    blockedReason: 'บัญชีนี้เชื่อมต่อกับ Facebook อยู่แล้ว (ไม่สามารถเชื่อมต่อ Google ได้)',
                    activeDescription: 'บัญชีของคุณผูกกับ Google เรียบร้อยแล้ว สามารถเข้าสู่ระบบด้วย Google ได้ทันที',
                    idleDescription: 'เชื่อมต่อบัญชี Google เพื่อความสะดวกรวดเร็วในการเข้าสู่ระบบครั้งถัดไป',
                    brandColor: const Color(0xFF3C4043),
                    iconWidget: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE2E2E2), width: 1.2),
                      ),
                      alignment: Alignment.center,
                      child: const SizedBox(
                        width: 24,
                        height: 24,
                        child: CustomPaint(painter: GoogleLogoPainter()),
                      ),
                    ),
                    onConnect: () => _handleConnect('google'),
                    onUnlink: () => _handleUnlink('google'),
                    connectKey: const Key('social_connect_google_btn'),
                    unlinkKey: const Key('social_unlink_google_btn'),
                  ),

                  const SizedBox(height: 28),

                  // Helpful Guide / FAQ Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF2DDE1), width: 1.1),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.help_outline_rounded, color: Color(0xFF6E162B), size: 18),
                            SizedBox(width: 8),
                            Text(
                              'คำแนะนำในการเปลี่ยนบัญชี',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF6E162B),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'หากคุณต้องการเปลี่ยนไปเชื่อมต่ออีกบัญชีหนึ่ง เช่น ต้องการเปลี่ยนจาก Facebook ไปเป็น Google ให้กด "ยกเลิกการเชื่อมต่อ" บัญชีปัจจุบันก่อน จากนั้นจึงจะสามารถกดเชื่อมต่อบัญชีใหม่ได้ทันที',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF5A4B4F),
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialCard({
    required String provider,
    required String title,
    required bool isLinked,
    required bool isBlocked,
    required String blockedReason,
    required String activeDescription,
    required String idleDescription,
    required Color brandColor,
    required Widget iconWidget,
    required VoidCallback onConnect,
    required VoidCallback onUnlink,
    required Key connectKey,
    required Key unlinkKey,
  }) {
    Color cardBorderColor = const Color(0xFFF2DDE1);
    Color cardBgColor = Colors.white;

    if (isLinked) {
      cardBorderColor = const Color(0xFF81C784);
      cardBgColor = const Color(0xFFFBFDFB);
    } else if (isBlocked) {
      cardBorderColor = const Color(0xFFE7E3E5);
      cardBgColor = const Color(0xFFFDFCFD);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cardBorderColor, width: isLinked ? 1.5 : 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Icon + Title + Status Badge
          Row(
            children: [
              iconWidget,
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: isBlocked ? const Color(0xFF8E888B) : const Color(0xFF221F21),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isLinked
                          ? 'สถานะ: ผูกบัญชีแล้ว'
                          : (isBlocked ? 'สถานะ: ปิดการเชื่อมต่อ' : 'สถานะ: ยังไม่ได้เชื่อมต่อ'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isLinked
                            ? const Color(0xFF2E7D32)
                            : (isBlocked ? const Color(0xFF9E9E9E) : const Color(0xFF7E777B)),
                      ),
                    ),
                  ],
                ),
              ),
              // Status Pill
              if (isLinked)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFC8E6C9)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, size: 13, color: Color(0xFF2E7D32)),
                      SizedBox(width: 4),
                      Text(
                        'เชื่อมต่อแล้ว',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                )
              else if (isBlocked)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEEEE),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_outline_rounded, size: 13, color: Color(0xFF757575)),
                      SizedBox(width: 4),
                      Text(
                        'ล็อก',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF757575),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F5F6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE4DFE1)),
                  ),
                  child: const Text(
                    'ยังไม่เชื่อมต่อ',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF7E777B),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF6EFF2)),
          const SizedBox(height: 12),

          // Description Text
          Text(
            isLinked
                ? activeDescription
                : (isBlocked ? blockedReason : idleDescription),
            style: TextStyle(
              fontSize: 12.8,
              height: 1.45,
              fontWeight: FontWeight.w500,
              color: isBlocked
                  ? const Color(0xFF8C7980)
                  : (isLinked ? const Color(0xFF2E7D32) : const Color(0xFF5A4B4F)),
            ),
          ),

          const SizedBox(height: 14),

          // Action Button
          if (isLinked)
            SizedBox(
              width: double.infinity,
              height: 42,
              child: OutlinedButton.icon(
                key: unlinkKey,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFC2185B),
                  side: const BorderSide(color: Color(0xFFE57373), width: 1.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: const Color(0xFFFFF7F7),
                ),
                icon: const Icon(Icons.link_off_rounded, size: 18),
                label: Text(
                  'ยกเลิกการเชื่อมต่อ $title',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                ),
                onPressed: _isLoading ? null : onUnlink,
              ),
            )
          else if (isBlocked)
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton.icon(
                key: connectKey,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEAE7E8),
                  foregroundColor: const Color(0xFF9E979A),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.lock_rounded, size: 17),
                label: Text(
                  'ไม่สามารถเชื่อมต่อ $title ได้',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                ),
                onPressed: () {
                  final other = provider == 'facebook' ? 'Google' : 'Facebook';
                  _showWarningDialog(
                    title: 'ไม่สามารถเชื่อมต่อ $title ได้',
                    message: 'เนื่องจากบัญชีนี้ได้เชื่อมต่อกับ $other อยู่แล้ว หากต้องการเปลี่ยนมาเชื่อมต่อกับ $title กรุณากดยกเลิกการเชื่อมต่อกับ $other ก่อน',
                  );
                },
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton.icon(
                key: connectKey,
                style: ElevatedButton.styleFrom(
                  backgroundColor: provider == 'facebook' ? const Color(0xFF1877F2) : Colors.white,
                  foregroundColor: provider == 'facebook' ? Colors.white : const Color(0xFF3C4043),
                  side: provider == 'facebook' ? null : const BorderSide(color: Color(0xFFD6D6D6), width: 1.2),
                  elevation: 0.5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.link_rounded, size: 18),
                label: Text(
                  'เชื่อมต่อกับ $title',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                ),
                onPressed: _isLoading ? null : onConnect,
              ),
            ),
        ],
      ),
    );
  }
}
