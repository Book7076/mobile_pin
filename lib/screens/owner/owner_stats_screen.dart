import 'package:flutter/material.dart';
import 'owner_reviews_screen.dart';
import 'owner_menu_screen.dart';

/// สีหลักของแบรนด์ตามภาพ (แดงเบอร์กันดี / เลือดหมูเข้ม)
const Color kOwnerPrimaryColor = Color(0xFF7C1431);
const Color kOwnerSecondaryColor = Color(0xFFBA3D60);
const Color kOwnerLightRose = Color(0xFFD8BEB6);
const Color kOwnerBgColor = Color(0xFFFBF8F9);
const Color kOwnerPillBg = Color(0xFFF7ECEF);
const Color kOwnerBorderColor = Color(0xFFF2EAEB);

class OwnerStatsScreen extends StatefulWidget {
  const OwnerStatsScreen({super.key});

  @override
  State<OwnerStatsScreen> createState() => _OwnerStatsScreenState();
}

class _OwnerStatsScreenState extends State<OwnerStatsScreen> with SingleTickerProviderStateMixin {
  // 0: วันนี้, 1: 5 วันที่ผ่านมา, 2: 7 วันที่ผ่านมา, 3: 14 วันที่ผ่านมา
  int _selectedPeriodIndex = 1; // เริ่มต้นที่ 5 วันที่ผ่านมา (ตามภาพแรก)

  final List<String> _periodTitles = [
    'วันนี้',
    '5 วันที่ผ่านมา',
    '7 วันที่ผ่านมา',
    '14 วันที่ผ่านมา',
  ];

  final GlobalKey _dropdownKey = GlobalKey();

  // สำหรับการแตะลากดูกราฟ
  int? _hoveredHourIndex;
  int? _hoveredDayIndex;

