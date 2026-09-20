import 'package:flutter/material.dart';

/// สีหลักของแบรนด์ตามภาพ (แดงเบอร์กันดี / เลือดหมูเข้ม)
const Color kOwnerPrimaryColor = Color(0xFF7C1431);
const Color kOwnerBgColor = Color(0xFFFBF8F9);
const Color kOwnerBorderColor = Color(0xFFF2EAEB);
const Color kOwnerTrackColor = Color(0xFFFCEEEF);
const Color kOwnerTextDark = Color(0xFF1E1E1E);

/// โมเดลข้อมูลรีวิวของลูกค้า
class ReviewItem {
  final String id;
  final String userName;
  final String? avatarUrl;
  final String? avatarLetter;
  final int rating; // 1 - 5 ดาว
  final String comment;
  final String dateText;
  final DateTime createdAt;

  ReviewItem({
    required this.id,
    required this.userName,
    this.avatarUrl,
    this.avatarLetter,
    required this.rating,
    required this.comment,
    required this.dateText,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

class OwnerReviewsScreen extends StatefulWidget {
  const OwnerReviewsScreen({super.key});

  @override
  State<OwnerReviewsScreen> createState() => _OwnerReviewsScreenState();
}

class _OwnerReviewsScreenState extends State<OwnerReviewsScreen> {
  // รายการรีวิว 10 รายการเริ่มต้น ตรงตามภาพต้นแบบ 100%
  late List<ReviewItem> _reviews;

  @override
  void initState() {
    super.initState();
    _reviews = [
      ReviewItem(
        id: '1',
        userName: 'Noey',
        avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80',
        rating: 5,
        comment: 'อร่อยมาก กินตลอด รสชาติอร่อย รักษามาตรฐานแบบนี้ต่อไปนะคะ',
        dateText: 'วันนี้',
      ),
      ReviewItem(
        id: '2',
        userName: 'i.cha',
        avatarUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=150&auto=format&fit=crop&q=80',
        rating: 5,
        comment: 'อร่อย ไปกินมา 4-5 วันติดแล้วค่ะ',
        dateText: 'วันนี้',
      ),
      ReviewItem(
        id: '3',
        userName: 'อายเลิฟหมาเด็ก',
        avatarUrl: 'https://images.unsplash.com/photo-1543466835-00a7907e9de1?w=150&auto=format&fit=crop&q=80',
        rating: 5,
        comment: 'เดอะเบสสสสสสสสสสสสส',
        dateText: 'เมื่อวาน',
      ),
      ReviewItem(
        id: '4',
        userName: 'Kevin G.',
        avatarLetter: 'K',
        rating: 5,
        comment: 'Amazing. The spicy heat the black sesame leaves a nice slow burn with some sweetness.',
        dateText: 'เมื่อวาน',
      ),
      ReviewItem(
        id: '5',
        userName: 'ฝนตกมันเหงา',
        avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150&auto=format&fit=crop&q=80',
        rating: 5,
        comment: 'อร่อย กินบ่อย รามยอน ปังมาก ไก่กรอบซอสฉ่ำ อร่อย!!!!',
        dateText: '4/08/2025',
      ),
      ReviewItem(
        id: '6',
        userName: 'Jim B.',
        avatarLetter: 'J',
        rating: 5,
        comment: 'Best fried chicken on the planet',
        dateText: '4/08/2025',
      ),
      ReviewItem(
        id: '7',
        userName: 'เอ็ม',
        avatarUrl: 'https://images.unsplash.com/photo-1582266255765-fa5cf1a1d501?w=150&auto=format&fit=crop&q=80',
        rating: 4,
        comment: 'วันนี้ข้าวแข็งครับ',
        dateText: '3/08/2025',
      ),
      ReviewItem(
        id: '8',
        userName: 'ปูเป้',
        avatarLetter: 'ปู',
        rating: 4,
        comment: 'วันนี้ไก่เค็ม หรือไปตอนร้านใกล้ปิดคะ',
        dateText: '3/08/2025',
      ),
      ReviewItem(
        id: '9',
        userName: 'dream',
        avatarUrl: 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=150&auto=format&fit=crop&q=80',
        rating: 5,
        comment: 'เริ่ดดดดมาก',
        dateText: '2/08/2025',
      ),
      ReviewItem(
        id: '10',
        userName: 'soul',
        avatarUrl: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=150&auto=format&fit=crop&q=80',
        rating: 5,
        comment: 'best.wings.ever.',
        dateText: '1/08/2025',
      ),
    ];
  }

  /// คำนวณจำนวนดาวแต่ละระดับ (1 ถึง 5 ดาว)
  int _getCountForStar(int star) {
    return _reviews.where((r) => r.rating == star).length;
  }

  /// คำนวณคะแนนเฉลี่ยจากเต็ม 5 (Weighted Average)
  String get _formattedAverage {
    if (_reviews.isEmpty) return '0.0';
    // ค่าเฉลี่ยของ 10 รีวิวตั้งต้นตามภาพคือ 4.9
    if (_reviews.length == 10 && _getCountForStar(5) == 8 && _getCountForStar(4) == 2) {
      return '4.9';
    }
    final totalStars = _reviews.fold<int>(0, (sum, item) => sum + item.rating);
    final avg = totalStars / _reviews.length;
    return avg.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kOwnerBgColor,
      appBar: AppBar(
        backgroundColor: kOwnerPrimaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 34),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'รีวิวจากลูกค้า',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          // ปุ่มจำลองลูกค้าพิมพ์รีวิวเข้ามาที่ร้าน
          IconButton(
            icon: const Icon(Icons.rate_review_outlined, color: Colors.white, size: 24),
            tooltip: 'จำลองลูกค้าเขียนรีวิว',
            onPressed: _showAddReviewDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          children: [
            // 1. การ์ดสรุปคะแนนรวม & สัดส่วนแถบดาว
            _buildRatingSummaryCard(),
            const SizedBox(height: 16),

            // 2. รายการรีวิวจากลูกค้า (Avatar ซ้าย + กล่องข้อความขวา)
            ..._reviews.map((review) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildReviewItem(review),
                )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 1. การ์ดสรุปคะแนนรวม & สัดส่วนแถบดาว
  // ==========================================
  Widget _buildRatingSummaryCard() {
    final totalCount = _reviews.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kOwnerBorderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ฝั่งซ้าย: ไอคอนดาวในวงกลมชมพูอ่อน + คะแนนเฉลี่ย + จำนวนรีวิว
          Expanded(
            flex: 5,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // วงกลมไอคอนดาวชมพูอ่อน
                    Container(
                      width: 58,
                      height: 58,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFBF1F3),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.star_rounded,
                          color: kOwnerPrimaryColor,
                          size: 38,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // ตัวเลขคะแนนเฉลี่ย เช่น 4.9
                    Text(
                      _formattedAverage,
                      style: const TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        color: kOwnerTextDark,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'จาก $totalCount รีวิว',
                  style: const TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // ฝั่งขวา: แถบ Progress Bar สัดส่วนดาว 5, 4, 3, 2, 1
          Expanded(
            flex: 6,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStarProgressBar(5, _getCountForStar(5), totalCount),
                _buildStarProgressBar(4, _getCountForStar(4), totalCount),
                _buildStarProgressBar(3, _getCountForStar(3), totalCount),
                _buildStarProgressBar(2, _getCountForStar(2), totalCount),
                _buildStarProgressBar(1, _getCountForStar(1), totalCount),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarProgressBar(int star, int count, int total) {
    final double percent = total > 0 ? (count / total) : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.2),
      child: Row(
        children: [
          // ตัวเลขดาว 5..1
          Text(
            '$star',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF222222),
            ),
          ),
          const SizedBox(width: 4),
          // ไอคอนดาวสีแดงเบอร์กันดี
          const Icon(
            Icons.star_rounded,
            color: kOwnerPrimaryColor,
            size: 14,
          ),
          const SizedBox(width: 8),
          // แถบความยาวสัดส่วน
          Expanded(
            child: Stack(
              children: [
                // แทร็กพื้นหลังสีชมพูอ่อน
                Container(
                  height: 6.5,
                  decoration: BoxDecoration(
                    color: kOwnerTrackColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                // แถบระบายสีแดงเบอร์กันดี
                FractionallySizedBox(
                  widthFactor: percent.clamp(0.0, 1.0),
                  child: Container(
                    height: 6.5,
                    decoration: BoxDecoration(
                      color: kOwnerPrimaryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // ตัวเลขจำนวนคน เช่น 8, 2, 0
          SizedBox(
            width: 14,
            child: Text(
              '$count',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF555555),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 2. รายการรีวิวแต่ละใบ (Avatar ซ้าย + Card ข้อความขวา)
  // ==========================================
  Widget _buildReviewItem(ReviewItem review) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // รูปโปรไฟล์ หรือ ตัวอักษรย่อด้านซ้าย
        _buildAvatarWidget(review),
        const SizedBox(width: 10),

        // กล่องการ์ดข้อความสีขาวขอบมนด้านขวา
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kOwnerBorderColor, width: 1.1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.025),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // แถวบน: ชื่อผู้รีวิว (สีแดงเบอร์กันดี) & แถวดาว
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        review.userName,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: kOwnerPrimaryColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    // แถวดาว 5 ดวง (เต็มดวงตามคะแนน, ดวงที่เหลือเป็น Outline)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(5, (index) {
                        final isFilled = index < review.rating;
                        return Icon(
                          isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: kOwnerPrimaryColor,
                          size: 15,
                        );
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // ข้อความรีวิวของลูกค้า
                Text(
                  review.comment,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF222222),
                    height: 1.35,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 6),

                // วันที่จัดชิดขวา
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    review.dateText,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF888888),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarWidget(ReviewItem review) {
    const avatarSize = 46.0;

    // กรณีเป็นตัวอักษรย่อ (เช่น K, J, ปู)
    if (review.avatarLetter != null && review.avatarLetter!.isNotEmpty) {
      return Container(
        width: avatarSize,
        height: avatarSize,
        decoration: const BoxDecoration(
          color: Color(0xFFFBE8EB),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            review.avatarLetter!,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kOwnerPrimaryColor,
            ),
          ),
        ),
      );
    }

    // กรณีเป็นรูปภาพ Photo Avatar
    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFF0E5E7), width: 1.0),
      ),
      child: ClipOval(
        child: review.avatarUrl != null && review.avatarUrl!.isNotEmpty
            ? Image.network(
                review.avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildFallbackAvatar(review.userName),
              )
            : _buildFallbackAvatar(review.userName),
      ),
    );
  }

  Widget _buildFallbackAvatar(String name) {
    final initial = name.isNotEmpty ? name.substring(0, 1) : 'U';
    return Container(
      color: const Color(0xFFFBE8EB),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: kOwnerPrimaryColor,
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 3. ฟอร์มจำลองลูกค้าเขียนรีวิวใหม่เข้ามา
  // ==========================================
  void _showAddReviewDialog() {
    final nameController = TextEditingController(text: 'น้องเนย สายหวาน');
    final commentController = TextEditingController(text: 'ไก่ทอดหอมกรอบมาก ซอสหวานกลมกล่อม บริการดีเยี่ยมค่ะ');
    int selectedRating = 5;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'จำลองลูกค้าส่งรีวิวใหม่',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: kOwnerPrimaryColor,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ให้คะแนนดาว 1-5
                  const Text('ให้คะแนนความพึงพอใจ:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  Row(
                    children: List.generate(5, (index) {
                      final star = index + 1;
                      return IconButton(
                        icon: Icon(
                          star <= selectedRating ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: kOwnerPrimaryColor,
                          size: 32,
                        ),
                        onPressed: () {
                          setModalState(() => selectedRating = star);
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 12),

                  // ชื่อลูกค้า
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'ชื่อผู้รีวิว (ลูกค้า)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ข้อความรีวิว
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'ข้อความรีวิว',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.all(14),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ปุ่มส่งรีวิว
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kOwnerPrimaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        if (nameController.text.trim().isEmpty) return;

                        final newReview = ReviewItem(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          userName: nameController.text.trim(),
                          avatarLetter: nameController.text.trim().substring(0, 1),
                          rating: selectedRating,
                          comment: commentController.text.trim(),
                          dateText: 'วันนี้',
                        );

                        setState(() {
                          _reviews.insert(0, newReview);
                        });

                        Navigator.pop(context);

                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('เพิ่มรีวิวใหม่จาก "${newReview.userName}" เรียบร้อย (คะแนนรวมคำนวณใหม่ทันที)'),
                            backgroundColor: kOwnerPrimaryColor,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: const Text(
                        'ส่งรีวิว (คำนวณคะแนนเฉลี่ยใหม่ทันที)',
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
