import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class EditAddressScreen extends StatefulWidget {
  final String initialAddress;
  final String initialMapUrl;
  final String initialPhone;
  final String initialEmail;
  final double? initialLat;
  final double? initialLng;

  const EditAddressScreen({
    super.key,
    required this.initialAddress,
    required this.initialMapUrl,
    required this.initialPhone,
    required this.initialEmail,
    this.initialLat,
    this.initialLng,
  });

  @override
  State<EditAddressScreen> createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  static const Color maroonColor = Color(0xFF7A1428);
  static const Color inputBgColor = Color(0xFFF7F7F9);
  static const Color borderSubtle = Color(0xFFE5E7EB);

  final _formKey = GlobalKey<FormState>();

  late TextEditingController _mapUrlController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  late MapController _mapController;
  late LatLng _currentLocation;
  bool _hasCustomCoordinatesFromUrl = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _mapUrlController = TextEditingController(text: widget.initialMapUrl);
    _addressController = TextEditingController(text: widget.initialAddress);
    _phoneController = TextEditingController(text: widget.initialPhone);
    _emailController = TextEditingController(text: widget.initialEmail);

    // Initial coordinates (default to Chiang Mai Suthep if not provided)
    final double lat = widget.initialLat ?? 18.7883;
    final double lng = widget.initialLng ?? 98.9853;
    _currentLocation = LatLng(lat, lng);

    // Check if initial URL contains extractable coordinates
    final parsed = _extractCoordinates(widget.initialMapUrl);
    if (parsed != null) {
      _currentLocation = parsed;
      _hasCustomCoordinatesFromUrl = true;
    }

    _mapUrlController.addListener(_onMapUrlChanged);
  }

  @override
  void dispose() {
    _mapUrlController.removeListener(_onMapUrlChanged);
    _mapUrlController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  // Extract coordinates from Google Maps URLs (e.g. /@18.7883,98.9853 or ?q=18.7883,98.9853)
  LatLng? _extractCoordinates(String url) {
    if (url.isEmpty) return null;

    // 1. Google Maps URL parameter patterns (@lat,lng or query=lat,lng or q=lat,lng or destination=lat,lng)
    final paramRegex = RegExp(
      r'(?:@|query=|q=|destination=|ll=)(-?\d+\.\d+),(-?\d+\.\d+)',
      caseSensitive: false,
    );
    final paramMatch = paramRegex.firstMatch(url);
    if (paramMatch != null) {
      final lat = double.tryParse(paramMatch.group(1)!);
      final lng = double.tryParse(paramMatch.group(2)!);
      if (lat != null && lng != null && lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180) {
        return LatLng(lat, lng);
      }
    }

    // 2. Raw decimal coordinate pairs (e.g. 18.7883, 98.9853)
    final genericRegex = RegExp(r'(-?\d{1,2}\.\d{3,})\s*,\s*(-?\d{1,3}\.\d{3,})');
    final genericMatch = genericRegex.firstMatch(url);
    if (genericMatch != null) {
      final lat = double.tryParse(genericMatch.group(1)!);
      final lng = double.tryParse(genericMatch.group(2)!);
      if (lat != null && lng != null && lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180) {
        return LatLng(lat, lng);
      }
    }

    return null;
  }

  void _onMapUrlChanged() {
    final text = _mapUrlController.text.trim();
    final parsed = _extractCoordinates(text);
    setState(() {
      if (parsed != null) {
        _currentLocation = parsed;
        _hasCustomCoordinatesFromUrl = true;
      } else {
        _hasCustomCoordinatesFromUrl = false;
      }
    });

    if (parsed != null) {
      try {
        _mapController.move(_currentLocation, 15.0);
      } catch (_) {}
    }
  }

  Future<void> _openGoogleMaps() async {
    String url = _mapUrlController.text.trim();
    if (url.isEmpty) {
      url = 'https://www.google.com/maps/search/?api=1&query=${_currentLocation.latitude},${_currentLocation.longitude}';
    } else if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ไม่สามารถเปิดลิงก์ Google Maps ได้'),
            backgroundColor: maroonColor,
          ),
        );
      }
    }
  }

  bool _isValidThaiPhone(String phone) {
    final clean = phone.replaceAll(RegExp(r'[-\s]'), '');
    return RegExp(r'^0[0-9]{8,9}$').hasMatch(clean);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email.trim());
  }

  bool _isValidUrl(String url) {
    if (url.isEmpty) return false;
    final trimmed = url.trim().toLowerCase();
    return trimmed.startsWith('http://') ||
        trimmed.startsWith('https://') ||
        trimmed.startsWith('www.') ||
        trimmed.contains('maps') ||
        trimmed.contains('goo.gl');
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final address = _addressController.text.trim();
    final mapUrl = _mapUrlController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();

    if (!_isValidUrl(mapUrl)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาระบุลิงก์ Google Maps ที่ถูกต้อง'),
          backgroundColor: maroonColor,
        ),
      );
      return;
    }

    // Return temporary state back to parent screen
    Navigator.of(context).pop({
      'updated': true,
      'address': address,
      'mapUrl': mapUrl,
      'phone': phone,
      'email': email,
      'lat': _currentLocation.latitude,
      'lng': _currentLocation.longitude,
    });
  }

  void _onCancel() {
    Navigator.of(context).pop();
  }

  Widget _buildMapStatusBadge() {
    final text = _mapUrlController.text.trim().toLowerCase();
    if (_hasCustomCoordinatesFromUrl) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF10B981)),
        ),
        child: const Text(
          '📍 อัปเดตพิกัดตาม URL',
          style: TextStyle(fontSize: 11, color: Color(0xFF059669), fontWeight: FontWeight.bold),
        ),
      );
    } else if (text.contains('goo.gl') || text.contains('maps.app')) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF3B82F6)),
        ),
        child: const Text(
          'ℹ️ ลิงก์ย่อ (เปิดดูในแอป Maps)',
          style: TextStyle(fontSize: 11, color: Color(0xFF1D4ED8), fontWeight: FontWeight.w600),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: const Text(
          'พิกัดปัจจุบันของร้าน',
          style: TextStyle(fontSize: 11, color: Color(0xFF6B7280), fontWeight: FontWeight.w500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: maroonColor,
        elevation: 0,
        leadingWidth: 160,
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
              'แก้ไขที่อยู่',
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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- 1. ลิงก์ตำแหน่งร้าน ---
                const Text(
                  'ลิงก์ตำแหน่งร้าน',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _mapUrlController,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'วางลิงก์จาก Google Maps เช่น https://maps.app.goo.gl/...',
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                    filled: true,
                    fillColor: inputBgColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: borderSubtle),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: borderSubtle),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: maroonColor, width: 1.2),
                    ),
                    suffixIcon: _mapUrlController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.grey, size: 20),
                            onPressed: () {
                              _mapUrlController.clear();
                            },
                          )
                        : null,
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'กรุณาระบุลิงก์ Google Maps';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 4),
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Text(
                    'วางลิงก์จาก GOOGLE MAPS',
                    style: TextStyle(fontSize: 11.5, color: Colors.black45, letterSpacing: 0.3),
                  ),
                ),

                const SizedBox(height: 20),

                // --- 2. ตำแหน่งร้านบนแผนที่ ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ตำแหน่งร้านบนแผนที่',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    _buildMapStatusBadge(),
                  ],
                ),
                const SizedBox(height: 10),

                // Map Container with OpenStreetMap and Pin Marker
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFD1D5DB), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Stack(
                      children: [
                        FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: _currentLocation,
                            initialZoom: 15.0,
                            interactionOptions: const InteractionOptions(
                              flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                            ),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.pin_mobile',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: _currentLocation,
                                  width: 44,
                                  height: 44,
                                  child: const Icon(
                                    Icons.location_on,
                                    color: Color(0xFFE11D48),
                                    size: 40,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Overlay Button: "เปิดใน GOOGLE MAPS" (Matching Reference)
                        Positioned(
                          bottom: 10,
                          left: 10,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _openGoogleMaps,
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.92),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.12),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(
                                      Icons.open_in_new,
                                      size: 14,
                                      color: Colors.black87,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      'เปิดใน GOOGLE MAPS',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // --- 3. ที่อยู่โดยสรุป (แสดงให้ลูกค้าเห็น) ---
                Row(
                  children: const [
                    Text(
                      'ที่อยู่โดยสรุป',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(width: 6),
                    Text(
                      '(แสดงให้ลูกค้าเห็น)',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _addressController,
                  maxLines: 2,
                  maxLength: 100,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
                    return Text(
                      '$currentLength/$maxLength',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    );
                  },
                  decoration: InputDecoration(
                    hintText: 'กรุณาระบุที่อยู่โดยสรุป เช่น 31/0 ตำบลสุเทพ ซอยวัดอุโมงค์ หลังมช',
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                    filled: true,
                    fillColor: inputBgColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: borderSubtle),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: borderSubtle),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: maroonColor, width: 1.2),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'กรุณากรอกที่อยู่โดยสรุป';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 10),

                // --- 4. เบอร์โทรศัพท์ ---
                const Text(
                  'เบอร์โทรศัพท์',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'เบอร์โทรศัพท์ร้านค้า เช่น 0991234567',
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                    prefixIcon: const Icon(Icons.phone_outlined, color: maroonColor, size: 20),
                    filled: true,
                    fillColor: inputBgColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: borderSubtle),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: borderSubtle),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: maroonColor, width: 1.2),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'กรุณากรอกเบอร์โทรศัพท์';
                    }
                    if (!_isValidThaiPhone(val)) {
                      return 'กรุณากรอกเบอร์โทรศัพท์ให้ถูกต้อง (เช่น 0812345678)';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // --- 5. อีเมล ---
                const Text(
                  'อีเมล',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'อีเมลร้านค้า เช่น store@example.com',
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                    prefixIcon: const Icon(Icons.mail_outline, color: maroonColor, size: 20),
                    filled: true,
                    fillColor: inputBgColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: borderSubtle),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: borderSubtle),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: maroonColor, width: 1.2),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'กรุณากรอกอีเมลร้านค้า';
                    }
                    if (!_isValidEmail(val)) {
                      return 'กรุณากรอกรูปแบบอีเมลให้ถูกต้อง (เช่น example@email.com)';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // --- 6. TIP Box matching reference image ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1EB),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFFD8CC), width: 1),
                  ),
                  child: Row(
                    children: const [
                      Text('💡', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'TIP : แนะนำให้ตรวจสอบบนแผนที่ก่อนบันทึก',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF9A3412),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
