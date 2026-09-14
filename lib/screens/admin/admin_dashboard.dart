import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../main.dart';
import '../../models/restaurant_model.dart';
import '../auth/login_screen.dart';
import '../restaurants/restaurant_detail_screen.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> with SingleTickerProviderStateMixin {
  int _selectedTabIndex = 0;
  late TabController _approvalTabController;
  Timer? _liveStatsTimer;

  // Real-time statistics state
  double _rightSwipeRate = 53.52;
  int _activeUsers = 150;
  int _totalSwipes = 435;
  int _matchedCount = 200;

  static const Color primaryBurgundy = Color(0xFF700F2B);
  static const Color cardBorderColor = Color(0xFFF4E5EB);
  static const Color unselectedNavColor = Color(0xFFC7A8B4);

  // Top 10 Popular Restaurants data
  final List<Map<String, dynamic>> _topRestaurants = [
    {
      'rank': 1,
      'name': 'RawTruckr',
      'category': 'อาหารเกาหลี',
      'likes': 80,
      'imageUrl': 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=300&q=80',
      'address': 'สยามสแควร์ ซอย 7 แขวงปทุมวัน เขตปทุมวัน กรุงเทพฯ',
      'phone': '089-111-2233',
      'openingHours': '11:00 - 22:00 น.',
      'description': 'ไก่ทอดเกาหลีสูตรต้นตำรับ กรอบนอกนุ่มใน คลุกเคล้าซอสการ์ลิกและซอสสไปซี่สุดเข้มข้น พร้อมรามยอนและต๊อกบกกี',
      'signatureDishes': ['ไก่ทอดซอสการ์ลิก', 'ไก่ทอดซอสเผ็ดเกาหลี', 'ต๊อกบกกีชีสลาวา', 'คิมมาริ'],
    },
    {
      'rank': 2,
      'name': 'ครัวปันเจียง',
      'category': 'อาหารไทย/อาหารตามสั่ง',
      'likes': 70,
      'imageUrl': 'https://images.unsplash.com/photo-1559847844-5315695dadae?w=300&q=80',
      'address': '45/1 ถนนพหลโยธิน แขวงลาดยาว เขตจตุจักร กรุงเทพฯ',
      'phone': '082-345-6789',
      'openingHours': '09:00 - 20:30 น.',
      'description': 'ร้านอาหารตามสั่งรสเด็ด ฝีมือระดับภัตตาคาร ผัดกะเพราพริกแห้งโบราณ ข้าวผัดต้มยำ และไข่เจียวปูฟูกรอบ',
      'signatureDishes': ['กะเพราเนื้อโคขุนพริกแห้ง', 'ข้าวไข่ข้นกุ้งกระเทียม', 'ต้มยำกุ้งน้ำข้นยอดมะพร้าว'],
    },
    {
      'rank': 3,
      'name': 'ก๋วยเตี๋ยวเรือขั้นเทพ',
      'category': 'อาหารไทย/ก๋วยเตี๋ยว',
      'likes': 62,
      'imageUrl': 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=300&q=80',
      'address': '88 ถนนรัชดาภิเษก แขวงดินแดง เขตดินแดง กรุงเทพฯ',
      'phone': '083-999-8877',
      'openingHours': '08:30 - 18:00 น.',
      'description': 'ก๋วยเตี๋ยวเรือน้ำตกเข้มข้นสูตรอยุธยาแท้ น้ำซุปหอมเครื่องเทศตุ๋นกว่า 8 ชั่วโมง พร้อมกากหมูกรอบเจียวสดใหม่ทุกวัน',
      'signatureDishes': ['เส้นเล็กเนื้อน่องลายตุ๋นน้ำตก', 'บะหมี่หมูคุโรบูตะน้ำตก', 'กากหมูทอดกรอบสูตรลับ'],
    },
    {
      'rank': 4,
      'name': 'Sweet & Sour Bakery',
      'category': 'ร้านกาแฟ/เบเกอรี่',
      'likes': 58,
      'imageUrl': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=300&q=80',
      'address': '12 ซอยทองหล่อ 10 แขวงคลองตันเหนือ เขตวัฒนา กรุงเทพฯ',
      'phone': '084-555-1234',
      'openingHours': '07:30 - 19:00 น.',
      'description': 'คาเฟ่เบเกอรี่สไตล์ฝรั่งเศส กลิ่นเนยหอมอบอวล ครัวซองต์เนยแท้ AOP กรอบนอกนุ่มฟู พร้อมกาแฟ Specialty หลากหลายสายพันธุ์',
      'signatureDishes': ['ครัวซองต์เนยสด AOP', 'เลมอนทาร์ต', 'เดอร์ตี้คอฟฟี่', 'สตรอว์เบอร์รีชอร์ตเค้ก'],
    },
    {
      'rank': 5,
      'name': 'ชาบูอินดี้ พรีเมียม',
      'category': 'ชาบู/ปิ้งย่าง',
      'likes': 54,
      'imageUrl': 'https://images.unsplash.com/photo-1544025162-d76694265947?w=300&q=80',
      'address': '200 ถนนรามคำแหง แขวงหัวหมาก เขตบางกะปิ กรุงเทพฯ',
      'phone': '086-777-8899',
      'openingHours': '11:30 - 23:00 น.',
      'description': 'บุฟเฟต์ชาบูสไตล์ญี่ปุ่น น้ำซุปดำสุกี้ยากี้รสกลมกล่อม เนื้อวากิวพรีเมียมลายหินอ่อน และน้ำจิ้มงาสูตรพิเศษ',
      'signatureDishes': ['เนื้อวากิวออสเตรเลียสไลซ์', 'หมูคุโรบูตะสันคอ', 'น้ำซุปต้มยำน้ำข้น', 'ไอศกรีมมัทฉะ'],
    },
    {
      'rank': 6,
      'name': 'ส้มตำแซ่บนัวร์',
      'category': 'อาหารอีสาน',
      'likes': 49,
      'imageUrl': 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=300&q=80',
      'address': '55 ถนนเกษตร-นวมินทร์ แขวงนวมินทร์ เขตบึงกุ่ม กรุงเทพฯ',
      'phone': '087-123-4567',
      'openingHours': '10:30 - 21:30 น.',
      'description': 'อาหารอีสานรสเด็ด แซ่บนัวถึงใจ ปลาร้าต้มสุกกลิ่นหอมสะอาด ไก่ย่างเขาสวนกวางหนังกรอบเนื้อนุ่ม และคอหมูย่างฉ่ำๆ',
      'signatureDishes': ['ตำปูปลาร้ากุ้งสด', 'ไก่ย่างหนังกรอบ', 'ต้มแซ่บกระดูกอ่อนหมู', 'คอหมูย่างเตาถ่าน'],
    },
    {
      'rank': 7,
      'name': 'Burger Craft House',
      'category': 'เบอร์เกอร์/ฟาสต์ฟู้ด',
      'likes': 45,
      'imageUrl': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=300&q=80',
      'address': '101 ถนนอารีย์สัมพันธ์ แขวงพญาไท เขตพญาไท กรุงเทพฯ',
      'phone': '081-998-8776',
      'openingHours': '11:00 - 21:00 น.',
      'description': 'เบอร์เกอร์โฮมเมดสไตล์คราฟต์ เนื้อแองกัสบดสด ย่างบนเตากริลล์ร้อนๆ เสิร์ฟบนขนมปังบริยอชอบใหม่คู่กับเฟรนช์ฟรายส์ทรัฟเฟิล',
      'signatureDishes': ['Double Angus Bacon Cheese', 'Truffle Mushroom Burger', 'Crispy Chicken Brioche'],
    },
    {
      'rank': 8,
      'name': 'Sushi Hana',
      'category': 'อาหารญี่ปุ่น',
      'likes': 40,
      'imageUrl': 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=300&q=80',
      'address': '72 ถนนพระราม 9 แขวงห้วยขวาง เขตห้วยขวาง กรุงเทพฯ',
      'phone': '085-432-1098',
      'openingHours': '11:00 - 22:00 น.',
      'description': 'ซูชิและซาชิมิสดใหม่นำเข้าจากตลาดปลาโทโยสุ ประเทศญี่ปุ่น ข้าวซูชิปรุงรสละมุนด้วยน้ำส้มสายชูแดงสูตรเฉพาะ',
      'signatureDishes': ['Salmon Sashimi Set', 'Otoro Nigiri', 'Unagi Don', 'Foie Gras Roll'],
    },
    {
      'rank': 9,
      'name': 'ข้าวมันไก่เฮียชัย',
      'category': 'อาหารจานเดียว',
      'likes': 36,
      'imageUrl': 'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=300&q=80',
      'address': '18 ถนนบรรทัดทอง แขวงวังใหม่ เขตปทุมวัน กรุงเทพฯ',
      'phone': '082-888-9990',
      'openingHours': '06:30 - 15:00 น.',
      'description': 'ข้าวมันไก่สูตรไหหลำแท้ ข้าวหุงน้ำซุปกระดูกไก่หอมเรียงเม็ด ไก่ตอนเนื้อแน่นนุ่มชุ่มฉ่ำ น้ำจิ้มเต้าเจี้ยวรสจัดจ้าน',
      'signatureDishes': ['ข้าวมันไก่ตอนเนื้อน่อง', 'ข้าวมันไก่ทอดกรอบ', 'ต้มมะระซี่โครงหมู'],
    },
    {
      'rank': 10,
      'name': 'กาแฟดอยปางขอน',
      'category': 'คาเฟ่/เครื่องดื่ม',
      'likes': 31,
      'imageUrl': 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=300&q=80',
      'address': '33 ถนนสีลม แขวงสีลม เขตบางรัก กรุงเทพฯ',
      'phone': '084-333-2211',
      'openingHours': '07:00 - 18:00 น.',
      'description': 'เมล็ดกาแฟอาราบิก้าแท้ 100% จากยอดดอยปางขอน จังหวัดเชียงราย คั่วสดใหม่ กลิ่นหอมฟลอรัลและคาราเมล',
      'signatureDishes': ['เอสเพรสโซ่เย็นสไตล์ไทย', 'Dirty Pangkhon', 'Cold Brew Honey Lemon'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _approvalTabController = TabController(length: 3, vsync: this);
    _startLiveStatsSimulation();
    _fetchRealStatsIfAvailable();
  }

  @override
  void dispose() {
    _liveStatsTimer?.cancel();
    _approvalTabController.dispose();
    super.dispose();
  }

  void _startLiveStatsSimulation() {
    // Subtle periodic real-time updates to make metrics feel alive
    _liveStatsTimer = Timer.periodic(const Duration(seconds: 12), (timer) {
      if (!mounted) return;
      setState(() {
        // Micro variations in live users and swipes
        final deltaUsers = (DateTime.now().second % 3) - 1;
        _activeUsers = (_activeUsers + deltaUsers).clamp(135, 175);
        if (DateTime.now().second % 6 == 0) {
          _totalSwipes += 1;
          if (DateTime.now().second % 12 == 0) {
            _matchedCount += 1;
          }
          _rightSwipeRate = double.parse(((_matchedCount * 2.675 / _totalSwipes) * 100).clamp(51.0, 56.5).toStringAsFixed(2));
        }
      });
    });
  }

  Future<void> _fetchRealStatsIfAvailable() async {
    try {
      final userCountResponse = await supabase.from('users').select('id');
      final usersLength = (userCountResponse as List).length;
      if (usersLength > 0 && mounted) {
        setState(() {
          _activeUsers = usersLength;
        });
      }
    } catch (_) {
      // Keep initial simulated live stats when database tables are empty or offline
    }
  }

  Stream<List<RestaurantModel>> _getRestaurants(String status) {
    try {
      return supabase
          .from('restaurants')
          .stream(primaryKey: ['id'])
          .eq('status', status)
          .order('created_at', ascending: false)
          .map((maps) => maps.map((map) => RestaurantModel.fromJson(map)).toList());
    } catch (_) {
      return const Stream.empty();
    }
  }

  String _getAdminEmail() {
    try {
      return supabase.auth.currentUser?.email ?? 'admin@mealmate.com';
    } catch (_) {
      return 'admin@mealmate.com';
    }
  }

  Future<void> _updateStatus(String id, String newStatus) async {
    try {
      await supabase.from('restaurants').update({'status': newStatus}).eq('id', id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'เปลี่ยนสถานะร้านเป็น $newStatus สำเร็จ',
              style: GoogleFonts.notoSansThai(color: Colors.white),
            ),
            backgroundColor: primaryBurgundy,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ข้อผิดพลาด: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showNotificationSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'การแจ้งเตือนระบบ',
                    style: GoogleFonts.notoSansThai(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: primaryBurgundy,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFF9EEF2),
                  child: Icon(Icons.store_rounded, color: primaryBurgundy),
                ),
                title: Text(
                  'มีคำขอเปิดร้านอาหารใหม่รอการอนุมัติ',
                  style: GoogleFonts.notoSansThai(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'ร้าน RawTruckr ขออนุมัติเปิดร้านเมื่อ 10 นาทีที่แล้ว',
                  style: GoogleFonts.notoSansThai(fontSize: 12, color: Colors.grey),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _selectedTabIndex = 1);
                },
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFF9EEF2),
                  child: Icon(Icons.trending_up_rounded, color: primaryBurgundy),
                ),
                title: Text(
                  'ยอดการปัดทะลุเป้าหมายรายวัน',
                  style: GoogleFonts.notoSansThai(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'มียอดปัดร้านอาหารรวมกว่า 400 ครั้งในวันนี้',
                  style: GoogleFonts.notoSansThai(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openRestaurantDetail(Map<String, dynamic> item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RestaurantDetailScreen(
          rank: item['rank'] as int,
          name: item['name'] as String,
          category: item['category'] as String,
          likes: item['likes'] as int,
          imageUrl: item['imageUrl'] as String?,
          address: item['address'] as String,
          phone: item['phone'] as String,
          openingHours: item['openingHours'] as String,
          description: item['description'] as String,
          signatureDishes: List<String>.from(item['signatureDishes'] as List),
        ),
      ),
    );
  }

  Widget _buildCurrentTab() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildDashboardTab();
      case 1:
        return _buildStoreManagementTab();
      case 2:
        return _buildUsersTab();
      case 3:
        return _buildSettingsTab();
      default:
        return _buildDashboardTab();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: _buildCurrentTab(),
      ),
      bottomNavigationBar: _buildFloatingBottomNav(),
    );
  }

  // ==================== TAB 0: DASHBOARD ====================
  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Title and Notification
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ภาพรวมสถิติ',
                style: GoogleFonts.notoSansThai(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: primaryBurgundy,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: primaryBurgundy,
                  size: 28,
                ),
                onPressed: _showNotificationSheet,
              ),
            ],
          ),

          const SizedBox(height: 18),

          // 2x2 Metric Cards Grid
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'อัตราการปัดขวา',
                  value: '$_rightSwipeRate%',
                  unit: '',
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildMetricCard(
                  title: 'จำนวนผู้ใช้งานขณะนี้',
                  value: '$_activeUsers',
                  unit: 'คน',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'จำนวนการปัดทั้งหมด',
                  value: '$_totalSwipes',
                  unit: 'ครั้ง',
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildMetricCard(
                  title: 'จำนวนที่จับคู่สำเร็จ',
                  value: '$_matchedCount',
                  unit: 'ครั้ง',
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Popular Restaurants Ranking Container
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: cardBorderColor, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: primaryBurgundy.withValues(alpha: 0.03),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'รายการยอดฮิต',
                      style: GoogleFonts.notoSansThai(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: primaryBurgundy,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9EEF2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'อันดับ 1 - 10',
                        style: GoogleFonts.notoSansThai(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: primaryBurgundy,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _topRestaurants.length,
                  separatorBuilder: (context, index) => const Divider(
                    height: 22,
                    color: Color(0xFFF2F2F2),
                  ),
                  itemBuilder: (context, index) {
                    final item = _topRestaurants[index];
                    return _buildRestaurantRankItem(item);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String unit,
  }) {
    return Container(
      height: 112,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: primaryBurgundy.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.notoSansThai(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF222222),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: GoogleFonts.notoSansThai(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: primaryBurgundy,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 6),
                Text(
                  unit,
                  style: GoogleFonts.notoSansThai(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: primaryBurgundy,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantRankItem(Map<String, dynamic> item) {
    return InkWell(
      onTap: () => _openRestaurantDetail(item),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            // Image with rounded corners
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 62,
                height: 62,
                color: const Color(0xFFF2E6EB),
                child: item['imageUrl'] != null
                    ? Image.network(
                        item['imageUrl'] as String,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.fastfood_rounded,
                          color: primaryBurgundy,
                          size: 28,
                        ),
                      )
                    : const Icon(Icons.fastfood_rounded, color: primaryBurgundy),
              ),
            ),
            const SizedBox(width: 14),

            // Restaurant Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'] as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.notoSansThai(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['category'] as String,
                    style: GoogleFonts.notoSansThai(
                      fontSize: 12,
                      color: const Color(0xFF757575),
                    ),
                  ),
                ],
              ),
            ),

            // Likes / Swipe count
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${item['likes']}',
                  style: GoogleFonts.notoSansThai(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E1E1E),
                  ),
                ),
                Text(
                  'จำนวนถูกใจ',
                  style: GoogleFonts.notoSansThai(
                    fontSize: 11,
                    color: const Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==================== TAB 1: STORE MANAGEMENT ====================
  Widget _buildStoreManagementTab() {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'จัดการร้านค้า',
                style: GoogleFonts.notoSansThai(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: primaryBurgundy,
                ),
              ),
              const SizedBox(height: 8),
              TabBar(
                controller: _approvalTabController,
                labelColor: primaryBurgundy,
                unselectedLabelColor: Colors.grey,
                indicatorColor: primaryBurgundy,
                indicatorWeight: 3,
                labelStyle: GoogleFonts.notoSansThai(fontWeight: FontWeight.w700),
                tabs: const [
                  Tab(text: 'รออนุมัติ'),
                  Tab(text: 'อนุมัติแล้ว'),
                  Tab(text: 'ปฏิเสธ'),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _approvalTabController,
            children: [
              _buildApprovalList('pending'),
              _buildApprovalList('approved'),
              _buildApprovalList('rejected'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildApprovalList(String status) {
    return StreamBuilder<List<RestaurantModel>>(
      stream: _getRestaurants(status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: primaryBurgundy));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final restaurants = snapshot.data ?? [];
        if (restaurants.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.store_mall_directory_outlined, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text(
                  'ไม่มีร้านค้าในหมวดหมู่นี้',
                  style: GoogleFonts.notoSansThai(color: Colors.grey, fontSize: 15),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
          itemCount: restaurants.length,
          itemBuilder: (context, index) {
            final restaurant = restaurants[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cardBorderColor),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          restaurant.name,
                          style: GoogleFonts.notoSansThai(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          restaurant.address,
                          style: GoogleFonts.notoSansThai(color: Colors.grey, fontSize: 13),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'โทร: ${restaurant.phone}',
                          style: GoogleFonts.notoSansThai(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  if (status == 'pending') ...[
                    IconButton(
                      icon: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 30),
                      onPressed: () => _updateStatus(restaurant.id, 'approved'),
                      tooltip: 'อนุมัติ',
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel_rounded, color: Colors.redAccent, size: 30),
                      onPressed: () => _updateStatus(restaurant.id, 'rejected'),
                      tooltip: 'ปฏิเสธ',
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ==================== TAB 2: USERS OVERVIEW ====================
  Widget _buildUsersTab() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ผู้ใช้งานระบบ',
            style: GoogleFonts.notoSansThai(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: primaryBurgundy,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: cardBorderColor),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 26,
                  backgroundColor: Color(0xFFF9EEF2),
                  child: Icon(Icons.people_alt_rounded, color: primaryBurgundy, size: 28),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ผู้ใช้งานทั้งหมดในระบบ',
                      style: GoogleFonts.notoSansThai(fontSize: 14, color: Colors.grey),
                    ),
                    Text(
                      '$_activeUsers คน',
                      style: GoogleFonts.notoSansThai(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: primaryBurgundy,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'สถานะบัญชี',
            style: GoogleFonts.notoSansThai(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: primaryBurgundy,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: [
                _buildUserStatusTile('ผู้ใช้งานทั่วไป (Active)', '$_activeUsers คน', Colors.green),
                _buildUserStatusTile('เจ้าของร้านค้า (Store Owners)', '14 ร้าน', Colors.blue),
                _buildUserStatusTile('ผู้ดูแลระบบ (Admin)', '1 บัญชี', primaryBurgundy),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserStatusTile(String title, String count, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cardBorderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.notoSansThai(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          Text(
            count,
            style: GoogleFonts.notoSansThai(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== TAB 3: SETTINGS & LOGOUT ====================
  Widget _buildSettingsTab() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ตั้งค่าระบบ',
            style: GoogleFonts.notoSansThai(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: primaryBurgundy,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: cardBorderColor),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: primaryBurgundy,
                  child: Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ผู้ดูแลระบบ (Admin)',
                      style: GoogleFonts.notoSansThai(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      _getAdminEmail(),
                      style: GoogleFonts.notoSansThai(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: cardBorderColor),
            ),
            tileColor: Colors.white,
            leading: const Icon(Icons.security_rounded, color: primaryBurgundy),
            title: Text(
              'ความปลอดภัยและสิทธิ์การใช้งาน',
              style: GoogleFonts.notoSansThai(fontWeight: FontWeight.w600),
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
          ),
          const SizedBox(height: 12),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: cardBorderColor),
            ),
            tileColor: Colors.white,
            leading: const Icon(Icons.notifications_active_outlined, color: primaryBurgundy),
            title: Text(
              'การแจ้งเตือนสถิติประจำวัน',
              style: GoogleFonts.notoSansThai(fontWeight: FontWeight.w600),
            ),
            trailing: Switch(
              value: true,
              activeThumbColor: primaryBurgundy,
              onChanged: (_) {},
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () async {
                await supabase.auth.signOut();
                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                }
              },
              icon: const Icon(Icons.logout_rounded, color: Colors.white),
              label: Text(
                'ออกจากระบบ',
                style: GoogleFonts.notoSansThai(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBurgundy,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== FLOATING BOTTOM NAV BAR ====================
  Widget _buildFloatingBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(28, 0, 28, 20),
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.grid_view_rounded),
          _buildNavItem(1, Icons.storefront_outlined),
          _buildNavItem(2, Icons.people_outline_rounded),
          _buildNavItem(3, Icons.settings_outlined),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon) {
    final isSelected = _selectedTabIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedTabIndex = index),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: isSelected
            ? BoxDecoration(
                color: const Color(0xFFF9EEF2),
                borderRadius: BorderRadius.circular(16),
              )
            : null,
        child: Icon(
          icon,
          color: isSelected ? primaryBurgundy : unselectedNavColor,
          size: 26,
        ),
      ),
    );
  }
}
