import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class VehicleMarkerService {
  Future<BitmapDescriptor> createVehicleMarker() async {
    const double size = 120;

    ui.PictureRecorder recorder = ui.PictureRecorder();

    Canvas canvas = Canvas(recorder);

    Paint backgroundPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    canvas.drawCircle(const Offset(size / 2, size / 2), 54, backgroundPaint);

    Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    canvas.drawCircle(const Offset(size / 2, size / 2), 54, borderPaint);

    TextPainter textPainter = TextPainter(
      text:  TextSpan(
        text: String.fromCharCode(Icons.directions_car_filled.codePoint),
        style: TextStyle(fontSize: 65, fontFamily: 'MaterialIcons', color: Colors.white),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    textPainter.paint(
      canvas,
      Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2),
    );

    ui.Picture picture = recorder.endRecording();

    ui.Image image = await picture.toImage(size.toInt(), size.toInt());

    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) {
      throw Exception('Unable to generate vehicle marker.');
    }

    return BitmapDescriptor.bytes(byteData.buffer.asUint8List(), imagePixelRatio: 2);
  }
}