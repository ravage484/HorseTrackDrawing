import 'package:flutter/material.dart';
import 'package:horse_track_drawing/models/track_segment.dart';
import 'package:horse_track_drawing/resources/configurations.dart';
import 'package:horse_track_drawing/utils/utils_algorithms.dart';
import 'package:horse_track_drawing/utils/utils_extensions.dart';
import 'dart:math';
import 'dart:ui';

/// Generate a standard oval track path
Path generateTrackPathStandardOval(Size trackSize) {
  
  Offset centerOffset = Offset(trackSize.width / 2, trackSize.height / 2);
  final trackPath = Path()
  ..addRRect(RRect.fromRectAndRadius(
    Rect.fromCenter(center: centerOffset, width: trackSize.width - Configurations.trackOutlinePaint.strokeWidth, height: trackSize.height),
    Radius.circular(trackSize.height / 2),
    ));
  return trackPath;
}

/// Generate a track using the midpoint displacement algorithm
Path generateTrackPathUsingGenerator(Size size, int numberOfPoints, double displacement, double minDistance, double minAngle) {

    // Create a track generator with specified parameters
    TrackGenerator generator = TrackGenerator(
      area: size,
      numberOfPoints: numberOfPoints, // Number of initial random points
      displacement: displacement, // Initial displacement for the midpoint algorithm
      minDistance: minDistance, // Minimum distance between adjacent points
      minAngle: minAngle, // Minimum angle in degrees between three consecutive points
    );

    // Generate the track path
    return generator.generateTrack();
}

/// Class for generating a track using the midpoint displacement algorithm
class TrackGenerator {
  Size area;
  int numberOfPoints;
  double displacement;
  double minDistance;
  double minAngle;

  List<TrackSegment> trackSegments = [];

  TrackGenerator({
    required this.area,
    required this.numberOfPoints,
    required this.displacement,
    required this.minDistance,
    required this.minAngle,
  });

  /// Generate a track using the midpoint displacement algorithm
  Path generateTrack() {
    // Step 1: Generate random points
    List<Offset> randomPoints = generateRandomPoints(area, numberOfPoints);

    // Step 2: Compute the convex hull
    List<Offset> convexHull = computeConvexHull(randomPoints);

    // Step 3: Displace midpoints
    List<Offset> displacedMidpoints = displaceMidpoints(convexHull, displacement);

    // Step 4: Push apart points
    List<Offset> pushedApartPoints = pushApartPoints(displacedMidpoints, minDistance, minAngle);

    // Step 5: Interpolate points with splines
    Path finalTrackPath = interpolateWithSplines(pushedApartPoints);
    
    // Step 6: Idenfity track segments from interpolated path
    // List<TrackSegment> trackSegments = pathToTrackSegments(finalTrackPath);

    // Return the final track path
    return finalTrackPath;
  }

  List<Offset> generateRandomPoints(Size area, int numberOfPoints) {
    final random = Random();
    List<Offset> points = [];
    for (int i = 0; i < numberOfPoints; i++) {
      points.add(Offset(
        random.nextDouble() * area.width,
        random.nextDouble() * area.height,
      ));
    }
    return points;
  }

  List<Offset> displaceMidpoints(List<Offset> convexHull, double displacement) {
    List<Offset> newPoints = [];
    for (int i = 0; i < convexHull.length; i++) {
      Offset p1 = convexHull[i];
      Offset p2 = convexHull[(i + 1) % convexHull.length]; // Wrap around
      Offset midPoint = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
      // Displace midpoint
      midPoint = Offset(midPoint.dx, midPoint.dy + (Random().nextDouble() - 0.5) * displacement);
      newPoints.add(midPoint);
    }
    return newPoints;
  }

