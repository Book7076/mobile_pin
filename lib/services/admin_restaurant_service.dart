import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/restaurant_admin_model.dart';
import '../main.dart';

class AdminRestaurantNotifier extends StateNotifier<List<RestaurantAdminModel>> {
  AdminRestaurantNotifier() : super(_initialMockData) {
    _fetchFromSupabase();
  }

  static final List<RestaurantAdminModel> _initialMockData = [
    RestaurantAdminModel(
      id: 'res-01',
      ownerId: 'user-01',
      ownerName: 'คุณกิตติศักดิ์ ชัยชนะ',
      name: 'Kohatsu Matcha',
      storeCode: '111U1103',
      address: 'เทศบาลเชียงใหม่ อำเภอเมือง จังหวัดเชียงใหม่ ประเทศไทย',
      mapUrl: 'www.googlemap.com',
      phone: '083-666-7777',
      email: 'kohatsu.matcha@gmail.com',
      category: 'เครื่องดื่ม/คาเฟ่',
      imageUrl: 'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?w=400',
      status: 'pending',
      createdAt: DateTime(2026, 8, 2, 10, 30),
      documentUrl: 'https://example.com/docs/kohatsu_license.pdf',
      openingHours: {
        'อาทิตย์': '07.00 - 16.00',
        'จันทร์': '07.00 - 16.00',
        'อังคาร': '07.00 - 16.00',
        'พุธ': '07.00 - 16.00',
        'พฤหัสบดี': '07.00 - 16.00',
        'ศุกร์': '07.00 - 16.00',
        'เสาร์': '07.00 - 16.00',
      },
      amenities: ['จอดจักรยานยนต์', 'มีอินเทอร์เน็ต'],
      menuItems: [
        RestaurantMenuItem(
          name: 'Earl Grey Matcha Foam',
          price: 99,
          imageUrl: 'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?w=300',
        ),
        RestaurantMenuItem(
          name: 'Matcha Ocean',
          price: 89,
          imageUrl: 'https://images.unsplash.com/photo-1576092768241-dec231879fc3?w=300',
        ),
        RestaurantMenuItem(
          name: 'Matcha Foam Latte',
          price: 75,
          imageUrl: 'https://images.unsplash.com/photo-1544787219-7f47ccb76574?w=300',
        ),
      ],
    ),
    RestaurantAdminModel(
      id: 'res-02',
      ownerId: 'user-02',
      ownerName: 'คุณสมชาย พัฒนกิจ',
      name: 'ข้าวบ้านก๋ง',
      address: '45 ซอยอารีย์สัมพันธ์ แขวงพญาไท เขตพญาไท กรุงเทพฯ 10400',
      phone: '089-876-5432',
      email: 'grandpa.homekitchen@gmail.com',
      category: 'อาหารไทยโบราณ & โฮมคุกกิ้ง',
      menu: 'ข้าวหมูกรอบคั่วพริกเกลือ, ไข่พะโล้โบราณ, แกงส้มชะอมกุ้งสด',
      imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',
      status: 'pending',
      createdAt: DateTime(2026, 8, 1, 14, 15),
      documentUrl: 'https://example.com/docs/grandpa_license.pdf',
    ),
    RestaurantAdminModel(
      id: 'res-03',
      ownerId: 'user-03',
      ownerName: 'คุณวิภาวรรณ สดใส',
      name: 'Potto Hot Pot',
      address: '99/1 โครงการมาร์เช่ ทองหล่อ ซอยสุขุมวิท 55 เขตวัฒนา กรุงเทพฯ 10110',
      phone: '02-987-6543',
      email: 'contact@pottohotpot.com',
      category: 'ชาบู & สุกี้ หม้อไฟสไตล์ญี่ปุ่น',
      menu: 'ชุดเนื้อวากิวพรีเมียม A4, ซุปสุกี้ยากี้น้ำดำ, ซุปกระดูกหมูทงคตสึ',
      imageUrl: 'https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=400',
      status: 'pending',
      createdAt: DateTime(2026, 8, 1, 9, 45),
      documentUrl: 'https://example.com/docs/potto_cert.pdf',
    ),
    // ร้านที่อนุมัติแล้ว
    RestaurantAdminModel(
      id: 'res-04',
      ownerId: 'user-04',
      ownerName: 'คุณณภัทร วงศ์เจริญ',
      name: 'Haru Sushi Bar',
      address: '77 ซอยทองหล่อ 10 เขตวัฒนา กรุงเทพฯ 10110',
      phone: '095-112-3344',
      email: 'harusushi@gmail.com',
      category: 'อาหารญี่ปุ่น & ซูชิบาร์',
      menu: 'Salmon Sashimi Set, Otoro Nigiri, Unagi Don',
      imageUrl: 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=400',
      status: 'approved',
      createdAt: DateTime(2026, 7, 28, 11, 0),
    ),
    RestaurantAdminModel(
      id: 'res-05',
      ownerId: 'user-05',
      ownerName: 'ป้าอนงค์ สุขเกษม',
      name: 'ส้มตำเจ๊นก ครกยักษ์',
      address: '12 ถนนประชาชื่น เขตบางซื่อ กรุงเทพฯ 10800',
      phone: '084-555-6677',
      email: 'somtum.nok@gmail.com',
      category: 'อาหารอีสานรสเด็ด',
      menu: 'ส้มตำปูปลาร้า, คอหมูย่างเตาถ่าน, ไก่ย่างเขาสวนกวาง',
      imageUrl: 'https://images.unsplash.com/photo-1559847844-5315695dadae?w=400',
      status: 'approved',
      createdAt: DateTime(2026, 7, 25, 13, 20),
    ),
    // ร้านที่ไม่อนุมัติ (ตรงตามภาพที่ 1 และภาพที่ 3)
    RestaurantAdminModel(
      id: 'res-rejected-01',
      ownerId: 'user-06',
      ownerName: 'คุณปนัสยา ใจดี',
      name: 'เตาอุ่น',
      storeCode: '111U1101',
      category: 'ขนมหวาน/เบเกอรี่',
      address: 'เทศบาลเชียงใหม่ อำเภอเมือง จังหวัดเชียงใหม่ ประเทศไทย',
      mapUrl: 'www.googlemap.com',
      phone: '091234567',
      email: 'tao-oon.bakery@gmail.com',
      imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400',
      status: 'rejected',
      createdAt: DateTime(2026, 8, 2, 9, 0),
      requestSubmittedDate: DateTime(2026, 8, 3),
      rejectionReason: 'ที่อยู่ไม่ถูกต้อง',
      reviewerName: 'ปนัสยา',
      openingHours: {
        'อาทิตย์': '08.00 - 21.00',
        'จันทร์': '08.00 - 21.00',
        'อังคาร': '08.00 - 21.00',
        'พุธ': '08.00 - 21.00',
        'พฤหัสบดี': '08.00 - 21.00',
        'ศุกร์': '08.00 - 21.00',
        'เสาร์': '08.00 - 21.00',
      },
      amenities: [
        'ที่จอดรถยนต์',
        'รถจักรยานยนต์',
        'มีอินเทอร์เน็ต',
        'เครื่องปรับอากาศ',
      ],
      menuItems: [
        RestaurantMenuItem(
          name: 'ชีสเค้ก',
          price: 50,
          description: 'มีส่วนประกอบของนมวัว, ไข่',
          imageUrl: 'https://images.unsplash.com/photo-1533134242443-d4fd215305ad?w=300',
        ),
        RestaurantMenuItem(
          name: 'ชิโอะปัง',
          price: 35,
          description: 'มีส่วนประกอบของแป้งสาลี, นมวัว, ไข่',
          imageUrl: 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=300',
        ),
        RestaurantMenuItem(
          name: 'ทาร์ตไข่',
          price: 20,
          description: 'มีส่วนประกอบของแป้งสาลี, นมวัว, ไข่',
          imageUrl: 'https://images.unsplash.com/photo-1587314168485-3236d6710814?w=300',
        ),
      ],
    ),
    RestaurantAdminModel(
      id: 'res-rejected-02',
      ownerId: 'user-07',
      ownerName: 'คุณกานต์ เมธากุล',
      name: 'KAME KAFE',
      storeCode: '111U1102',
      category: 'เครื่องดื่ม/กาแฟ',
      address: 'เทศบาลเชียงใหม่ อำเภอเมือง จังหวัดเชียงใหม่ ประเทศไทย',
      phone: '091-234-5678',
      status: 'rejected',
      createdAt: DateTime(2026, 8, 2, 9, 0),
      requestSubmittedDate: DateTime(2026, 8, 2),
      rejectionReason: 'ไม่ตรงตามเงื่อนไข',
      reviewerName: 'ปนัสยา',
    ),
    RestaurantAdminModel(
      id: 'res-rejected-03',
      ownerId: 'user-08',
      ownerName: 'คุณวิทวัส ชัยพฤกษ์',
      name: 'สุกี้ช้างเผือก',
      storeCode: '111U1103',
      category: 'อาหารตามสั่ง/สุกี้',
      address: 'เทศบาลเชียงใหม่ อำเภอเมือง จังหวัดเชียงใหม่ ประเทศไทย',
      phone: '089-876-5432',
      status: 'rejected',
      createdAt: DateTime(2026, 8, 1, 9, 0),
      requestSubmittedDate: DateTime(2026, 8, 1),
      rejectionReason: 'ไม่ตรงตามเงื่อนไข',
      reviewerName: 'ปนัสยา',
    ),
    // ร้านเดิมสำหรับทดสอบ
    RestaurantAdminModel(
      id: 'res-06',
      ownerId: 'user-09',
      ownerName: 'คุณประดิษฐ์ รักษ์ดี',
      name: 'กาแฟโบราณลุงสม',
      address: '88 ถนนเจริญกรุง แขวงวังบูรพา เขตพระนคร กรุงเทพฯ',
      phone: '086-777-8899',
      category: 'เครื่องดื่ม & กาแฟโบราณ',
      imageUrl: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=400',
      status: 'rejected',
      createdAt: DateTime(2026, 7, 20, 16, 40),
      rejectionReason: 'เอกสารใบจดทะเบียนพาณิชย์หมดอายุหรือไม่ชัดเจน กรุณาอัปโหลดเอกสารฉบับปัจจุบัน',
    ),
  ];

