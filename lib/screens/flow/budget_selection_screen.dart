import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../models/swipe_session_model.dart';
import '../../providers/restaurant_provider.dart';
import 'food_swipe_screen.dart';

/// Flow 4: กำหนดช่วงราคา / ตั้งงบประมาณสำหรับมื้อนี้ (Budget Selection Screen)
/// Matches Figma Mockup:
/// - Title: ตั้งงบประมาณสำหรับมื้อนี้
/// - Subtitle: เลือกช่วงราคาที่คุณต้องการ \n MealMate จะหาร้านที่เหมาะกับงบให้
/// - Interactive Tooltip Speech Bubble (฿ 50) floating dynamically above slider thumb
/// - Burgundy active track and soft pastel pink inactive track
/// - Burgundy pill "ถัดไป" button
class BudgetSelectionScreen extends ConsumerStatefulWidget {
  final List<String> selectedCategories;
  final bool isStandalone;

  const BudgetSelectionScreen({
    super.key,
    required this.selectedCategories,
    this.isStandalone = false,
  });

  @override
  ConsumerState<BudgetSelectionScreen> createState() =>
      _BudgetSelectionScreenState();
}

class _BudgetSelectionScreenState extends ConsumerState<BudgetSelectionScreen> {
  static const double _minBudget = 50.0; // Minimum budget is 50 THB
  static const double _maxBudget = 1000.0;
  static const double _step = 10.0;

  double _currentBudget = 50.0; // Initial value matching mockup (฿ 50)

  // Quick preset amounts in THB
  final List<double> _presetBudgets = [50, 100, 200, 300, 500, 800, 1000];

