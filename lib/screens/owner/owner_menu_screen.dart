import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const Color kOwnerPrimaryColor = Color(0xFF7C1431);

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
  int _selectedCategory = 0;
  final List<String> _categories = ['ทั้งหมด', 'ไก่ทอด', 'อาหารจานเดียว', 'ของทานเล่น', 'เครื่องดื่ม'];
  bool _isLoading = false;

  // ตัวอย่างรายการเมนูสำรองกรณี Offline หรือยังไม่มีข้อมูลใน DB
  static final List<Map<String, dynamic>> _defaultMockItems = [
    {
      'id': 'mock-1',
      'name': 'ไก่ทอดซอสเกาหลี (เซ็ตใหญ่)',
      'category': 'ไก่ทอด',
      'price': 199.0,
      'isAvailable': true,
      'image': 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=200&auto=format&fit=crop&q=80',
    },
    {
      'id': 'mock-2',
      'name': 'ไก่ป๊อปสไปซี่',
      'category': 'ไก่ทอด',
      'price': 69.0,
      'isAvailable': true,
      'image': 'https://images.unsplash.com/photo-1562967914-608f82629710?w=200&auto=format&fit=crop&q=80',
    },
    {
      'id': 'mock-3',
      'name': 'ข้าวหน้าไก่ทอดซอสเทอริยากิ',
      'category': 'อาหารจานเดียว',
      'price': 89.0,
      'isAvailable': true,
      'image': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=200&auto=format&fit=crop&q=80',
    },
    {
      'id': 'mock-4',
      'name': 'เฟรนช์ฟรายส์ชีส',
      'category': 'ของทานเล่น',
      'price': 59.0,
      'isAvailable': false,
      'image': 'https://images.unsplash.com/photo-1576107232684-1279f3908594?w=200&auto=format&fit=crop&q=80',
    },
    {
      'id': 'mock-5',
      'name': 'ชาไทยเย็นหวานน้อย',
      'category': 'เครื่องดื่ม',
      'price': 45.0,
      'isAvailable': true,
      'image': 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=200&auto=format&fit=crop&q=80',
    },
  ];

  List<Map<String, dynamic>> _menuItems = [];

  @override
  void initState() {
    super.initState();
    _loadMenuItems();
  }

  /// โหลดข้อมูลเมนูจากตาราง menu_items ใน Supabase
  Future<void> _loadMenuItems() async {
    if (widget.restaurantId == null) {
      setState(() {
        _menuItems = List.from(_defaultMockItems);
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await Supabase.instance.client
          .from('menu_items')
          .select()
          .eq('restaurant_id', widget.restaurantId!);

      if (response.isNotEmpty) {
        final List<Map<String, dynamic>> loaded = [];
        for (final row in response) {
          loaded.add({
            'id': row['id']?.toString() ?? '',
            'restaurant_id': row['restaurant_id']?.toString() ?? '',
            'name': row['name']?.toString() ?? '',
            'category': 'ทั้งหมด',
            'price': (row['price'] as num?)?.toDouble() ?? 0.0,
            'isAvailable': true,
            'image': (row['image_url'] != null && row['image_url'].toString().isNotEmpty)
                ? row['image_url'].toString()
                : 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=200&auto=format&fit=crop&q=80',
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

  /// เพิ่มเมนูใหม่ลงในตาราง menu_items ใน Supabase
  void _showAddMenuDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final imageController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
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
                    'เพิ่มเมนูใหม่',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kOwnerPrimaryColor),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'ชื่อเมนูอาหาร *',
                  hintText: 'เช่น ไก่ทอดซอสเกาหลี',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'ราคา (บาท) *',
                  hintText: 'เช่น 89',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: imageController,
                decoration: InputDecoration(
                  labelText: 'ลิงก์รูปภาพ (ไม่บังคับ)',
                  hintText: 'https://...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final price = double.tryParse(priceController.text.trim()) ?? 0.0;
                    final imgUrl = imageController.text.trim().isNotEmpty
                        ? imageController.text.trim()
                        : 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=200&auto=format&fit=crop&q=80';

                    if (name.isEmpty || priceController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('กรุณากรอกชื่อและราคาอาหาร')),
                      );
                      return;
                    }

                    Navigator.pop(context);

                    if (widget.restaurantId != null) {
                      try {
                        final insertData = {
                          'restaurant_id': widget.restaurantId,
                          'name': name,
                          'price': price,
                          'image_url': imgUrl,
                        };

                        final inserted = await Supabase.instance.client
                            .from('menu_items')
                            .insert(insertData)
                            .select()
                            .maybeSingle();

                        if (inserted != null && mounted) {
                          setState(() {
                            _menuItems.insert(0, {
                              'id': inserted['id']?.toString() ?? UniqueKey().toString(),
                              'restaurant_id': widget.restaurantId,
                              'name': name,
                              'price': price,
                              'image': imgUrl,
                              'isAvailable': true,
                              'category': 'ไก่ทอด',
                            });
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('เพิ่มเมนูสำเร็จ'),
                              backgroundColor: kOwnerPrimaryColor,
                            ),
                          );
                          return;
                        }
                      } catch (e) {
                        debugPrint('Error inserting menu item to Supabase: $e');
                      }
                    }

                    // Fallback
                    if (mounted) {
                      setState(() {
                        _menuItems.insert(0, {
                          'id': UniqueKey().toString(),
                          'name': name,
                          'category': 'ไก่ทอด',
                          'price': price,
                          'isAvailable': true,
                          'image': imgUrl,
                        });
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('เพิ่มเมนูเรียบร้อยแล้ว'),
                          backgroundColor: kOwnerPrimaryColor,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kOwnerPrimaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('บันทึกเมนู', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// แก้ไขข้อมูลเมนูอาหาร
  void _showEditMenuDialog(int index) {
    final item = _menuItems[index];
    final nameController = TextEditingController(text: item['name']);
    final priceController = TextEditingController(text: (item['price'] as num).toInt().toString());
    final imageController = TextEditingController(text: item['image']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
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
                    'แก้ไขเมนูอาหาร',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kOwnerPrimaryColor),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'ชื่อเมนูอาหาร *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'ราคา (บาท) *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: imageController,
                decoration: InputDecoration(
                  labelText: 'ลิงก์รูปภาพ',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    final newName = nameController.text.trim();
                    final newPrice = double.tryParse(priceController.text.trim()) ?? (item['price'] as num).toDouble();
                    final newImage = imageController.text.trim().isNotEmpty ? imageController.text.trim() : item['image'];

                    if (newName.isEmpty) return;

                    Navigator.pop(context);

                    final itemId = item['id']?.toString();
                    if (itemId != null && !itemId.startsWith('mock-')) {
                      try {
                        await Supabase.instance.client.from('menu_items').update({
                          'name': newName,
                          'price': newPrice,
                          'image_url': newImage,
                        }).eq('id', itemId);
                      } catch (e) {
                        debugPrint('Error updating menu item in Supabase: $e');
                      }
                    }

                    if (mounted) {
                      setState(() {
                        item['name'] = newName;
                        item['price'] = newPrice;
                        item['image'] = newImage;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('อัปเดตข้อมูลเมนูสำเร็จ'),
                          backgroundColor: kOwnerPrimaryColor,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kOwnerPrimaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('บันทึกการแก้ไข', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        );
      },
    );
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
        await Supabase.instance.client.from('menu_items').delete().eq('id', itemId);
      } catch (e) {
        debugPrint('Error deleting menu item: $e');
      }
    }

    if (mounted) {
      setState(() {
        _menuItems.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ลบเมนูเรียบร้อยแล้ว'),
          backgroundColor: kOwnerPrimaryColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _selectedCategory == 0
        ? _menuItems
        : _menuItems.where((item) => item['category'] == _categories[_selectedCategory]).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        backgroundColor: kOwnerPrimaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'จัดการเมนูอาหาร (${widget.restaurantName})',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
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
                        itemCount: _categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final isSelected = _selectedCategory == index;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedCategory = index),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? kOwnerPrimaryColor : Colors.grey[100],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _categories[index],
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
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        item['image'] ?? '',
                                        width: 65,
                                        height: 65,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          width: 65,
                                          height: 65,
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.fastfood, color: Colors.grey),
                                        ),
                                      ),
                                    ),
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
                                          onChanged: (val) {
                                            setState(() {
                                              item['isAvailable'] = val;
                                            });
                                          },
                                        ),
                                        Text(
                                          isAvailable ? 'เปิดขาย' : 'หมด',
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
