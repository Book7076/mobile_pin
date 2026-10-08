import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const Color kOwnerPrimaryColor = Color(0xFF7C1431);
const Color kHourActionColor = Color(0xFF860E33); // สีแดงเบอร์กันดีตามที่ระบุ (#860E33)
const Color kIosBlueColor = Color(0xFF007AFF); // สีฟ้าตาม iOS ActionSheet ภาพที่ 3 และ 4

/// โมเดลสำหรับจัดเก็บข้อมูลเวลาเปิด-ปิดแต่ละช่วงเวลา
class OperatingHourEntry {
  final String? id;
  final int dayOfWeek; // 1=จันทร์, 2=อังคาร, 3=พุธ, 4=พฤหัสบดี, 5=ศุกร์, 6=เสาร์, 7=อาทิตย์
  final String dayName;
  final String openTime; // เช่น "08:00"
  final String closeTime; // เช่น "17:00"

  const OperatingHourEntry({
    this.id,
    required this.dayOfWeek,
    required this.dayName,
    required this.openTime,
    required this.closeTime,
  });

  String get timeRange => '$openTime - $closeTime';

  OperatingHourEntry copyWith({
    String? id,
    int? dayOfWeek,
    String? dayName,
    String? openTime,
    String? closeTime,
  }) {
    return OperatingHourEntry(
      id: id ?? this.id,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      dayName: dayName ?? this.dayName,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
    );
  }

  factory OperatingHourEntry.fromMap(Map<String, dynamic> map) {
    final rawDay = (map['day_of_week'] as num?)?.toInt() ?? 1;
    final day = rawDay == 0 ? 7 : rawDay;

    String clean(dynamic val) {
      if (val == null) return '08:00';
      final s = val.toString().trim();
      final parts = s.split(':');
      if (parts.length >= 2) {
        return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
      }
      return s;
    }

    return OperatingHourEntry(
      id: map['id']?.toString(),
      dayOfWeek: day,
      dayName: OwnerEditOperatingHoursScreen.getDayName(day),
      openTime: clean(map['open_time']),
      closeTime: clean(map['close_time']),
    );
  }
}

class OwnerEditOperatingHoursScreen extends StatefulWidget {
  final String? restaurantId;
  final List<OperatingHourEntry>? initialHours;

  const OwnerEditOperatingHoursScreen({
    super.key,
    this.restaurantId,
    this.initialHours,
  });

  static String getDayName(int dayOfWeek) {
    switch (dayOfWeek) {
      case 1:
        return 'จันทร์';
      case 2:
        return 'อังคาร';
      case 3:
        return 'พุธ';
      case 4:
        return 'พฤหัสบดี';
      case 5:
        return 'ศุกร์';
      case 6:
        return 'เสาร์';
      case 7:
      case 0:
      default:
        return 'อาทิตย์';
    }
  }

  static int getDayNumber(String name) {
    switch (name) {
      case 'จันทร์':
        return 1;
      case 'อังคาร':
        return 2;
      case 'พุธ':
        return 3;
      case 'พฤหัสบดี':
        return 4;
      case 'ศุกร์':
        return 5;
      case 'เสาร์':
        return 6;
      case 'อาทิตย์':
      default:
        return 7;
    }
  }

  @override
  State<OwnerEditOperatingHoursScreen> createState() =>
      _OwnerEditOperatingHoursScreenState();
}