  @override
  void initState() {
    super.initState();
    // Always reset budget to initial default mockup value (฿ 50) when entering afresh
    _currentBudget = 50.0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final currentCriteria = ref.read(filterCriteriaProvider);
        ref.read(filterCriteriaProvider.notifier).state =
            currentCriteria.copyWith(clearBudget: true);
      }
    });
  }

  void _onSliderChanged(double value) {
    // Snap to step
    final steppedValue = (value / _step).round() * _step;
    if (steppedValue != _currentBudget) {
      HapticFeedback.selectionClick();
      setState(() {
        _currentBudget = steppedValue.clamp(_minBudget, _maxBudget);
      });
    }
  }

  void _selectPreset(double amount) {
    HapticFeedback.lightImpact();
    setState(() {
      _currentBudget = amount;
    });
  }

  Future<void> _confirmAndProceed() async {
    HapticFeedback.mediumImpact();

    // ก่อนสร้าง session ให้เช็กว่าผู้ใช้เลือกอย่างน้อย 1 ประเภท
    if (widget.selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'กรุณาเลือกประเภทอาหารอย่างน้อย 1 ประเภทก่อนเริ่มปัด',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    final currentCriteria = ref.read(filterCriteriaProvider);
    final cuisineTypeIds = widget.selectedCategories
        .map((cat) => mapCategoryToCuisineTypeId(cat))
        .whereType<int>()
        .toSet()
        .toList();

    if (cuisineTypeIds.isEmpty) {
      final fallbackSingle = currentCriteria.cuisineTypeId ?? 1;
      cuisineTypeIds.add(fallbackSingle);
    }
    final primaryFallbackId = cuisineTypeIds.first;

    // Save selected categories, minBudget, maxBudget & cuisineTypeId to filter criteria provider
    ref.read(filterCriteriaProvider.notifier).state = currentCriteria.copyWith(
      selectedCategories: widget.selectedCategories,
      minBudget: _minBudget,
      maxBudget: _currentBudget,
      cuisineTypeId: primaryFallbackId,
    );

    // Reset swipe session so new session starts fresh with filtered restaurants
    ref.read(swipeSessionProvider.notifier).reset();

    // Initialize swipe session in Supabase (swipe_sessions + swipe_session_cuisines) & local state
    try {
      await ref.read(swipeSessionProvider.notifier).initSession(
        cuisineTypeId: primaryFallbackId,
        cuisineTypeIds: cuisineTypeIds,
        priceMin: _minBudget,
        priceMax: _currentBudget,
      );
    } catch (e) {
      if (!mounted) return;
      final errorMsg = e.toString().contains('42501')
          ? 'เกิดข้อผิดพลาดเรื่องสิทธิ์ (RLS) ของ swipe_session_cuisines กรุณาลองใหม่อีกครั้ง'
          : 'เกิดข้อผิดพลาดในการบันทึกประเภทอาหาร กรุณาลองใหม่อีกครั้ง';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  errorMsg,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    if (!mounted) return;

    // Navigate to FoodSwipeScreen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const FoodSwipeScreen(),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'ตั้งงบ ฿${_currentBudget.round()} เรียบร้อยแล้ว! กำลังค้นหาร้านอาหารที่โดนใจ...',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppConstants.burgundyPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(milliseconds: 2500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundWarm,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppConstants.burgundyPrimary,
            size: 22,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_currentBudget != 50.0)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _currentBudget = 50.0;
                  });
                },
                child: const Text(
                  'รีเซ็ต',
                  style: TextStyle(
                    color: AppConstants.burgundyPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),

                    // Header Title (Matching Mockup)
                    const Text(
                      'ตั้งงบประมาณสำหรับมื้อนี้',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w800,
                        color: AppConstants.textBurgundy,
                        letterSpacing: -0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    // Subtitle with MealMate branding (Matching Mockup)
                    const Text(
                      'เลือกช่วงราคาที่คุณต้องการ',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF475569),
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.1,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 4),

                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        text: 'MealMate ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppConstants.textBurgundy,
                        ),
                        children: [
                          TextSpan(
                            text: 'จะหาร้านที่เหมาะกับงบให้',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 90),

                    // Interactive Tooltip Slider
                    _buildInteractiveBudgetSlider(),

                    const SizedBox(height: 48),

                    // Quick Preset Chips for Easy Selection
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'งบประมาณยอดนิยม:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 8,
                      runSpacing: 10,
                      children: _presetBudgets.map((amount) {
                        final isCurrent = _currentBudget == amount;
                        return InkWell(
                          onTap: () => _selectPreset(amount),
                          borderRadius: BorderRadius.circular(20),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isCurrent
                                  ? AppConstants.burgundyPrimary
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isCurrent
                                    ? AppConstants.burgundyPrimary
                                    : AppConstants.cardBorderLight,
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isCurrent
                                      ? AppConstants.burgundyPrimary
                                          .withValues(alpha: 0.25)
                                      : Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              '฿${amount.round()}',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: isCurrent
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isCurrent
                                    ? Colors.white
                                    : const Color(0xFF334155),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Bottom "ถัดไป" Pill Button (Matching Mockup)
            Container(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _confirmAndProceed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.burgundyPrimary,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor:
                        AppConstants.burgundyPrimary.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27),
                    ),
                  ),
                  child: const Text(
                    'ถัดไป',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the custom slider with a floating speech bubble tooltip
  Widget _buildInteractiveBudgetSlider() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        const double thumbRadius = 14.0;
        const double horizontalPadding = 16.0;
        final sliderWidth = totalWidth - (horizontalPadding * 2);

        // Normalize 0.0 to 1.0
        final ratio = (_currentBudget - _minBudget) / (_maxBudget - _minBudget);

        // Thumb position along slider track
        final thumbCenter = horizontalPadding +
            thumbRadius +
            ratio * (sliderWidth - (thumbRadius * 2));

        // Tooltip bubble dimensions
        const double bubbleWidth = 82.0;
        const double bubbleHeight = 44.0;

        // Clamp bubble horizontally so it never overflows screen edge
        final bubbleLeft = (thumbCenter - (bubbleWidth / 2))
            .clamp(4.0, totalWidth - bubbleWidth - 4.0);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              children: [
                // Space for Tooltip Bubble above slider
                const SizedBox(height: bubbleHeight + 14),

                // Custom Themed Slider
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 9.0,
                    activeTrackColor: AppConstants.sliderActive,
                    inactiveTrackColor: AppConstants.sliderInactive,
                    thumbColor: Colors.white,
                    overlayColor:
                        AppConstants.burgundyPrimary.withValues(alpha: 0.12),
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 22.0),
                    trackShape: const RoundedRectSliderTrackShape(),
                    thumbShape: const _BurgundyBorderThumbShape(
                      thumbRadius: thumbRadius,
                      borderWidth: 2.8,
                      borderColor: AppConstants.burgundyPrimary,
                    ),
                  ),
                  child: Slider(
                    value: _currentBudget,
                    min: _minBudget,
                    max: _maxBudget,
                    onChanged: _onSliderChanged,
                  ),
                ),
              ],
            ),

            // Dynamic Floating Speech Bubble Tooltip (Matching Mockup)
            Positioned(
              left: bubbleLeft,
              top: 0,
              child: _PriceSpeechBubble(
                amountText: '฿ ${_currentBudget.round()}',
                width: bubbleWidth,
                height: bubbleHeight,
                arrowOffset: thumbCenter - bubbleLeft,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Custom Tooltip Speech Bubble with drop shadow and downward arrow
class _PriceSpeechBubble extends StatelessWidget {
  final String amountText;
  final double width;
  final double height;
  final double arrowOffset;

  const _PriceSpeechBubble({
    required this.amountText,
    required this.width,
    required this.height,
    required this.arrowOffset,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bubble Body
        Container(
          width: width,
          height: height - 8,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            amountText,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
              letterSpacing: 0.2,
            ),
          ),
        ),

        // Downward Arrow pointing to slider thumb
        Padding(
          padding: EdgeInsets.only(
            left: (arrowOffset - 6.0).clamp(6.0, width - 16.0),
          ),
          child: CustomPaint(
            size: const Size(12, 8),
            painter: _DownwardTrianglePainter(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

/// Painter for the speech bubble downward pointer triangle
class _DownwardTrianglePainter extends CustomPainter {
  final Color color;

  const _DownwardTrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    // Subtle shadow behind triangle
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.05)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawPath(path, shadowPaint);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom Circular Thumb Shape with White Center and Burgundy Border
class _BurgundyBorderThumbShape extends SliderComponentShape {
  final double thumbRadius;
  final double borderWidth;
  final Color borderColor;

  const _BurgundyBorderThumbShape({
    required this.thumbRadius,
    required this.borderWidth,
    required this.borderColor,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    // Drop shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawCircle(center + const Offset(0, 2), thumbRadius, shadowPaint);

    // White Fill
    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, thumbRadius, fillPaint);

    // Burgundy Border
    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, thumbRadius - (borderWidth / 2), borderPaint);
  }
}
