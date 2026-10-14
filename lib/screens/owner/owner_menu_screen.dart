import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/menu_availability_manager.dart';
import 'owner_edit_menu_item_screen.dart';

const Color kOwnerPrimaryColor = Color(0xFF8B1E3F);

class OwnerMenuScreen extends StatefulWidget {
  final String? restaurantId;
  final String restaurantName;

  const OwnerMenuScreen({
    super.key,
    this.restaurantId,
    this.restaurantName = 'The CHICKEN',
  });

  @override
  State<OwnerMenuScreen> createState() => _OwnerMenuScreenState();
}

class _OwnerMenuScreenState extends State<OwnerMenuScreen> {
  String _selectedCategory = 'ทั้งหมด';
  // รายการหมวดหมู่ทั้งหมดที่มีในฐานข้อมูล (จากตาราง categories หรือค่าเริ่มต้นตามภาพที่ 4)
  List<String> _allCategories = [
    'ข้าว',
    'ของทอด',
    'เมนูเส้น',
    'เครื่องดื่ม',
    'ของหวาน',
  ];
  final Map<String, String> _catNameToId = {};
  bool _isLoading = false;

  /// หมวดหมู่ที่จะนำมาแสดงเป็นแท็บด้านบน (เฉพาะ 'ทั้งหมด' และหมวดหมู่ที่มีรายการเมนูในร้านจริงๆ)
  List<String> get _displayedCategories {
    final usedCategories = <String>{};
    for (final item in _menuItems) {
      final cats = item['categories'];
      if (cats is List && cats.isNotEmpty) {
        for (final c in cats) {
          if (c != null && c.toString().trim().isNotEmpty) {
            usedCategories.add(c.toString().trim());
          }
        }
      } else {
        final c = item['category']?.toString().trim() ?? '';
        if (c.isNotEmpty) usedCategories.add(c);
      }
    }

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

  // รายการเมนูสำรองกรณี Offline หรือยังไม่มีข้อมูลใน DB (สอดคล้องกับภาพที่ 1)
  static final List<Map<String, dynamic>> _defaultMockItems = [
    {
      'id': 'mock-1',
      'name': 'ข้าวหน้ากุ้งย่างซีอิ๊ว',
      'category': 'ข้าว',
      'price': 89.0,
      'isAvailable': true,
      'image': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=200&auto=format&fit=crop&q=80',
    },
    {
      'id': 'mock-2',
      'name': 'ข้าวหน้าหมูสามชั้นย่าง',
      'category': 'ข้าว',
      'price': 118.0,
      'isAvailable': true,
      'image': 'https://images.unsplash.com/photo-1562967914-608f82629710?w=200&auto=format&fit=crop&q=80',
    },
    {
      'id': 'mock-3',
      'name': 'ข้าวหน้าหมูสันคอย่าง',
      'category': 'ข้าว',
      'price': 112.0,
      'isAvailable': true,
      'image': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=200&auto=format&fit=crop&q=80',
    },
    {
      'id': 'mock-4',
      'name': 'ข้าวหน้าหมูสันคอซีอิ๊ว',
      'category': 'ข้าว',
      'price': 69.0,
      'isAvailable': true,
      'image': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=200&auto=format&fit=crop&q=80',
    },
    {
      'id': 'mock-5',
      'name': 'ข้าวหน้าไก่ย่าง โชยุ',
      'category': 'ข้าว',
      'price': 69.0,
      'isAvailable': true,
      'image': 'https://images.unsplash.com/photo-1562967914-608f82629710?w=200&auto=format&fit=crop&q=80',
    },
  ];

  List<Map<String, dynamic>> _menuItems = [];

  @override
  void initState() {
    super.initState();
    _loadMenuItems();
  }

  /// ค้นหา ID ร้านค้าจาก Parameter หรือจาก Owner ปัจจุบันใน Database
  Future<String?> _resolveRestaurantId() async {
    if (widget.restaurantId != null && widget.restaurantId!.trim().isNotEmpty) {
      final rid = widget.restaurantId!.trim();
      if (rid.contains('-')) return rid;
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

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final res = await Supabase.instance.client
            .from('restaurants')
            .select('id')
            .eq('owner_id', user.id)
            .limit(1)
            .maybeSingle();
        if (res != null && res['id'] != null) {
          return res['id'].toString();
        }
      }
    } catch (_) {}
    return null;
  }

