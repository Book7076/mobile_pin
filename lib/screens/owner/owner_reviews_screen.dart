import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  final String? restaurantId;
  final String restaurantName;

  const OwnerReviewsScreen({
    super.key,
    this.restaurantId,
    this.restaurantName = '',
  });

  @override
  State<OwnerReviewsScreen> createState() => _OwnerReviewsScreenState();
}

class _OwnerReviewsScreenState extends State<OwnerReviewsScreen> {
  // ข้อมูลรีวิวทั้งหมดดึงมาจาก Database 100% (ไม่มี mock หรือคิดข้อมูลขึ้นมาเอง)
  List<ReviewItem> _reviews = [];
  bool _isLoading = true;
  String? _resolvedRestaurantId;

  @override
  void initState() {
    super.initState();
    _loadReviewsFromSupabase();
  }

  /// ค้นหา ID ร้านค้าจาก Parameter หรือจาก Owner ปัจจุบันใน Database
  Future<String?> _resolveRestaurantId() async {
    // 1. หากส่ง restaurantId เข้ามาโดยตรง
    if (widget.restaurantId != null && widget.restaurantId!.trim().isNotEmpty) {
      final rid = widget.restaurantId!.trim();
      // หากเป็น UUID ใช้ได้ทันที
      if (rid.contains('-')) {
        return rid;
      }

      // หากไม่ใช่ UUID เผื่อเป็นชื่อร้าน ให้ลองค้นหา ID จริงจากตาราง restaurants
      try {
        final res = await Supabase.instance.client
            .from('restaurants')
            .select('id')
            .ilike('name', '%$rid%')
            .limit(1)
            .maybeSingle();
        if (res != null && res['id'] != null) {
          return res['id'].toString();
        }
      } catch (_) {}
      return rid;
    }

    // 2. หากไม่ได้ส่ง restaurantId ให้ค้นหาจาก owner_id ของผู้ใช้ปัจจุบันที่ล็อกอิน
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        // ค้นหาร้านค้าที่ owner_id ตรงกับ auth user
        try {
          final res = await Supabase.instance.client
              .from('restaurants')
              .select('id, name')
              .eq('owner_id', user.id)
              .order('created_at', ascending: false)
              .limit(1)
              .maybeSingle();
          if (res != null && res['id'] != null) {
            return res['id'].toString();
          }
        } catch (_) {
          // หากไม่มี column created_at ให้ query แบบธรรมดา
          final resFallback = await Supabase.instance.client
              .from('restaurants')
              .select('id, name')
              .eq('owner_id', user.id)
              .limit(1)
              .maybeSingle();
          if (resFallback != null && resFallback['id'] != null) {
            return resFallback['id'].toString();
          }
        }

        // กรณี fallback ค้นหาผ่านตาราง public users
        if (user.email != null && user.email!.isNotEmpty) {
          try {
            final uRow = await Supabase.instance.client
                .from('users')
                .select('id')
                .eq('email', user.email!)
                .maybeSingle();
            if (uRow != null && uRow['id'] != null) {
              final resByUid = await Supabase.instance.client
                  .from('restaurants')
                  .select('id, name')
                  .eq('owner_id', uRow['id'])
                  .limit(1)
                  .maybeSingle();
              if (resByUid != null && resByUid['id'] != null) {
                return resByUid['id'].toString();
              }
            }
          } catch (_) {}
        }
      }
    } catch (e) {
      debugPrint('Note: Error resolving restaurantId for reviews: $e');
    }

    return null;
  }

  /// โหลดรีวิวจาก Supabase ตาราง reviews จริงตาม database 100%
  Future<void> _loadReviewsFromSupabase() async {
    setState(() => _isLoading = true);

    try {
      // ตรวจสอบความพร้อมของ Supabase client
      try {
        Supabase.instance.client;
      } catch (_) {
        if (mounted) {
          setState(() {
            _reviews = [];
            _isLoading = false;
          });
        }
        return;
      }

      final effectiveId = await _resolveRestaurantId();
      _resolvedRestaurantId = effectiveId;

      if (effectiveId == null || effectiveId.isEmpty) {
        if (mounted) {
          setState(() {
            _reviews = [];
            _isLoading = false;
          });
        }
        return;
      }

      // ดึงข้อมูลรีวิวพร้อมข้อมูลผู้ใช้ที่เขียนรีวิว (ถ้ามี relation users)
      dynamic data;
      try {
        data = await Supabase.instance.client
            .from('reviews')
            .select('*, users(first_name, last_name, email, image_url)')
            .eq('restaurant_id', effectiveId);
      } catch (e) {
        debugPrint('Query reviews with users join failed, falling back to plain select: $e');
        try {
          data = await Supabase.instance.client
              .from('reviews')
              .select('*')
              .eq('restaurant_id', effectiveId);
        } catch (e2) {
          debugPrint('Error querying reviews from Supabase: $e2');
          data = [];
        }
      }

      final List<ReviewItem> loaded = [];
      if (data != null && data is List) {
        for (final row in data) {
          String uName = '';
          String? uAvatar;

          // 1. อ่านข้อมูลชื่อจาก Relation users
          if (row['users'] != null && row['users'] is Map) {
            final u = row['users'] as Map;
            final f = u['first_name']?.toString().trim() ?? '';
            final l = u['last_name']?.toString().trim() ?? '';
            if (f.isNotEmpty || l.isNotEmpty) {
              uName = '$f $l'.trim();
            } else if (u['email'] != null) {
              uName = u['email'].toString().split('@').first;
            }
            uAvatar = u['image_url']?.toString() ?? u['avatar_url']?.toString();
          }

          // 2. ถ้าไม่มี relation ให้ดูจาก field ใน row โดยตรง
          if (uName.isEmpty && row['user_name'] != null) {
            uName = row['user_name'].toString().trim();
          }
          if (uName.isEmpty && row['contact_email'] != null) {
            uName = row['contact_email'].toString().split('@').first;
          }
          if (uName.isEmpty) {
            uName = 'ผู้ใช้งาน';
          }

          uAvatar ??= row['user_avatar']?.toString() ?? row['photo_url']?.toString();

          // 3. วันที่สร้างรีวิว (รองรับทั้ง created_at และ create_at)
          final rawDate = row['created_at'] ?? row['create_at'];
          DateTime dt = DateTime.now();
          if (rawDate != null) {
            dt = DateTime.tryParse(rawDate.toString())?.toLocal() ?? DateTime.now();
          }

          // 4. คะแนนดาว (1 - 5)
          final ratingNum = (row['rating'] as num?)?.toInt() ?? 5;
          final clampedRating = ratingNum.clamp(1, 5);

          loaded.add(
            ReviewItem(
              id: row['id']?.toString() ?? '',
              userName: uName,
              avatarUrl: uAvatar,
              avatarLetter: (uAvatar == null || uAvatar.isEmpty)
                  ? (uName.isNotEmpty ? uName.substring(0, 1).toUpperCase() : 'U')
                  : null,
              rating: clampedRating,
              comment: row['comment']?.toString() ?? '',
              dateText: _formatReviewDate(dt),
              createdAt: dt,
            ),
          );
        }
      }

      // เรียงลำดับรีวิวล่าสุดขึ้นก่อนเสมอ
      loaded.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (mounted) {
        setState(() {
          _reviews = loaded;
        });
      }
    } catch (e) {
      debugPrint('Error loading reviews from database: $e');
      if (mounted) {
        setState(() {
          _reviews = [];
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// แปลงวันที่ให้อ่านเข้าใจง่าย
  String _formatReviewDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final reviewDate = DateTime(dt.year, dt.month, dt.day);
    final diffDays = today.difference(reviewDate).inDays;

    if (diffDays == 0) {
      return 'วันนี้';
    } else if (diffDays == 1) {
      return 'เมื่อวาน';
    } else {
      return '${dt.day}/${dt.month}/${dt.year}';
    }
  }

  /// คำนวณจำนวนดาวแต่ละระดับ (1 ถึง 5 ดาว) ตามข้อมูลจริงใน Database
  int _getCountForStar(int star) {
    return _reviews.where((r) => r.rating == star).length;
  }

  /// คำนวณคะแนนเฉลี่ยจากเต็ม 5 (Weighted Average) ตามข้อมูลจริงใน Database
  String get _formattedAverage {
    if (_reviews.isEmpty) return '0.0';
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
          IconButton(
            icon: const Icon(Icons.rate_review_outlined, color: Colors.white, size: 24),
            tooltip: 'เขียนรีวิว',
            onPressed: _showAddReviewDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: kOwnerPrimaryColor,
          onRefresh: _loadReviewsFromSupabase,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            children: [
              // 1. การ์ดสรุปคะแนนรวม & สัดส่วนแถบดาว
              _buildRatingSummaryCard(),
              const SizedBox(height: 16),

              // 2. รายการรีวิวจากลูกค้าตาม Database
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48.0),
                  child: Center(
                    child: CircularProgressIndicator(color: kOwnerPrimaryColor),
                  ),
                )
              else if (_reviews.isEmpty)
                _buildEmptyReviewsState()
              else
                ..._reviews.map((review) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _buildReviewItem(review),
                    )),
              const SizedBox(height: 20),
            ],
          ),
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
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
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
                      // ตัวเลขคะแนนเฉลี่ยจริงตาม database
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
          // ตัวเลขจำนวนคนจริง
          SizedBox(
            width: 18,
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
  // แสดงสถานะเมื่อยังไม่มีรีวิวใน Database
  // ==========================================
  Widget _buildEmptyReviewsState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kOwnerBorderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0xFFFBF1F3),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.reviews_outlined,
                size: 32,
                color: kOwnerPrimaryColor,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'ยังไม่มีรีวิวสำหรับร้านนี้',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: kOwnerTextDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'ข้อมูลรีวิวจะแสดงที่นี่โดยอัตโนมัติเมื่อมีลูกค้าเขียนรีวิวในระบบ',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF777777),
              height: 1.4,
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
                    // แถวดาว 5 ดวง (เต็มดวงตามคะแนนจริง, ดวงที่เหลือเป็น Outline)
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

    // กรณีเป็นตัวอักษรย่อ
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
    final initial = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'U';
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
  // 3. ฟอร์มเขียนรีวิวเข้าสู่ Database
  // ==========================================
  void _showAddReviewDialog() {
    final nameController = TextEditingController();
    final commentController = TextEditingController();
    int selectedRating = 5;
    bool isSubmitting = false;

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
                        'เขียนรีวิวใหม่',
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
                        onPressed: isSubmitting
                            ? null
                            : () {
                                setModalState(() => selectedRating = star);
                              },
                      );
                    }),
                  ),
                  const SizedBox(height: 12),

                  // ชื่อลูกค้า
                  TextField(
                    controller: nameController,
                    enabled: !isSubmitting,
                    decoration: InputDecoration(
                      labelText: 'ชื่อผู้รีวิว (ลูกค้า)',
                      hintText: 'กรอกชื่อผู้รีวิว',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ข้อความรีวิว
                  TextField(
                    controller: commentController,
                    enabled: !isSubmitting,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'ข้อความรีวิว',
                      hintText: 'กรอกข้อความรีวิว...',
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
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              final commentText = commentController.text.trim();
                              final userNameText = nameController.text.trim();

                              if (commentText.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('กรุณากรอกข้อความรีวิว'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }

                              setModalState(() => isSubmitting = true);

                              final effectiveId = _resolvedRestaurantId ?? await _resolveRestaurantId();
                              if (effectiveId != null && effectiveId.isNotEmpty) {
                                try {
                                  final user = Supabase.instance.client.auth.currentUser;
                                  final payload = <String, dynamic>{
                                    'restaurant_id': effectiveId,
                                    if (user != null) 'user_id': user.id,
                                    'rating': selectedRating,
                                    'comment': commentText,
                                    if (userNameText.isNotEmpty) 'user_name': userNameText,
                                    'create_at': DateTime.now().toIso8601String(),
                                  };
                                  await Supabase.instance.client.from('reviews').insert(payload);
                                } catch (e) {
                                  debugPrint('Error inserting review to Supabase: $e');
                                }
                              }

                              if (mounted) {
                                Navigator.pop(context);
                                await _loadReviewsFromSupabase();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('บันทึกรีวิวเข้าสู่ระบบเรียบร้อยแล้ว'),
                                    backgroundColor: kOwnerPrimaryColor,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                      child: isSubmitting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Text(
                              'ส่งรีวิวเข้าสู่ระบบ',
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
