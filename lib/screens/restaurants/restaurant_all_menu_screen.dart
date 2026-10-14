import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants.dart';
import '../../models/restaurant_model.dart';
import '../../services/menu_availability_manager.dart';

class RestaurantAllMenuScreen extends StatefulWidget {
  final String? restaurantId;
  final String restaurantName;
  final List<SignatureDish>? initialDishes;

  const RestaurantAllMenuScreen({
    super.key,
    this.restaurantId,
    this.restaurantName = 'ร้านอาหาร',
    this.initialDishes,
  });

  @override
  State<RestaurantAllMenuScreen> createState() =>
      _RestaurantAllMenuScreenState();
}

class _RestaurantAllMenuScreenState extends State<RestaurantAllMenuScreen> {
  String _selectedCategory = 'ทั้งหมด';
  List<String> _allCategories = [
    'ข้าว',
    'ของทอด',
    'เมนูเส้น',
    'เครื่องดื่ม',
    'ของหวาน',
  ];
  final Map<String, String> _catNameToId = {};
  bool _isLoading = false;
  List<Map<String, dynamic>> _menuItems = [];

  /// หมวดหมู่ที่จะนำมาแสดงเป็นแท็บด้านบน (เฉพาะ 'ทั้งหมด' และหมวดหมู่ที่มีรายการเมนูของร้านนี้จริงๆ)
  List<String> get _displayedCategories {
    final usedCategories = _menuItems
        .map((item) => item['category']?.toString().trim() ?? '')
        .where((c) => c.isNotEmpty)
        .toSet();

    final List<String> list = ['ทั้งหมด'];
    for (final cat in _allCategories) {
      if (usedCategories.contains(cat) && !list.contains(cat)) {
        list.add(cat);
      }
    }
    // กรณีมีหมวดหมู่อื่นที่ไม่ได้อยู่ใน _allCategories ให้ดึงมาแสดงด้วย
    for (final cat in usedCategories) {
      if (!list.contains(cat)) {
        list.add(cat);
      }
    }
    return list;
  }

  @override
  void initState() {
    super.initState();
    _loadMenuItems();
  }

