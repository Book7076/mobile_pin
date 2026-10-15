import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

/// วิดเจ็ตแสดงรูปภาพอเนกประสงค์
/// รองรับทั้ง URL เครือข่าย (http/https), ข้อมูลรูปภาพแบบ Base64 (data:image/...), และไฟล์ Asset (assets/...)
class AppAdaptiveImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? fallback;
  final BorderRadius? borderRadius;

  const AppAdaptiveImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fallback,
    this.borderRadius,
  });

  /// แปลง Base64 String ให้เป็น Uint8List
  static Uint8List? decodeBase64(String dataUri) {
    try {
      final commaIndex = dataUri.indexOf(',');
      final base64String =
          commaIndex != -1 ? dataUri.substring(commaIndex + 1) : dataUri;
      final clean = base64String.replaceAll(RegExp(r'\s+'), '');
      return base64Decode(clean);
    } catch (_) {
      return null;
    }
  }

  /// ตรวจสอบว่าเป็น Base64 Data URL หรือไม่
  static bool isBase64(String? url) {
    if (url == null) return false;
    final trimmed = url.trim();
    return trimmed.startsWith('data:image') || trimmed.startsWith('data:application');
  }

  /// สร้าง Image Widget ตามประเภทของ Image Source
  static Widget buildImage({
    required String? imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? fallback,
  }) {
    final defaultFallback = fallback ??
        Container(
          width: width,
          height: height,
          color: const Color(0xFFF9EEF2),
          child: const Center(
            child: Icon(
              Icons.storefront_rounded,
              color: Color(0xFF700F2B),
              size: 36,
            ),
          ),
        );

    if (imageUrl == null || imageUrl.trim().isEmpty) {
      return defaultFallback;
    }

    final trimmed = imageUrl.trim();

    // 1. Data URL (Base64)
    if (trimmed.startsWith('data:image') || trimmed.startsWith('data:application')) {
      final bytes = decodeBase64(trimmed);
      if (bytes != null && bytes.isNotEmpty) {
        return Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => defaultFallback,
        );
      }
      return defaultFallback;
    }

    // 2. HTTP / HTTPS Network URL
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return Image.network(
        trimmed,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => defaultFallback,
      );
    }

    // 3. Local Assets (assets/...)
    if (trimmed.startsWith('assets/')) {
      return Image.asset(
        trimmed,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => defaultFallback,
      );
    }

    // กรณีเป็น String Base64 เพียวๆ ที่ไม่มี data:image header
    if (trimmed.length > 100 && !trimmed.contains('/') && !trimmed.contains(' ')) {
      final bytes = decodeBase64(trimmed);
      if (bytes != null && bytes.isNotEmpty) {
        return Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => defaultFallback,
        );
      }
    }

    // Fallback สุดท้าย พยายามโหลดเป็น Image.asset
    return Image.asset(
      trimmed,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => defaultFallback,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = buildImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      fallback: fallback,
    );

    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}
