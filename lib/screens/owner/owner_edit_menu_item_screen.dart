import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../widgets/image_crop_screen.dart';

const Color kHeaderBurgundy = Color(0xFF8B1E3F);

/// Screen for adding and editing a menu item.
/// Aligned strictly with database tables (categories, menu_items, menu_item_categories).
class OwnerEditMenuItemScreen extends StatefulWidget {
  final String? restaurantId;
  final Map<String, dynamic>? itemToEdit;
  final List<String> allCategories;
  final Map<String, String> catNameToId;
  final String? selectedCategory;

  const OwnerEditMenuItemScreen({
    super.key,
    this.restaurantId,
    this.itemToEdit,
    this.allCategories = const [],
    this.catNameToId = const {},
    this.selectedCategory,
  });

  @override
  State<OwnerEditMenuItemScreen> createState() => _OwnerEditMenuItemScreenState();
}

class _OwnerEditMenuItemScreenState extends State<OwnerEditMenuItemScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  bool _isSaving = false;
  String _selectedImageUrl = '';
  late List<String> _categories;
  final Set<String> _selectedCategories = {};
  late Map<String, String> _localCatNameToId;

  // รายการหมวดหมู่หลักตามลำดับใน Database (ตาราง categories: ข้าว 1, ของทอด 2, เมนูเส้น 3, เครื่องดื่ม 4, ของหวาน 5)
  static const List<String> _databaseDefaultCategories = [
    'ข้าว',
    'ของทอด',
    'เมนูเส้น',
    'เครื่องดื่ม',
    'ของหวาน',
  ];

  @override
  void initState() {
    super.initState();
    _localCatNameToId = Map.from(widget.catNameToId);

    // เรียงลำดับประเภทอาหารจากบนลงล่าง: ข้าว, ของทอด, เมนูเส้น, เครื่องดื่ม, ของหวาน
    final List<String> ordered = [];
    for (final defCat in _databaseDefaultCategories) {
      if (!ordered.contains(defCat)) {
        ordered.add(defCat);
      }
    }
    // เพิ่มหมวดหมู่อื่นๆ ที่มาจาก Database (ถ้ามี) ต่อท้าย
    for (final cat in widget.allCategories) {
      if (!_databaseDefaultCategories.contains(cat) && !ordered.contains(cat)) {
        ordered.add(cat);
      }
    }
    _categories = ordered;

    if (widget.itemToEdit != null) {
      final item = widget.itemToEdit!;
      _nameController.text = item['name']?.toString() ?? '';
      final priceVal = item['price'];
      if (priceVal != null) {
        _priceController.text = (priceVal is num && priceVal % 1 == 0)
            ? priceVal.toInt().toString()
            : priceVal.toString();
      }
      // รูปภาพตรงตามที่มีใน database
      _selectedImageUrl = item['image_url']?.toString() ??
          item['image']?.toString() ??
          '';

      // 1 เมนูสามารถมีได้หลายประเภท
      final cats = item['categories'];
      if (cats is List && cats.isNotEmpty) {
        for (final c in cats) {
          if (c != null && c.toString().isNotEmpty) {
            _selectedCategories.add(c.toString());
          }
        }
      } else {
        final cat = item['category']?.toString();
        if (cat != null && cat.isNotEmpty) {
          _selectedCategories.add(cat);
        }
      }
    } else {
      // โหมดเพิ่มเมนูใหม่: ไม่ใส่รูปแนะนำล่วงหน้า และไม่ติ๊กเลือกประเภทใดๆ ค้างไว้
      _selectedImageUrl = '';
      _selectedCategories.clear();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // --- การแสดงผลรูปภาพ (Image Widget Helper) ---
  Widget _buildImagePreview() {
    if (_selectedImageUrl.isEmpty) {
      return Container(
        width: 130,
        height: 130,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined, size: 36, color: Colors.grey.shade500),
            const SizedBox(height: 6),
            Text(
              'เพิ่มรูปภาพอาหาร',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    Widget imageWidget;
    if (_selectedImageUrl.startsWith('data:image')) {
      try {
        final base64Data = _selectedImageUrl.split(',').last;
        final bytes = base64Decode(base64Data);
        imageWidget = Image.memory(bytes, width: 130, height: 130, fit: BoxFit.cover);
      } catch (_) {
        imageWidget = _fallbackImagePlaceholder();
      }
    } else {
      imageWidget = Image.network(
        _selectedImageUrl,
        width: 130,
        height: 130,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallbackImagePlaceholder(),
      );
    }

    return Stack(
      children: [
        Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: imageWidget,
          ),
        ),
        Positioned(
          left: 6,
          bottom: 6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.65),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.camera_alt, color: Colors.white, size: 13),
                SizedBox(width: 4),
                Text(
                  'เปลี่ยนรูป',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          right: 6,
          top: 6,
          child: GestureDetector(
            onTap: _confirmDeleteImage,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.red.shade700.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// ป็อปอัพยืนยันการลบรูปภาพอาหาร
  Future<void> _confirmDeleteImage() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('ยืนยันลบรูปภาพ', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('คุณต้องการลบรูปภาพอาหารนี้ใช่หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('ลบรูปภาพ'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() {
        _selectedImageUrl = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ลบรูปภาพเรียบร้อยแล้ว'),
          backgroundColor: kHeaderBurgundy,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  Widget _fallbackImagePlaceholder() {
    return Container(
      width: 130,
      height: 130,
      color: Colors.grey.shade200,
      child: const Icon(Icons.fastfood, size: 40, color: Colors.grey),
    );
  }

  // --- เลือกรูปภาพ (เฉพาะกล้องและคลังภาพ ไม่ใส่ทางเลือก URL) ---
  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'เลือกรูปภาพอาหาร',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kHeaderBurgundy.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: kHeaderBurgundy),
                ),
                title: const Text('ถ่ายรูปภาพ', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('ถ่ายรูปอาหารจากกล้องของคุณ'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final picker = ImagePicker();
                  final picked = await picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 800,
                    maxHeight: 800,
                    imageQuality: 80,
                  );
                  if (picked != null) {
                    await _processPickedImage(picked);
                  }
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kHeaderBurgundy.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: kHeaderBurgundy),
                ),
                title: const Text('เลือกจากคลังรูปภาพ', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('เลือกรูปภาพจากเครื่องของคุณ'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final picker = ImagePicker();
                  final picked = await picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 800,
                    maxHeight: 800,
                    imageQuality: 80,
                  );
                  if (picked != null) {
                    await _processPickedImage(picked);
                  }
                },
              ),
              if (_selectedImageUrl.isNotEmpty) ...[
                const Divider(),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                  ),
                  title: const Text(
                    'ลบรูปภาพ',
                    style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red),
                  ),
                  subtitle: const Text('นำรูปภาพอาหารนี้ออก'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _confirmDeleteImage();
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _processPickedImage(XFile picked) async {
    try {
      final rawBytes = await picked.readAsBytes();
      if (!mounted) return;

      // 1. เปิดหน้าจอครอบตัดรูปภาพ (Image Crop Screen)
      final croppedBytes = await Navigator.push<Uint8List>(
        context,
        MaterialPageRoute(
          builder: (_) => ImageCropScreen(imageBytes: rawBytes),
        ),
      );

      // หากผู้ใช้กดยกเลิกการครอบตัด ให้คงสภาพรูปเดิมไว้
      if (croppedBytes == null) return;

      // 2. แปลงรูปที่ผ่านการครอบตัดแล้วเป็น Data URL เพื่อให้เป็นลิงก์ที่บันทึกลงใน database
      String convertedUrl = 'data:image/png;base64,${base64Encode(croppedBytes)}';

      // ลองอัปโหลดไปยัง Supabase storage ถ้ามี bucket พร้อมใช้งาน
      try {
        final fileName = 'menu_${DateTime.now().millisecondsSinceEpoch}.png';
        await Supabase.instance.client.storage.from('menu-images').uploadBinary(
          fileName,
          croppedBytes,
          fileOptions: const FileOptions(contentType: 'image/png', upsert: true),
        );
        final pubUrl = Supabase.instance.client.storage.from('menu-images').getPublicUrl(fileName);
        if (pubUrl.isNotEmpty) {
          convertedUrl = pubUrl;
        }
      } catch (_) {
        // ใช้ Data URL บันทึกลง database ได้อย่างสมบูรณ์
      }

      setState(() {
        _selectedImageUrl = convertedUrl;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ครอบตัดและเลือกรูปภาพเรียบร้อยแล้ว'),
            backgroundColor: kHeaderBurgundy,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error processing picked image: $e');
    }
  }

  // --- สร้างประเภทใหม่ และบันทึกลง categories ใน Database ---
  void _showAddCategoryDialog() {
    final catCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('สร้างประเภทอาหารใหม่', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: catCtrl,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'ชื่อประเภทอาหาร',
            hintText: 'เช่น สเต๊ก, ซุป, สลัด',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: kHeaderBurgundy, width: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ยกเลิก', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kHeaderBurgundy,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              final newCatName = catCtrl.text.trim();
              if (newCatName.isEmpty) return;

              Navigator.pop(ctx);

              // 1. อัปเดตลงตาราง categories ใน database ทันที
              if (widget.restaurantId != null) {
                try {
                  final nextSortOrder = _categories.length + 1;
                  final inserted = await Supabase.instance.client
                      .from('categories')
                      .insert({
                        'restaurant_id': widget.restaurantId,
                        'name': newCatName,
                        'sort_order': nextSortOrder,
                      })
                      .select('id, name, sort_order')
                      .maybeSingle();

                  if (inserted != null && inserted['id'] != null) {
                    _localCatNameToId[newCatName] = inserted['id'].toString();
                  }
                } catch (e) {
                  debugPrint('Error inserting new category to DB: $e');
                }
              }

              // 2. เพิ่มลงในรายการตัวเลือกและเลือกประเภทนี้ให้อัตโนมัติ
              setState(() {
                if (!_categories.contains(newCatName)) {
                  _categories.add(newCatName);
                }
                _selectedCategories.add(newCatName);
              });
            },
            child: const Text('สร้างประเภท'),
          ),
        ],
      ),
    );
  }

  // --- บันทึกข้อมูลเข้า Database ตามเงื่อนไข ---
  Future<void> _saveMenu() async {
    final name = _nameController.text.trim();
    final priceStr = _priceController.text.trim();
    final price = double.tryParse(priceStr);

    // เงื่อนไข: จะต้องใส่ทั้งชื่ออาหาร และราคา เลือกประเภทเรียบร้อย ถ้าไม่มีอย่างใดอย่างหนึ่งไม่อนุญาตให้บันทึก
    final List<String> missing = [];
    if (name.isEmpty) missing.add('ชื่ออาหาร');
    if (priceStr.isEmpty || price == null || price <= 0) missing.add('ราคาอาหาร');
    if (_selectedCategories.isEmpty) missing.add('เลือกประเภทอาหารอย่างน้อย 1 ประเภท');

    if (missing.isNotEmpty) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('กรุณาระบุข้อมูลให้ครบ: ${missing.join(', ')}'),
          backgroundColor: kHeaderBurgundy,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final isEditing = widget.itemToEdit != null;
      final existingId = widget.itemToEdit?['id']?.toString();

      if (widget.restaurantId != null) {
        if (isEditing && existingId != null && !existingId.startsWith('mock-')) {
          // 1. อัปเดตข้อมูลตาราง menu_items
          await Supabase.instance.client.from('menu_items').update({
            'name': name,
            'price': price,
            'image_url': _selectedImageUrl,
            'updated_at': DateTime.now().toIso8601String(),
          }).eq('id', existingId);

          // 2. อัปเดตประเภทอาหารในตาราง menu_item_categories (1 เมนูมีได้หลายประเภท)
          try {
            await Supabase.instance.client
                .from('menu_item_categories')
                .delete()
                .eq('menu_item_id', existingId);

            for (final catName in _selectedCategories) {
              final catId = _localCatNameToId[catName];
              if (catId != null) {
                await Supabase.instance.client.from('menu_item_categories').insert({
                  'menu_item_id': existingId,
                  'category_id': catId,
                });
              }
            }
          } catch (e) {
            debugPrint('Note: Error updating menu_item_categories: $e');
          }
        } else {
          // 1. เพิ่มรายการใหม่ในตาราง menu_items
          final insertData = {
            'restaurant_id': widget.restaurantId,
            'name': name,
            'price': price,
            'image_url': _selectedImageUrl,
          };

          final inserted = await Supabase.instance.client
              .from('menu_items')
              .insert(insertData)
              .select()
              .maybeSingle();

          if (inserted != null) {
            final newId = inserted['id']?.toString();
            if (newId != null) {
              // 2. บันทึกประเภทอาหารทั้งหมดที่เลือกลงใน menu_item_categories
              for (final catName in _selectedCategories) {
                final catId = _localCatNameToId[catName];
                if (catId != null) {
                  try {
                    await Supabase.instance.client.from('menu_item_categories').insert({
                      'menu_item_id': newId,
                      'category_id': catId,
                    });
                  } catch (_) {}
                }
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error saving menu to Supabase: $e');
    }

    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.pop(context, {
        'saved': true,
        'item': {
          'id': widget.itemToEdit?['id'] ?? UniqueKey().toString(),
          'name': name,
          'price': price,
          'image': _selectedImageUrl,
          'image_url': _selectedImageUrl,
          'category': _selectedCategories.first,
          'categories': _selectedCategories.toList(),
          'isAvailable': true,
        },
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.itemToEdit != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: kHeaderBurgundy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context), // ย้อนกลับเฉยๆ ไม่บันทึกอะไร
        ),
        title: Text(
          isEditing ? 'แก้ไขเมนู' : 'เพิ่มเมนูใหม่',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _isSaving ? null : _saveMenu,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.white.withOpacity(0.18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      'บันทึก',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- รูปภาพอาหาร ---
            Center(
              child: GestureDetector(
                onTap: _showImagePickerModal,
                child: _buildImagePreview(),
              ),
            ),
            const SizedBox(height: 24),

            // --- ชื่อเมนู ---
            const Text(
              'ชื่อเมนู',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'ชื่อเมนู',
                hintText: 'ชื่อเมนูอาหาร *',
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: kHeaderBurgundy, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- ราคา ---
            const Text(
              'ราคา',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'ราคา (บาท) *',
                hintText: 'เช่น 89',
                prefixIcon: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Text(
                    '฿',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide(color: kHeaderBurgundy, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- ประเภทอาหาร (ตาม Database: ข้าว, ของทอด, เมนูเส้น, เครื่องดื่ม, ของหวาน) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ประเภทอาหาร',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'เลือกได้หลายประเภท',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            ..._categories.map((cat) {
              final isChecked = _selectedCategories.contains(cat);
              return InkWell(
                onTap: () {
                  setState(() {
                    if (isChecked) {
                      _selectedCategories.remove(cat);
                    } else {
                      _selectedCategories.add(cat);
                    }
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: isChecked,
                          activeColor: kHeaderBurgundy,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          side: BorderSide(
                            color: isChecked ? kHeaderBurgundy : Colors.grey.shade400,
                          ),
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                _selectedCategories.add(cat);
                              } else {
                                _selectedCategories.remove(cat);
                              }
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        cat,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                          fontWeight: isChecked ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 14),

            // ปุ่มสร้างประเภทใหม่
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                onPressed: _showAddCategoryDialog,
                icon: const Icon(Icons.add, size: 18, color: kHeaderBurgundy),
                label: const Text(
                  'สร้างประเภท',
                  style: TextStyle(
                    color: kHeaderBurgundy,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: kHeaderBurgundy.withOpacity(0.04),
                  side: BorderSide(color: kHeaderBurgundy.withOpacity(0.3)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