  /// โหลดข้อมูลเมนูจากตาราง menu_items และหมวดหมู่จากตาราง categories
  Future<void> _loadMenuItems() async {
    final effectiveRestaurantId = await _resolveRestaurantId();
    if (effectiveRestaurantId == null) {
      setState(() {
        _menuItems = List.from(_defaultMockItems);
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. โหลดหมวดหมู่จากตาราง categories (เรียงตาม sort_order ภาพที่ 4)
      try {
        final catRows = await Supabase.instance.client
            .from('categories')
            .select('id, name, sort_order')
            .eq('restaurant_id', effectiveRestaurantId)
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

      // 2. โหลดความสัมพันธ์ของเมนูกับหมวดหมู่จากตาราง menu_item_categories (1 เมนูมีได้หลายประเภท)
      final Map<String, List<String>> itemToCategories = {};
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
                if (itemToCategories[mId] == null) itemToCategories[mId] = [];
                if (!itemToCategories[mId]!.contains(catEntry.key)) {
                  itemToCategories[mId]!.add(catEntry.key);
                }
              }
            }
          }
        }
      } catch (_) {}

      // 3. โหลดเมนูอาหารจากตาราง menu_items
      final response = await Supabase.instance.client
          .from('menu_items')
          .select()
          .eq('restaurant_id', effectiveRestaurantId)
          .order('sort_order', ascending: true);

