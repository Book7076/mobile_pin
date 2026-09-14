import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/restaurant_admin_model.dart';
import '../../services/admin_restaurant_service.dart';
import 'admin_theme.dart';
import 'cancel_rejection_success_screen.dart';
import 'widgets/cancel_rejection_confirm_dialog.dart';

class CancelRejectionScreen extends ConsumerStatefulWidget {
  final String restaurantId;

  const CancelRejectionScreen({
    super.key,
    required this.restaurantId,
  });

  @override
  ConsumerState<CancelRejectionScreen> createState() => _CancelRejectionScreenState();
}

class _CancelRejectionScreenState extends ConsumerState<CancelRejectionScreen> {
  bool _isProcessing = false;

  void _showConfirmDialog(RestaurantAdminModel restaurant) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => CancelRejectionConfirmDialog(
        restaurantName: restaurant.name,
        onConfirm: () => _executeCancelRejection(restaurant.id),
      ),
    );
  }

  Future<void> _executeCancelRejection(String id) async {
    setState(() => _isProcessing = true);
    final success = await ref.read(adminRestaurantProvider.notifier).cancelRejection(id);
    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const CancelRejectionSuccessScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('เกิดข้อผิดพลาดในการยกเลิกการไม่อนุมัติ กรุณาลองใหม่อีกครั้ง'),
          backgroundColor: AdminTheme.statusRejected,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final restaurants = ref.watch(adminRestaurantProvider);
    final restaurant = restaurants.firstWhere(
      (r) => r.id == widget.restaurantId,
      orElse: () => RestaurantAdminModel(
        id: widget.restaurantId,
        ownerId: '',
        name: 'เตาอุ่น',
        storeCode: '111U1101',
        address: 'เทศบาลเชียงใหม่ อำเภอเมือง จังหวัดเชียงใหม่ ประเทศไทย',
        phone: '091234567',
        status: 'rejected',
        createdAt: DateTime(2026, 8, 2, 9, 0),
        requestSubmittedDate: DateTime(2026, 8, 3),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left_rounded,
            color: AdminTheme.primaryMaroon,
            size: 32,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'ยกเลิกการไม่อนุมัติ',
          style: TextStyle(
            color: AdminTheme.primaryMaroon,
            fontWeight: FontWeight.bold,
            fontSize: 19,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1, color: Color(0xFFF2E6E8)),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 12),

                        // 1. ไอคอนเอกสารสีแดงเบอร์กันดีพร้อมกากบาท (ตรงตามภาพที่ 2 ซ้าย)
                        _buildCancelDocumentIcon(),
                        const SizedBox(height: 24),

                        // 2. หัวข้อ "ยืนยันการยกเลิกไม่อนุมัติ"
                        const Text(
                          'ยืนยันการยกเลิกไม่อนุมัติ',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E1E1E),
                            letterSpacing: -0.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),

                        // 3. คำอธิบาย
                        const Text(
                          'คุณกำลังจะยกเลิกการไม่อนุมัติร้านนี้\nกรุณาตรวจสอบข้อมูลให้ถูกต้องก่อนดำเนินการ',
                          style: TextStyle(
                            fontSize: 13.5,
                            color: Color(0xFF555555),
                            height: 1.4,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),

                        // 4. การ์ด "ข้อมูลร้าน" (ตรงตามภาพที่ 2 ซ้าย)
                        _buildRestaurantInfoCard(restaurant),
                      ],
                    ),
                  ),
                ),

                // 5. ปุ่ม Sticky ด้านล่าง: "ยืนยันยกเลิกการไม่อนุมัติ"
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : () => _showConfirmDialog(restaurant),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF800F2F),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shadowColor: Colors.black.withValues(alpha: 0.15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      child: _isProcessing
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'ยืนยันยกเลิกการไม่อนุมัติ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.2,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (_isProcessing)
            Container(
              color: Colors.black12,
              child: const Center(
                child: CircularProgressIndicator(color: AdminTheme.primaryMaroon),
              ),
            ),
        ],
      ),
    );
  }

  /// ไอคอนเอกสารพร้อมสัญลักษณ์กากบาท (ตรงตามภาพที่ 2 ซ้าย)
  Widget _buildCancelDocumentIcon() {
    return SizedBox(
      width: 100,
      height: 104,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // รูปทรงเอกสารสีแดงเบอร์กันดี
          Container(
            width: 78,
            height: 96,
            decoration: BoxDecoration(
              color: const Color(0xFF800F2F),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(32), // มุมพับ
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF800F2F).withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              children: [
                // เส้นขอบมุมพับด้านบนขวา
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        topRight: Radius.circular(32),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // วงกลมตรากากบาทสีขาวพื้นแดงเข้มตรงมุมล่างขวา
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: Color(0xFF800F2F),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// การ์ด "ข้อมูลร้าน" (ตรงตามภาพที่ 2 ซ้าย)
  Widget _buildRestaurantInfoCard(RestaurantAdminModel restaurant) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F8),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEBEBEF), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ข้อมูลร้าน',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 14),

          _buildInfoRow('ชื่อร้าน', restaurant.name),
          const SizedBox(height: 10),
          _buildInfoRow('รหัสร้าน', restaurant.storeCode ?? '111U1101'),
          const SizedBox(height: 10),
          _buildInfoRow('วันที่ส่งคำขอ', restaurant.formattedRequestDate),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label : ',
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
            color: Color(0xFF333333),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w400,
              color: Color(0xFF555555),
            ),
          ),
        ),
      ],
    );
  }
}
