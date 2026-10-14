import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'widgets/scalloped_check_badge.dart';
export 'widgets/scalloped_check_badge.dart';
import 'admin_dashboard.dart';

class RejectSuccessScreen extends StatelessWidget {
  const RejectSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // 1. ตราสัญลักษณ์ขอบหยักมนสีเขียวมรกต พร้อมเครื่องหมายถูกสีขาว (ตรงตามภาพที่ 1)
              const Center(
                child: ScallopedCheckBadge(size: 116),
              ),
              const SizedBox(height: 28),

              // 2. หัวข้อ "ไม่อนุมัติสำเร็จ"
              const Text(
                'ไม่อนุมัติสำเร็จ',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E1E),
                  letterSpacing: -0.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // 3. คำอธิบาย "คำขอของคุณเรียบร้อยแล้ว"
              const Text(
                'คำขอของคุณเรียบร้อยแล้ว',
                style: TextStyle(
                  fontSize: 14.5,
                  color: Color(0xFF666666),
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 3),

              // 4. ปุ่ม "กลับหน้าจัดการร้านอาหาร" สีแดงเบอร์กันดีเข้ม (ตรงตามภาพที่ 1)
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    // นำทางกลับสู่หน้าจัดการร้านอาหาร (แท็บรออนุมัติ)
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const AdminDashboard(initialTabIndex: 1),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF800F2F),
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shadowColor: Colors.black.withOpacity(0.18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'กลับหน้าจัดการร้านอาหาร',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.2,
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

