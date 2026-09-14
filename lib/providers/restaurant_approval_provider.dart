import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/approval_restaurant.dart';

class RestaurantApprovalNotifier extends StateNotifier<List<ApprovalRestaurant>> {
  RestaurantApprovalNotifier() : super(_initialRestaurants);

  static final List<ApprovalRestaurant> _initialRestaurants = [
    const ApprovalRestaurant(
      id: 'damnoen_saduak',
      name: 'ดำเนินสะดวก',
      code: '111U1102',
      category: 'อาหารตามสั่ง/คาเฟ่',
      lastUpdated: '2 ส.ค. 2569',
      requestDate: '2 ส.ค. 2569',
      address: '107 ซอย 7 บ้านใหม่หลังมอ หมู่ 14 ถนนสุเทพ ตำบลสุเทพ อ.เมือง เชียงใหม่ จ.เชียงใหม่ 50200',
      mapUrl: 'www.googlemap.com',
      phone: '085-555-5555',
      imageAsset: 'assets/images/damnoen_saduak.jpg',
      openingHours: {
        'อาทิตย์': '09.00 - 19.30',
        'จันทร์': '09.00 - 19.30',
        'อังคาร': '09.00 - 19.30',
        'พุธ': '09.00 - 19.30',
        'พฤหัสบดี': '09.00 - 19.30',
        'ศุกร์': '09.00 - 19.30',
        'เสาร์': '09.00 - 19.30',
      },
      amenities: ['รถจักรยานยนต์'],
      menuItems: [
        ApprovalMenuItem(
          name: 'ข้าวไข่ข้นกะเพราทะเล',
          ingredients: 'มีส่วนประกอบของไข่ไก่ กุ้ง ปลาหมึก',
          price: '฿65',
          imageAsset: 'assets/images/food_krapow_egg.jpg',
        ),
        ApprovalMenuItem(
          name: 'ข้าวกะเพราหมูกรอบ',
          ingredients: 'มีส่วนประกอบของใบกะเพรา กระเทียม',
          price: '฿65',
          imageAsset: 'assets/images/food_crispy_pork.jpg',
        ),
        ApprovalMenuItem(
          name: 'ข้าวไข่ข้นทะเล',
          ingredients: 'มีส่วนประกอบของไข่ไก่ กุ้ง ปลาหมึก',
          price: '฿65',
          imageAsset: 'assets/images/food_creamy_omelette.jpg',
        ),
      ],
      status: 'approved',
    ),
    const ApprovalRestaurant(
      id: 'the_volcano',
      name: 'The Volcano',
      code: '111U1103',
      category: 'ของหวาน/คาเฟ่',
      lastUpdated: '1 ส.ค. 2569',
      requestDate: '1 ส.ค. 2569',
      address: 'นิมมานเหมินท์ ซอย 5 ตำบลสุเทพ อ.เมือง จ.เชียงใหม่ 50200',
      mapUrl: 'www.googlemap.com',
      phone: '081-234-5678',
      imageAsset: 'assets/images/the_volcano.jpg',
      openingHours: {
        'อาทิตย์': '10.30 - 22.00',
        'จันทร์': '10.30 - 22.00',
        'อังคาร': '10.30 - 22.00',
        'พุธ': '10.30 - 22.00',
        'พฤหัสบดี': '10.30 - 22.00',
        'ศุกร์': '10.30 - 22.00',
        'เสาร์': '10.30 - 22.00',
      },
      amenities: ['รถจักรยานยนต์'],
      menuItems: [
        ApprovalMenuItem(
          name: 'Super Cheese Toast',
          ingredients: 'ขนมปังปิ้งโทสต์ ชีสยืดเนยสดเกรดพรีเมียม',
          price: '฿89',
          imageAsset: 'assets/images/the_volcano.jpg',
        ),
      ],
      status: 'approved',
    ),
    const ApprovalRestaurant(
      id: 'jeaw_dao',
      name: 'เจียวดาวหลังมอ(เจ้าแรก)',
      code: '111U1104',
      category: 'อาหารตามสั่ง',
      lastUpdated: '1 ส.ค. 2569',
      requestDate: '1 ส.ค. 2569',
      address: 'หลัง มช. ถนนสุเทพ ตำบลสุเทพ อ.เมือง จ.เชียงใหม่ 50200',
      mapUrl: 'www.googlemap.com',
      phone: '089-876-5432',
      imageAsset: 'assets/images/jeaw_dao.jpg',
      openingHours: {
        'อาทิตย์': '16.00 - 23.30',
        'จันทร์': '16.00 - 23.30',
        'อังคาร': '16.00 - 23.30',
        'พุธ': '16.00 - 23.30',
        'พฤหัสบดี': '16.00 - 23.30',
        'ศุกร์': '16.00 - 23.30',
        'เสาร์': '16.00 - 23.30',
      },
      amenities: ['รถจักรยานยนต์'],
      menuItems: [
        ApprovalMenuItem(
          name: 'ข้าวไข่เจียวดาวทรงเครื่อง',
          ingredients: 'ไข่ไก่ 2 ฟอง ขอบกรอบ ไข่แดงเยิ้ม พร้อมหมูสับ',
          price: '฿45',
          imageAsset: 'assets/images/jeaw_dao.jpg',
        ),
      ],
      status: 'approved',
    ),
    const ApprovalRestaurant(
      id: 'raw_truckr',
      name: 'RawTruckr',
      code: '111U1105',
      category: 'อาหารเกาหลี',
      lastUpdated: '3 ส.ค. 2569',
      requestDate: '3 ส.ค. 2569',
      address: 'สยามสแควร์ ซอย 7 กรุงเทพฯ',
      mapUrl: 'www.googlemap.com',
      phone: '089-111-2233',
      imageAsset: 'assets/images/Logo_mm.png',
      openingHours: {
        'อาทิตย์': '11.00 - 21.00',
      },
      amenities: ['รถจักรยานยนต์'],
      menuItems: [],
      status: 'pending',
    ),
  ];

  /// Revoke approval for a restaurant with a reason.
  /// Updates status to 'rejected' and records reason & time.
  void revokeApproval(String restaurantId, String reason) {
    state = [
      for (final r in state)
        if (r.id == restaurantId)
          r.copyWith(
            status: 'rejected',
            rejectionReason: reason.trim(),
            revokedAt: DateTime.now(),
          )
        else
          r,
    ];
  }

  /// Optional: Approve a pending restaurant
  void approveRestaurant(String restaurantId) {
    state = [
      for (final r in state)
        if (r.id == restaurantId)
          r.copyWith(status: 'approved')
        else
          r,
    ];
  }

  /// Reset state to initial mock data
  void resetToInitial() {
    state = _initialRestaurants;
  }
}

final restaurantApprovalProvider =
    StateNotifierProvider<RestaurantApprovalNotifier, List<ApprovalRestaurant>>((ref) {
  return RestaurantApprovalNotifier();
});

/// Search filter provider for store management tab
final restaurantSearchQueryProvider = StateProvider<String>((ref) => '');