      if (response.isNotEmpty) {
        final List<Map<String, dynamic>> loaded = [];
        for (final row in response) {
          final id = row['id']?.toString() ?? '';
          final name = row['name']?.toString() ?? '';
          final itemCats = itemToCategories[id] ?? [_detectCategoryByName(name)];
          final categoryName = itemCats.isNotEmpty ? itemCats.first : _detectCategoryByName(name);

          // ดึงสถานะเปิดขาย / สินค้าหมด ตามฐานข้อมูลและ cache
          final isAvailable = MenuAvailabilityManager.parseFromRow(row);

          loaded.add({
            'id': id,
            'restaurant_id': row['restaurant_id']?.toString() ?? effectiveRestaurantId,
            'name': name,
            'category': categoryName,
            'categories': itemCats,
            'price': (row['price'] as num?)?.toDouble() ?? 0.0,
            'isAvailable': isAvailable,
            'image': (row['image_url'] != null && row['image_url'].toString().isNotEmpty)
                ? row['image_url'].toString()
                : '',
            'image_url': (row['image_url'] != null && row['image_url'].toString().isNotEmpty)
                ? row['image_url'].toString()
                : '',
          });
        }
        if (mounted) {
          setState(() {
            _menuItems = loaded;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _menuItems = [];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading menu items from Supabase: $e');
      if (mounted) {
        setState(() {
          _menuItems = List.from(_defaultMockItems);
          _isLoading = false;
        });
      }
    }
  }

  /// ฟังก์ชันช่วยตรวจจับหมวดหมู่อาหารเริ่มต้นจากชื่ออาหาร (อิงตามหมวดหมู่ภาพที่ 4)
  String _detectCategoryByName(String name) {
    if (name.contains('ข้าว') || name.contains('โจ๊ก') || name.contains('ต้ม')) return 'ข้าว';
    if (name.contains('เส้น') || name.contains('เตี๋ยว') || name.contains('สปาเกตตี') || name.contains('ผัดซีอิ๊ว') || name.contains('บะหมี่') || name.contains('ราเมน')) {
      return 'เมนูเส้น';
    }
    if (name.contains('ทอด') || name.contains('เกี๊ยว') || name.contains('ป๊อป') || name.contains('ไก่')) {
      return 'ของทอด';
    }
    if (name.contains('ชา') || name.contains('น้ำ') || name.contains('กาแฟ') || name.contains('นม') || name.contains('ดื่ม')) {
      return 'เครื่องดื่ม';
    }
    if (name.contains('หวาน') || name.contains('เค้ก') || name.contains('ไอศกรีม') || name.contains('พุดดิ้ง') || name.contains('ขนม')) {
      return 'ของหวาน';
    }
    return _allCategories.isNotEmpty ? _allCategories.first : 'ข้าว';
  }

  /// Helper ในการแสดงรูปภาพเมนูอาหาร รองรับทั้ง Base64 Data URL และรูปภาพ Network ทั่วไป
  Widget _buildMenuThumbnail(String? url, {double width = 65, double height = 65}) {
    if (url == null || url.trim().isEmpty) {
      return _fallbackNoImage(width, height);
    }
    if (url.startsWith('data:image')) {
      try {
        final base64String = url.split(',').last;
        final bytes = base64Decode(base64String);
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            bytes,
            width: width,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _fallbackNoImage(width, height),
          ),
        );
      } catch (_) {}
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        url,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallbackNoImage(width, height),
      ),
    );
  }

  /// แสดงพื้นที่สีเทาพร้อมไอคอนกล้องถ่ายรูปกรณีเมนูไม่มีรูปภาพ
  Widget _fallbackNoImage(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 0.5),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              color: const Color(0xFF94A3B8),
              size: width * 0.38,
            ),
            if (width >= 60) ...[
              const SizedBox(height: 2),
              const Text(
                'ไม่มีรูป',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// เปิดหน้าจอเพิ่มเมนูใหม่ (สอดคล้องกับภาพที่ 3 และ 4)
  Future<void> _showAddMenuDialog() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => OwnerEditMenuItemScreen(
          restaurantId: widget.restaurantId,
          allCategories: _allCategories,
          catNameToId: _catNameToId,
        ),
      ),
    );

    if (result != null && result['saved'] == true) {
      final newItem = result['item'] as Map<String, dynamic>?;
      if (newItem != null) {
        final cat = newItem['category']?.toString() ?? 'ข้าว';
        setState(() {
          if (!_allCategories.contains(cat)) {
            _allCategories.add(cat);
          }
          _menuItems.insert(0, newItem);
          _selectedCategory = cat;
        });
      }
      if (widget.restaurantId != null) {
        _loadMenuItems();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('เพิ่มเมนูสำเร็จ'),
            backgroundColor: kOwnerPrimaryColor,
          ),
        );
      }
    }
  }

  /// เปิดหน้าจอแก้ไขข้อมูลเมนูอาหาร (สอดคล้องกับภาพที่ 3 และ 4)
  Future<void> _showEditMenuDialog(int index) async {
    final item = _menuItems[index];
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => OwnerEditMenuItemScreen(
          restaurantId: widget.restaurantId,
          itemToEdit: item,
          allCategories: _allCategories,
          catNameToId: _catNameToId,
          selectedCategory: item['category']?.toString(),
        ),
      ),
    );

    if (result != null && result['saved'] == true) {
      final updatedItem = result['item'] as Map<String, dynamic>?;
      if (updatedItem != null) {
        final cat = updatedItem['category']?.toString() ?? item['category']?.toString() ?? 'ข้าว';
        setState(() {
          if (!_allCategories.contains(cat)) {
            _allCategories.add(cat);
          }
          item['name'] = updatedItem['name'] ?? item['name'];
          item['price'] = updatedItem['price'] ?? item['price'];
          item['image'] = updatedItem['image'] ?? item['image'];
          item['image_url'] = updatedItem['image_url'] ?? item['image_url'];
          item['category'] = cat;
          _selectedCategory = cat;
        });
      }
      if (widget.restaurantId != null) {
        _loadMenuItems();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('อัปเดตข้อมูลเมนูสำเร็จ'),
            backgroundColor: kOwnerPrimaryColor,
          ),
        );
      }
    }
  }

  /// ลบเมนูอาหารออกจากตาราง menu_items
  Future<void> _deleteMenuItem(int index) async {
    final item = _menuItems[index];
    final itemId = item['id']?.toString();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('ยืนยันการลบเมนู'),
        content: Text('คุณต้องการลบเมนู "${item['name']}" ใช่หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('ลบเมนู'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (itemId != null && !itemId.startsWith('mock-')) {
      try {
        // 1. ลบความสัมพันธ์ในตาราง menu_item_categories ก่อนเพื่อป้องกัน foreign key error
        try {
          await Supabase.instance.client
              .from('menu_item_categories')
              .delete()
              .eq('menu_item_id', itemId);
        } catch (e) {
          debugPrint('Note: Error deleting menu_item_categories: $e');
        }

        // 2. ลบเมนูอาหารออกจากตาราง menu_items ในฐานข้อมูลจริง
        await Supabase.instance.client
            .from('menu_items')
            .delete()
            .eq('id', itemId);
      } catch (e) {
        debugPrint('Error deleting menu item from Supabase: $e');
      }
    }

    if (mounted) {
      setState(() {
        _menuItems.removeAt(index);
        if (!_displayedCategories.contains(_selectedCategory)) {
          _selectedCategory = 'ทั้งหมด';
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ลบเมนูออกจากฐานข้อมูลเรียบร้อยแล้ว'),
          backgroundColor: kOwnerPrimaryColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayedCats = _displayedCategories;
    final currentSelected = displayedCats.contains(_selectedCategory)
        ? _selectedCategory
        : 'ทั้งหมด';

    final filteredList = currentSelected == 'ทั้งหมด'
        ? _menuItems
        : _menuItems.where((item) {
            final cat = item['category']?.toString();
            final cats = item['categories'];
            if (cats is List && cats.map((e) => e.toString()).contains(currentSelected)) {
              return true;
            }
            return cat == currentSelected;
          }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        backgroundColor: kOwnerPrimaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'จัดการเมนูอาหาร',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMenuDialog,
        backgroundColor: kOwnerPrimaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('เพิ่มเมนู', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: kOwnerPrimaryColor),
            )
          : RefreshIndicator(
              onRefresh: _loadMenuItems,
              color: kOwnerPrimaryColor,
              child: Column(
                children: [
                  // แถบเลือกหมวดหมู่อาหาร (Horizontal Chips)
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                            onTap: () => setState(() => _selectedCategory = catName),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? kOwnerPrimaryColor : Colors.grey[100],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                catName,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.grey[700],
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 13.5,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // รายการเมนู
                  Expanded(
                    child: filteredList.isEmpty
                        ? Center(
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.restaurant_menu_rounded, size: 70, color: Colors.grey[300]),
                                  const SizedBox(height: 12),
                                  Text(
                                    'ยังไม่มีเมนูอาหารในร้านนี้',
                                    style: TextStyle(color: Colors.grey[600], fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton.icon(
                                    onPressed: _showAddMenuDialog,
                                    icon: const Icon(Icons.add, size: 18),
                                    label: const Text('เพิ่มเมนูแรกของคุณ'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: kOwnerPrimaryColor,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
                            itemCount: filteredList.length,
                            itemBuilder: (context, index) {
                              final item = filteredList[index];
                              final isAvailable = item['isAvailable'] as bool? ?? true;
                              final originalIndex = _menuItems.indexOf(item);

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey.shade200),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    _buildMenuThumbnail(item['image'] ?? item['image_url']),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['name'],
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '฿${(item['price'] as num).toStringAsFixed(0)}',
                                            style: const TextStyle(
                                              color: kOwnerPrimaryColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.grey),
                                      onPressed: () => _showEditMenuDialog(originalIndex >= 0 ? originalIndex : index),
                                      tooltip: 'แก้ไข',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.redAccent),
                                      onPressed: () => _deleteMenuItem(originalIndex >= 0 ? originalIndex : index),
                                      tooltip: 'ลบ',
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Switch(
                                          value: isAvailable,
                                          activeColor: kOwnerPrimaryColor,
                                          onChanged: (val) async {
                                            setState(() {
                                              item['isAvailable'] = val;
                                            });
                                            final itemId = item['id']?.toString();
                                            if (itemId != null && itemId.isNotEmpty) {
                                              await MenuAvailabilityManager.updateAvailabilityInDatabase(itemId, val);
                                            }
                                          },
                                        ),
                                        Text(
                                          isAvailable ? 'เปิดขาย' : 'สินค้าหมด',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isAvailable ? Colors.green : Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
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
}