  /// โหลดข้อมูลเมนูจากตาราง menu_items และหมวดหมู่จากตาราง categories
  Future<void> _loadMenuItems() async {
    setState(() => _isLoading = true);

    String? restaurantUuid = widget.restaurantId;

    try {
      // If restaurantUuid is not a valid UUID, try lookup by name
      if (restaurantUuid == null || !restaurantUuid.contains('-')) {
        if (widget.restaurantName.isNotEmpty) {
          try {
            final resRows = await Supabase.instance.client
                .from('restaurants')
                .select('id')
                .ilike('name', '%${widget.restaurantName}%')
                .limit(1);
            if (resRows is List && resRows.isNotEmpty) {
              restaurantUuid = resRows.first['id']?.toString();
            }
          } catch (_) {}
        }
      }

      if (restaurantUuid == null || restaurantUuid.isEmpty) {
        _loadFallbackDishes();
        return;
      }

      // 1. โหลดหมวดหมู่ทั้งหมดจากตาราง categories
      try {
        final catRows = await Supabase.instance.client
            .from('categories')
            .select('id, name, sort_order')
            .eq('restaurant_id', restaurantUuid)
            .order('sort_order', ascending: true);

        if (catRows is List && catRows.isNotEmpty) {
          final List<String> loadedCats = [];
          _catNameToId.clear();
          for (final row in catRows) {
            final id = row['id']?.toString();
            final name = row['name']?.toString().trim();
            if (id != null && name != null && name.isNotEmpty) {
              _catNameToId[name] = id;
              if (!loadedCats.contains(name)) {
                loadedCats.add(name);
              }
            }
          }
          if (loadedCats.isNotEmpty && mounted) {
            setState(() {
              _allCategories = loadedCats;
            });
          }
        }
      } catch (e) {
        debugPrint('Note: Error loading categories from Supabase: $e');
      }

      // 2. โหลดความสัมพันธ์ของเมนูกับหมวดหมู่จากตาราง menu_item_categories
      final Map<String, String> itemToCategoryName = {};
      try {
        final linkRows = await Supabase.instance.client
            .from('menu_item_categories')
            .select('menu_item_id, category_id');

        if (linkRows is List && linkRows.isNotEmpty) {
          for (final row in linkRows) {
            final mId = row['menu_item_id']?.toString();
            final cId = row['category_id']?.toString();
            if (mId != null && cId != null && _catNameToId.containsValue(cId)) {
              final catEntry = _catNameToId.entries.firstWhere(
                (e) => e.value == cId,
                orElse: () => const MapEntry('', ''),
              );
              if (catEntry.key.isNotEmpty) {
                itemToCategoryName[mId] = catEntry.key;
              }
            }
          }
        }
      } catch (_) {}

      // 3. โหลดเมนูอาหารจากตาราง menu_items
      final response = await Supabase.instance.client
          .from('menu_items')
          .select()
          .eq('restaurant_id', restaurantUuid)
          .order('sort_order', ascending: true);

      if (response.isNotEmpty) {
        final List<Map<String, dynamic>> loaded = [];
        for (final row in response) {
          final id = row['id']?.toString() ?? '';
          final name = row['name']?.toString() ?? '';
          final categoryName =
              itemToCategoryName[id] ?? _detectCategoryByName(name);

          final isAvailable = MenuAvailabilityManager.parseFromRow(row);

          loaded.add({
            'id': id,
            'name': name,
            'category': categoryName,
            'price': (row['price'] as num?)?.toDouble() ?? 0.0,
            'isAvailable': isAvailable,
            'image': (row['image_url'] != null &&
                    row['image_url'].toString().isNotEmpty)
                ? row['image_url'].toString()
                : '',
          });
        }
        if (mounted) {
          setState(() {
            _menuItems = loaded;
            _isLoading = false;
          });
          return;
        }
      }
    } catch (e) {
      debugPrint('Error loading menu items in user view: $e');
    }

    _loadFallbackDishes();
  }

