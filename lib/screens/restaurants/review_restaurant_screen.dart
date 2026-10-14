import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../models/restaurant_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/restaurant_provider.dart';
import '../../services/review_service.dart';

class ReviewRestaurantScreen extends ConsumerStatefulWidget {
  final RestaurantModel restaurant;

  const ReviewRestaurantScreen({super.key, required this.restaurant});

  @override
  ConsumerState<ReviewRestaurantScreen> createState() => _ReviewRestaurantScreenState();
}

class _ReviewRestaurantScreenState extends ConsumerState<ReviewRestaurantScreen> {
  double _rating = 5.0;
  final _commentController = TextEditingController();
  final _photoUrlController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _commentController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาเขียนข้อความรีวิวสักนิดนึงนะ'),
          backgroundColor: AppConstants.burgundyPrimary,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final currentUser = ref.read(authProvider);

    try {
      final newReview = await ReviewService.submitReview(
        restaurantId: widget.restaurant.id,
        rating: _rating,
        comment: _commentController.text.trim(),
        photoUrl: _photoUrlController.text.trim().isNotEmpty
            ? _photoUrlController.text.trim()
            : null,
        explicitUserId: currentUser?.id,
        explicitUserName: currentUser?.name,
      );

      if (newReview != null) {
        ref.read(reviewsProvider.notifier).addReview(newReview);
        ref.read(restaurantsProvider.notifier).loadRestaurants();
      }
    } catch (e) {
      debugPrint('Note: Error submitting review: $e');
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ขอบคุณสำหรับการรีวิว! ความคิดเห็นของคุณช่วยเหลือนักชิมท่านอื่น'),
        backgroundColor: Color(0xFF10B981),
      ),
    );

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'รีวิวร้านอาหาร',
          style: TextStyle(
            color: AppConstants.burgundyPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppConstants.burgundyPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFF1F5F9), height: 1),
        ),
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Restaurant Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: widget.restaurant.imageUrls.isNotEmpty
                        ? Image.network(
                            widget.restaurant.imageUrls.first,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 60,
                              height: 60,
                              color: const Color(0xFFF1F5F9),
                              child: const Icon(Icons.storefront_rounded, color: AppConstants.burgundyPrimary),
                            ),
                          )
                        : Container(
                            width: 60,
                            height: 60,
                            color: const Color(0xFFF1F5F9),
                            child: const Icon(Icons.storefront_rounded, color: AppConstants.burgundyPrimary),
                          ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.restaurant.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.restaurant.address,
                          style: const TextStyle(fontSize: 12, color: AppConstants.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Rating Stars
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  const Text(
                    'ให้คะแนนความพึงพอใจ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starVal = index + 1.0;
                      return IconButton(
                        iconSize: 38,
                        icon: Icon(
                          starVal <= _rating ? Icons.star_rounded : Icons.star_border_rounded,
                          color: const Color(0xFFF59E0B),
                        ),
                        onPressed: () => setState(() => _rating = starVal),
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _rating == 5.0
                        ? 'ยอดเยี่ยม ประทับใจมาก ⭐⭐⭐⭐⭐'
                        : _rating >= 4.0
                            ? 'อร่อยมาก คุ้มค่า ⭐⭐⭐⭐'
                            : _rating >= 3.0
                                ? 'รสชาติปานกลาง พอใช้ได้ ⭐⭐⭐'
                                : 'ควรปรับปรุง ⭐⭐',
                    style: const TextStyle(color: AppConstants.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Comment Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('บอกเล่าความประทับใจ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _commentController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'เมนูที่ชอบ, รสชาติ, บรรยากาศ, การบริการ...',
                      hintStyle: const TextStyle(fontSize: 13, color: AppConstants.textMuted),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppConstants.burgundyPrimary, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Optional Photo URL Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('รูปภาพประกอบ (ถ้ามี)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _photoUrlController,
                    decoration: InputDecoration(
                      hintText: 'ใส่ลิงก์รูปภาพ เช่น https://...',
                      hintStyle: const TextStyle(fontSize: 13, color: AppConstants.textMuted),
                      prefixIcon: const Icon(Icons.image_outlined, color: Color(0xFF8E8E93), size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppConstants.burgundyPrimary, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Submit Button
            ElevatedButton(
              onPressed: _isLoading ? null : _submitReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.burgundyPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Text('ส่งรีวิวร้านอาหาร', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