  @override
  Widget build(BuildContext context) {
    final stats = _getStatsForPeriod(_selectedPeriodIndex);

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
          'สถิติ',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // หัวข้อภาพรวม และปุ่มเลือกช่วงเวลา (Dropdown)
              _buildHeaderRow(),
              const SizedBox(height: 16),

              // การ์ดสถิติ 3 ใบ (ผู้เข้าชม, ถูกใจ, ไม่ถูกใจ)
              _buildOverviewCards(stats),
              const SizedBox(height: 20),

              // การ์ดกราฟแนวโน้มการเข้าชม
              _buildTrendChartCard(),
              const SizedBox(height: 20),

              // การ์ดสองใบด้านล่าง (เรทรีวิว & เมนูยอดนิยม)
              _buildBottomCards(stats),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 1. ส่วนหัวภาพรวม + Dropdown Filter
  // ==========================================
  Widget _buildHeaderRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'ภาพรวม',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E1E1E),
          ),
        ),
        GestureDetector(
          key: _dropdownKey,
          onTap: _showPeriodDropdownMenu,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: kOwnerPillBg,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFECD5DA), width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: kOwnerPrimaryColor.withOpacity(0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _periodTitles[_selectedPeriodIndex],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2C181C),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: kOwnerPrimaryColor,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // แสดง Popup เมนูสำหรับเลือกช่วงเวลา ตามแบบภาพที่ 2 และ 3
  void _showPeriodDropdownMenu() {
    final renderBox = _dropdownKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withOpacity(0.05),
      transitionDuration: const Duration(milliseconds: 180),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim1, curve: Curves.easeOut),
          child: child,
        );
      },
      pageBuilder: (context, anim1, anim2) {
        return Stack(
          children: [
            Positioned(
              right: MediaQuery.of(context).size.width - (offset.dx + size.width),
              top: offset.dy + size.height + 6,
              width: 195,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF0E5E7), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(_periodTitles.length, (index) {
                      final isSelected = index == _selectedPeriodIndex;
                      return InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            _selectedPeriodIndex = index;
                            _hoveredHourIndex = null;
                            _hoveredDayIndex = null;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          color: isSelected ? const Color(0xFFFBF1F3) : Colors.transparent,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_month_outlined,
                                color: kOwnerPrimaryColor,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _periodTitles[index],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: const Color(0xFF222222),
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_rounded,
                                  color: kOwnerPrimaryColor,
                                  size: 19,
                                ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ==========================================
  // 2. การ์ดภาพรวม 3 ใบ (ผู้เข้าชม, ถูกใจ, ไม่ถูกใจ)
  // ==========================================
  Widget _buildOverviewCards(PeriodStats stats) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            icon: Icons.people_outline_rounded,
            title: 'ผู้เข้าชม',
            value: stats.visitors,
            trend: stats.visitorsTrend,
            isPositive: stats.visitorsTrend.startsWith('+') || stats.visitorsTrend.startsWith('↑'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricCard(
            icon: Icons.favorite_border_rounded,
            title: 'ถูกใจ',
            value: stats.likes,
            trend: stats.likesTrend,
            isPositive: stats.likesTrend.startsWith('+') || stats.likesTrend.startsWith('↑'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricCard(
            icon: Icons.heart_broken_outlined,
            title: 'ไม่ถูกใจ',
            value: stats.dislikes,
            trend: stats.dislikesTrend,
            isPositive: false,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String value,
    required String trend,
    required bool isPositive,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ไอคอนในวงกลมพื้นหลังชมพูอ่อน
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Color(0xFFFBF1F3),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: kOwnerPrimaryColor, size: 23),
          ),
          const SizedBox(height: 12),
          // ชื่อตัวชี้วัด
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF555555),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          // ค่าตัวเลข
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1E1E),
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 6),
          // อัตราการเปลี่ยนแปลง (ลูกศรเขียวขึ้น / แดงลง)
          Text(
            trend,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isPositive ? const Color(0xFF00A854) : const Color(0xFFE53935),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 3. การ์ดแนวโน้มการเข้าชม (กราฟช่วงเวลา หรือ กราฟ 3 เส้น)
  // ==========================================
  Widget _buildTrendChartCard() {
    final isToday = _selectedPeriodIndex == 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'แนวโน้มการเข้าชม',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 14),

          // Legend สัญลักษณ์สี
          if (isToday)
            Row(
              children: [
                _buildLegendItem(kOwnerPrimaryColor, 'ผู้เข้าชม'),
              ],
            )
          else
            Row(
              children: [
                _buildLegendItem(kOwnerPrimaryColor, 'ผู้เข้าชม'),
                const SizedBox(width: 16),
                _buildLegendItem(kOwnerSecondaryColor, 'ถูกใจ'),
                const SizedBox(width: 16),
                _buildLegendItem(kOwnerLightRose, 'ไม่ถูกใจ'),
              ],
            ),
          const SizedBox(height: 18),

          // ตัวกราฟที่วาดด้วย CustomPainter Native 100%
          SizedBox(
            height: 190,
            child: isToday
                ? _buildTodayAreaSplineChart()
                : _buildMultiLineDayChart(_selectedPeriodIndex),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF333333),
          ),
        ),
      ],
    );
  }

  // กราฟช่วงเวลาของ "วันนี้" (Smooth Bezier Area Chart)
  Widget _buildTodayAreaSplineChart() {
    final hours = ['00:00', '04:00', '08:00', '12:00', '16:00', '20:00', '23:00'];
    final yLabels = [48, 36, 24, 12, 0];

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onPanUpdate: (details) {
            final x = details.localPosition.dx;
            final chartLeft = 32.0;
            final chartWidth = constraints.maxWidth - chartLeft - 10;
            if (x >= chartLeft && x <= constraints.maxWidth - 10) {
              final ratio = (x - chartLeft) / chartWidth;
              final index = (ratio * (hours.length - 1)).round().clamp(0, hours.length - 1);
              setState(() => _hoveredHourIndex = index);
            }
          },
          onTapDown: (details) {
            final x = details.localPosition.dx;
            final chartLeft = 32.0;
            final chartWidth = constraints.maxWidth - chartLeft - 10;
            if (x >= chartLeft && x <= constraints.maxWidth - 10) {
              final ratio = (x - chartLeft) / chartWidth;
              final index = (ratio * (hours.length - 1)).round().clamp(0, hours.length - 1);
              setState(() => _hoveredHourIndex = index);
            }
          },
          child: CustomPaint(
            size: Size(constraints.maxWidth, 190),
            painter: TodayAreaSplineChartPainter(
              hours: hours,
              yLabels: yLabels,
              hoveredIndex: _hoveredHourIndex,
            ),
          ),
        );
      },
    );
  }

  // กราฟ 3 เส้น (สำหรับ 5 วันที่ผ่านมา, 7 วัน, 14 วัน)
  Widget _buildMultiLineDayChart(int periodIndex) {
    List<String> xLabels;
    List<double> visitors;
    List<double> likes;
    List<double> dislikes;

    if (periodIndex == 1) {
      // 5 วันที่ผ่านมา
      xLabels = ['3/8', '4/8', '5/8', '6/8', '7/8'];
      visitors = [245, 215, 255, 275, 298];
      likes = [170, 135, 180, 192, 202];
      dislikes = [90, 55, 100, 108, 118];
    } else if (periodIndex == 2) {
      // 7 วันที่ผ่านมา
      xLabels = ['1/8', '2/8', '3/8', '4/8', '5/8', '6/8', '7/8'];
      visitors = [230, 245, 215, 255, 275, 280, 298];
      likes = [155, 170, 135, 180, 192, 195, 202];
      dislikes = [85, 90, 55, 100, 108, 110, 118];
    } else {
      // 14 วันที่ผ่านมา
      xLabels = ['25/7', '27/7', '29/7', '31/7', '2/8', '4/8', '6/8', '7/8'];
      visitors = [210, 225, 240, 230, 250, 275, 285, 298];
      likes = [140, 150, 165, 155, 175, 190, 198, 202];
      dislikes = [75, 85, 90, 80, 95, 105, 112, 118];
    }

    final yLabels = [300, 225, 150, 75, 0];

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onPanUpdate: (details) {
            final x = details.localPosition.dx;
            final chartLeft = 32.0;
            final chartWidth = constraints.maxWidth - chartLeft - 10;
            if (x >= chartLeft && x <= constraints.maxWidth - 10) {
              final ratio = (x - chartLeft) / chartWidth;
              final index = (ratio * (xLabels.length - 1)).round().clamp(0, xLabels.length - 1);
              setState(() => _hoveredDayIndex = index);
            }
          },
          onTapDown: (details) {
            final x = details.localPosition.dx;
            final chartLeft = 32.0;
            final chartWidth = constraints.maxWidth - chartLeft - 10;
            if (x >= chartLeft && x <= constraints.maxWidth - 10) {
              final ratio = (x - chartLeft) / chartWidth;
              final index = (ratio * (xLabels.length - 1)).round().clamp(0, xLabels.length - 1);
              setState(() => _hoveredDayIndex = index);
            }
          },
          child: CustomPaint(
            size: Size(constraints.maxWidth, 190),
            painter: MultiLineChartPainter(
              xLabels: xLabels,
              yLabels: yLabels,
              visitors: visitors,
              likes: likes,
              dislikes: dislikes,
              hoveredIndex: _hoveredDayIndex,
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // 4. การ์ดสองใบด้านล่าง (เรทรีวิว & เมนูยอดนิยม)
  // ==========================================
  Widget _buildBottomCards(PeriodStats stats) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // การ์ดเรทรีวิว
        Expanded(
          flex: 4,
          child: _buildReviewCard(),
        ),
        const SizedBox(width: 12),
        // การ์ดเมนูยอดนิยม
        Expanded(
          flex: 5,
          child: _buildPopularMenuCard(stats),
        ),
      ],
    );
  }

  Widget _buildReviewCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OwnerReviewsScreen()),
        );
      },
      child: Container(
        height: 205,
        padding: const EdgeInsets.all(16),
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
        child: Stack(
          children: [
            // ดาวประดับโปร่งแสงที่มุมบนขวาตามแบบภาพ
            Positioned(
              top: -2,
              right: 2,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star_rounded,
                    color: const Color(0xFFD8B5BB).withOpacity(0.7),
                    size: 26,
                  ),
                  const SizedBox(width: 2),
                  Transform.translate(
                    offset: const Offset(0, 8),
                    child: Icon(
                      Icons.star_rounded,
                      color: const Color(0xFFD8B5BB).withOpacity(0.7),
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),

            // เนื้อหาหลักของการ์ดเรทรีวิว
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'เรทรีวิว',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                Center(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            '4.9',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: kOwnerPrimaryColor,
                              height: 1.0,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.star_rounded,
                            color: kOwnerPrimaryColor,
                            size: 32,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'จาก 10 รีวิว',
                        style: TextStyle(
                          color: Color(0xFF757575),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          5,
                          (_) => const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 1.5),
                            child: Icon(
                              Icons.star_rounded,
                              color: kOwnerPrimaryColor,
                              size: 19,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularMenuCard(PeriodStats stats) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OwnerMenuScreen()),
        );
      },
      child: Container(
        height: 205,
        padding: const EdgeInsets.all(16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'เมนูยอดนิยม',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1E1E),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: stats.topMenus.map((menu) {
                  return Row(
                    children: [
                      // รูปภาพอาหารทรงกลม
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFF0E5E7), width: 1),
                        ),
                        child: ClipOval(
                          child: Image.network(
                            menu.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: const Color(0xFFFFF1EB),
                              child: const Icon(
                                Icons.lunch_dining_rounded,
                                color: kOwnerPrimaryColor,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // ชื่อเมนู (เช่น 1.ข้าวไก่เทอริยากิ)
                      Expanded(
                        child: Text(
                          menu.name,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF222222),
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      // จำนวนครั้ง
                      Text(
                        '${menu.count} ครั้ง',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF555555),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // ข้อมูลจำลองที่ตรงตามภาพของแต่ละช่วงเวลา
  // ==========================================
  PeriodStats _getStatsForPeriod(int index) {
    if (index == 0) {
      // วันนี้ (ภาพที่ 2, 3, 4)
      return PeriodStats(
        visitors: '300',
        visitorsTrend: '↑15%',
        likes: '195',
        likesTrend: '↑14%',
        dislikes: '105',
        dislikesTrend: '↓3%',
        topMenus: [
          PopularMenuItem(
            name: '1.ข้าวไก่ย่างน้ำจิ้มแจ่ว',
            count: 82,
            imageUrl: 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=150&auto=format&fit=crop&q=80',
          ),
          PopularMenuItem(
            name: '2.ข้าวไก่เทอริยากิ',
            count: 65,
            imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=150&auto=format&fit=crop&q=80',
          ),
          PopularMenuItem(
            name: '3.ข้าวไก่แซ่บ',
            count: 53,
            imageUrl: 'https://images.unsplash.com/photo-1562967914-608f82629710?w=150&auto=format&fit=crop&q=80',
          ),
        ],
      );
    } else if (index == 1) {
      // 5 วันที่ผ่านมา (ภาพที่ 1)
      return PeriodStats(
        visitors: '1250',
        visitorsTrend: '↑18%',
        likes: '820',
        likesTrend: '↑12%',
        dislikes: '430',
        dislikesTrend: '↓8%',
        topMenus: [
          PopularMenuItem(
            name: '1.ข้าวไก่เทอริยากิ',
            count: 320,
            imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=150&auto=format&fit=crop&q=80',
          ),
          PopularMenuItem(
            name: '2.ข้าวไก่แซ่บ',
            count: 210,
            imageUrl: 'https://images.unsplash.com/photo-1562967914-608f82629710?w=150&auto=format&fit=crop&q=80',
          ),
          PopularMenuItem(
            name: '3.ข้าวไก่ย่างน้ำจิ้มแจ่ว',
            count: 180,
            imageUrl: 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=150&auto=format&fit=crop&q=80',
          ),
        ],
      );
    } else if (index == 2) {
      // 7 วันที่ผ่านมา
      return PeriodStats(
        visitors: '1780',
        visitorsTrend: '↑16%',
        likes: '1190',
        likesTrend: '↑15%',
        dislikes: '590',
        dislikesTrend: '↓5%',
        topMenus: [
          PopularMenuItem(
            name: '1.ข้าวไก่เทอริยากิ',
            count: 480,
            imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=150&auto=format&fit=crop&q=80',
          ),
          PopularMenuItem(
            name: '2.ข้าวไก่แซ่บ',
            count: 315,
            imageUrl: 'https://images.unsplash.com/photo-1562967914-608f82629710?w=150&auto=format&fit=crop&q=80',
          ),
          PopularMenuItem(
            name: '3.ข้าวไก่ย่างน้ำจิ้มแจ่ว',
            count: 270,
            imageUrl: 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=150&auto=format&fit=crop&q=80',
          ),
        ],
      );
    } else {
      // 14 วันที่ผ่านมา
      return PeriodStats(
        visitors: '3420',
        visitorsTrend: '↑22%',
        likes: '2280',
        likesTrend: '↑19%',
        dislikes: '1140',
        dislikesTrend: '↓6%',
        topMenus: [
          PopularMenuItem(
            name: '1.ข้าวไก่เทอริยากิ',
            count: 920,
            imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=150&auto=format&fit=crop&q=80',
          ),
          PopularMenuItem(
            name: '2.ข้าวไก่แซ่บ',
            count: 640,
            imageUrl: 'https://images.unsplash.com/photo-1562967914-608f82629710?w=150&auto=format&fit=crop&q=80',
          ),
          PopularMenuItem(
            name: '3.ข้าวไก่ย่างน้ำจิ้มแจ่ว',
            count: 520,
            imageUrl: 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=150&auto=format&fit=crop&q=80',
          ),
        ],
      );
    }
  }
}

// ==========================================
// Data Models
// ==========================================
class PeriodStats {
  final String visitors;
  final String visitorsTrend;
  final String likes;
  final String likesTrend;
  final String dislikes;
  final String dislikesTrend;
  final List<PopularMenuItem> topMenus;

  PeriodStats({
    required this.visitors,
    required this.visitorsTrend,
    required this.likes,
    required this.likesTrend,
    required this.dislikes,
    required this.dislikesTrend,
    required this.topMenus,
  });
}

class PopularMenuItem {
  final String name;
  final int count;
  final String imageUrl;

  PopularMenuItem({
    required this.name,
    required this.count,
    required this.imageUrl,
  });
}

// ==========================================================
// CustomPainter สำหรับกราฟ "วันนี้" (Smooth Area Spline)
// ==========================================
class TodayAreaSplineChartPainter extends CustomPainter {
  final List<String> hours;
  final List<int> yLabels;
  final int? hoveredIndex;

  TodayAreaSplineChartPainter({
    required this.hours,
    required this.yLabels,
    this.hoveredIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const leftPadding = 30.0;
    const bottomPadding = 24.0;
    const topPadding = 34.0; // เว้นที่ด้านบนสำหรับ Tooltip Bubble
    const rightPadding = 10.0;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;

    final gridPaint = Paint()
      ..color = const Color(0xFFF2E6E8)
      ..strokeWidth = 1.0;

    final textStyle = const TextStyle(
      color: Color(0xFF555555),
      fontSize: 10,
      fontWeight: FontWeight.w400,
    );

    // 1. วาดแกน Y และเส้น Grid แนวนอน (0, 12, 24, 36, 48)
    for (int i = 0; i < yLabels.length; i++) {
      final yVal = yLabels[i];
      final yPos = topPadding + (i / (yLabels.length - 1)) * chartHeight;

      // เส้นแนวนอน
      canvas.drawLine(
        Offset(leftPadding, yPos),
        Offset(leftPadding + chartWidth, yPos),
        gridPaint,
      );

      // ข้อความแกน Y
      final span = TextSpan(text: '$yVal', style: textStyle);
      final tp = TextPainter(text: span, textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, Offset(leftPadding - tp.width - 6, yPos - tp.height / 2));
    }

    // 2. ข้อมูลจุดโค้งสำหรับสร้าง Spline Curve
    // พิกัดสัมพันธ์ (normalized x: 0..1, normalized y: 0..48)
    final points = [
      const Offset(0.00, 0.5), // 00:00
      const Offset(0.08, 0.5),
      const Offset(0.167, 3.0), // 04:00
      const Offset(0.25, 14.0),
      const Offset(0.333, 18.0), // 08:00
      const Offset(0.42, 24.0),
      const Offset(0.50, 38.0), // 12:00 (Peak จุดสูงสุด)
      const Offset(0.58, 25.0),
      const Offset(0.667, 24.0), // 16:00
      const Offset(0.75, 15.0),
      const Offset(0.833, 24.0), // 20:00 (Dinner peak)
      const Offset(0.92, 10.0),
      const Offset(1.00, 2.0), // 23:00
    ];

    // แปลงพิกัดเป็น Canvas Pixel Coordinate
    final pixelPoints = points.map((p) {
      final px = leftPadding + p.dx * chartWidth;
      final py = topPadding + chartHeight - (p.dy / 48.0) * chartHeight;
      return Offset(px, py);
    }).toList();

    // สร้าง Path เส้นโค้งนุ่มนวล (Catmull-Rom to Cubic Bezier)
    final path = Path();
    path.moveTo(pixelPoints[0].dx, pixelPoints[0].dy);

    for (int i = 0; i < pixelPoints.length - 1; i++) {
      final p0 = i > 0 ? pixelPoints[i - 1] : pixelPoints[i];
      final p1 = pixelPoints[i];
      final p2 = pixelPoints[i + 1];
      final p3 = i < pixelPoints.length - 2 ? pixelPoints[i + 2] : p2;

      // คำนวณ Control Points สำหรับ Catmull-Rom Spline
      final cp1x = p1.dx + (p2.dx - p0.dx) / 6.0;
      final cp1y = p1.dy + (p2.dy - p0.dy) / 6.0;
      final cp2x = p2.dx - (p3.dx - p1.dx) / 6.0;
      final cp2y = p2.dy - (p3.dy - p1.dy) / 6.0;

      path.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.dx, p2.dy);
    }

    // 3. ระบายสีพื้นที่ใต้กราฟ (Area Gradient Fill)
    final fillPath = Path.from(path);
    fillPath.lineTo(leftPadding + chartWidth, topPadding + chartHeight);
    fillPath.lineTo(leftPadding, topPadding + chartHeight);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          kOwnerPrimaryColor.withOpacity(0.18),
          kOwnerPrimaryColor.withOpacity(0.01),
        ],
      ).createShader(Rect.fromLTWH(leftPadding, topPadding, chartWidth, chartHeight))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // 4. วาดเส้นกราฟขอบโค้งมน
    final linePaint = Paint()
      ..color = kOwnerPrimaryColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);

    // 5. วาดแกน X (ชั่วโมง 00:00, 04:00, 08:00, 12:00, 16:00, 20:00, 23:00)
    for (int i = 0; i < hours.length; i++) {
      final xPos = leftPadding + (i / (hours.length - 1)) * chartWidth;
      final span = TextSpan(text: hours[i], style: textStyle);
      final tp = TextPainter(text: span, textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, Offset(xPos - tp.width / 2, topPadding + chartHeight + 6));
    }

    // 6. จุดพีค 12:00 และกล่อง Tooltip Bubble สไตล์ Speech Bubble
    // ถ้ามีการ Hover ให้แสดงจุดที่เลือก ถ้าไม่มีให้แสดงจุด 12:00
    int activeIndex = hoveredIndex ?? 3; // 3 คือ 12:00
    final hourNames = ['00:00', '04:00', '08:00', '12:00', '16:00', '20:00', '23:00'];
    final hourValues = [1, 3, 18, 38, 24, 24, 2];

    final activeHour = hourNames[activeIndex];
    final activeValue = hourValues[activeIndex];
    final peakX = leftPadding + (activeIndex / (hours.length - 1)) * chartWidth;
    final peakY = topPadding + chartHeight - (activeValue / 48.0) * chartHeight;

    // วาดจุดวงกลมบนเส้นกราฟ
    final dotPaint = Paint()
      ..color = kOwnerPrimaryColor
      ..style = PaintingStyle.fill;
    final dotBorderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(Offset(peakX, peakY), 4.5, dotPaint);
    canvas.drawCircle(Offset(peakX, peakY), 4.5, dotBorderPaint);

    // วาดกล่อง Tooltip Bubble สีแดงเบอร์กันดี
    const bubbleWidth = 48.0;
    const bubbleHeight = 28.0;
    final bubbleRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(peakX, peakY - 21),
        width: bubbleWidth,
        height: bubbleHeight,
      ),
      const Radius.circular(6),
    );

    final bubblePaint = Paint()
      ..color = kOwnerPrimaryColor
      ..style = PaintingStyle.fill;

    // ตัวบับเบิ้ล
    canvas.drawRRect(bubbleRect, bubblePaint);

    // หางลูกศรชี้ลงไปที่จุด
    final arrowPath = Path();
    arrowPath.moveTo(peakX - 4, peakY - 7);
    arrowPath.lineTo(peakX + 4, peakY - 7);
    arrowPath.lineTo(peakX, peakY - 2);
    arrowPath.close();
    canvas.drawPath(arrowPath, bubblePaint);

    // ข้อความใน Tooltip (บรรทัด 1: เวลา, บรรทัด 2: ตัวเลข)
    final textSpan1 = TextSpan(
      text: '$activeHour น.\n',
      style: const TextStyle(color: Colors.white, fontSize: 8, height: 1.1),
      children: [
        TextSpan(
          text: '$activeValue',
          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, height: 1.1),
        ),
      ],
    );

    final tooltipTp = TextPainter(
      text: textSpan1,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tooltipTp.layout(maxWidth: bubbleWidth);
    tooltipTp.paint(
      canvas,
      Offset(peakX - tooltipTp.width / 2, peakY - 33),
    );
  }

  @override
  bool shouldRepaint(covariant TodayAreaSplineChartPainter oldDelegate) {
    return oldDelegate.hoveredIndex != hoveredIndex;
  }
}

// ==========================================================
// CustomPainter สำหรับกราฟ 3 เส้น (5 วันที่ผ่านมา / 7 วัน / 14 วัน)
// ==========================================================
class MultiLineChartPainter extends CustomPainter {
  final List<String> xLabels;
  final List<int> yLabels;
  final List<double> visitors;
  final List<double> likes;
  final List<double> dislikes;
  final int? hoveredIndex;

  MultiLineChartPainter({
    required this.xLabels,
    required this.yLabels,
    required this.visitors,
    required this.likes,
    required this.dislikes,
    this.hoveredIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const leftPadding = 30.0;
    const bottomPadding = 24.0;
    const topPadding = 12.0;
    const rightPadding = 10.0;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;

    final gridPaint = Paint()
      ..color = const Color(0xFFF2E6E8)
      ..strokeWidth = 1.0;

    final textStyle = const TextStyle(
      color: Color(0xFF555555),
      fontSize: 10,
      fontWeight: FontWeight.w400,
    );

    // 1. วาดแกน Y และเส้น Grid แนวนอน (0, 75, 150, 225, 300)
    for (int i = 0; i < yLabels.length; i++) {
      final yVal = yLabels[i];
      final yPos = topPadding + (i / (yLabels.length - 1)) * chartHeight;

      // เส้นแนวนอน
      canvas.drawLine(
        Offset(leftPadding, yPos),
        Offset(leftPadding + chartWidth, yPos),
        gridPaint,
      );

      // ข้อความแกน Y
      final span = TextSpan(text: '$yVal', style: textStyle);
      final tp = TextPainter(text: span, textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, Offset(leftPadding - tp.width - 6, yPos - tp.height / 2));
    }

    // 2. เส้นแกนตั้งและไฮไลต์วันที่เลือก (ถ้ามีการกด)
    if (hoveredIndex != null && hoveredIndex! >= 0 && hoveredIndex! < xLabels.length) {
      final hX = leftPadding + (hoveredIndex! / (xLabels.length - 1)) * chartWidth;
      final highlightPaint = Paint()
        ..color = kOwnerPrimaryColor.withOpacity(0.12)
        ..strokeWidth = 1.5;
      canvas.drawLine(Offset(hX, topPadding), Offset(hX, topPadding + chartHeight), highlightPaint);
    }

    // ฟังก์ชันคำนวณจุดพิกัดใน Canvas
    List<Offset> getPoints(List<double> values) {
      return List.generate(values.length, (i) {
        final px = leftPadding + (i / (values.length - 1)) * chartWidth;
        final py = topPadding + chartHeight - (values[i] / 300.0) * chartHeight;
        return Offset(px, py);
      });
    }

    // 3. วาดเส้นและจุดทั้ง 3 เส้น
    _drawLineAndDots(canvas, getPoints(dislikes), kOwnerLightRose);
    _drawLineAndDots(canvas, getPoints(likes), kOwnerSecondaryColor);
    _drawLineAndDots(canvas, getPoints(visitors), kOwnerPrimaryColor);

    // 4. วาดแกน X (วันที่ เช่น 3/8, 4/8, 5/8, 6/8, 7/8)
    for (int i = 0; i < xLabels.length; i++) {
      final xPos = leftPadding + (i / (xLabels.length - 1)) * chartWidth;
      final isHovered = hoveredIndex == i;
      final span = TextSpan(
        text: xLabels[i],
        style: textStyle.copyWith(
          fontWeight: isHovered ? FontWeight.bold : FontWeight.normal,
          color: isHovered ? kOwnerPrimaryColor : const Color(0xFF555555),
        ),
      );
      final tp = TextPainter(text: span, textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, Offset(xPos - tp.width / 2, topPadding + chartHeight + 6));
    }

    // 5. ถ้ากดดูวันที่ แสดง Tooltip บอกค่าทั้ง 3 ของวันนั้น
    if (hoveredIndex != null && hoveredIndex! >= 0 && hoveredIndex! < xLabels.length) {
      final hX = leftPadding + (hoveredIndex! / (xLabels.length - 1)) * chartWidth;
      final dayVis = visitors[hoveredIndex!].round();
      final dayLike = likes[hoveredIndex!].round();
      final dayDis = dislikes[hoveredIndex!].round();

      final tooltipSpan = TextSpan(
        text: '${xLabels[hoveredIndex!]}: ผู้เข้าชม $dayVis | ถูกใจ $dayLike | ไม่ถูกใจ $dayDis',
        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
      );
      final tooltipTp = TextPainter(text: tooltipSpan, textDirection: TextDirection.ltr);
      tooltipTp.layout();

      final bubbleW = tooltipTp.width + 16;
      final bubbleH = 22.0;
      final clampedX = hX.clamp(bubbleW / 2 + 5, size.width - bubbleW / 2 - 5);

      final bubbleRect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(clampedX, topPadding - 2), width: bubbleW, height: bubbleH),
        const Radius.circular(5),
      );
      final bPaint = Paint()..color = kOwnerPrimaryColor;
      canvas.drawRRect(bubbleRect, bPaint);
      tooltipTp.paint(canvas, Offset(clampedX - tooltipTp.width / 2, topPadding - 2 - tooltipTp.height / 2));
    }
  }

  void _drawLineAndDots(Canvas canvas, List<Offset> points, Color color) {
    if (points.isEmpty) return;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, linePaint);

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (final p in points) {
      canvas.drawCircle(p, 4.0, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant MultiLineChartPainter oldDelegate) {
    return oldDelegate.hoveredIndex != hoveredIndex ||
        oldDelegate.visitors != visitors ||
        oldDelegate.likes != likes ||
        oldDelegate.dislikes != dislikes;
  }
}
