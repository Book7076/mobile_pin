import 'package:flutter/material.dart';
import '../../../models/restaurant_admin_model.dart';
import '../admin_theme.dart';
import 'restaurant_logo_badge.dart';

class RestaurantCard extends StatelessWidget {
  final RestaurantAdminModel restaurant;
  final VoidCallback onTap;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
      decoration: BoxDecoration(
        color: AdminTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AdminTheme.cardBorder, width: 1),
        boxShadow: AdminTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: AdminTheme.primaryMaroon.withValues(alpha: 0.06),
          highlightColor: AdminTheme.primaryMaroon.withValues(alpha: 0.03),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. โลโก้ / รูปร้านค้า (ฝั่งซ้าย)
                RestaurantLogoBadge(
                  name: restaurant.name,
                  imageUrl: restaurant.imageUrl,
                  size: 82,
                ),
                const SizedBox(width: 16),

                // 2. ข้อมูลร้านค้า (ตรงกลาง)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ชื่อร้าน
                      Text(
                        restaurant.name,
                        style: const TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.bold,
                          color: AdminTheme.textPrimary,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      if (restaurant.status == 'rejected') ...[
                        // วันที่และเวลา เช่น 2 ส.ค. 2569
                        Text(
                          restaurant.formattedThaiDate,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF4A4A4A),
                          ),
                        ),
                        const SizedBox(height: 1),
                        // เวลา เช่น 09.00 น.
                        Text(
                          restaurant.formattedThaiTime,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF666666),
                          ),
                        ),
                        const SizedBox(height: 2),
                        // หมายเหตุ
                        Text(
                          'หมายเหตุ: ${restaurant.rejectionReason ?? "ไม่ตรงตามเงื่อนไข"}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF757575),
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ] else ...[
                        // วันที่สมัคร
                        const Text(
                          'วันที่สมัคร',
                          style: TextStyle(
                            fontSize: 12,
                            color: AdminTheme.textSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 2),

                        // วันที่ภาษาไทย เช่น "2 ส.ค. 2569"
                        Text(
                          restaurant.formattedThaiDate,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // 3. ปุ่ม "รายละเอียด >" (ฝั่งขวาล่าง)
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 38.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'รายละเอียด',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF262626),
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 16,
                          color: Color(0xFF262626),
                        ),
                      ],
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