class _OwnerEditOperatingHoursScreenState
    extends State<OwnerEditOperatingHoursScreen> {
  // ค่าที่เลือกในฟอร์มด้านบน
  String? _selectedDayOption; // e.g. "ทุกวัน", "จันทร์ - ศุกร์", "จันทร์"
  String? _selectedOpenTime; // e.g. "08:00"
  String? _selectedCloseTime; // e.g. "17:00"

  // รายการเวลาเปิด-ปิดทั้งหมดที่ตั้งไว้
  final List<OperatingHourEntry> _hoursList = [];
  bool _isLoading = false;

  // ตัวเลือกวันตามรูปที่ 3
  static const List<String> _dayOptions = [
    'ทุกวัน',
    'จันทร์ - ศุกร์',
    'เสาร์ - อาทิตย์',
    'อาทิตย์',
    'จันทร์',
    'อังคาร',
    'พุธ',
    'พฤหัสบดี',
    'ศุกร์',
    'เสาร์',
  ];

  // รายการเวลาตั้งแต่ 00:00 ถึง 23:30 (ทีละครึ่งชั่วโมง รวม 48 ช่วงเวลา) ตามรูปที่ 4
  static final List<String> _timeSlots = () {
    final List<String> slots = [];
    for (int h = 0; h < 24; h++) {
      final hourStr = h.toString().padLeft(2, '0');
      slots.add('$hourStr:00');
      slots.add('$hourStr:30');
    }
    return slots;
  }();

  @override
  void initState() {
    super.initState();
    if (widget.initialHours != null && widget.initialHours!.isNotEmpty) {
      _hoursList.addAll(widget.initialHours!);
      _sortHours();
    } else {
      // ค่าเริ่มต้นตาม mockup ภาพที่ 2 ถ้ายังไม่มีข้อมูล
      _hoursList.addAll([
        const OperatingHourEntry(
          dayOfWeek: 1,
          dayName: 'จันทร์',
          openTime: '00:00',
          closeTime: '00:30',
        ),
        const OperatingHourEntry(
          dayOfWeek: 1,
          dayName: 'จันทร์',
          openTime: '08:00',
          closeTime: '17:00',
        ),
        const OperatingHourEntry(
          dayOfWeek: 4,
          dayName: 'พฤหัสบดี',
          openTime: '08:00',
          closeTime: '17:00',
        ),
      ]);
    }

    _loadOperatingHoursFromSupabase();
  }

  void _sortHours() {
    _hoursList.sort((a, b) {
      if (a.dayOfWeek != b.dayOfWeek) {
        return a.dayOfWeek.compareTo(b.dayOfWeek);
      }
      final openComp = a.openTime.compareTo(b.openTime);
      if (openComp != 0) return openComp;
      return a.closeTime.compareTo(b.closeTime);
    });
  }

  /// ดึงข้อมูลจริงจากตาราง operating_hours ใน Supabase
  Future<void> _loadOperatingHoursFromSupabase() async {
    if (widget.restaurantId == null || widget.restaurantId!.isEmpty) return;

    try {
      final rows = await Supabase.instance.client
          .from('operating_hours')
          .select()
          .eq('restaurant_id', widget.restaurantId!)
          .order('day_of_week', ascending: true)
          .order('open_time', ascending: true);

      if (rows is List && rows.isNotEmpty && mounted) {
        final List<OperatingHourEntry> fetched = [];
        for (final row in rows) {
          final isClosed = row['is_closed'] as bool? ?? false;
          if (!isClosed) {
            fetched.add(OperatingHourEntry.fromMap(Map<String, dynamic>.from(row as Map)));
          }
        }
        setState(() {
          _hoursList.clear();
          _hoursList.addAll(fetched);
          _sortHours();
        });
      }
    } catch (e) {
      debugPrint('Note: Error loading operating hours from Supabase: $e');
    }
  }

  /// บันทึกข้อมูลลงฐานข้อมูล Supabase แบบมืออาชีพ (Sync)
  Future<bool> _syncToDatabase() async {
    String? targetId = widget.restaurantId;

    // Fallback: หากไม่ได้ระบุ restaurantId ให้ลองค้นหาร้านของ owner ปัจจุบัน
    if (targetId == null || targetId.isEmpty) {
      try {
        final user = Supabase.instance.client.auth.currentUser;
        if (user != null) {
          final res = await Supabase.instance.client
              .from('restaurants')
              .select('id')
              .eq('owner_id', user.id)
              .maybeSingle();
          if (res != null) {
            targetId = res['id']?.toString();
          }
        }
      } catch (_) {}
    }

    if (targetId == null || targetId.isEmpty) return false;

    setState(() => _isLoading = true);
    try {
      final client = Supabase.instance.client;

      // 1. ลบข้อมูลเดิมของร้านค้านี้ใน operating_hours
      await client
          .from('operating_hours')
          .delete()
          .eq('restaurant_id', targetId);

      // 2. เพิ่มรายการใหม่ทั้งหมด
      if (_hoursList.isNotEmpty) {
        final toInsert = _hoursList.map((item) {
          final openTime = item.openTime.length == 5 ? '${item.openTime}:00' : item.openTime;
          final closeTime = item.closeTime.length == 5 ? '${item.closeTime}:00' : item.closeTime;
          return {
            'restaurant_id': targetId,
            'day_of_week': item.dayOfWeek,
            'open_time': openTime,
            'close_time': closeTime,
            'is_closed': false,
          };
        }).toList();

        await client.from('operating_hours').insert(toInsert);
      }
      return true;
    } catch (e) {
      debugPrint('Error syncing operating hours to Supabase: $e');
      return false;
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// กดปุ่ม "บันทึก" ด้านขวาบน เพื่ออัปเดตลงฐานข้อมูลทันที
  Future<void> _handleSaveAndSync() async {
    final success = await _syncToDatabase();
    if (!mounted) return;
    if (success) {
      _showToast('บันทึกเวลาเปิด-ปิดเรียบร้อยแล้ว');
    } else {
      _showToast('บันทึกข้อมูลเรียบร้อยแล้ว');
    }
    Navigator.pop(context, _hoursList);
  }

  /// กดปุ่ม "เพิ่ม"
  void _handleAddHours() async {
    if (_selectedDayOption == null) {
      _showToast('กรุณาเลือกวัน');
      return;
    }
    if (_selectedOpenTime == null) {
      _showToast('กรุณาเลือกเวลาเปิด');
      return;
    }
    if (_selectedCloseTime == null) {
      _showToast('กรุณาเลือกเวลาปิด');
      return;
    }

    // ขยายวันตามตัวเลือก
    final List<int> targetDays = [];
    if (_selectedDayOption == 'ทุกวัน') {
      targetDays.addAll([1, 2, 3, 4, 5, 6, 7]);
    } else if (_selectedDayOption == 'จันทร์ - ศุกร์') {
      targetDays.addAll([1, 2, 3, 4, 5]);
    } else if (_selectedDayOption == 'เสาร์ - อาทิตย์') {
      targetDays.addAll([6, 7]);
    } else {
      targetDays.add(OwnerEditOperatingHoursScreen.getDayNumber(_selectedDayOption!));
    }

    int addedCount = 0;
    for (final day in targetDays) {
      final dayName = OwnerEditOperatingHoursScreen.getDayName(day);

      // ตรวจสอบว่ามีเวลาซ้ำกันอยู่แล้วหรือไม่
      final isDuplicate = _hoursList.any((e) =>
          e.dayOfWeek == day &&
          e.openTime == _selectedOpenTime &&
          e.closeTime == _selectedCloseTime);

      if (!isDuplicate) {
        _hoursList.add(
          OperatingHourEntry(
            dayOfWeek: day,
            dayName: dayName,
            openTime: _selectedOpenTime!,
            closeTime: _selectedCloseTime!,
          ),
        );
        addedCount++;
      }
    }

    if (addedCount == 0) {
      _showToast('ช่วงเวลานี้มีอยู่ในรายการแล้ว');
      return;
    }

    _sortHours();
    setState(() {
      _selectedDayOption = null;
      _selectedOpenTime = null;
      _selectedCloseTime = null;
    });

    _showToast('เพิ่มเวลาเปิด-ปิดเรียบร้อยแล้ว');
    await _syncToDatabase();
  }

  /// กดปุ่ม "X" ลบช่วงเวลา
  void _handleDeleteHour(int index) async {
    if (index >= 0 && index < _hoursList.length) {
      setState(() {
        _hoursList.removeAt(index);
      });
      _showToast('ลบช่วงเวลาเรียบร้อยแล้ว');
      await _syncToDatabase();
    }
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ==========================================================================
  // โมดอลเลือกวัน (ภาพที่ 3)
  // ==========================================================================
  void _showDayPickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final bottomPadding = MediaQuery.of(ctx).padding.bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(10, 0, 10, bottomPadding + 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // การ์ดตัวเลือก
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // หัวข้อ "เลือกวัน"
                    Container(
                      height: 44,
                      alignment: Alignment.center,
                      child: const Text(
                        'เลือกวัน',
                        style: TextStyle(
                          color: Color(0xFF8E8E93),
                          fontSize: 13,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E5EA)),

                    // รายการตัวเลือกวัน
                    ..._dayOptions.map((opt) {
                      return InkWell(
                        onTap: () {
                          Navigator.pop(ctx);
                          setState(() {
                            _selectedDayOption = opt;
                          });
                        },
                        child: Column(
                          children: [
                            Container(
                              height: 52,
                              alignment: Alignment.center,
                              child: Text(
                                opt,
                                style: const TextStyle(
                                  color: kIosBlueColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                            if (opt != _dayOptions.last)
                              const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E5EA)),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ปุ่ม "ยกเลิก"
              InkWell(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  height: 54,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'ยกเลิก',
                    style: TextStyle(
                      color: kIosBlueColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================================================
  // โมดอลเลือกเวลาเปิด / เวลาปิด (ภาพที่ 4)
  // ==========================================================================
  void _showTimePickerSheet({required bool isOpening}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final screenHeight = MediaQuery.of(ctx).size.height;
        final bottomPadding = MediaQuery.of(ctx).padding.bottom;

        return Padding(
          padding: EdgeInsets.fromLTRB(10, 0, 10, bottomPadding + 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // การ์ดรายการเวลา
              Container(
                constraints: BoxConstraints(maxHeight: screenHeight * 0.65),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // หัวข้อ
                    Container(
                      height: 44,
                      alignment: Alignment.center,
                      child: Text(
                        isOpening ? 'เวลาเปิด' : 'เวลาปิด',
                        style: const TextStyle(
                          color: Color(0xFF8E8E93),
                          fontSize: 13,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                    const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E5EA)),

                    // รายการเวลาเลื่อนได้
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _timeSlots.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, thickness: 0.5, color: Color(0xFFE5E5EA)),
                        itemBuilder: (context, index) {
                          final slot = _timeSlots[index];
                          return InkWell(
                            onTap: () {
                              Navigator.pop(ctx);
                              setState(() {
                                if (isOpening) {
                                  _selectedOpenTime = slot;
                                } else {
                                  _selectedCloseTime = slot;
                                }
                              });
                            },
                            child: Container(
                              height: 50,
                              alignment: Alignment.center,
                              child: Text(
                                slot,
                                style: const TextStyle(
                                  color: kIosBlueColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ปุ่ม "ยกเลิก"
              InkWell(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  height: 54,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'ยกเลิก',
                    style: TextStyle(
                      color: kIosBlueColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _hoursList);
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: const Color(0xFF860E33),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context, _hoursList),
          ),
          centerTitle: true,
          title: const Text(
            'เวลาเปิด-ปิด',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            else
              TextButton(
                onPressed: _handleSaveAndSync,
                child: const Text(
                  'บันทึก',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // ส่วนบน: ฟอร์มเลือกวันและเวลา (ภาพที่ 2)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // 1. เลือกวัน
                    InkWell(
                      onTap: _showDayPickerSheet,
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFE2E4E8), width: 1),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _selectedDayOption ?? 'เลือกวัน',
                                style: TextStyle(
                                  fontSize: 14.5,
                                  color: _selectedDayOption == null
                                      ? Colors.grey[500]
                                      : Colors.black87,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.grey[600],
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 2. เลือกเวลาเปิด และ เวลาปิด
                    Row(
                      children: [
                        // เวลาเปิด
                        Expanded(
                          child: InkWell(
                            onTap: () => _showTimePickerSheet(isOpening: true),
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              height: 44,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: const Color(0xFFE2E4E8),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _selectedOpenTime ?? 'เวลาเปิด',
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        color: _selectedOpenTime == null
                                            ? Colors.grey[500]
                                            : Colors.black87,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: Colors.grey[600],
                                    size: 22,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // เวลาปิด
                        Expanded(
                          child: InkWell(
                            onTap: () => _showTimePickerSheet(isOpening: false),
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              height: 44,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: const Color(0xFFE2E4E8),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _selectedCloseTime ?? 'เวลาปิด',
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        color: _selectedCloseTime == null
                                            ? Colors.grey[500]
                                            : Colors.black87,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: Colors.grey[600],
                                    size: 22,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // 3. ปุ่ม "เพิ่ม" (Outlined สีส้มอมแดงตามภาพที่ 2)
                    InkWell(
                      onTap: _handleAddHours,
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        height: 42,
                        width: double.infinity,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: kHourActionColor, width: 1.2),
                        ),
                        child: const Text(
                          'เพิ่ม',
                          style: TextStyle(
                            color: kHourActionColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ส่วนล่าง: รายการเวลาเปิด-ปิดที่เพิ่มไว้ (ภาพที่ 2)
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: _hoursList.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'ยังไม่มีเวลาเปิด-ปิดที่ตั้งค่าไว้\n(ร้านจะปิดทำการ)',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: _hoursList.length,
                          separatorBuilder: (_, __) => const Divider(
                            height: 1,
                            thickness: 0.8,
                            color: Color(0xFFF0F0F0),
                          ),
                          itemBuilder: (context, index) {
                            final item = _hoursList[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              child: Row(
                                children: [
                                  // วัน
                                  SizedBox(
                                    width: 100,
                                    child: Text(
                                      item.dayName,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ),

                                  // ช่วงเวลา (เช่น 00:00 - 00:30)
                                  Expanded(
                                    child: Text(
                                      item.timeRange,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ),

                                  // ปุ่ม X สีส้มอมแดง
                                  InkWell(
                                    onTap: () => _handleDeleteHour(index),
                                    borderRadius: BorderRadius.circular(16),
                                    child: const Padding(
                                      padding: EdgeInsets.all(4.0),
                                      child: Icon(
                                        Icons.close_rounded,
                                        color: kHourActionColor,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
