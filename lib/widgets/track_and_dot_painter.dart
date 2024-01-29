import 'package:flutter/material.dart';
import 'package:horse_track_drawing/models/dot.dart';
import 'package:horse_track_drawing/widgets/custom_painter.dart';

// Custom painter class for drawing the track and animated dot
class TrackAndDotPainter extends CustomPainter {
  final List<Dot> dots;

  TrackAndDotPainter({required this.dots});

  @override
  void paint(Canvas canvas, Size size) {
    // Paint for the track outline
    final trackOutlinePaint = Paint()
      ..color = Colors.brown
      ..style = PaintingStyle.stroke
      ..strokeWidth = 60.0;

    // Paint for the track fill
    final trackFillPaint = Paint()
      ..color = Colors.green[800]!
      ..style = PaintingStyle.fill;

    // Define the track path (from center)
    // Center of the canvas
    final centerOffset = Offset(size.width / 2, size.height / 2);
    final trackPath = Path()
    ..addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: centerOffset, width: size.width, height: size.height),
      Radius.circular(size.height / 2),
      ));

    // Draw the filled track
    canvas.drawPath(trackPath, trackFillPaint);
    
    // Draw the track outline
    canvas.drawPath(trackPath, trackOutlinePaint);
    
    // Paint each animated dot with white outlines
    for (var dot in dots) {
      // Get the current progress of the animation
      final progress = dot.controller.value;

      // Get the dot's properties
      final dotPaint = Paint()..color = dot.color;
      final outlinePaint = Paint()..color = Colors.white;
      const dotRadius = 10.0;
      const outlineWidth = 4.0;
      final pathMetrics = trackPath.computeMetrics();
      final metric = pathMetrics.first;

      // Calculate the position of the dot based on the progress of the animation
      final dotPath = metric.extractPath(
        0.0,
        metric.length * progress,
      );
      final dotPosition = dotPath.computeMetrics().first.getTangentForOffset(dotPath.computeMetrics().first.length)?.position ?? Offset.zero;
      
      // Draw the outline
      canvas.drawCircle(dotPosition, dotRadius + outlineWidth, outlinePaint);

      // Draw the dot
      canvas.drawCircle(dotPosition, dotRadius, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

}
