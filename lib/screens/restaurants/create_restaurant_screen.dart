import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../main.dart';
import '../../widgets/map_picker_widget.dart';

class CreateRestaurantScreen extends ConsumerStatefulWidget {
  const CreateRestaurantScreen({super.key});

  @override
  ConsumerState<CreateRestaurantScreen> createState() => _CreateRestaurantScreenState();
}

class _CreateRestaurantScreenState extends ConsumerState<CreateRestaurantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _menuController = TextEditingController();
  
  LatLng? _selectedLocation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  Future<void> _pickLocation() async {
    final selected = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(builder: (_) => const MapPickerScreen()),
    );
    if (selected != null) {
      setState(() {
        _selectedLocation = selected;
      });
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'กรุณาปักหมุดตำแหน่งที่ตั้งร้านค้าบนแผนที่',
            style: TextStyle(fontFamily: 'Prompt'),
          ),
          backgroundColor: const Color(0xFF6E162B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        await supabase.from('restaurants').insert({
          'owner_id': user.id,
          'name': _nameController.text.trim(),
          'address': _addressController.text.trim(),
          'phone': _phoneController.text.trim(),
          'email': _emailController.text.trim(),
          'menu': _menuController.text.trim(),
          'lat': _selectedLocation!.latitude,
          'lng': _selectedLocation!.longitude,
          'status': 'pending', // Waiting for admin approval
        });
      }

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            contentPadding: const EdgeInsets.all(24),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF7EAEC),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF6E162B),
                      size: 38,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'ลงทะเบียนร้านอาหารสำเร็จ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E1E1E),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'ข้อมูลร้านค้าของคุณถูกส่งเรียบร้อยแล้ว ทีมงานจะตรวจสอบและอนุมัติการแสดงผลภายใน 24 ชม.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF666666),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6E162B),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).pop();
                    },
                    child: const Text('ตกลง', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: const Color(0xFF6E162B),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _menuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header Burgundy
          Container(
            color: const Color(0xFF6E162B),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 14,
              bottom: 16,
              left: 14,
              right: 14,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.chevron_left_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const Expanded(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(right: 34),
                      child: Text(
                        'ลงทะเบียนร้านอาหาร',
                        style: TextStyle(
                          fontSize: 19.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Form
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF6E162B),
                    ),
                  )
                : Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildFieldLabel('ชื่อร้านอาหาร *'),
                        const SizedBox(height: 6),
                        _buildTextField(
                          controller: _nameController,
                          hintText: 'เช่น ข้าวซอยแม่สาย นิมมาน',
                          validator: (val) => val == null || val.trim().isEmpty ? 'กรุณาระบุชื่อร้านอาหาร' : null,
                        ),
                        const SizedBox(height: 18),

                        _buildFieldLabel('ที่อยู่ร้านค้า *'),
                        const SizedBox(height: 6),
                        _buildTextField(
                          controller: _addressController,
                          hintText: 'ระบุที่ตั้ง ถนน ซอย หรือจุดสังเกต',
                          validator: (val) => val == null || val.trim().isEmpty ? 'กรุณาระบุที่อยู่ร้าน' : null,
                        ),
                        const SizedBox(height: 18),

                        _buildFieldLabel('เบอร์โทรศัพท์ติดต่อ *'),
                        const SizedBox(height: 6),
                        _buildTextField(
                          controller: _phoneController,
                          hintText: 'เช่น 081-234-5678',
                          keyboardType: TextInputType.phone,
                          validator: (val) => val == null || val.trim().isEmpty ? 'กรุณาระบุเบอร์โทรศัพท์' : null,
                        ),
                        const SizedBox(height: 18),

                        _buildFieldLabel('อีเมลร้านค้า (ไม่บังคับ)'),
                        const SizedBox(height: 6),
                        _buildTextField(
                          controller: _emailController,
                          hintText: 'เช่น shop@gmail.com',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 18),

                        _buildFieldLabel('เมนูแนะนำ / รายละเอียดร้าน'),
                        const SizedBox(height: 6),
                        _buildTextField(
                          controller: _menuController,
                          hintText: 'เช่น ข้าวซอยไก่, น้ำเงี้ยว, ไส้อั่ว...',
                          minLines: 3,
                          maxLines: 4,
                        ),
                        const SizedBox(height: 20),

                        // Map Location Picker Button Card
                        _buildFieldLabel('ตำแหน่งบนแผนที่ *'),
                        const SizedBox(height: 6),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBF4F5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedLocation != null
                                  ? const Color(0xFF6E162B)
                                  : const Color(0xFFF2DDE1),
                              width: 1.2,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: _pickLocation,
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF6E162B),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.location_on_rounded,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _selectedLocation == null
                                                ? 'แตะเพื่อเลือกพิกัดบนแผนที่'
                                                : 'เลือกพิกัดเรียบร้อยแล้ว',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: _selectedLocation == null
                                                  ? const Color(0xFF6E162B)
                                                  : const Color(0xFF221F21),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            _selectedLocation == null
                                                ? 'ระบุตำแหน่งหมุดร้านเพื่อให้ลูกค้าค้นพบ'
                                                : 'ละติจูด: ${_selectedLocation!.latitude.toStringAsFixed(4)}, ลองจิจูด: ${_selectedLocation!.longitude.toStringAsFixed(4)}',
                                            style: const TextStyle(
                                              fontSize: 11.5,
                                              color: Color(0xFF777777),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right_rounded,
                                      color: Color(0xFF6E162B),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6E162B),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              shadowColor: const Color(0x336E162B),
                            ),
                            onPressed: _submit,
                            child: const Text(
                              'ส่งข้อมูลเพื่อรออนุมัติ',
                              style: TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14.5,
        fontWeight: FontWeight.w700,
        color: Color(0xFF221F21),
        letterSpacing: -0.2,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int minLines = 1,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFF2DDE1),
          width: 1.2,
        ),
      ),
      child: TextFormField(
        controller: controller,
        minLines: minLines,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(
          fontSize: 14.5,
          color: Color(0xFF221F21),
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: 14,
            color: Color(0xFFAAAAAA),
            fontWeight: FontWeight.w400,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
