import 'package:flutter/material.dart';
import 'package:horse_track_drawing/models/dot_combo.dart';
import 'package:horse_track_drawing/resources/configurations.dart';

// Custom painter class for drawing the track and animated dot
class GamePainter extends CustomPainter {
  final List<DotCombo> dots;
  final Path trackPath;

  GamePainter({required this.dots, required this.trackPath});

  @override
  void paint(Canvas canvas, Size size) {

    // Draw the filled track
    canvas.drawPath(trackPath, Configurations.trackFillPaint);
    
    // Draw the track outline
    canvas.drawPath(trackPath, Configurations.trackOutlinePaint);
    
    // Paint each animated dot with white outlines
    for (var dotCombo in dots) {
      try {
        var dot = dotCombo.dot;
        
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
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
