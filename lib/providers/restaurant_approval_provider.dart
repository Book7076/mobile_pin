import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/approval_restaurant.dart';

class RestaurantApprovalNotifier extends StateNotifier<List<ApprovalRestaurant>> {
  RestaurantApprovalNotifier() : super(_initialRestaurants);

  static final List<ApprovalRestaurant> _initialRestaurants = [
    // 1. Kohatsu Matcha (Pending from Image 1 & Image 3)
    const ApprovalRestaurant(
      id: 'kohatsu_matcha',
      name: 'Kohatsu Matcha',
      code: '111U1103',
      category: 'เครื่องดื่ม/คาเฟ่',
      lastUpdated: '2 ส.ค. 2569',
      requestDate: '2 ส.ค. 2569',
      address: 'เทศบาลเชียงใหม่ อำเภอเมือง จังหวัดเชียงใหม่ ประเทศไทย',
      mapUrl: 'www.googlemap.com',
      phone: '083-666-7777',
      imageAsset: 'assets/images/kohatsu_matcha.jpg',
      openingHours: {
        'อาทิตย์': '07.00 - 16.00',
        'จันทร์': '07.00 - 16.00',
        'อังคาร': '07.00 - 16.00',
        'พุธ': '07.00 - 16.00',
        'พฤหัสบดี': '07.00 - 16.00',
        'ศุกร์': '07.00 - 16.00',
        'เสาร์': '07.00 - 16.00',
      },
      amenities: ['รถจักรยานยนต์', 'มีอินเทอร์เน็ต'],
      menuItems: [
        ApprovalMenuItem(
          name: 'Earl Grey Matcha Foam',
          ingredients: 'ชาเอิร์ลเกรย์พรีเมียม ท็อปด้วยโฟมมัทฉะเข้มข้น',
          price: '฿99',
          imageAsset: 'assets/images/earl_grey_matcha.jpg',
        ),
        ApprovalMenuItem(
          name: 'Matcha Ocean',
          ingredients: 'มัทฉะชิซูโอกะ เลเยอร์นมสดและน้ำเชื่อมบลูคูราโซ่',
          price: '฿89',
          imageAsset: 'assets/images/matcha_ocean.jpg',
        ),
        ApprovalMenuItem(
          name: 'Matcha Foam Latte',
          ingredients: 'มัทฉะลาเต้นมสดนุ่มละมุน ท็อปด้วยฟองนมหนานุ่ม',
          price: '฿75',
          imageAsset: 'assets/images/matcha_foam_latte.jpg',
        ),
      ],
      status: 'pending',
    ),

    // 2. ข้าวบ้านก๋ง (Pending from Image 1)
    const ApprovalRestaurant(
      id: 'khao_baan_gong',
      name: 'ข้าวบ้านก๋ง',
      code: '111U1104',
      category: 'อาหารไทย/อาหารตามสั่ง',
      lastUpdated: '1 ส.ค. 2569',
      requestDate: '1 ส.ค. 2569',
      address: '45/1 ถนนสุเทพ ตำบลสุเทพ อำเภอเมือง จังหวัดเชียงใหม่ 50200',
      mapUrl: 'www.googlemap.com',
      phone: '082-345-6789',
      imageAsset: 'assets/images/khao_baan_gong.jpg',
      openingHours: {
        'อาทิตย์': '09.00 - 20.00',
        'จันทร์': '09.00 - 20.00',
        'อังคาร': '09.00 - 20.00',
        'พุธ': '09.00 - 20.00',
        'พฤหัสบดี': '09.00 - 20.00',
        'ศุกร์': '09.00 - 20.00',
        'เสาร์': '09.00 - 20.00',
      },
      amenities: ['รถจักรยานยนต์'],
      menuItems: [
        ApprovalMenuItem(
          name: 'ข้าวผัดโบราณก๋ง',
          ingredients: 'ข้าวผัดซีอิ๊วดำหอมกลิ่นกระทะ หมูหมักนุ่ม',
          price: '฿55',
          imageAsset: 'assets/images/food_fried_rice.jpg',
        ),
        ApprovalMenuItem(
          name: 'ต้มยำกุ้งน้ำข้นยอดมะพร้าว',
          ingredients: 'กุ้งสดตัวโต ต้มยำสมุนไพรสดแท้',
          price: '฿80',
          imageAsset: 'assets/images/food_tomyum.jpg',
        ),
      ],
      status: 'pending',
    ),

    // 3. Potto Hot Pot (Pending from Image 1)
    const ApprovalRestaurant(
      id: 'potto_hot_pot',
      name: 'Potto Hot Pot',
      code: '111U1105',
      category: 'ชาบู/สุกี้',
      lastUpdated: '1 ส.ค. 2569',
      requestDate: '1 ส.ค. 2569',
      address: 'นิมมานเหมินท์ ซอย 9 ตำบลสุเทพ อำเภอเมือง จังหวัดเชียงใหม่ 50200',
      mapUrl: 'www.googlemap.com',
      phone: '089-777-6655',
      imageAsset: 'assets/images/potto_hot_pot.jpg',
      openingHours: {
        'อาทิตย์': '11.00 - 22.00',
        'จันทร์': '11.00 - 22.00',
        'อังคาร': '11.00 - 22.00',
        'พุธ': '11.00 - 22.00',
        'พฤหัสบดี': '11.00 - 22.00',
        'ศุกร์': '11.00 - 22.00',
        'เสาร์': '11.00 - 22.00',
      },
      amenities: ['รถจักรยานยนต์', 'มีอินเทอร์เน็ต'],
      menuItems: [
        ApprovalMenuItem(
          name: 'ชุดชาบูหมูพรีเมียม',
          ingredients: 'สันคอ สันนอก สามชั้น สไลซ์บางพร้อมชุดผักสด',
          price: '฿299',
          imageAsset: 'assets/images/food_shabu_pork.jpg',
        ),
        ApprovalMenuItem(
          name: 'ชุดเนื้อวากิวออสเตรเลีย',
          ingredients: 'เนื้อวากิวลายหินอ่อน นุ่มละลายในปาก',
          price: '฿459',
          imageAsset: 'assets/images/food_shabu_beef.jpg',
        ),
      ],
      status: 'pending',
    ),

    // 4. ดำเนินสะดวก (Approved)
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
      ],
      status: 'approved',
    ),

    // 5. The Volcano (Approved)
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

    // 6. เจียวดาวหลังมอ(เจ้าแรก) (Approved)
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
  ];

  /// Approve a pending restaurant.
  /// Moves status from 'pending' to 'approved'.
  void approveRestaurant(String restaurantId) {
    state = [
      for (final r in state)
        if (r.id == restaurantId)
          r.copyWith(
            status: 'approved',
            lastUpdated: '2 ส.ค. 2569',
          )
        else
          r,
    ];
  }

  /// Reject a pending restaurant with reason and optional details.
  /// Moves status from 'pending' to 'rejected'.
  void rejectRestaurant(String restaurantId, String reason, {String? details}) {
    state = [
      for (final r in state)
        if (r.id == restaurantId)
          r.copyWith(
            status: 'rejected',
            rejectionReason: reason.trim(),
            rejectionDetails: details?.trim(),
            lastUpdated: '2 ส.ค. 2569',
            revokedAt: DateTime.now(),
          )
        else
          r,
    ];
  }

  /// Revoke approval for an already approved restaurant.
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