  Future<void> _fetchFromSupabase() async {
    try {
      final response = await supabase
          .from('restaurants')
          .select()
          .order('created_at', ascending: false);

      if (response.isNotEmpty) {
        final List<RestaurantAdminModel> loaded = [];
        for (var item in response) {
          loaded.add(RestaurantAdminModel.fromJson(item));
        }
        state = loaded;
      }
    } catch (_) {
      // ใช้ Mock Data ต่อไปหากยังไม่ได้ต่อ Database จริง
    }
  }

  /// อนุมัติร้านอาหาร
  Future<bool> approveRestaurant(String id) async {
    try {
      // พยายามอัปเดตไปที่ Supabase
      try {
        await supabase.from('restaurants').update({
          'status': 'approved',
        }).eq('id', id);
      } catch (_) {}

      // อัปเดต State ภายในแอป
      state = state.map((restaurant) {
        if (restaurant.id == id) {
          return restaurant.copyWith(status: 'approved', clearRejection: true);
        }
        return restaurant;
      }).toList();

      return true;
    } catch (e) {
      return false;
    }
  }

  /// ไม่อนุมัติร้านอาหาร พร้อมระบุเหตุผล
  Future<bool> rejectRestaurant(String id, String reason) async {
    try {
      try {
        await supabase.from('restaurants').update({
          'status': 'rejected',
          'rejection_reason': reason,
        }).eq('id', id);
      } catch (_) {}

      state = state.map((restaurant) {
        if (restaurant.id == id) {
          return restaurant.copyWith(
            status: 'rejected',
            rejectionReason: reason,
          );
        }
        return restaurant;
      }).toList();

      return true;
    } catch (e) {
      return false;
    }
  }

