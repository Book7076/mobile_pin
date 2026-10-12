import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

const Color kCropPrimaryColor = Color(0xFF8B1E3F);

/// หน้าจอสำหรับครอบตัดรูปภาพ (Image Crop Screen)
/// รองรับการซูม (Pinch-to-zoom), แพน (Pan), หมุนภาพ 90 องศา (Rotate), และรีเซ็ต
class ImageCropScreen extends StatefulWidget {
  final Uint8List imageBytes;
  final double aspectRatio; // อัตราส่วน เช่น 1.0 (สี่เหลี่ยมจัตุรัส 1:1) หรือ (width / height)
  final double cornerRadius; // ความโค้งมนของมุมกรอบ
  final double? targetWidth; // ขนาดความกว้างที่ต้องการ เช่น ขนาดการ์ดในหน้าปัดร้านอาหาร
  final double? targetHeight; // ขนาดความสูงที่ต้องการ เช่น ขนาดการ์ดในหน้าปัดร้านอาหาร
  final String title;
  final String? subtitleTag;

  const ImageCropScreen({
    super.key,
    required this.imageBytes,
    this.aspectRatio = 1.0,
    this.cornerRadius = 8.0,
    this.targetWidth,
    this.targetHeight,
    this.title = 'ครอบตัดรูปภาพ',
    this.subtitleTag,
  });

  @override
  State<ImageCropScreen> createState() => _ImageCropScreenState();
}

class _ImageCropScreenState extends State<ImageCropScreen> {
  final GlobalKey _cropKey = GlobalKey();
  final TransformationController _transformController = TransformationController();
  int _quarterTurns = 0;
  bool _isProcessing = false;

  void _rotateImage() {
    setState(() {
      _quarterTurns = (_quarterTurns + 1) % 4;
      _transformController.value = Matrix4.identity();
    });
  }

  void _resetTransform() {
    setState(() {
      _quarterTurns = 0;
      _transformController.value = Matrix4.identity();
    });
  }

  Future<void> _captureCroppedImage() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final boundary = _cropKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary != null) {
        final ui.Image image = await boundary.toImage(pixelRatio: 2.5);
        final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        image.dispose();

        if (byteData != null) {
          final croppedBytes = byteData.buffer.asUint8List();
          if (mounted) {
            Navigator.pop(context, croppedBytes);
            return;
          }
        }
      }
    } catch (e) {
      debugPrint('Error cropping image: $e');
    }

    if (mounted) {
      setState(() => _isProcessing = false);
      // กรณีเกิดข้อผิดพลาดในการ capture ให้ใช้รูปภาพเดิม
      Navigator.pop(context, widget.imageBytes);
    }
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: _isProcessing ? null : _captureCroppedImage,
              style: TextButton.styleFrom(
                backgroundColor: kCropPrimaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              icon: _isProcessing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.check_rounded, size: 18, color: Colors.white),
              label: const Text(
                'ครอบตัด',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // คำแนะนำด้านบน
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'เลื่อน ซูม หรือหมุนภาพให้อยู่ในกรอบที่ต้องการ',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  ),
                  if (widget.subtitleTag != null) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: kCropPrimaryColor.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: kCropPrimaryColor.withOpacity(0.7), width: 1),
                      ),
                      child: Text(
                        widget.subtitleTag!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // พื้นที่แสดงภาพและกรอบครอบตัด
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double cropWidth;
                  double cropHeight;

                  if (widget.targetWidth != null &&
                      widget.targetHeight != null &&
                      widget.targetHeight! > 0) {
                    cropWidth = widget.targetWidth!;
                    cropHeight = widget.targetHeight!;

                    final maxAvailableWidth = (constraints.maxWidth - 24).clamp(100.0, 1000.0);
                    final maxAvailableHeight = (constraints.maxHeight - 20).clamp(100.0, 1000.0);

                    // หากขนาดเกินพื้นที่แสดงผลจริงของหน้าจอครอบตัด ให้ย่อขนาดลงตามสัดส่วนการ์ดอย่างแม่นยำ
                    if (cropWidth > maxAvailableWidth || cropHeight > maxAvailableHeight) {
                      final scaleW = maxAvailableWidth / cropWidth;
                      final scaleH = maxAvailableHeight / cropHeight;
                      final scale = (scaleW < scaleH ? scaleW : scaleH).clamp(0.1, 1.0);
                      cropWidth *= scale;
                      cropHeight *= scale;
                    }
                  } else {
                    final maxAvailableWidth = (constraints.maxWidth - 44).clamp(160.0, 500.0);
                    final maxAvailableHeight = (constraints.maxHeight - 24).clamp(160.0, 700.0);

                    cropWidth = maxAvailableWidth;
                    cropHeight = cropWidth / widget.aspectRatio;

                    if (cropHeight > maxAvailableHeight) {
                      cropHeight = maxAvailableHeight;
                      cropWidth = cropHeight * widget.aspectRatio;
                    }

                    if (cropWidth > maxAvailableWidth) {
                      cropWidth = maxAvailableWidth;
                      cropHeight = cropWidth / widget.aspectRatio;
                    }
                  }

                  return Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // ส่วนที่จะถูกจับภาพ (RepaintBoundary)
                        RepaintBoundary(
                          key: _cropKey,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(widget.cornerRadius),
                            child: Container(
                              width: cropWidth,
                              height: cropHeight,
                              color: Colors.black,
                              child: InteractiveViewer(
                                transformationController: _transformController,
                                minScale: 0.5,
                                maxScale: 4.0,
                                boundaryMargin: const EdgeInsets.all(double.infinity),
                                child: Center(
                                  child: RotatedBox(
                                    quarterTurns: _quarterTurns,
                                    child: Image.memory(
                                      widget.imageBytes,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // กรอบเส้นสี่เหลี่ยมและเส้นตาราง (Grid / Rule of Thirds)
                        IgnorePointer(
                          child: Container(
                            width: cropWidth,
                            height: cropHeight,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white.withOpacity(0.85), width: 2),
                              borderRadius: BorderRadius.circular(widget.cornerRadius),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(widget.cornerRadius),
                              child: Stack(
                                children: [
                                  // เส้นตารางแนวตั้ง 2 เส้น
                                  Positioned(
                                    left: cropWidth / 3,
                                    top: 0,
                                    bottom: 0,
                                    child: Container(width: 1, color: Colors.white.withOpacity(0.3)),
                                  ),
                                  Positioned(
                                    left: (cropWidth / 3) * 2,
                                    top: 0,
                                    bottom: 0,
                                    child: Container(width: 1, color: Colors.white.withOpacity(0.3)),
                                  ),
                                  // เส้นตารางแนวนอน 2 เส้น
                                  Positioned(
                                    top: cropHeight / 3,
                                    left: 0,
                                    right: 0,
                                    child: Container(height: 1, color: Colors.white.withOpacity(0.3)),
                                  ),
                                  Positioned(
                                    top: (cropHeight / 3) * 2,
                                    left: 0,
                                    right: 0,
                                    child: Container(height: 1, color: Colors.white.withOpacity(0.3)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // แถบเครื่องมือด้านล่าง (หมุนภาพ, รีเซ็ต)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              color: const Color(0xFF18181B),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: _rotateImage,
                    icon: const Icon(Icons.rotate_right_rounded, color: Colors.white),
                    label: const Text('หมุนภาพ', style: TextStyle(color: Colors.white)),
                  ),
                  TextButton.icon(
                    onPressed: _resetTransform,
                    icon: const Icon(Icons.restart_alt_rounded, color: Colors.white70),
                    label: const Text('รีเซ็ต', style: TextStyle(color: Colors.white70)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
