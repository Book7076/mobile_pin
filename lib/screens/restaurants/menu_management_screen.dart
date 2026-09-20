import 'package:flutter/material.dart';
import 'add_menu_screen.dart';

class MenuManagementScreen extends StatefulWidget {
  final Map<String, dynamic>? shopData;
  final List<Map<String, dynamic>>? initialMenus;

  const MenuManagementScreen({
    super.key,
    this.shopData,
    this.initialMenus,
  });

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  // Theme Color matching Shop Owner UI
  static const Color maroonColor = Color(0xFF7A1428);
  static const Color headerBorderColor = Color(0xFFECD8DC);
  static const Color cardBgColor = Colors.white;

  late List<Map<String, dynamic>> _menus;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  bool _isRecommendedExpanded = true;
  bool _isRegularExpanded = true;

  @override
  void initState() {
    super.initState();
    // Initialize menu list from props, or fallback to default sample menus matching reference
    if (widget.initialMenus != null && widget.initialMenus!.isNotEmpty) {
      _menus = widget.initialMenus!.map((m) => Map<String, dynamic>.from(m)).toList();
    } else {
      _menus = [
        {
          'id': 'menu_rec_1',
          'name': 'ข้าวไก่กรอบซอสน้ำปลา',
          'price': 79.0,
          'description': 'ไก่ทอดกรอบราดซอสน้ำปลาหอมหวาน เสิร์ฟพร้อมข้าวสวยร้อนๆ',
          'category': 'อาหารจานเดียว',
          'imageUrl': 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=300',
          'isRecommended': true,
          'isHidden': false,
        },
        {
          'id': 'menu_rec_2',
          'name': 'ข้าวไก่ย่างน้ำจิ้มแจ่ว',
          'price': 59.0,
          'description': 'ไก่ย่างเนื้อนุ่มหอมกลิ่นเครื่องเทศ เสิร์ฟพร้อมน้ำจิ้มแจ่วรสเด็ด',
          'category': 'อาหารจานเดียว',
          'imageUrl': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=300',
          'isRecommended': true,
          'isHidden': false,
        },
        {
          'id': 'menu_reg_1',
          'name': 'ข้าวไก่เทอริยากิ',
          'price': 59.0,
          'description': 'ข้าวหน้าไก่ย่างราดซอสเทอริยากิรสชาติเข้มข้นสไตล์ญี่ปุ่น',
          'category': 'อาหารจานเดียว',
          'imageUrl': 'https://images.unsplash.com/photo-1548946526-f69e2424cf45?w=300',
          'isRecommended': false,
          'isHidden': false,
        },
        {
          'id': 'menu_reg_2',
          'name': 'ข้าวไก่กรอบเกาหลี',
          'price': 59.0,
          'description': 'ไก่ทอดคลุกซอสเกาหลีเข้มข้น เผ็ดหวานกำลังดี',
          'category': 'อาหารจานเดียว',
          'imageUrl': 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=300',
          'isRecommended': false,
          'isHidden': false,
        },
        {
          'id': 'menu_reg_3',
          'name': 'ข้าวไก่แซ่บ',
          'price': 49.0,
          'description': 'ไก่กรอบคลุกเครื่องลาบรสจัดจ้าน เปรี้ยว เผ็ด แซ่บถึงใจ',
          'category': 'อาหารจานเดียว',
          'imageUrl': 'https://images.unsplash.com/photo-1517701604599-bb29b565090c?w=300',
          'isRecommended': false,
          'isHidden': false,
        },
      ];
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filtered lists based on live search query
  List<Map<String, dynamic>> get _recommendedMenus {
    return _menus.where((item) {
      final isRec = item['isRecommended'] == true;
      if (!isRec) return false;
      if (_searchQuery.isEmpty) return true;
      final name = item['name']?.toString().toLowerCase() ?? '';
      return name.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  List<Map<String, dynamic>> get _regularMenus {
    return _menus.where((item) {
      final isRec = item['isRecommended'] == true;
      if (isRec) return false;
      if (_searchQuery.isEmpty) return true;
      final name = item['name']?.toString().toLowerCase() ?? '';
      return name.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  bool get _hasSearchResults => _recommendedMenus.isNotEmpty || _regularMenus.isNotEmpty;

  // Toggle dish hidden/visible status
  void _toggleVisibility(Map<String, dynamic> item) {
    setState(() {
      final isCurrentlyHidden = item['isHidden'] == true;
      item['isHidden'] = !isCurrentlyHidden;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          item['isHidden'] == true
              ? 'ซ่อนเมนู "${item['name']}" แล้ว (ลูกค้าจะไม่เห็นเมนูนี้)'
              : 'เปิดแสดงเมนู "${item['name']}" แล้ว',
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: maroonColor,
      ),
    );
  }

  // Delete dish with confirmation dialog
  Future<void> _confirmDelete(Map<String, dynamic> item) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'ต้องการลบเมนูนี้หรือไม่?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        content: Text(
          'ต้องการลบเมนู "${item['name']}" ออกจากรายการอาหารหรือไม่? เมื่อลบแล้วจะไม่สามารถกู้คืนได้',
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'ยกเลิก',
              style: TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: maroonColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'ลบ',
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _menus.removeWhere((element) => element['id'] == item['id']);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ลบเมนู "${item['name']}" เรียบร้อยแล้ว'),
            duration: const Duration(seconds: 2),
            backgroundColor: maroonColor,
          ),
        );
      }
    }
  }

  // Navigate to Add Menu screen
  Future<void> _navigateToAddMenu() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => AddMenuScreen(
          shopData: widget.shopData,
          isEditing: false,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _menus.add(Map<String, dynamic>.from(result));
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เพิ่มเมนู "${result['name']}" เรียบร้อยแล้ว'),
            backgroundColor: maroonColor,
          ),
        );
      }
    }
  }

  // Navigate to Edit Menu screen
  Future<void> _navigateToEditMenu(Map<String, dynamic> item) async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => AddMenuScreen(
          shopData: widget.shopData,
          initialMenu: item,
          isEditing: true,
        ),
      ),
    );

    if (result != null) {
      if (result['deleted'] == true) {
        setState(() {
          _menus.removeWhere((m) => m['id'] == (result['id'] ?? item['id']));
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('ลบเมนู "${item['name']}" เรียบร้อยแล้ว'),
              backgroundColor: maroonColor,
            ),
          );
        }
      } else {
        setState(() {
          final index = _menus.indexWhere((m) => m['id'] == item['id']);
          if (index != -1) {
            _menus[index] = Map<String, dynamic>.from(result);
          }
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('อัปเดตเมนู "${result['name']}" เรียบร้อยแล้ว'),
              backgroundColor: maroonColor,
            ),
          );
        }
      }
    }
  }

  void _onBack() {
    Navigator.of(context).pop(_menus);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _onBack();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFBF9F9),
        body: Column(
          children: [
            // Top Header Bar
            _buildHeader(),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Live Search Input Box
                    _buildSearchBar(),
                    const SizedBox(height: 16),

                    // If searching and no results found anywhere
                    if (_searchQuery.isNotEmpty && !_hasSearchResults)
                      _buildEmptySearchResult()
                    else ...[
                      // Section 1: เมนูแนะนำ (Recommended)
                      _buildRecommendedSection(),
                      const SizedBox(height: 16),

                      // Section 2: เมนู (Regular) with + เพิ่มเมนูอาหาร
                      _buildRegularSection(),
                    ],

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Maroon Header with Back Button and Title
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: maroonColor,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 22,
                ),
                onPressed: _onBack,
              ),
              const SizedBox(width: 4),
              const Text(
                'เมนูอาหาร',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Rounded Search Bar with Instant Live Search
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6F7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8CBD1), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: maroonColor.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value.trim();
          });
        },
        style: const TextStyle(fontSize: 15, color: Colors.black87),
        decoration: InputDecoration(
          hintText: 'ค้นหาเมนูอาหาร',
          hintStyle: TextStyle(
            color: maroonColor.withOpacity(0.65),
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: maroonColor,
            size: 24,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, color: maroonColor, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  // Empty Search Result Indicator
  Widget _buildEmptySearchResult() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: headerBorderColor),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 54,
            color: maroonColor.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          const Text(
            'ไม่พบเมนูอาหาร',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'ไม่พบรายการอาหารที่ตรงกับ "$_searchQuery"',
            style: const TextStyle(fontSize: 14, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
              });
            },
            icon: const Icon(Icons.refresh, color: maroonColor, size: 18),
            label: const Text('ล้างการค้นหา', style: TextStyle(color: maroonColor)),
          ),
        ],
      ),
    );
  }

  // Section 1: เมนูแนะนำ (Collapsible Card)
  Widget _buildRecommendedSection() {
    final list = _recommendedMenus;

    return Column(
      children: [
        // Section Header Pill
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            setState(() {
              _isRecommendedExpanded = !_isRecommendedExpanded;
            });
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: headerBorderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'เมนูแนะนำ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Icon(
                  _isRecommendedExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.black87,
                  size: 26,
                ),
              ],
            ),
          ),
        ),

        // Expanded Dish List Card
        if (_isRecommendedExpanded) ...[
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: headerBorderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: list.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    child: Center(
                      child: Text(
                        _searchQuery.isNotEmpty
                            ? 'ไม่พบเมนูแนะนำที่ตรงกับ "$_searchQuery"'
                            : 'ไม่มีรายการเมนูแนะนำ',
                        style: const TextStyle(color: Colors.black45, fontSize: 14),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFF2E6E8),
                      indent: 16,
                      endIndent: 16,
                    ),
                    itemBuilder: (context, index) {
                      return _buildDishRow(list[index]);
                    },
                  ),
          ),
        ],
      ],
    );
  }

  // Section 2: เมนูธรรมดา (Collapsible Card) with + เพิ่มเมนูอาหาร
  Widget _buildRegularSection() {
    final list = _regularMenus;

    return Column(
      children: [
        // Section Header Pill
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            setState(() {
              _isRegularExpanded = !_isRegularExpanded;
            });
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: headerBorderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'เมนู',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Icon(
                  _isRegularExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.black87,
                  size: 26,
                ),
              ],
            ),
          ),
        ),

        // Expanded Dish List Card
        if (_isRegularExpanded) ...[
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: cardBgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: headerBorderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                if (list.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    child: Center(
                      child: Text(
                        _searchQuery.isNotEmpty
                            ? 'ไม่พบเมนูที่ตรงกับ "$_searchQuery"'
                            : 'ไม่มีรายการเมนู',
                        style: const TextStyle(color: Colors.black45, fontSize: 14),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFF2E6E8),
                      indent: 16,
                      endIndent: 16,
                    ),
                    itemBuilder: (context, index) {
                      return _buildDishRow(list[index]);
                    },
                  ),

                // Divider before "+ เพิ่มเมนูอาหาร" button
                if (list.isNotEmpty)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFF2E6E8),
                    indent: 16,
                    endIndent: 16,
                  ),

                // Bottom button "+ เพิ่มเมนูอาหาร"
                InkWell(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                  onTap: _navigateToAddMenu,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.add,
                          color: maroonColor,
                          size: 22,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'เพิ่มเมนูอาหาร',
                          style: TextStyle(
                            color: maroonColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // Single Dish Row with Circular Image, Name, Price, Eye Toggle, and Trash Delete
  Widget _buildDishRow(Map<String, dynamic> item) {
    final bool isHidden = item['isHidden'] == true;
    final String name = item['name']?.toString() ?? 'ชื่อเมนู';
    final dynamic rawPrice = item['price'];
    final String priceStr = rawPrice != null
        ? (rawPrice is num ? rawPrice.toInt().toString() : rawPrice.toString())
        : '0';
    final String? imageUrl = item['imageUrl']?.toString();

    return InkWell(
      onTap: () => _navigateToEditMenu(item),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isHidden ? 0.55 : 1.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Circular Dish Image
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF8EEF0),
                  border: Border.all(
                    color: const Color(0xFFE8CBD1),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: (imageUrl != null && imageUrl.trim().isNotEmpty)
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.restaurant_menu,
                              color: maroonColor,
                              size: 26,
                            );
                          },
                        )
                      : const Icon(
                          Icons.restaurant_menu,
                          color: maroonColor,
                          size: 26,
                        ),
                ),
              ),

              const SizedBox(width: 14),

              // Dish Name, Price, and Hidden indicator
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isHidden) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEEEEE),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'ซ่อนอยู่',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$priceStr บาท',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Visibility Eye Toggle Button
              IconButton(
                icon: Icon(
                  isHidden ? Icons.visibility_off_outlined : Icons.remove_red_eye_outlined,
                  color: isHidden ? Colors.grey : maroonColor,
                  size: 24,
                ),
                tooltip: isHidden ? 'แสดงเมนูให้ลูกค้าเห็น' : 'ซ่อนเมนูจากลูกค้า',
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
                splashRadius: 20,
                onPressed: () => _toggleVisibility(item),
              ),

              const SizedBox(width: 4),

              // Trash Delete Button
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: maroonColor,
                  size: 24,
                ),
                tooltip: 'ลบเมนู',
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
                splashRadius: 20,
                onPressed: () => _confirmDelete(item),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