  /// โหลดเมนูสำรองกรณี Offline หรือยังไม่มีข้อมูลในฐานข้อมูล
  void _loadFallbackDishes() {
    if (!mounted) return;

    if (widget.initialDishes != null && widget.initialDishes!.isNotEmpty) {
      final List<Map<String, dynamic>> loaded = [];
      for (final dish in widget.initialDishes!) {
        loaded.add({
          'id': dish.name,
          'name': dish.name,
          'category': _detectCategoryByName(dish.name),
          'price': dish.price.toDouble(),
          'isAvailable': dish.isAvailable,
          'image': (dish.imageUrl != null && dish.imageUrl!.isNotEmpty)
              ? dish.imageUrl!
              : 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=200&auto=format&fit=crop&q=80',
        });
      }
      setState(() {
        _menuItems = loaded;
        _isLoading = false;
      });
      return;
    }

    // เมนูสำรองที่สมจริงตามประเภทร้านอาหาร
    final bool isNoodle = widget.restaurantName.contains('เตี๋ยว') ||
        widget.restaurantName.contains('เส้น');

    final List<Map<String, dynamic>> defaults = isNoodle
        ? [
            {
              'id': 'fallback-1',
              'name': 'ก๋วยเตี๋ยวเรือ พิเศษ',
              'category': 'เมนูเส้น',
              'price': 50.0,
              'image':
                  'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=200&auto=format&fit=crop&q=80',
            },
            {
              'id': 'fallback-2',
              'name': 'ก๋วยเตี๋ยวต้มยำพริกสด พิเศษ',
              'category': 'เมนูเส้น',
              'price': 50.0,
              'image':
                  'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=200&auto=format&fit=crop&q=80',
            },
            {
              'id': 'fallback-3',
              'name': 'กากหมูเจียวทรงเครื่อง',
              'category': 'ของทอด',
              'price': 15.0,
              'image':
                  'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=200&auto=format&fit=crop&q=80',
            },
            {
              'id': 'fallback-4',
              'name': 'แคบหมูกรอบ',
              'category': 'ของทอด',
              'price': 15.0,
              'image':
                  'https://images.unsplash.com/photo-1562967914-608f82629710?w=200&auto=format&fit=crop&q=80',
            },
            {
              'id': 'fallback-5',
              'name': 'น้ำเก๊กฮวยเย็น',
              'category': 'เครื่องดื่ม',
              'price': 20.0,
              'image':
                  'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=200&auto=format&fit=crop&q=80',
            },
            {
              'id': 'fallback-6',
              'name': 'ขนมถ้วยโบราณ',
              'category': 'ของหวาน',
              'price': 20.0,
              'image':
                  'https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=200&auto=format&fit=crop&q=80',
            },
          ]
        : [
            {
              'id': 'fallback-1',
              'name': 'ข้าวหน้ากุ้งย่างซีอิ๊ว',
              'category': 'ข้าว',
              'price': 89.0,
              'image':
                  'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=200&auto=format&fit=crop&q=80',
            },
            {
              'id': 'fallback-2',
              'name': 'ข้าวหน้าหมูสามชั้นย่าง',
              'category': 'ข้าว',
              'price': 118.0,
              'image':
                  'https://images.unsplash.com/photo-1562967914-608f82629710?w=200&auto=format&fit=crop&q=80',
            },
            {
              'id': 'fallback-3',
              'name': 'ข้าวหน้าหมูสันคอย่าง',
              'category': 'ข้าว',
              'price': 112.0,
              'image':
                  'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=200&auto=format&fit=crop&q=80',
            },
            {
              'id': 'fallback-4',
              'name': 'เกี๊ยวซ่าทอดกรอบ',
              'category': 'ของทอด',
              'price': 45.0,
              'image':
                  'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=200&auto=format&fit=crop&q=80',
            },
            {
              'id': 'fallback-5',
              'name': 'ชาเขียวมัทฉะเย็น',
              'category': 'เครื่องดื่ม',
              'price': 40.0,
              'image':
                  'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=200&auto=format&fit=crop&q=80',
            },
          ];

    setState(() {
      _menuItems = defaults;
      _isLoading = false;
    });
  }

  /// ตรวจจับหมวดหมู่อาหารเริ่มต้นจากชื่ออาหาร
  String _detectCategoryByName(String name) {
    if (name.contains('ก๋วยเตี๋ยว') ||
        name.contains('เตี๋ยว') ||
        name.contains('เส้น') ||
        name.contains('สปาเกตตี') ||
        name.contains('ราเมน') ||
        name.contains('บะหมี่')) {
      return 'เมนูเส้น';
    }
    if (name.contains('ข้าว') ||
        name.contains('โจ๊ก') ||
        name.contains('ต้ม') ||
        name.contains('ด้ง')) {
      return 'ข้าว';
    }
    if (name.contains('ทอด') ||
        name.contains('เกี๊ยว') ||
        name.contains('กากหมู') ||
        name.contains('แคบหมู') ||
        name.contains('ป๊อป') ||
        name.contains('ไก่')) {
      return 'ของทอด';
    }
    if (name.contains('ชา') ||
        name.contains('น้ำ') ||
        name.contains('เก๊กฮวย') ||
        name.contains('กาแฟ') ||
        name.contains('นม') ||
        name.contains('ดื่ม')) {
      return 'เครื่องดื่ม';
    }
    if (name.contains('หวาน') ||
        name.contains('ขนม') ||
        name.contains('ถ้วย') ||
        name.contains('เค้ก') ||
        name.contains('ไอศกรีม') ||
        name.contains('พุดดิ้ง')) {
      return 'ของหวาน';
    }
    return _allCategories.isNotEmpty ? _allCategories.first : 'ข้าว';
  }