  List<Offset> pushApartPoints(List<Offset> points, double minDistance, double minAngle) {
    // Converts degrees to radians for angle comparison.
    double minAngleRad = minAngle * (pi / 180);

    for (int i = 0; i < points.length; i++) {
      // Check minimum distance constraint for adjacent points.
      if (i > 0 && (points[i] - points[i - 1]).distance < minDistance) {
        // Move the point away by the difference plus a small epsilon.
        double angle = atan2(points[i].dy - points[i - 1].dy, points[i].dx - points[i - 1].dx);
        points[i] = points[i - 1] + Offset(cos(angle), sin(angle)) * (minDistance + 1.0);
      }

      // Check minimum angle constraint for every set of three consecutive points.
      if (i > 1) {
        Offset vectorA = points[i - 1] - points[i - 2];
        Offset vectorB = points[i] - points[i - 1];
        double angle = vectorA.direction - vectorB.direction;

        // Ensure the angle is within the range [-pi, pi].
        angle = (angle + pi) % (2 * pi) - pi;

        if (angle.abs() < minAngleRad) {
          // Calculate the new position for the point.
          double correctionAngle = angle.sign * (minAngleRad - angle.abs()) / 2;
          points[i] = points[i - 1] + Offset(cos(vectorB.direction + correctionAngle), sin(vectorB.direction + correctionAngle)) * vectorB.distance;
        }
      }
    }

    // Close the loop by ensuring the first and last points satisfy the constraints.
    if ((points.first - points.last).distance < minDistance) {
      double angle = atan2(points.first.dy - points.last.dy, points.first.dx - points.last.dx);
      points[0] = points.last + Offset(cos(angle), sin(angle)) * (minDistance + 1.0);
    }

    return points;
  }

  Path interpolateWithSplines(List<Offset> points) {
    Path path = Path();
    if (points.isEmpty) return path;

    // Start the path
    path.moveTo(points.first.dx, points.first.dy);

    if (points.length == 2) {
      // If there are exactly two points, just draw a line.
      path.lineTo(points.last.dx, points.last.dy);
      return path;
    }

    // Calculate the first control points
    Offset firstControlPoint = getControlPoint(points.last, points.first, points[1]);
    Offset lastControlPoint = firstControlPoint;

    for (int i = 0; i < points.length; i++) {
      final Offset current = points[i];
      final Offset next = points[(i + 1) % points.length];
      final Offset afterNext = points[(i + 2) % points.length];

      // Calculate control points for the current segment
      Offset nextControlPoint = getControlPoint(current, next, afterNext);

      // Draw the cubic Bezier curve segment
      path.cubicTo(
        lastControlPoint.dx,
        lastControlPoint.dy,
        current.dx,
        current.dy,
        (current.dx + nextControlPoint.dx) / 2,
        (current.dy + nextControlPoint.dy) / 2,
      );

      // Update the last control point for the next segment
      lastControlPoint = nextControlPoint;
    }

    // Close the path
    path.close();

    return path;
  }

  Offset getControlPoint(Offset before, Offset current, Offset after) {
    // Calculate the tangent vector for the current point
    Offset tangent = (after - before).normalize();

    // The distance between the current point and the next point
    // should be proportional to the length of the segment
    double length = (current - after).distance * 0.25; // Adjust this factor as needed

    // Calculate and return the control point
    return current + tangent * length;
  }
}

List<TrackSegment> pathToTrackSegments(Path path) {
  final List<TrackSegment> segments = [];
  final pathMetrics = path.computeMetrics(); // Get the metrics of the path

  for (final metric in pathMetrics) {
    final pathLength = metric.length;

    // Use a small delta to get the start and end points of the segment
    // We use delta because getTangentForOffset doesn't work well exactly at 0 or the maximum length
    const double delta = 0.01;

    // Get the start point tangent
    final startTangent = metric.getTangentForOffset(delta);
    // Get the end point tangent
    final endTangent = metric.getTangentForOffset(pathLength - delta);

    if (startTangent != null && endTangent != null) {
      final startOffset = startTangent.position;
      final endOffset = endTangent.position;
      // final distance = (endOffset - startOffset).distance; // Calculate the distance between start and end

      segments.add(TrackSegment(start: startOffset, end: endOffset));
    }
  }

  return segments;
}