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
    if (kDebugMode) {
      // // Paint each point with a blue outline
      // for (var point in track.allPoints) {
      //   canvas.drawCircle(point, 25.0, Paint()..color = Colors.blue);
      // }
      
      // Paint each convex hull point with a green outline
      for (var point in track.trackPointsConvexHull) {
        canvas.drawCircle(point, 20.0, Paint()..color = Colors.green);
        final nextPoint = track.trackPointsConvexHull[(track.trackPointsConvexHull.indexOf(point) + 1) % track.trackPointsConvexHull.length];
        canvas.drawLine(point, nextPoint, Paint()..color = Colors.green
          ..strokeWidth = 15.0);
      }

      // for loop over the amount of points
      for (int i = 0; i < track.trackPointsDisplaced.length; i++) {
        // get the current point from the convex hull
        final point = track.trackPointsConvexHull[i];

        // get the next point from the convex hull
        final nextPoint = track.trackPointsConvexHull[(i + 1) % track.trackPointsConvexHull.length];

        // get the midpoint between the two convex hull points
        final midpoint = Offset((point.dx + nextPoint.dx) / 2, (point.dy + nextPoint.dy) / 2);

        // get the current point from the displaced points
        final displacedPoint = track.trackPointsDisplaced[i];

        // draw a line from the displaced point to the midpoint of the convex hull points
        canvas.drawLine(displacedPoint, midpoint, Paint()..color = Colors.teal
          ..strokeWidth = 10.0);
      }

      // Paint each displaced point with a yellow outline
      for (var point in track.trackPointsDisplaced) {
        canvas.drawCircle(point, 15.0, Paint()..color = Colors.orange);
        final nextPoint = track.trackPointsDisplaced[(track.trackPointsDisplaced.indexOf(point) + 1) % track.trackPointsDisplaced.length];
        canvas.drawLine(point, nextPoint, Paint()..color = Colors.orange
          ..strokeWidth = 10.0);
      }

      // // Paint each pushed apart point with a purple outline
      // for (var point in track.trackPointsPushedApart) {
      //   canvas.drawCircle(point, 10.0, Paint()..color = Colors.purple);
      //   final nextPoint = track.trackPointsPushedApart[(track.trackPointsPushedApart.indexOf(point) + 1) % track.trackPointsPushedApart.length];
      //   canvas.drawLine(point, nextPoint, Paint()..color = Colors.purple
      //     ..strokeWidth = 5.0);

      //   // Also paint the index of this point
      //   final textPainter = TextPainter(
      //     text: TextSpan(
      //       text: track.trackPointsPushedApart.indexOf(point).toString(),
      //       style: TextStyle(color: Colors.black, fontSize: 20.0),
      //     ),
      //     textDirection: TextDirection.ltr,
      //   )..layout();
      // }

    }

    // Paint each braking point with a red outline
    for (var bp in track.trackSegments.map((e) => e.brakingPoint)) {
      canvas.drawCircle(bp, 15.0, Paint()..color = Colors.red);
    }
    // Paint each acceleration point with a green outline
    for (var bp in track.trackSegments.map((e) => e.brakingPoint)) {
      canvas.drawCircle(bp, 10.0, Paint()..color = Colors.blue);
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
