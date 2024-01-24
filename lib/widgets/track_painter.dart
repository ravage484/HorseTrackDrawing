import 'package:flutter/material.dart';
import 'package:horse_track_drawing/widgets/custom_painter.dart';

class TrackPainter extends BaseCustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final trackPaint = Paint()
      ..color = Colors.green[800]! // Color of the track
      ..style = PaintingStyle.fill; // Fill the track

    final trackOutlinePaint = Paint()
      ..color = Colors.brown // Outline color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0; // Outline width

    // Draw the track
    final trackPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(size.height / 2), // Rounded corners
      ));

    canvas.drawPath(trackPath, trackPaint); // Fill
    canvas.drawPath(trackPath, trackOutlinePaint); // Outline
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
