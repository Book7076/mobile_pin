import 'package:flutter/material.dart';

/// Model representing a row from `reports` table
class ReportModel {
  final String id;
  final String? userId;
  final String? restaurantId;
  final String category;
  final String description;
  final String? contactEmail;
  final String status;
  final DateTime? createAt;
  final String? adminNote;
  final String? handledBy;
  final DateTime? resolvedAt;
  final DateTime? updatedAt;

  // Joined display metadata
  final String? restaurantName;
  final String? userName;
  final String? userPhone;

  ReportModel({
    required this.id,
    this.userId,
    this.restaurantId,
    required this.category,
    required this.description,
    this.contactEmail,
    this.status = 'pending',
    this.createAt,
    this.adminNote,
    this.handledBy,
    this.resolvedAt,
    this.updatedAt,
    this.restaurantName,
    this.userName,
    this.userPhone,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    String? rName;
    if (json['restaurants'] is Map && json['restaurants']['name'] != null) {
      rName = json['restaurants']['name'].toString();
    } else if (json['restaurant_name'] != null) {
      rName = json['restaurant_name'].toString();
    }

    String? uName;
    String? uPhone;
    if (json['users'] is Map) {
      final userMap = json['users'] as Map;
      final fName = userMap['first_name']?.toString() ?? '';
      final lName = userMap['last_name']?.toString() ?? '';
      final fullName = '$fName $lName'.trim();
      uName = fullName.isNotEmpty ? fullName : userMap['email']?.toString();
      uPhone = userMap['phone']?.toString();
    } else if (json['contact_email'] != null && json['contact_email'].toString().isNotEmpty) {
      uName = json['contact_email'].toString();
    }

    final rawStatus = json['status']?.toString() ?? 'pending';
    final uiStatus = rawStatus == 'reviewing' ? 'in_progress' : rawStatus;

    return ReportModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString(),
      restaurantId: json['restaurant_id']?.toString(),
      category: json['category']?.toString() ?? 'ข้อมูลร้านค้าไม่ถูกต้อง',
      description: json['description']?.toString() ?? '',
      contactEmail: json['contact_email']?.toString(),
      status: uiStatus,
      createAt: json['create_at'] != null
          ? DateTime.tryParse(json['create_at'].toString())
          : null,
      adminNote: json['admin_note']?.toString(),
      handledBy: json['handled_by']?.toString(),
      resolvedAt: json['resolved_at'] != null
          ? DateTime.tryParse(json['resolved_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      restaurantName: rName,
      userName: uName,
      userPhone: uPhone,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'restaurant_id': restaurantId,
      'category': category,
      'description': description,
      'contact_email': contactEmail,
      'status': status,
      'create_at': createAt?.toIso8601String(),
      'admin_note': adminNote,
      'handled_by': handledBy,
      'resolved_at': resolvedAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Returns Thai display title for the report category
  String get categoryDisplayTitle {
    switch (category) {
      case 'wrong_info':
      case 'store_info':
        return 'ข้อมูลร้านค้าไม่ถูกต้อง';
      case 'not_found':
      case 'store_closed':
        return 'ร้านค้าปิดหรือไม่พบร้าน';
      case 'app_issue':
        return 'ปัญหาการใช้งานแอปพลิเคชัน';
      case 'other':
        return 'อื่นๆ';
      default:
        return category;
    }
  }

  /// Returns icon matching the report category
  IconData get categoryIcon {
    switch (category) {
      case 'wrong_info':
      case 'store_info':
        return Icons.storefront_outlined;
      case 'not_found':
      case 'store_closed':
        return Icons.location_off_outlined;
      case 'app_issue':
        return Icons.phone_android_rounded;
      case 'other':
      default:
        return Icons.more_horiz_rounded;
    }
  }
}


/// Model representing a row from `report_types` table
class ReportTypeModel {
  final String id;
  final String code;
  final String name;
  final String description;
  final String icon;
  final int sortOrder;
  final bool isActive;

  ReportTypeModel({
    required this.id,
    required this.code,
    required this.name,
    this.description = '',
    this.icon = 'store',
    this.sortOrder = 0,
    this.isActive = true,
  });

  factory ReportTypeModel.fromJson(Map<String, dynamic> json) {
    return ReportTypeModel(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      icon: json['icon']?.toString() ?? 'store',
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] == true || json['is_active'] == 'true',
    );
  }

  IconData get iconData {
    switch (code) {
      case 'wrong_info':
      case 'store_info':
        return Icons.storefront_outlined;
      case 'not_found':
      case 'store_closed':
        return Icons.location_off_outlined;
      case 'app_issue':
        return Icons.phone_android_rounded;
      case 'other':
      default:
        return Icons.more_horiz_rounded;
    }
  }
}
