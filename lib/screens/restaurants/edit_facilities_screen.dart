import 'package:flutter/material.dart';

class FacilityItem {
  final String name;
  final IconData icon;

  const FacilityItem({
    required this.name,
    required this.icon,
  });
}

class EditFacilitiesScreen extends StatefulWidget {
  final List<String> initialFacilities;

  const EditFacilitiesScreen({
    super.key,
    required this.initialFacilities,
  });

  @override
  State<EditFacilitiesScreen> createState() => _EditFacilitiesScreenState();
}

class _EditFacilitiesScreenState extends State<EditFacilitiesScreen> {
  static const Color maroonColor = Color(0xFF82152B);
  static const Color selectedBgColor = Color(0xFFF6E6EB);
  static const Color selectedBorderColor = Color(0xFFE6BDC8);
  static const Color unselectedBorderColor = Color(0xFFE5E7EB);
  static const Color bottomPillBg = Color(0xFFE8CFD6);

  // 16 standard facility items matching requirements and Figma design
  static const List<FacilityItem> allFacilities = [
    FacilityItem(name: 'มีปลั๊กไฟ', icon: Icons.power),
    FacilityItem(name: 'มีอินเทอร์เน็ต', icon: Icons.wifi),
    FacilityItem(name: 'ที่จอดรถยนต์', icon: Icons.directions_car),
    FacilityItem(name: 'รถจักรยานยนต์', icon: Icons.two_wheeler),
    FacilityItem(name: 'รับบัตรเครดิต', icon: Icons.credit_card),
    FacilityItem(name: 'เดลิเวอรี่', icon: Icons.delivery_dining),
    FacilityItem(name: 'เครื่องปรับอากาศ', icon: Icons.ac_unit),
    FacilityItem(name: 'มีห้องน้ำ', icon: Icons.wc),
    FacilityItem(name: 'เหมาะสำหรับกลุ่ม', icon: Icons.groups_outlined),
    FacilityItem(name: 'เหมาะกับเด็ก', icon: Icons.child_care),
    FacilityItem(name: 'Pet Friendly', icon: Icons.pets),
    FacilityItem(name: 'รับบัตรสวัสดิการ', icon: Icons.card_membership),
    FacilityItem(name: 'เพลงเพราะ', icon: Icons.music_note),
    FacilityItem(name: 'พื้นที่สนามเด็กเล่น', icon: Icons.toys),
    FacilityItem(name: 'เหมาะกับผู้พิการ', icon: Icons.accessible),
    FacilityItem(name: 'มุมถ่ายรูป', icon: Icons.camera_alt),
  ];

  late Set<String> _selectedFacilities;

  @override
  void initState() {
    super.initState();
    // Normalize existing data to match standard names
    _selectedFacilities = widget.initialFacilities.map((name) {
      if (name == 'เหมาะกับกลุ่ม') return 'เหมาะสำหรับกลุ่ม';
      if (name == 'ที่จอดรถ') return 'ที่จอดรถยนต์';
      if (name == 'บริการส่งอาหาร') return 'เดลิเวอรี่';
      if (name == 'รับบัตรเครดิต/สแกนจ่าย') return 'รับบัตรเครดิต';
      if (name == 'ดนตรีสด') return 'เพลงเพราะ';
      return name;
    }).toSet();
  }

  void _toggleFacility(String name) {
    setState(() {
      if (_selectedFacilities.contains(name)) {
        _selectedFacilities.remove(name);
      } else {
        _selectedFacilities.add(name);
      }
    });
  }

  void _onSave() {
    if (_selectedFacilities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาเลือกรายการ'),
          backgroundColor: maroonColor,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Preserve standard 16-item canonical order
    final orderedResult = allFacilities
        .map((item) => item.name)
        .where((name) => _selectedFacilities.contains(name))
        .toList();

    Navigator.of(context).pop(orderedResult);
  }

  void _onCancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: maroonColor,
        elevation: 0,
        leadingWidth: 260,
        leading: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
              onPressed: _onCancel,
            ),
            const Text(
              'แก้ไขสิ่งอำนวยความสะดวก',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _onSave,
            child: const Text(
              'บันทึก',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subheader
                    const Text(
                      'เลือกสิ่งอำนวยความสะดวกที่มีในร้าน (เลือกได้หลายรายการ)',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 4-Column Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: allFacilities.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.84,
                      ),
                      itemBuilder: (context, index) {
                        final item = allFacilities[index];
                        final isSelected = _selectedFacilities.contains(item.name);

                        return GestureDetector(
                          onTap: () => _toggleFacility(item.name),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            decoration: BoxDecoration(
                              color: isSelected ? selectedBgColor : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? selectedBorderColor : unselectedBorderColor,
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected
                                      ? maroonColor.withOpacity(0.06)
                                      : Colors.black.withOpacity(0.03),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  item.icon,
                                  color: maroonColor,
                                  size: 28,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item.name,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                    color: isSelected ? maroonColor : const Color(0xFF374151),
                                    height: 1.15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom Summary Bar matching Figma
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: bottomPillBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: _selectedFacilities.isNotEmpty
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: maroonColor,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 13,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'เลือกแล้ว ${_selectedFacilities.length} รายการ',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      )
                    : const Text(
                        'กรุณาเลือกรายการ',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280),
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
