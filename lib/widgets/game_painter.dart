import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:horse_track_drawing/models/race_entity.dart';
import 'package:horse_track_drawing/models/track/track.dart';
import 'package:horse_track_drawing/resources/configurations.dart';
import 'package:horse_track_drawing/resources/enums.dart';

// Custom painter class for drawing the track and animated dot
class GamePainter extends CustomPainter {
  final List<RaceEntity> raceEntities;
  final Track track;

  GamePainter({required this.raceEntities, required this.track});

  @override
  void paint(Canvas canvas, Size size) {
    Paint outlinePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    Paint fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..strokeWidth = 1.0;
    
    switch (Configurations.trackType) {
      case TrackType.horseTrack:
        outlinePaint = Configurations.horseTrackOutlinePaint;
        fillPaint = Configurations.horseTrackFillPaint;
        break;
      case TrackType.standardOval:
        outlinePaint = Configurations.standardOvalOutlinePaint;
        fillPaint = Configurations.standardOvalFillPaint;
        break;
      case TrackType.midpointDisplacement:
        outlinePaint = Configurations.standardOvalOutlinePaint;
        fillPaint = Configurations.standardOvalFillPaint;
        break;
      case TrackType.square:
        outlinePaint = Configurations.standardOvalOutlinePaint;
        fillPaint = Configurations.standardOvalFillPaint;
        break;
      default:
        break;
    }

    // Draw the filled track
    canvas.drawPath(track.trackPath, fillPaint);
    
    // Draw the track outline
    canvas.drawPath(track.trackPath, outlinePaint);

    // Paint each braking point with a red outline
    for (var bp in track.trackSegments.map((e) => e.brakingPoint)) {
      canvas.drawCircle(bp, 10.0, Paint()..color = Colors.red);
    }
    
    // Paint each animated dot with white outlines
    for (var re in raceEntities) {
      try {
        // Get the current progress of the animation
        final progress = re.controller.value;

        // Get the dot's properties
        final dotPaint = Paint()..color = re.color;
        final outlinePaint = Paint()..color = Colors.white;
        const dotRadius = 10.0;
        const outlineWidth = 4.0;
        final pathMetrics = track.trackPath.computeMetrics();
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
        if (kDebugMode) {
          print(e);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
