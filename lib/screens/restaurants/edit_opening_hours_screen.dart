import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DaySchedule {
  bool isOpen;
  String openTime;
  String closeTime;

  DaySchedule({
    required this.isOpen,
    required this.openTime,
    required this.closeTime,
  });

  DaySchedule copy() => DaySchedule(
        isOpen: isOpen,
        openTime: openTime,
        closeTime: closeTime,
      );
}

class EditOpeningHoursScreen extends StatefulWidget {
  final Map<String, String> initialOpeningHours;

  const EditOpeningHoursScreen({
    super.key,
    required this.initialOpeningHours,
  });

  @override
  State<EditOpeningHoursScreen> createState() => _EditOpeningHoursScreenState();
}

class _EditOpeningHoursScreenState extends State<EditOpeningHoursScreen> {
  static const Color maroonColor = Color(0xFF7A1428);

  static const List<String> _days = [
    'จันทร์',
    'อังคาร',
    'พุธ',
    'พฤหัสบดี',
    'ศุกร์',
    'เสาร์',
    'อาทิตย์',
  ];

  late Map<String, DaySchedule> _schedule;

  @override
  void initState() {
    super.initState();
    _schedule = {};

    for (final day in _days) {
      final rawVal = widget.initialOpeningHours[day] ?? '';
      if (rawVal.contains('ปิดร้าน') || rawVal.contains('หยุดทำการ') || rawVal.isEmpty) {
        _schedule[day] = DaySchedule(
          isOpen: false,
          openTime: '09:00',
          closeTime: '22:00',
        );
      } else {
        // Parse "HH:mm - HH:mm" or "HH.mm - HH.mm"
        final match = RegExp(r'(\d{1,2})[:.](\d{2})\s*-\s*(\d{1,2})[:.](\d{2})').firstMatch(rawVal);
        if (match != null) {
          final h1 = match.group(1)!.padLeft(2, '0');
          final m1 = match.group(2)!;
          final h2 = match.group(3)!.padLeft(2, '0');
          final m2 = match.group(4)!;
          _schedule[day] = DaySchedule(
            isOpen: true,
            openTime: '$h1:$m1',
            closeTime: '$h2:$m2',
          );
        } else {
          _schedule[day] = DaySchedule(
            isOpen: true,
            openTime: '09:00',
            closeTime: '22:00',
          );
        }
      }
    }
  }

