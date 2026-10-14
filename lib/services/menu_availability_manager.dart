import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// ตัวจัดการสถานะความพร้อมของเมนูอาหาร (เปิดขาย / สินค้าหมด)
/// ซิงค์ข้อมูลกับฐานข้อมูล Supabase ตาราง `menu_items` (ฟิลด์ `is_available` และ fallback `sort_order`)
/// และบันทึกสถานะให้ตรงกันทั้งฝั่งเจ้าของร้าน (Owner) และฝั่งลูกค้า (Customer)
class MenuAvailabilityManager {
  static final Map<String, bool> _cache = {};

  /// คืนค่าสถานะพร้อมขาย (true = เปิดขาย, false = สินค้าหมด)
  static bool isAvailable(String itemId, {bool defaultValue = true}) {
    if (itemId.isEmpty) return defaultValue;
    return _cache[itemId] ?? defaultValue;
  }

  /// บันทึกสถานะลงใน Local Memory Cache
  static void setAvailable(String itemId, bool available) {
    if (itemId.isEmpty) return;
    _cache[itemId] = available;
  }

  /// แยกสถานะจาก Row ในตาราง menu_items
  static bool parseFromRow(Map<String, dynamic> row) {
    final id = row['id']?.toString() ?? '';
    bool available = true;

    if (row.containsKey('is_available') && row['is_available'] != null) {
      available = row['is_available'] == true;
    } else if (row['sort_order'] != null && (row['sort_order'] as num) < 0) {
      available = false;
    } else if (id.isNotEmpty && _cache.containsKey(id)) {
      available = _cache[id]!;
    }

    if (id.isNotEmpty) {
      _cache[id] = available;
    }
    return available;
  }

  /// อัปเดตสถานะลงใน Database Supabase
  static Future<void> updateAvailabilityInDatabase(String itemId, bool available) async {
    if (itemId.isEmpty) return;
    setAvailable(itemId, available);

    if (itemId.startsWith('mock-')) return;

    try {
      // 1. ลองอัปเดตฟิลด์ is_available โดยตรง
      await Supabase.instance.client.from('menu_items').update({
        'is_available': available,
        'sort_order': available ? 0 : -9999,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', itemId);
    } catch (_) {
      // 2. เผื่อกรณีคอลัมน์ is_available ยังไม่ถูกสร้างใน schema cache ให้ใช้ sort_order เป็น fallback
      try {
        await Supabase.instance.client.from('menu_items').update({
          'sort_order': available ? 0 : -9999,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', itemId);
      } catch (e2) {
        debugPrint('Note: Error updating menu item availability in DB: $e2');
      }
    }
  }
}
