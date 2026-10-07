import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const Color kOwnerPrimaryColor = Color(0xFF7C1431);

class AmenityOption {
  final String label;
  final IconData icon;

  const AmenityOption(this.label, this.icon);
}

/// รายการสิ่งอำนวยความสะดวกทั้ง 16 รายการ เรียงตาม Mockup 4 แถว x 4 คอลัมน์
final List<AmenityOption> kAllAmenityOptions = [
  // แถวที่ 1
  const AmenityOption('มีปลั๊กไฟ', Icons.power_rounded),
  const AmenityOption('มีอินเทอร์เน็ต', Icons.wifi_rounded),
  const AmenityOption('ที่จอดรถยนต์', Icons.directions_car_rounded),
  const AmenityOption('รถจักรยานยนต์', Icons.two_wheeler_rounded),

  // แถวที่ 2
  const AmenityOption('รับบัตรเครดิต', Icons.credit_card_rounded),
  const AmenityOption('เดลิเวอรี่', Icons.delivery_dining_rounded),
  const AmenityOption('เครื่องปรับอากาศ', Icons.ac_unit_rounded),
  const AmenityOption('มีห้องน้ำ', Icons.favorite_border_rounded),

  // แถวที่ 3
  const AmenityOption('เหมาะกับกลุ่ม', Icons.groups_rounded),
  const AmenityOption('เหมาะกับเด็ก', Icons.child_care_rounded),
  const AmenityOption('Pet Friendly', Icons.pets_rounded),
  const AmenityOption('พื้นที่สังสรรค์', Icons.sports_bar_rounded),

  // แถวที่ 4
  const AmenityOption('เพลงเพราะ', Icons.music_note_rounded),
  const AmenityOption('พื้นที่สนทนา', Icons.record_voice_over_rounded),
  const AmenityOption('เหมาะกับผู้พิการ', Icons.accessible_rounded),
  const AmenityOption('มุมถ่ายรูป', Icons.photo_camera_rounded),
];

class OwnerEditAmenitiesScreen extends StatefulWidget {
  final String? restaurantId;
  final List<String> initialAmenities;

  const OwnerEditAmenitiesScreen({
    super.key,
    this.restaurantId,
    this.initialAmenities = const [
      'มีปลั๊กไฟ',
      'มีอินเทอร์เน็ต',
      'เครื่องปรับอากาศ',
      'มีห้องน้ำ',
      'เหมาะกับกลุ่ม',
    ],
  });

  @override
  State<OwnerEditAmenitiesScreen> createState() => _OwnerEditAmenitiesScreenState();
}

class _OwnerEditAmenitiesScreenState extends State<OwnerEditAmenitiesScreen> {
  late final Set<String> _selectedAmenities;

  @override
  void initState() {
    super.initState();
    _selectedAmenities = Set<String>.from(widget.initialAmenities);
  }

  void _toggleAmenity(String label) {
    setState(() {
      if (_selectedAmenities.contains(label)) {
        _selectedAmenities.remove(label);
      } else {
        _selectedAmenities.add(label);
      }
    });
  }

  void _saveAndPop() async {
    final list = _selectedAmenities.toList();
    if (widget.restaurantId != null) {
      try {
        await Supabase.instance.client
            .from('restaurants')
            .update({'amenities': list})
            .eq('id', widget.restaurantId!);
      } catch (_) {}
    }

    if (mounted) {
      Navigator.pop(context, list);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: kOwnerPrimaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 34),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'แก้ไขสิ่งอำนวยความสะดวก',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 19,
            letterSpacing: 0.2,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: TextButton(
              onPressed: _saveAndPop,
              child: const Text(
                'บันทึก',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.5,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // คำอธิบายหัวข้อ
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 14),
              child: Text(
                'เลือกสิ่งอำนวยความสะดวกที่มีในร้าน (เลือกได้หลายรายการ)',
                style: TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),

            // ตารางไอคอน 4 แถว x 4 คอลัมน์
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.88,
                  ),
                  itemCount: kAllAmenityOptions.length,
                  itemBuilder: (context, index) {
                    final item = kAllAmenityOptions[index];
                    final isSelected = _selectedAmenities.contains(item.label);

                    return _buildAmenityCard(
                      option: item,
                      isSelected: isSelected,
                      onTap: () => _toggleAmenity(item.label),
                    );
                  },
                ),
              ),
            ),

            // ปุ่มแสดงจำนวนรายการที่เลือกด้านล่าง
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
              child: InkWell(
                onTap: _saveAndPop,
                borderRadius: BorderRadius.circular(28),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD6B5BC),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: kOwnerPrimaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(Icons.check, color: Colors.white, size: 16),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'เลือกแล้ว ${_selectedAmenities.length} รายการ',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF262626),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmenityCard({
    required AmenityOption option,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEAD4D8) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? const Color(0xFFDFB8C1) : const Color(0xFFF2E6E8),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isSelected ? 0.03 : 0.05),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                option.icon,
                color: kOwnerPrimaryColor,
                size: 30,
              ),
              const SizedBox(height: 6),
              Text(
                option.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: kOwnerPrimaryColor,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
