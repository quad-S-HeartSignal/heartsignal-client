import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerGenerator {
  static Future<BitmapDescriptor> createCustomMarkerBitmap({
    bool isSelected = false,
    bool isOpen = true,
    int targetWidth = 40,
  }) async {
    final String assetPath = isOpen
        ? 'assets/images/hospital_marker.png'
        : 'assets/images/hospital_marker_closed.png';

    final ByteData data = await rootBundle.load(assetPath);
    final Uint8List bytes = data.buffer.asUint8List();

    final double pixelRatio =
        ui.PlatformDispatcher.instance.views.first.devicePixelRatio;
    final int physicalWidth = (targetWidth * pixelRatio).round();

    final ui.Codec codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: physicalWidth,
    );
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ByteData? resizedByteData = await frameInfo.image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    final Uint8List resizedBytes = resizedByteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(
      resizedBytes,
      size: Size(targetWidth.toDouble(), targetWidth.toDouble()),
    );
  }
}
