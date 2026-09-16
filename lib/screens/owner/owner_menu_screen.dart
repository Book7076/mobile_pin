import 'package:flutter/material.dart';

const Color kOwnerPrimaryColor = Color(0xFF7C1431);

class OwnerMenuScreen extends StatefulWidget {
  const OwnerMenuScreen({super.key});

  @override
  State<OwnerMenuScreen> createState() => _OwnerMenuScreenState();
}

class _OwnerMenuScreenState extends State<OwnerMenuScreen> {
  int _selectedCategory = 0;
  final List<String> _categories = ['ทั้งหมด', 'ไก่ทอด', 'อาหารจานเดียว', 'ของทานเล่น', 'เครื่องดื่ม'];

  // ตัวอย่างรายการเมนู
  final List<Map<String, dynamic>> _menuItems = [
    {
      'name': 'ไก่ทอดซอสเกาหลี (เซ็ตใหญ่)',
      'category': 'ไก่ทอด',
      'price': 199,
      'isAvailable': true,
      'image': 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=200&auto=format&fit=crop&q=80',
    },
    {
      'name': 'ไก่ป๊อปสไปซี่',
      'category': 'ไก่ทอด',
      'price': 69,
      'isAvailable': true,
      'image': 'https://images.unsplash.com/photo-1562967914-608f82629710?w=200&auto=format&fit=crop&q=80',
    },
    {
      'name': 'ข้าวหน้าไก่ทอดซอสเทอริยากิ',
      'category': 'อาหารจานเดียว',
      'price': 89,
      'isAvailable': true,
      'image': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=200&auto=format&fit=crop&q=80',
    },
    {
      'name': 'เฟรนช์ฟรายส์ชีส',
      'category': 'ของทานเล่น',
      'price': 59,
      'isAvailable': false,
      'image': 'https://images.unsplash.com/photo-1576107232684-1279f3908594?w=200&auto=format&fit=crop&q=80',
    },
    {
      'name': 'ชาไทยเย็นหวานน้อย',
      'category': 'เครื่องดื่ม',
      'price': 45,
      'isAvailable': true,
      'image': 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=200&auto=format&fit=crop&q=80',
    },
  ];

  void _showAddMenuDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();

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
              const Text(
                'เพิ่มเมนูใหม่',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kOwnerPrimaryColor),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'ชื่อเมนูอาหาร',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'ราคา (บาท)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty && priceController.text.isNotEmpty) {
                      setState(() {
                        _menuItems.add({
                          'name': nameController.text.trim(),
                          'category': 'ไก่ทอด',
                          'price': int.tryParse(priceController.text) ?? 0,
                          'isAvailable': true,
                          'image': 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=200&auto=format&fit=crop&q=80',
                        });
                      });
                      Navigator.pop(context);
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
        title: const Text(
          'จัดการเมนูอาหาร',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
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
      body: Column(
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
            child: ListView.builder(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final item = filteredList[index];
                final isAvailable = item['isAvailable'] as bool;

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
                          item['image'],
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
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '฿${item['price']}',
                              style: const TextStyle(
                                color: kOwnerPrimaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
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
    );
  }
}
