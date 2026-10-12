import 'package:flutter_test/flutter_test.dart';
import 'package:pin_mobile/models/report_model.dart';
import 'package:pin_mobile/services/report_service.dart';

void main() {
  group('ReportService & ReportModel Unit Tests', () {
    test('ReportTypeModel maps json and provides correct icon', () {
      final model = ReportTypeModel.fromJson({
        'id': 'test-id',
        'code': 'wrong_info',
        'name': 'ข้อมูลร้านค้าไม่ถูกต้อง',
        'description': 'ชื่อร้านหรือเมนูไม่ถูกต้อง',
        'icon': 'store',
        'sort_order': 1,
        'is_active': true,
      });

      expect(model.id, 'test-id');
      expect(model.code, 'wrong_info');
      expect(model.name, 'ข้อมูลร้านค้าไม่ถูกต้อง');
      expect(model.isActive, isTrue);
      expect(model.iconData, isNotNull);
    });

    test('ReportModel maps json correctly with joined relations', () {
      final report = ReportModel.fromJson({
        'id': 'rep-123',
        'user_id': 'usr-456',
        'restaurant_id': 'res-789',
        'category': 'ข้อมูลร้านค้าไม่ถูกต้อง',
        'description': 'เวลาเปิดปิดไม่ตรง',
        'contact_email': 'user@test.com',
        'status': 'pending',
        'create_at': '2026-10-12T14:30:00Z',
        'updated_at': '2026-10-12T14:30:00Z',
        'restaurants': {'name': 'RawTruckr'},
        'users': {
          'first_name': 'Zoe',
          'last_name': 'Evans',
          'phone': '0812345678',
        },
      });

      expect(report.id, 'rep-123');
      expect(report.restaurantName, 'RawTruckr');
      expect(report.userName, 'Zoe Evans');
      expect(report.userPhone, '0812345678');
      expect(report.category, 'ข้อมูลร้านค้าไม่ถูกต้อง');
      expect(report.status, 'pending');
    });

    test('ReportService fetches default report types when offline', () async {
      final types = await ReportService.fetchReportTypes();
      expect(types, isNotEmpty);
      expect(types.length, 4);
      expect(types.any((t) => t.name == 'ข้อมูลร้านค้าไม่ถูกต้อง'), isTrue);
    });

    test('ReportService handles submit report gracefully when uninitialized', () async {
      final result = await ReportService.submitReport(
        category: 'ข้อมูลร้านค้าไม่ถูกต้อง',
        description: 'เมนูราคาไม่ตรงกับป้าย',
        restaurantName: 'RawTruckr',
      );
      expect(result, isNotNull);
    });

    test('normalizeCategoryCode converts Thai and legacy inputs to valid FK code', () {
      expect(ReportService.normalizeCategoryCode('ข้อมูลร้านค้าไม่ถูกต้อง'), 'wrong_info');
      expect(ReportService.normalizeCategoryCode('store_info'), 'wrong_info');
      expect(ReportService.normalizeCategoryCode('wrong_info'), 'wrong_info');

      expect(ReportService.normalizeCategoryCode('ร้านค้าปิดหรือไม่พบร้าน'), 'not_found');
      expect(ReportService.normalizeCategoryCode('store_closed'), 'not_found');
      expect(ReportService.normalizeCategoryCode('not_found'), 'not_found');

      expect(ReportService.normalizeCategoryCode('ปัญหาการใช้งานแอปพลิเคชัน'), 'app_issue');
      expect(ReportService.normalizeCategoryCode('app_issue'), 'app_issue');

      expect(ReportService.normalizeCategoryCode('อื่นๆ'), 'other');
      expect(ReportService.normalizeCategoryCode('other'), 'other');
      expect(ReportService.normalizeCategoryCode('unknown_category'), 'other');
    });

    test('ReportModel provides categoryDisplayTitle and categoryIcon correctly', () {
      final report = ReportModel(
        id: 'rep-1',
        category: 'wrong_info',
        description: 'test',
      );
      expect(report.categoryDisplayTitle, 'ข้อมูลร้านค้าไม่ถูกต้อง');
      expect(report.categoryIcon, isNotNull);
    });

    test('toDbStatus and toUiStatus map correctly between UI and Supabase check constraints', () {
      expect(ReportService.toDbStatus('in_progress'), 'reviewing');
      expect(ReportService.toDbStatus('กำลังตรวจสอบ'), 'reviewing');
      expect(ReportService.toDbStatus('resolved'), 'resolved');
      expect(ReportService.toDbStatus('แก้ไขแล้ว'), 'resolved');
      expect(ReportService.toDbStatus('pending'), 'pending');

      expect(ReportService.toUiStatus('reviewing'), 'in_progress');
      expect(ReportService.toUiStatus('pending'), 'pending');
      expect(ReportService.toUiStatus('resolved'), 'resolved');
    });

    test('ReportModel.fromJson maps reviewing status to in_progress and uses contact_email as fallback', () {
      final report = ReportModel.fromJson({
        'id': 'rep-reviewing',
        'category': 'app_issue',
        'description': 'แอปค้าง',
        'contact_email': 'emma.wilson@gmail.com',
        'status': 'reviewing',
        'create_at': '2026-10-12T22:36:07.017156',
      });

      expect(report.status, 'in_progress');
      expect(report.userName, 'emma.wilson@gmail.com');
      expect(report.categoryDisplayTitle, 'ปัญหาการใช้งานแอปพลิเคชัน');
    });
  });
}
