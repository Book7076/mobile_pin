class OperatingHoursModel {
  final String id;
  final String restaurantId;
  final int dayOfWeek; // 0=Sunday or 1=Monday
  final String openTime;
  final String closeTime;
  final bool isClosed;

  const OperatingHoursModel({
    required this.id,
    required this.restaurantId,
    required this.dayOfWeek,
    required this.openTime,
    required this.closeTime,
    this.isClosed = false,
  });

  factory OperatingHoursModel.fromJson(Map<String, dynamic> json) {
    return OperatingHoursModel(
      id: json['id']?.toString() ?? '',
      restaurantId: json['restaurant_id']?.toString() ?? '',
      dayOfWeek: (json['day_of_week'] as num?)?.toInt() ?? 1,
      openTime: json['open_time']?.toString() ?? '10:00',
      closeTime: json['close_time']?.toString() ?? '21:30',
      isClosed: json['is_closed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'restaurant_id': restaurantId,
      'day_of_week': dayOfWeek,
      'open_time': openTime,
      'close_time': closeTime,
      'is_closed': isClosed,
    };
  }

  /// Helper to format list of operating hours into readable Thai text
  static String formatDisplay(List<OperatingHoursModel> hours) {
    if (hours.isEmpty) {
      return '10:00 - 21:30 น. (เปิดทุกวัน)';
    }

    final openDays = hours.where((h) => !h.isClosed).toList();
    if (openDays.isEmpty) {
      return 'ปิดทำการชั่วคราว';
    }

    // Clean time strings (e.g. "10:00:00" -> "10:00")
    String cleanTime(String t) {
      final parts = t.split(':');
      if (parts.length >= 2) return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
      return t;
    }

    final sample = openDays.first;
    final timeStr = '${cleanTime(sample.openTime)} - ${cleanTime(sample.closeTime)} น.';

    if (openDays.length >= 7) {
      return '$timeStr (เปิดทุกวัน)';
    } else if (openDays.length == 5 && !openDays.any((h) => h.dayOfWeek == 0 || h.dayOfWeek == 6 || h.dayOfWeek == 7)) {
      return '$timeStr (จันทร์ - ศุกร์)';
    } else {
      return '$timeStr (เปิด ${openDays.length} วัน/สัปดาห์)';
    }
  }
}
