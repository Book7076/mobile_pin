import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/scalloped_check_badge.dart';
import 'admin_dashboard.dart';

class ApprovalActionSuccessScreen extends StatelessWidget {
  final bool isApproved; // true for อนุมัติสำเร็จ, false for ไม่อนุมัติสำเร็จ

  const ApprovalActionSuccessScreen({
    super.key,
    required this.isApproved,
  });

  static const Color primaryBurgundy = Color(0xFF700F2B);
  static const Color emeraldGreen = Color(0xFF00B368);

  @override
  Widget build(BuildContext context) {
    final title = isApproved ? 'อนุมัติสำเร็จ' : 'ไม่อนุมัติสำเร็จ';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Authentic Green Scalloped Seal with Checkmark (Unified)
              const Center(
                child: ScallopedCheckBadge(size: 116),
              ),

              const SizedBox(height: 28),

              // Title
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSansThai(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1A1A),
                  letterSpacing: -0.2,
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle
              Text(
                'คำขอของคุณเรียบร้อยแล้ว',
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSansThai(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF757575),
                ),
              ),

              const Spacer(),

              // Bottom Button: กลับหน้าจัดการร้านอาหาร
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate back to AdminDashboard with Store Management Tab (index 1)
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const AdminDashboard(initialTabIndex: 1),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBurgundy,
                    foregroundColor: Colors.white,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
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
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