  // Scroll wheel 24-hour time picker
  Future<void> _pickTime(String day, bool isOpeningTime) async {
    final currentStr = isOpeningTime ? _schedule[day]!.openTime : _schedule[day]!.closeTime;
    final parts = currentStr.split(':');
    final initialHour = int.tryParse(parts[0]) ?? 9;
    final initialMinute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;

    int selectedHour = initialHour;
    int selectedMinute = initialMinute;

    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return CupertinoTheme(
          data: const CupertinoThemeData(
            brightness: Brightness.light,
          ),
          child: StatefulBuilder(
            builder: (context, setPickerState) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text(
                            'ยกเลิก',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ),
                        Text(
                          isOpeningTime ? 'เลือกเวลาเปิด ($day)' : 'เลือกเวลาปิด ($day)',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            final h = selectedHour.toString().padLeft(2, '0');
                            final m = selectedMinute.toString().padLeft(2, '0');
                            Navigator.pop(ctx, '$h:$m');
                          },
                          child: const Text(
                            'ตกลง',
                            style: TextStyle(
                              color: maroonColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // 24-Hour Wheel Picker (Hours 00-23, Minutes 00-59)
                  SizedBox(
                    height: 200,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Hours
                        SizedBox(
                          width: 80,
                          child: CupertinoPicker(
                            scrollController: FixedExtentScrollController(initialItem: selectedHour),
                            itemExtent: 40,
                            selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(capStartEdge: true),
                            onSelectedItemChanged: (index) {
                              selectedHour = index;
                            },
                            children: List.generate(24, (i) {
                              return Center(
                                child: Text(
                                  i.toString().padLeft(2, '0'),
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            ':',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        // Minutes
                        SizedBox(
                          width: 80,
                          child: CupertinoPicker(
                            scrollController: FixedExtentScrollController(initialItem: selectedMinute),
                            itemExtent: 40,
                            selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(capEndEdge: true),
                            onSelectedItemChanged: (index) {
                              selectedMinute = index;
                            },
                            children: List.generate(60, (i) {
                              return Center(
                                child: Text(
                                  i.toString().padLeft(2, '0'),
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        ),
      );
    },
  );

    if (result != null) {
      setState(() {
        if (isOpeningTime) {
          _schedule[day]!.openTime = result;
        } else {
          _schedule[day]!.closeTime = result;
        }
      });
    }
  }

  void _onSave() {
    for (final day in _days) {
      final s = _schedule[day]!;
      if (s.isOpen) {
        if (s.openTime.isEmpty || s.closeTime.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('กรุณาระบุเวลาเปิด-ปิดสำหรับวัน$day'),
              backgroundColor: maroonColor,
            ),
          );
          return;
        }
        // Validation: If open time equals close time, reject and alert
        if (s.openTime == s.closeTime) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('กรุณาตรวจสอบเวลาเปิด-ปิด'),
              backgroundColor: maroonColor,
            ),
          );
          return;
        }
      }
    }

    // Build final Map<String, String>
    final Map<String, String> result = {};
    for (final day in _days) {
      final s = _schedule[day]!;
      if (s.isOpen) {
        result[day] = '${s.openTime} - ${s.closeTime}';
      } else {
        result[day] = 'ปิดร้าน';
      }
    }

    Navigator.of(context).pop({
      'updated': true,
      'openingHours': result,
    });
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
        leadingWidth: 220,
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
              'แก้ไขเวลาเปิด-ปิดร้าน',
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subheader
              Row(
                children: const [
                  Icon(
                    Icons.access_time,
                    size: 18,
                    color: Color(0xFF6B7280),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'ตั้งเวลาเปิด-ปิดในแต่ละวัน',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 7 Day Cards
              ..._days.map((day) {
                final schedule = _schedule[day]!;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF3E7E4), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Day Name
                      SizedBox(
                        width: 65,
                        child: Text(
                          day,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF374151),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Pill Switch
                      _PillSwitch(
                        value: schedule.isOpen,
                        onChanged: (val) {
                          setState(() {
                            schedule.isOpen = val;
                          });
                        },
                      ),

                      const SizedBox(width: 12),

                      // Right Content: Either "ปิดร้าน" or Open - Close pickers
                      if (!schedule.isOpen)
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Text(
                            'ปิดร้าน',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF4B5563),
                            ),
                          ),
                        )
                      else ...[
                        // Open Time Box
                        GestureDetector(
                          onTap: () => _pickTime(day, true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFD1D5DB)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  schedule.openTime,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF374151),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 16,
                                  color: Color(0xFF6B7280),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            '-',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        // Close Time Box
                        GestureDetector(
                          onTap: () => _pickTime(day, false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFD1D5DB)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  schedule.closeTime,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF374151),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 16,
                                  color: Color(0xFF6B7280),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),

              const SizedBox(height: 18),

              // Bottom TIP Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7EBEF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEED5DC)),
                ),
                child: Row(
                  children: const [
                    Icon(
                      Icons.calendar_month_outlined,
                      size: 18,
                      color: Color(0xFF9B2C47),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'หากปิดร้านทั้งวัน ให้ปิดสวิตช์และเลือกปิดร้าน',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF832338),
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
    );
  }
}

// Compact pill toggle switch matching Figma design
class _PillSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PillSwitch({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 42,
        height: 23,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: value ? const Color(0xFF7A1428) : Colors.transparent,
          border: Border.all(
            color: value ? const Color(0xFF7A1428) : const Color(0xFF9CA3AF),
            width: 1.5,
          ),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 180),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value ? Colors.white : const Color(0xFF9CA3AF),
            ),
          ),
        ),
      ),
    );
  }
}