  /// ยกเลิกการอนุมัติ พร้อมระบุเหตุผล
  Future<bool> cancelApproval(String id, String reason) async {
    try {
      try {
        await supabase.from('restaurants').update({
          'status': 'rejected',
          'rejection_reason': reason,
        }).eq('id', id);
      } catch (_) {}

      state = state.map((restaurant) {
        if (restaurant.id == id) {
          return restaurant.copyWith(
            status: 'rejected',
            rejectionReason: reason,
          );
        }
        return restaurant;
      }).toList();

      return true;
    } catch (e) {
      return false;
    }
  }

  /// ยกเลิกการไม่อนุมัติ (ย้ายร้านกลับสู่สถานะรออนุมัติ pending และล้างเหตุผลการไม่อนุมัติ)
  Future<bool> cancelRejection(String id) async {
    try {
      try {
        await supabase.from('restaurants').update({
          'status': 'pending',
          'rejection_reason': null,
          'reviewer_name': null,
        }).eq('id', id);
      } catch (_) {}

      state = state.map((restaurant) {
        if (restaurant.id == id) {
          return restaurant.copyWith(
            status: 'pending',
            clearRejection: true,
          );
        }
        return restaurant;
      }).toList();

      return true;
    } catch (e) {
      return false;
    }
  }

  /// นำร้านกลับมาตรวจสอบใหม่
  Future<bool> resetToPending(String id) async {
    try {
      try {
        await supabase.from('restaurants').update({
          'status': 'pending',
          'rejection_reason': null,
        }).eq('id', id);
      } catch (_) {}

      state = state.map((restaurant) {
        if (restaurant.id == id) {
          return restaurant.copyWith(
            status: 'pending',
            clearRejection: true,
          );
        }
        return restaurant;
      }).toList();

      return true;
    } catch (e) {
      return false;
    }
  }
}

final adminRestaurantProvider =
    StateNotifierProvider<AdminRestaurantNotifier, List<RestaurantAdminModel>>((ref) {
  return AdminRestaurantNotifier();
});
