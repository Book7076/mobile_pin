import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/report_model.dart';

/// Database service for interacting with Supabase `reports` and `report_types` tables
class ReportService {
  /// Safely checks if Supabase client is initialized
  static bool get isSupabaseAvailable {
    try {
      return Supabase.instance.client != null;
    } catch (_) {
      return false;
    }
  }

  /// Resolves the current user's ID
  static Future<String?> getCurrentUserId() async {
    if (!isSupabaseAvailable) return null;
    try {
      final client = Supabase.instance.client;
      final authUser = client.auth.currentUser;
      if (authUser != null) {
        return authUser.id;
      }

      // Check users table fallback
      try {
        final userRow =
            await client.from('users').select('id').limit(1).maybeSingle();
        if (userRow != null && userRow['id'] != null) {
          return userRow['id'].toString();
        }
      } catch (_) {}
    } catch (e) {
      debugPrint('Note: Supabase user resolution notice: $e');
    }
    return null;
  }

  /// Fetches active problem categories from `report_types` table
  static Future<List<ReportTypeModel>> fetchReportTypes() async {
    if (!isSupabaseAvailable) return _defaultReportTypes;

    try {
      final client = Supabase.instance.client;
      final response = await client
          .from('report_types')
          .select()
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      if (response is List && response.isNotEmpty) {
        return response
            .map((e) => ReportTypeModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (e) {
      debugPrint('Note: Error fetching report_types from Supabase: $e');
    }

    return _defaultReportTypes;
  }

  /// Safely converts any category string (Thai title, code, or legacy id) to valid `report_types.code` FK
  static String normalizeCategoryCode(String category) {
    final lower = category.trim().toLowerCase();
    if (lower == 'wrong_info' ||
        lower == 'store_info' ||
        category.contains('ข้อมูลร้านค้า') ||
        category.contains('ไม่ถูกต้อง')) {
      return 'wrong_info';
    }
    if (lower == 'not_found' ||
        lower == 'store_closed' ||
        category.contains('ปิด') ||
        category.contains('ไม่พบ')) {
      return 'not_found';
    }
    if (lower == 'app_issue' ||
        category.contains('แอป') ||
        category.contains('ระบบ') ||
        category.contains('บั๊ก')) {
      return 'app_issue';
    }
    return 'other';
  }

  /// Submits a problem report into `reports` table
  static Future<String?> submitReport({
    required String category,
    required String description,
    String? restaurantName,
    String? explicitRestaurantId,
    String? explicitUserId,
    String? contactEmail,
  }) async {
    if (!isSupabaseAvailable) {
      debugPrint('Note: Supabase not available, simulating successful report submission.');
      return 'local-simulated-report-id';
    }

    try {
      final client = Supabase.instance.client;
      final userId = explicitUserId ?? await getCurrentUserId();
      final userEmail = contactEmail ?? client.auth.currentUser?.email;

      String? restaurantId = explicitRestaurantId;

      // If restaurantName is provided and restaurantId is not, find restaurant in database
      if (restaurantId == null &&
          restaurantName != null &&
          restaurantName.trim().isNotEmpty) {
        try {
          final found = await client
              .from('restaurants')
              .select('id')
              .ilike('name', restaurantName.trim())
              .limit(1)
              .maybeSingle();

          if (found != null && found['id'] != null) {
            restaurantId = found['id'].toString();
          }
        } catch (_) {}
      }

      final nowIso = DateTime.now().toIso8601String();
      final validCategoryCode = normalizeCategoryCode(category);
      final payload = <String, dynamic>{
        'category': validCategoryCode,
        'description': description,
        'status': 'pending',
        'create_at': nowIso,
        'updated_at': nowIso,
      };

      if (userId != null && userId.isNotEmpty) {
        payload['user_id'] = userId;
      }
      if (restaurantId != null && restaurantId.isNotEmpty) {
        payload['restaurant_id'] = restaurantId;
      }
      if (userEmail != null && userEmail.isNotEmpty) {
        payload['contact_email'] = userEmail;
      }

      final response = await client.from('reports').insert(payload).select().maybeSingle();

      if (response != null && response['id'] != null) {
        return response['id'].toString();
      }
      return 'submitted';
    } catch (e) {
      debugPrint('Note: Error submitting report to Supabase: $e');
      return null;
    }
  }

  /// Converts UI status ('in_progress') to DB status ('reviewing')
  static String toDbStatus(String status) {
    if (status == 'in_progress' || status == 'กำลังตรวจสอบ') {
      return 'reviewing';
    }
    if (status == 'resolved' || status == 'แก้ไขแล้ว') {
      return 'resolved';
    }
    return 'pending';
  }

  /// Converts DB status ('reviewing') to UI status ('in_progress')
  static String toUiStatus(String dbStatus) {
    if (dbStatus == 'reviewing') {
      return 'in_progress';
    }
    return dbStatus;
  }

  /// Fetches reports from `reports` table (used in Admin panel)
  static Future<List<ReportModel>> fetchReports({String? statusFilter}) async {
    if (!isSupabaseAvailable) return [];

    try {
      final client = Supabase.instance.client;
      var query = client.from('reports').select('*, restaurants(id, name), users!user_id(id, first_name, last_name, email, phone)');

      if (statusFilter != null && statusFilter != 'all') {
        final dbStatus = toDbStatus(statusFilter);
        query = query.eq('status', dbStatus);
      }

      final response = await query.order('create_at', ascending: false);

      if (response is List) {
        return response
            .map((e) => ReportModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (e) {
      debugPrint('Note: Error fetching reports with joined users!user_id: $e');
      // Fallback query without specific relation hint
      try {
        final client = Supabase.instance.client;
        var query = client.from('reports').select('*');
        if (statusFilter != null && statusFilter != 'all') {
          final dbStatus = toDbStatus(statusFilter);
          query = query.eq('status', dbStatus);
        }
        final response = await query.order('create_at', ascending: false);
        if (response is List) {
          return response
              .map((e) => ReportModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      } catch (e2) {
        debugPrint('Note: Fallback query also failed: $e2');
      }
    }
    return [];
  }

  /// Updates report status and admin note in `reports` table
  static Future<bool> updateReportStatus({
    required String reportId,
    required String status,
    String? adminNote,
    String? handledBy,
  }) async {
    if (!isSupabaseAvailable) return true;

    try {
      final client = Supabase.instance.client;
      final nowIso = DateTime.now().toIso8601String();
      final dbStatus = toDbStatus(status);
      final updateData = <String, dynamic>{
        'status': dbStatus,
        'updated_at': nowIso,
      };

      if (adminNote != null) {
        updateData['admin_note'] = adminNote;
      }
      if (handledBy != null) {
        updateData['handled_by'] = handledBy;
      }
      if (dbStatus == 'resolved') {
        updateData['resolved_at'] = nowIso;
      }

      await client.from('reports').update(updateData).eq('id', reportId);
      return true;
    } catch (e) {
      debugPrint('Note: Error updating report status: $e');
      return false;
    }
  }

  /// Default fallback types matching `report_types` table
  static final List<ReportTypeModel> _defaultReportTypes = [
    ReportTypeModel(
      id: '6fbd4f3d-d541-470a-b1c8-6b30f801ed73',
      code: 'wrong_info',
      name: 'ข้อมูลร้านค้าไม่ถูกต้อง',
      description: 'ชื่อร้าน เมนู ราคา เวลาเปิด-ปิด พิกัด หรือเบอร์โทรศัพท์',
      icon: 'store',
      sortOrder: 1,
    ),
    ReportTypeModel(
      id: '12c5d795-95c4-474b-baa3-ce076fae8064',
      code: 'not_found',
      name: 'ร้านค้าปิดหรือไม่พบร้าน',
      description: 'ร้านปิดถาวร ปิดชั่วคราว ย้ายที่ตั้ง หรือค้นหาตามพิกัดไม่พบ',
      icon: 'map-pin-off',
      sortOrder: 2,
    ),
    ReportTypeModel(
      id: '9054a788-aeb9-42fa-8be6-28312582093d',
      code: 'app_issue',
      name: 'ปัญหาการใช้งานแอปพลิเคชัน',
      description: 'แอปค้าง บั๊กการทำงาน ระบบปัด/บันทึกร้าน หรือปัญหาบัญชีผู้ใช้',
      icon: 'smartphone',
      sortOrder: 3,
    ),
    ReportTypeModel(
      id: 'a4e51ad4-ef09-4045-b8b3-6717d839179b',
      code: 'other',
      name: 'อื่นๆ',
      description: 'ข้อเสนอแนะเพื่อการพัฒนา ติชม หรือปัญหาอื่นๆ ที่ต้องการแจ้งให้ทีมงานทราบ',
      icon: 'ellipsis',
      sortOrder: 4,
    ),
  ];
}
