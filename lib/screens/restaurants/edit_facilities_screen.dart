import 'package:flutter/material.dart';

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

  late List<String> _selectedFacilities;
  final TextEditingController _customFacilityController = TextEditingController();

  // All available facilities with their icons
  final List<Map<String, dynamic>> _allFacilities = [
    {'name': 'มีปลั๊กไฟ', 'icon': Icons.power},
    {'name': 'มีอินเทอร์เน็ต', 'icon': Icons.wifi},
    {'name': 'มีห้องน้ำ', 'icon': Icons.wc},
    {'name': 'เครื่องปรับอากาศ', 'icon': Icons.ac_unit},
    {'name': 'เหมาะกับกลุ่ม', 'icon': Icons.people_alt_outlined},
    {'name': 'ที่จอดรถ', 'icon': Icons.local_parking},
    {'name': 'บริการส่งอาหาร', 'icon': Icons.delivery_dining},
    {'name': 'รับบัตรเครดิต/สแกนจ่าย', 'icon': Icons.payment},
    {'name': 'รับจองโต๊ะล่วงหน้า', 'icon': Icons.book_online},
    {'name': 'ดนตรีสด', 'icon': Icons.music_note},
  ];

  @override
  void initState() {
    super.initState();
    _selectedFacilities = List<String>.from(widget.initialFacilities);

    // If initialFacilities had any custom items not in _allFacilities, add them
    for (final fac in widget.initialFacilities) {
      if (!_allFacilities.any((element) => element['name'] == fac)) {
        _allFacilities.add({'name': fac, 'icon': Icons.check_circle_outline});
      }
    }
  }

  @override
  void dispose() {
    _customFacilityController.dispose();
    super.dispose();
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

  void _addCustomFacility() {
    final text = _customFacilityController.text.trim();
    if (text.isEmpty) return;

    if (!_allFacilities.any((item) => item['name'] == text)) {
      setState(() {
        _allFacilities.add({'name': text, 'icon': Icons.check_circle_outline});
        _selectedFacilities.add(text);
      });
    } else if (!_selectedFacilities.contains(text)) {
      setState(() {
        _selectedFacilities.add(text);
      });
    }
    _customFacilityController.clear();
  }

  void _save() {
    Navigator.of(context).pop(_selectedFacilities);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'แก้ไขสิ่งอำนวยความสะดวก',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: maroonColor,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  const Text(
                    'เลือกสิ่งอำนวยความสะดวกของร้านคุณ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF222222),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'ข้อมูลนี้จะแสดงให้ลูกค้าเห็นในหน้ารายละเอียดร้านอาหาร',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Facilities List
                  ..._allFacilities.map((facility) {
                    final String name = facility['name'] as String;
                    final IconData icon = facility['icon'] as IconData;
                    final bool isSelected = _selectedFacilities.contains(name);

                    return Card(
                      elevation: 0,
                      color: isSelected ? maroonColor.withOpacity(0.06) : const Color(0xFFF9F9FB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected ? maroonColor : const Color(0xFFE5E7EB),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      margin: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _toggleFacility(name),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isSelected ? maroonColor.withOpacity(0.12) : Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  icon,
                                  color: isSelected ? maroonColor : Colors.grey[700],
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? maroonColor : const Color(0xFF2D3748),
                                  ),
                                ),
                              ),
                              Checkbox(
                                value: isSelected,
                                activeColor: maroonColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onChanged: (_) => _toggleFacility(name),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 16),
                  // Add custom facility input
                  const Text(
                    'เพิ่มสิ่งอำนวยความสะดวกอื่นๆ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF222222),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _customFacilityController,
                          decoration: InputDecoration(
                            hintText: 'พิมพ์สิ่งอำนวยความสะดวกเพิ่มเติม...',
                            hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                            filled: true,
                            fillColor: const Color(0xFFF3F4F6),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onSubmitted: (_) => _addCustomFacility(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _addCustomFacility,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: maroonColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        child: const Text('เพิ่ม'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Save Button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, -2),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: maroonColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'บันทึก',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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
