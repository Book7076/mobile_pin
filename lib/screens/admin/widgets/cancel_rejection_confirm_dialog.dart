import 'package:flutter/material.dart';
import '../admin_theme.dart';

class CancelRejectionConfirmDialog extends StatelessWidget {
  final String restaurantName;
  final VoidCallback onConfirm;

  const CancelRejectionConfirmDialog({
    super.key,
    required this.restaurantName,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 12,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. หัวข้อ Dialog
            const Text(
              'ยืนยันยกเลิกการไม่อนุมัติ',
              style: TextStyle(
                fontSize: 17.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1E1E),
                letterSpacing: -0.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // 2. ไอคอนวงกลมสีแดงเข้มพร้อมกากบาทสีขาว (ตรงตามภาพที่ 2 ขวา)
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFF9E0B1A),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 46,
                ),
              ),
            ),
            const SizedBox(height: 18),

            // 3. ข้อความยืนยัน
            const Text(
              'คุณต้องการยกเลิกไม่อนุมัติร้านนี้หรือไม่',
              style: TextStyle(
                fontSize: 13.5,
                color: Color(0xFF4A4A4A),
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),

            // 4. ชื่อร้านตัวหนา
            Text(
              restaurantName,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1E1E),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 26),

            // 5. ปุ่มกดยกเลิก และ ยืนยัน (ตรงตามภาพที่ 2 ขวา)
            Row(
              children: [
                // ปุ่ม "ยกเลิก" (พื้นสีชมพูอ่อน ตัวหนังสือสีแดงเข้ม)
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF9EAEF),
                        foregroundColor: AdminTheme.primaryMaroon,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text(
                        'ยกเลิก',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // ปุ่ม "ยืนยัน" (พื้นสีแดงเข้ม ตัวหนังสือสีขาว)
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onConfirm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B0E17),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shadowColor: Colors.black.withValues(alpha: 0.15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text(
                        'ยืนยัน',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
