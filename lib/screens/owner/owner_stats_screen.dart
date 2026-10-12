import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/owner_stats_service.dart';
import 'owner_reviews_screen.dart';

const Color kOwnerPrimaryColor = Color(0xFF7C1431);
const Color kOwnerBgColor = Color(0xFFFBF8F9);
const Color kOwnerPillBg = Color(0xFFF7ECEF);
const Color kOwnerBorderColor = Color(0xFFF2EAEB);

class OwnerStatsScreen extends ConsumerStatefulWidget {
  final String? restaurantId;
  final String restaurantName;

  const OwnerStatsScreen({
    super.key,
    this.restaurantId,
    this.restaurantName = '',
  });

  @override
  ConsumerState<OwnerStatsScreen> createState() => _OwnerStatsScreenState();
}

class _OwnerStatsScreenState extends ConsumerState<OwnerStatsScreen> {
  static const _periods = <({String label, int days})>[
    (label: 'วันนี้', days: 1),
    (label: '5 วันที่ผ่านมา', days: 5),
    (label: '7 วันที่ผ่านมา', days: 7),
    (label: '14 วันที่ผ่านมา', days: 14),
  ];

  int _selectedPeriodIndex = 1;

  OwnerStatsQuery? get _query {
    final restaurantId = widget.restaurantId?.trim();
    if (restaurantId == null || restaurantId.isEmpty) return null;
    return (
      restaurantId: restaurantId,
      days: _periods[_selectedPeriodIndex].days,
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _query;
    final stats = query == null
        ? null
        : ref.watch(ownerReviewStatsProvider(query));

    return Scaffold(
      backgroundColor: kOwnerBgColor,
      appBar: AppBar(
        backgroundColor: kOwnerPrimaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left_rounded,
            color: Colors.white,
            size: 34,
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'สถิติ',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: query == null
            ? _buildMissingRestaurant()
            : RefreshIndicator(
                color: kOwnerPrimaryColor,
                onRefresh: () =>
                    ref.refresh(ownerReviewStatsProvider(query).future),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 18),
                      stats!.when(
                        loading: _buildLoading,
                        error: (error, stackTrace) => _buildError(query),
                        data: _buildStats,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ภาพรวมรีวิว',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              if (widget.restaurantName.trim().isNotEmpty)
                Text(
                  widget.restaurantName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF757575),
                    fontSize: 13,
                  ),
                ),
            ],
          ),
        ),
        PopupMenuButton<int>(
          key: const Key('owner_stats_period_menu'),
          initialValue: _selectedPeriodIndex,
          onSelected: (index) => setState(() => _selectedPeriodIndex = index),
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          itemBuilder: (context) => [
            for (var index = 0; index < _periods.length; index++)
              PopupMenuItem<int>(
                value: index,
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_month_outlined,
                      color: kOwnerPrimaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(_periods[index].label),
                  ],
                ),
              ),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
            decoration: BoxDecoration(
              color: kOwnerPillBg,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFECD5DA)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _periods[_selectedPeriodIndex].label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: kOwnerPrimaryColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStats(OwnerReviewStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                icon: Icons.rate_review_outlined,
                title: 'รีวิวทั้งหมด',
                value: '${stats.totalReviews}',
                unit: 'รีวิว',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricCard(
                icon: Icons.star_outline_rounded,
                title: 'คะแนนเฉลี่ย',
                value: stats.averageRating.toStringAsFixed(1),
                unit: '/ 5',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricCard(
                icon: Icons.workspace_premium_outlined,
                title: 'รีวิว 5 ดาว',
                value: '${stats.fiveStarReviews}',
                unit: 'รีวิว',
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildTrendCard(stats),
        const SizedBox(height: 20),
        _buildFullWidthReviewCard(stats),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required String value,
    required String unit,
  }) {
    return Container(
      height: 148,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFFBF1F3),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: kOwnerPrimaryColor, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF555555), fontSize: 12),
          ),
          const Spacer(),
          FittedBox(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: const TextStyle(
                    color: Color(0xFF757575),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendCard(OwnerReviewStats stats) {
    final swipePoints = stats.swipeTrend.isNotEmpty
        ? stats.swipeTrend
        : [
            for (final p in stats.trend)
              OwnerSwipePoint(label: p.label, likes: p.count, dislikes: 0),
          ];

    final maxVal = swipePoints.fold<int>(
      0,
      (current, p) => math.max(current, math.max(p.likes, p.dislikes)),
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                'การถูกใจไม่ถูกใจ',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E1E),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLegendIndicator(
                    color: kOwnerPrimaryColor,
                    label: 'ถูกใจ',
                    count: stats.totalLikes,
                  ),
                  const SizedBox(width: 8),
                  _buildLegendIndicator(
                    color: const Color(0xFF64748B),
                    label: 'ไม่ถูกใจ',
                    count: stats.totalDislikes,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 190,
            width: double.infinity,
            child: _SwipeTrendLineChart(points: swipePoints, maxVal: maxVal),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendIndicator({
    required Color color,
    required String label,
    required int count,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            '$label $count',
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullWidthReviewCard(OwnerReviewStats stats) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        key: const Key('owner_review_rating_card'),
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OwnerReviewsScreen(
              restaurantId: widget.restaurantId,
              restaurantName: widget.restaurantName,
            ),
          ),
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Expanded(
                    child: Text(
                      'เรทรีวิว',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E1E1E),
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: Color(0xFF999999)),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 112,
                    child: Column(
                      children: [
                        Text(
                          stats.averageRating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 42,
                            height: 1,
                            fontWeight: FontWeight.bold,
                            color: kOwnerPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildStars(stats.averageRating),
                        const SizedBox(height: 8),
                        Text(
                          'จาก ${stats.totalReviews} รีวิว',
                          style: const TextStyle(
                            color: Color(0xFF757575),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      children: [
                        for (var star = 5; star >= 1; star--)
                          _buildRatingBar(
                            star: star,
                            count: stats.ratingCounts[star] ?? 0,
                            total: stats.totalReviews,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStars(double rating) {
    final rounded = rating.round();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var star = 1; star <= 5; star++)
          Icon(
            star <= rounded ? Icons.star_rounded : Icons.star_border_rounded,
            color: kOwnerPrimaryColor,
            size: 18,
          ),
      ],
    );
  }

  Widget _buildRatingBar({
    required int star,
    required int count,
    required int total,
  }) {
    final fraction = total == 0 ? 0.0 : count / total;
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          SizedBox(
            width: 13,
            child: Text('$star', style: const TextStyle(fontSize: 11)),
          ),
          const Icon(Icons.star_rounded, color: kOwnerPrimaryColor, size: 13),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 8,
                backgroundColor: const Color(0xFFF0E3E7),
                valueColor: const AlwaysStoppedAnimation(kOwnerPrimaryColor),
              ),
            ),
          ),
          const SizedBox(width: 7),
          SizedBox(
            width: 22,
            child: Text(
              '$count',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 11, color: Color(0xFF757575)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const SizedBox(
      height: 420,
      child: Center(
        child: CircularProgressIndicator(color: kOwnerPrimaryColor),
      ),
    );
  }

  Widget _buildError(OwnerStatsQuery query) {
    return Container(
      key: const Key('owner_stats_error'),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            color: kOwnerPrimaryColor,
            size: 42,
          ),
          const SizedBox(height: 12),
          const Text(
            'โหลดสถิติรีวิวไม่สำเร็จ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          const Text(
            'กรุณาตรวจสอบการเชื่อมต่อและลองอีกครั้ง',
            style: TextStyle(color: Color(0xFF757575), fontSize: 13),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => ref.invalidate(ownerReviewStatsProvider(query)),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('ลองอีกครั้ง'),
          ),
        ],
      ),
    );
  }

  Widget _buildMissingRestaurant() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.storefront_outlined,
              color: kOwnerPrimaryColor,
              size: 48,
            ),
            SizedBox(height: 12),
            Text(
              'กรุณาเลือกร้านอาหารก่อนดูสถิติ',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: kOwnerBorderColor, width: 1.2),
      boxShadow: const [
        BoxShadow(
          color: Color(0x08000000),
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    );
  }
}

class _SwipeTrendLineChart extends StatefulWidget {
  final List<OwnerSwipePoint> points;
  final int maxVal;

  const _SwipeTrendLineChart({required this.points, required this.maxVal});

  @override
  State<_SwipeTrendLineChart> createState() => _SwipeTrendLineChartState();
}

class _SwipeTrendLineChartState extends State<_SwipeTrendLineChart> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.points.isEmpty) {
      return const Center(
        child: Text(
          'ไม่มีข้อมูลในช่วงเวลานี้',
          style: TextStyle(color: Color(0xFF757575), fontSize: 13),
        ),
      );
    }

    final selected =
        _selectedIndex != null && _selectedIndex! < widget.points.length
        ? widget.points[_selectedIndex!]
        : null;

    return Column(
      children: [
        if (selected != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${selected.label}: ',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                Text(
                  'ถูกใจ ${selected.likes}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: kOwnerPrimaryColor,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'ไม่ถูกใจ ${selected.dislikes}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          )
        else
          const SizedBox(height: 18),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanDown: (details) =>
                    _handleTouch(details.localPosition, constraints.maxWidth),
                onPanUpdate: (details) =>
                    _handleTouch(details.localPosition, constraints.maxWidth),
                onPanEnd: (_) => setState(() => _selectedIndex = null),
                onTapUp: (_) => setState(() => _selectedIndex = null),
                child: CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: _SwipeTrendLineChartPainter(
                    points: widget.points,
                    maxVal: widget.maxVal,
                    selectedIndex: _selectedIndex,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _handleTouch(Offset localPos, double width) {
    const leftPad = 26.0;
    const rightPad = 14.0;
    final chartW = width - leftPad - rightPad;
    if (chartW <= 0 || widget.points.length <= 1) return;

    final xInChart = localPos.dx - leftPad;
    final step = chartW / (widget.points.length - 1);
    final idx = (xInChart / step).round().clamp(0, widget.points.length - 1);
    if (_selectedIndex != idx) {
      setState(() {
        _selectedIndex = idx;
      });
    }
  }
}

class _SwipeTrendLineChartPainter extends CustomPainter {
  final List<OwnerSwipePoint> points;
  final int maxVal;
  final int? selectedIndex;

  _SwipeTrendLineChartPainter({
    required this.points,
    required this.maxVal,
    required this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const leftPad = 26.0;
    const rightPad = 14.0;
    const topPad = 10.0;
    const bottomPad = 22.0;

    final chartW = size.width - leftPad - rightPad;
    final chartH = size.height - topPad - bottomPad;

    if (chartW <= 0 || chartH <= 0 || points.isEmpty) return;

    // Calculate nice Y max
    final rawMax = maxVal;
    final int yMax;
    if (rawMax <= 0) {
      yMax = 4;
    } else if (rawMax < 3) {
      yMax = 3;
    } else if (rawMax % 2 != 0) {
      yMax = rawMax + 1;
    } else {
      yMax = rawMax;
    }

    final gridPaint = Paint()
      ..color = const Color(0xFFEDE8E9)
      ..strokeWidth = 1;

    final yTextPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );

    // Draw horizontal grid lines and Y-axis labels
    const gridSteps = 3;
    for (var i = 0; i <= gridSteps; i++) {
      final ratio = i / gridSteps;
      final y = topPad + chartH * (1 - ratio);
      final val = (yMax * ratio).round();

      // Grid line
      canvas.drawLine(
        Offset(leftPad, y),
        Offset(leftPad + chartW, y),
        gridPaint,
      );

      // Y-axis label
      yTextPainter.text = TextSpan(
        text: '$val',
        style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 10),
      );
      yTextPainter.layout();
      yTextPainter.paint(
        canvas,
        Offset(leftPad - yTextPainter.width - 5, y - (yTextPainter.height / 2)),
      );
    }

    final xStep = points.length > 1 ? chartW / (points.length - 1) : 0.0;

    final likeOffsets = <Offset>[];
    final dislikeOffsets = <Offset>[];

    for (var i = 0; i < points.length; i++) {
      final p = points[i];
      final x = points.length > 1
          ? leftPad + (i * xStep)
          : leftPad + (chartW / 2);
      final likeY = topPad + chartH * (1 - (p.likes / yMax).clamp(0.0, 1.0));
      final dislikeY =
          topPad + chartH * (1 - (p.dislikes / yMax).clamp(0.0, 1.0));

      likeOffsets.add(Offset(x, likeY));
      dislikeOffsets.add(Offset(x, dislikeY));
    }

    // Draw selected indicator line
    if (selectedIndex != null &&
        selectedIndex! >= 0 &&
        selectedIndex! < points.length) {
      final selX = likeOffsets[selectedIndex!].dx;
      final selLinePaint = Paint()
        ..color = const Color(0xFFCBD5E1)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(selX, topPad),
        Offset(selX, topPad + chartH),
        selLinePaint,
      );
    }

    // Draw gradient fill under likes line
    if (likeOffsets.length > 1) {
      final fillPath = Path()..moveTo(likeOffsets.first.dx, topPad + chartH);
      for (final pt in likeOffsets) {
        fillPath.lineTo(pt.dx, pt.dy);
      }
      fillPath.lineTo(likeOffsets.last.dx, topPad + chartH);
      fillPath.close();

      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            kOwnerPrimaryColor.withValues(alpha: 0.18),
            kOwnerPrimaryColor.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(leftPad, topPad, chartW, chartH))
        ..style = PaintingStyle.fill;

      canvas.drawPath(fillPath, fillPaint);
    }

    // Draw Dislikes line
    final dislikePaint = Paint()
      ..color = const Color(0xFF64748B)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    if (dislikeOffsets.length > 1) {
      final dislikePath = Path()
        ..moveTo(dislikeOffsets.first.dx, dislikeOffsets.first.dy);
      for (var i = 1; i < dislikeOffsets.length; i++) {
        dislikePath.lineTo(dislikeOffsets[i].dx, dislikeOffsets[i].dy);
      }
      canvas.drawPath(dislikePath, dislikePaint);
    }

    // Draw Likes line
    final likePaint = Paint()
      ..color = kOwnerPrimaryColor
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    if (likeOffsets.length > 1) {
      final likePath = Path()
        ..moveTo(likeOffsets.first.dx, likeOffsets.first.dy);
      for (var i = 1; i < likeOffsets.length; i++) {
        likePath.lineTo(likeOffsets[i].dx, likeOffsets[i].dy);
      }
      canvas.drawPath(likePath, likePaint);
    }

    // Draw Dislike dots
    final dislikeOuter = Paint()..color = const Color(0xFF64748B);
    final dotInner = Paint()..color = Colors.white;

    for (var i = 0; i < dislikeOffsets.length; i++) {
      final pt = dislikeOffsets[i];
      final isSel = selectedIndex == i;
      canvas.drawCircle(pt, isSel ? 5.5 : 3.5, dislikeOuter);
      canvas.drawCircle(pt, isSel ? 3.0 : 1.8, dotInner);
    }

    // Draw Like dots
    final likeOuter = Paint()..color = kOwnerPrimaryColor;
    for (var i = 0; i < likeOffsets.length; i++) {
      final pt = likeOffsets[i];
      final isSel = selectedIndex == i;
      canvas.drawCircle(pt, isSel ? 6.5 : 4.0, likeOuter);
      canvas.drawCircle(pt, isSel ? 3.5 : 2.0, dotInner);
    }

    // Draw X-axis labels
    final xTextPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    final showStep = points.length <= 7
        ? 1
        : (points.length <= 14 ? 2 : (points.length / 5).ceil());

    for (var i = 0; i < points.length; i++) {
      final isLast = i == points.length - 1;
      final shouldShow = (i % showStep == 0) || isLast;
      if (!shouldShow) continue;

      final x = points.length > 1
          ? leftPad + (i * xStep)
          : leftPad + (chartW / 2);
      final label = points[i].label;

      xTextPainter.text = TextSpan(
        text: label,
        style: TextStyle(
          color: selectedIndex == i
              ? kOwnerPrimaryColor
              : const Color(0xFF757575),
          fontWeight: selectedIndex == i ? FontWeight.bold : FontWeight.normal,
          fontSize: 10,
        ),
      );
      xTextPainter.layout();
      xTextPainter.paint(
        canvas,
        Offset(x - (xTextPainter.width / 2), topPad + chartH + 6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SwipeTrendLineChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.maxVal != maxVal ||
        oldDelegate.selectedIndex != selectedIndex;
  }
}
