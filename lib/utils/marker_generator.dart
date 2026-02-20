import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerGenerator {
  static Future<BitmapDescriptor> createCustomMarkerBitmap(
    String title, {
    bool isSelected = false,
  }) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final Color bgColor = isSelected
        ? const Color(0xFFFF5252)
        : const Color(0xFF3366FF);
    final Paint paint = Paint()..color = bgColor;
    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    const double width = 32.0;
    const double height = 32.0;
    const double radius = 16.0;
    const double arrowSize = 12.0;
    const double totalHeight = height + arrowSize;

    final Path path = Path()
      ..moveTo(radius, 0)
      ..lineTo(width - radius, 0)
      ..arcToPoint(Offset(width, radius), radius: const Radius.circular(radius))
      ..lineTo(width, height - radius)
      ..arcToPoint(
        Offset(width - radius, height),
        radius: const Radius.circular(radius),
      )
      ..lineTo(width / 2 + arrowSize / 1.2, height)
      ..lineTo(width / 2, totalHeight)
      ..lineTo(width / 2 - arrowSize / 1.2, height)
      ..lineTo(radius, height)
      ..arcToPoint(
        Offset(0, height - radius),
        radius: const Radius.circular(radius),
      )
      ..lineTo(0, radius)
      ..arcToPoint(Offset(radius, 0), radius: const Radius.circular(radius))
      ..close();

    canvas.drawShadow(path, const Color(0x66000000), 5.0, false);

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);

    final Paint crossPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final double centerX = width / 2;
    final double centerY = height / 2;
    const double crossThickness = 6.0;
    const double crossLength = 16.0;
    const double crossRadius = 1.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX, centerY),
          width: crossThickness,
          height: crossLength,
        ),
        const Radius.circular(crossRadius),
      ),
      crossPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX, centerY),
          width: crossLength,
          height: crossThickness,
        ),
        const Radius.circular(crossRadius),
      ),
      crossPaint,
    );

    final ui.Image image = await pictureRecorder.endRecording().toImage(
      width.toInt(),
      totalHeight.toInt(),
    );
    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    final Uint8List uint8List = byteData!.buffer.asUint8List();

    return BitmapDescriptor.bytes(uint8List);
  }
}
