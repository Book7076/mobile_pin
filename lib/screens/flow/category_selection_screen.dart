import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../providers/restaurant_provider.dart';
import 'budget_selection_screen.dart';

/// Flow 3: เลือกประเภทอาหาร (Category Selection Screen)
/// Matches Figma Mockup:
/// - 12 Categories Grid (3 columns x 4 rows)
/// - Multi-selection support (เลือกได้มากกว่า 1 ประเภท)
/// - Rose-pink highlight and burgundy checkmark badge on selected items
/// - Floating / pinned burgundy pill "ถัดไป" button
class CategorySelectionScreen extends ConsumerStatefulWidget {
  final bool isStandalone;

  const CategorySelectionScreen({
    super.key,
    this.isStandalone = false,
  });

  @override
  ConsumerState<CategorySelectionScreen> createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState
    extends ConsumerState<CategorySelectionScreen> {
  late Set<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    // Initialize with previously selected categories if any
    final existingCriteria = ref.read(filterCriteriaProvider);
    _selectedIds = Set<String>.from(
      existingCriteria.selectedCategories.where((id) => id != 'all'),
    );
  }

  void _toggleCategory(String id) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _goToNextFlow() {
    if (_selectedIds.isEmpty) return;
    HapticFeedback.mediumImpact();

    // Update filterCriteriaProvider with selected categories
    final current = ref.read(filterCriteriaProvider);
    ref.read(filterCriteriaProvider.notifier).state = current.copyWith(
      selectedCategories: _selectedIds.toList(),
    );

    // Navigate to Flow 4 (Budget Selection)
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BudgetSelectionScreen(
          selectedCategories: _selectedIds.toList(),
          isStandalone: widget.isStandalone,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = AppConstants.flowCategories;
    final hasSelection = _selectedIds.isNotEmpty;

    return Scaffold(
      backgroundColor: AppConstants.backgroundWarm,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppConstants.burgundyPrimary,
                  size: 22,
                ),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),

                    // Header Title
                    const Text(
                      'เลือกประเภทอาหาร',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppConstants.textBurgundy,
                        letterSpacing: -0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 6),

                    // Subtitle
                    const Text(
                      '(เลือกได้มากกว่า 1 ประเภท)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppConstants.textBurgundy,
                        letterSpacing: 0.1,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 28),

                    // 12 Food Categories Grid (3 Columns)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: categories.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.86,
                      ),
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        final id = cat['id'] as String;
                        final name = cat['name'] as String;
                        final emoji = cat['emoji'] as String;
                        final imageUrl = cat['imageUrl'] as String?;
                        final isSelected = _selectedIds.contains(id);

                        return _CategoryGridCard(
                          name: name,
                          emoji: emoji,
                          imageUrl: imageUrl,
                          isSelected: isSelected,
                          onTap: () => _toggleCategory(id),
                        );
                      },
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom Next Button
            AnimatedSlide(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              offset: hasSelection ? Offset.zero : const Offset(0, 1.2),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: hasSelection ? 1.0 : 0.0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: hasSelection ? _goToNextFlow : null,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable Category Card matching Mockup styling
class _CategoryGridCard extends StatefulWidget {
  final String name;
  final String emoji;
  final String? imageUrl;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryGridCard({
    required this.name,
    required this.emoji,
    this.imageUrl,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_CategoryGridCard> createState() => _CategoryGridCardState();
}

class _CategoryGridCardState extends State<_CategoryGridCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.94,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _scaleController.reverse();
  void _onTapUp(TapUpDetails _) {
    _scaleController.forward();
    widget.onTap();
  }

  void _onTapCancel() => _scaleController.forward();

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.isSelected;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Card Base
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppConstants.cardSelectedBg
                    : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected
                      ? AppConstants.cardSelectedBorder
                      : AppConstants.cardBorderLight,
                  width: isSelected ? 1.8 : 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? AppConstants.burgundyPrimary.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Food Dish Graphic / Illustration
                  Expanded(
                    child: Center(
                      child: _buildFoodIllustration(),
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Category Label
                  Text(
                    widget.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AppConstants.burgundyDark
                          : const Color(0xFF334155),
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
            ),

            // Burgundy Checkmark Badge (Shown when selected)
            if (isSelected)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppConstants.burgundyPrimary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppConstants.burgundyPrimary.withValues(alpha: 0.35),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodIllustration() {
    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          widget.imageUrl!,
          width: 54,
          height: 54,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return _buildEmojiFallback();
          },
          errorBuilder: (context, error, stackTrace) => _buildEmojiFallback(),
        ),
      );
    }
    return _buildEmojiFallback();
  }

  Widget _buildEmojiFallback() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: widget.isSelected
            ? Colors.white.withValues(alpha: 0.7)
            : const Color(0xFFFFF6F5),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          widget.emoji,
          style: const TextStyle(fontSize: 28),
        ),
      ),
    );
  }
}