  @override
  Widget build(BuildContext context) {
    final displayedCats = _displayedCategories;
    final currentSelected = displayedCats.contains(_selectedCategory)
        ? _selectedCategory
        : 'ทั้งหมด';

    final filteredList = currentSelected == 'ทั้งหมด'
        ? _menuItems
        : _menuItems
            .where((item) => item['category'] == currentSelected)
            .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        backgroundColor: AppConstants.burgundyPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left_rounded,
            color: Colors.white,
            size: 32,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'เมนูทั้งหมด',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            if (widget.restaurantName.isNotEmpty)
              Text(
                widget.restaurantName,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppConstants.burgundyPrimary,
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadMenuItems,
              color: AppConstants.burgundyPrimary,
              child: Column(
                children: [
                  // แถบเลือกหมวดหมู่อาหาร (Horizontal Chips)
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    child: SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: displayedCats.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final catName = displayedCats[index];
                          final isSelected = currentSelected == catName;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedCategory = catName),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppConstants.burgundyPrimary
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                catName,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey[700],
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 13.5,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // รายการเมนูอาหาร
                  Expanded(
                    child: filteredList.isEmpty
                        ? Center(
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.restaurant_menu_rounded,
                                    size: 70,
                                    color: Colors.grey[300],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'ยังไม่มีรายการอาหารในหมวดหมู่นี้',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            itemCount: filteredList.length,
                            itemBuilder: (context, index) {
                              final item = filteredList[index];
                              final price = item['price'] as num? ?? 0;

                              final isAvailable = item['isAvailable'] as bool? ?? true;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Stack(
                                        children: [
                                          _buildDishThumbnailWidget(
                                            item['image']?.toString(),
                                          ),
                                          if (!isAvailable)
                                            Positioned.fill(
                                              child: Container(
                                                color: Colors.black.withOpacity(0.55),
                                                child: const Center(
                                                  child: Text(
                                                    'สินค้าหมด',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['name']?.toString() ?? '',
                                            style: TextStyle(
                                              fontSize: 15.5,
                                              fontWeight: FontWeight.bold,
                                              color: isAvailable
                                                  ? const Color(0xFF1E293B)
                                                  : const Color(0xFF94A3B8),
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Text(
                                                '฿${price.toInt()}',
                                                style: TextStyle(
                                                  fontSize: 15.5,
                                                  fontWeight: FontWeight.w800,
                                                  color: isAvailable
                                                      ? AppConstants.burgundyPrimary
                                                      : const Color(0xFF94A3B8),
                                                ),
                                              ),
                                              if (!isAvailable) ...[
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFFEE2E2),
                                                    borderRadius: BorderRadius.circular(6),
                                                    border: Border.all(color: const Color(0xFFFCA5A5), width: 0.8),
                                                  ),
                                                  child: const Text(
                                                    'สินค้าหมด',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: Color(0xFFDC2626),
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDishThumbnailWidget(String? imgUrl) {
    if (imgUrl == null || imgUrl.trim().isEmpty) {
      return _buildNoDishImagePlaceholder();
    }
    if (imgUrl.startsWith('data:image')) {
      try {
        final base64String = imgUrl.split(',').last;
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          width: 76,
          height: 76,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildNoDishImagePlaceholder(),
        );
      } catch (_) {}
    }
    return Image.network(
      imgUrl,
      width: 76,
      height: 76,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildNoDishImagePlaceholder(),
    );
  }

  Widget _buildNoDishImagePlaceholder() {
    return Container(
      width: 76,
      height: 76,
      color: const Color(0xFFF1F5F9),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.camera_alt_outlined,
              color: Color(0xFF94A3B8),
              size: 26,
            ),
            SizedBox(height: 2),
            Text(
              'ไม่มีรูป',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
