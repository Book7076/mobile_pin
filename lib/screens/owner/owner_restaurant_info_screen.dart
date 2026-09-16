import 'package:flutter/material.dart';

const Color kOwnerPrimaryColor = Color(0xFF7C1431);

class OwnerRestaurantInfoScreen extends StatefulWidget {
  const OwnerRestaurantInfoScreen({super.key});

  @override
  State<OwnerRestaurantInfoScreen> createState() => _OwnerRestaurantInfoScreenState();
}

class _OwnerRestaurantInfoScreenState extends State<OwnerRestaurantInfoScreen> {
  final _nameController = TextEditingController(text: 'The CHICKEN');
  final _categoryController = TextEditingController(text: 'ไก่ทอดและอาหารเกาหลี');
  final _addressController = TextEditingController(text: '123/45 ถนนสุขุมวิท แขวงคลองเตย เขตคลองเตย กรุงเทพฯ 10110');
  final _phoneController = TextEditingController(text: '081-234-5678');
  final _hoursController = TextEditingController(text: '10:00 - 21:30 น. (เปิดทุกวัน)');

  bool _isEditing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          'ข้อมูลร้านค้า',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check_rounded : Icons.edit_rounded, color: Colors.white),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
              if (!_isEditing) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('บันทึกข้อมูลเรียบร้อยแล้ว'),
                    backgroundColor: kOwnerPrimaryColor,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // ป้ายโปรไฟล์ร้าน
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: kOwnerPrimaryColor, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const ClipOval(
                      child: Image(
                        image: NetworkImage(
                          'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?w=300&auto=format&fit=crop&q=80',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: kOwnerPrimaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ช่องกรอกข้อมูลต่างๆ
            _buildInfoCard(
              title: 'ชื่อร้านอาหาร',
              controller: _nameController,
              icon: Icons.store_rounded,
              enabled: _isEditing,
            ),
            const SizedBox(height: 14),
            _buildInfoCard(
              title: 'หมวดหมู่ร้านค้า',
              controller: _categoryController,
              icon: Icons.category_rounded,
              enabled: _isEditing,
            ),
            const SizedBox(height: 14),
            _buildInfoCard(
              title: 'ที่อยู่ร้านอาหาร',
              controller: _addressController,
              icon: Icons.location_on_rounded,
              maxLines: 2,
              enabled: _isEditing,
            ),
            const SizedBox(height: 14),
            _buildInfoCard(
              title: 'เบอร์โทรศัพท์ติดต่อ',
              controller: _phoneController,
              icon: Icons.phone_rounded,
              enabled: _isEditing,
            ),
            const SizedBox(height: 14),
            _buildInfoCard(
              title: 'เวลาเปิด - ปิดทำการ',
              controller: _hoursController,
              icon: Icons.access_time_filled_rounded,
              enabled: _isEditing,
            ),

            const SizedBox(height: 32),

            if (_isEditing)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => _isEditing = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('บันทึกข้อมูลเรียบร้อยแล้ว'),
                        backgroundColor: kOwnerPrimaryColor,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kOwnerPrimaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('บันทึกการเปลี่ยนแปลง', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required TextEditingController controller,
    required IconData icon,
    required bool enabled,
    int maxLines = 1,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: kOwnerPrimaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            enabled: enabled,
            maxLines: maxLines,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 4),
              border: enabled ? const UnderlineInputBorder() : InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }
}
