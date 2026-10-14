import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/approval_restaurant.dart';
import 'widgets/scalloped_check_badge.dart';
import 'admin_dashboard.dart';

class RevokeSuccessScreen extends StatelessWidget {
  final ApprovalRestaurant restaurant;

  const RevokeSuccessScreen({
    super.key,
    required this.restaurant,
  });

  static const Color primaryBurgundy = Color(0xFF700F2B);
  static const Color successGreen = Color(0xFF00C853);
  static const Color textDark = Color(0xFF1E1E1E);
  static const Color textMuted = Color(0xFF6B6B6B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => const AdminDashboard(
                initialTabIndex: 1, // จัดการร้านอาหาร
                initialSubTabIndex: 2, // แท็บไม่อนุมัติ
              ),
            ),
            (route) => false,
          );
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const Spacer(flex: 3),

                // Emerald Green Scalloped Badge with Checkmark (Unified)
                const Center(
                  child: ScallopedCheckBadge(size: 116),
                ),

                const SizedBox(height: 32),

                // Title: ยกเลิกการอนุมัติสำเร็จ
                Text(
                  'ยกเลิกการอนุมัติสำเร็จ',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSansThai(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 12),

                // Subtitle: คำขอของคุณได้ถูกยกเลิกการอนุมัติเรียบร้อยแล้ว
                Text(
                  'คำขอของคุณได้ถูกยกเลิกการอนุมัติเรียบร้อยแล้ว',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSansThai(
                    fontSize: 14,
                    color: textMuted,
                    height: 1.4,
                  ),
                ),

                const Spacer(flex: 4),

                // Bottom Button: กลับหน้าจัดการร้านอาหาร
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate back to AdminDashboard with Store Management Tab (index 1) and Rejected Sub-Tab (index 2)
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => const AdminDashboard(
                              initialTabIndex: 1, // จัดการร้านอาหาร
                              initialSubTabIndex: 2, // แท็บไม่อนุมัติ
                            ),
                          ),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBurgundy,
                        foregroundColor: Colors.white,
                        elevation: 3,
                        shadowColor: primaryBurgundy.withValues(alpha: 0.35),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(27),
                        ),
                      ),
                      child: Text(
                        'กลับหน้าจัดการร้านอาหาร',
                        style: GoogleFonts.notoSansThai(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


