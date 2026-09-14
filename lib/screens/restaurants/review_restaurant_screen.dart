import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../models/restaurant_model.dart';
import '../../models/review_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/restaurant_provider.dart';

class ReviewRestaurantScreen extends ConsumerStatefulWidget {
  final RestaurantModel restaurant;

  const ReviewRestaurantScreen({super.key, required this.restaurant});

  @override
  ConsumerState<ReviewRestaurantScreen> createState() => _ReviewRestaurantScreenState();
}

class _ReviewRestaurantScreenState extends ConsumerState<ReviewRestaurantScreen> {
  double _rating = 5.0;
  final _commentController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitReview() {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเขียนข้อความรีวิวสักนิดนึงนะ')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final currentUser = ref.read(authProvider);

    final newReview = ReviewModel(
      id: 'rev_${DateTime.now().millisecondsSinceEpoch}',
      restaurantId: widget.restaurant.id,
      userId: currentUser?.id ?? 'anon',
      userName: currentUser?.name ?? 'นักชิม Mealmate',
      userAvatar: currentUser?.avatarUrl,
      rating: _rating,
      comment: _commentController.text.trim(),
      createdAt: DateTime.now(),
    );

    ref.read(reviewsProvider.notifier).addReview(newReview);

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ขอบคุณสำหรับการรีวิว! ความคิดเห็นของคุณช่วยเหลือนักชิมท่านอื่น'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รีวิวร้านอาหาร'),
        backgroundColor: Colors.white,
        foregroundColor: AppConstants.textPrimary,
        elevation: 0.5,
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
                          )
                        : Container(width: 60, height: 60, color: Colors.grey[200]),
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

            const SizedBox(height: 24),

            // Rating Stars
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                          color: Colors.amber,
                        ),
                        onPressed: () => setState(() => _rating = starVal),
                      );
                    }),
                  ),
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
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('ส่งรีวิวร้านอาหาร', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
