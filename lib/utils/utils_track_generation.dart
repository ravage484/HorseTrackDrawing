import 'package:flutter/material.dart';
import 'package:horse_track_drawing/models/track/track.dart';
import 'package:horse_track_drawing/models/track/track_segment.dart';
import 'package:horse_track_drawing/resources/configurations.dart';
import 'package:horse_track_drawing/resources/enums.dart';
import 'package:horse_track_drawing/utils/utils_algorithms.dart';
import 'package:horse_track_drawing/utils/utils_extensions.dart';
import 'dart:math';
import 'dart:ui';

/// Generate a track using the midpoint displacement algorithm
Track generateTrackPathUsingGenerator(Size size, int numberOfPoints, double displacement, double minDistance, double minAngle) {

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
  Track generateTrack() {
    // Step 1: Generate random points
    switch (Configurations.trackType) {
      case TrackType.horseTrack:
        return generateStandardOval();
      case TrackType.standardOval:
        return generateStandardOval();
      case TrackType.midpointDisplacement:
        return generateMidpointDisplacement();
      case TrackType.square:
        return generateDebugSquare();
      default:
        return generateStandardOval();
    }
  }

  /// Generate a debug square track
  Track generateDebugSquare() {
    
    // Define the square's corner points
    Offset p0 = Offset(100, 100); // Top left
    Offset p1 = Offset(500, 100); // Top right
    Offset p2 = Offset(500, 500); // Bottom right
    Offset p3 = Offset(100, 500); // Bottom left

    List<Offset> points = [p0, p1, p2, p3];

    // Create a simple square path
    Path simplePath = Path()
      ..moveTo(p0.dx, p0.dy)
      ..lineTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..close();

    // Get the track segments
    List<TrackSegment> trackSegments = pointsToTrackSegments(points);

    // Build the track object
    Track track = Track();
    track.trackSegments = trackSegments;
    track.trackPath = simplePath;

    return track;
  }

  /// Generate a standard oval track
  Track generateStandardOval() {
    // Create a track
    Track track = Track();

    // Get the center of the trackSize
    Offset centerOffset = Offset(area.width / 2, area.height / 2);

    RRect oval = RRect.fromRectAndRadius(
      Rect.fromCenter(center: centerOffset, width: area.width, height: area.height),
      Radius.circular(area.height / 2),
    );
    // Generate the path
    final trackPath = Path()
    ..addRRect(oval);
    
    // Get the track segments
    // Create a list of points from the oval
    List<Offset> points = [];
    points.add(Offset(oval.left, oval.top));
    points.add(Offset(oval.right, oval.top));
    points.add(Offset(oval.right, oval.bottom));
    points.add(Offset(oval.left, oval.bottom));

    List<TrackSegment> trackSegments = pointsToTrackSegments(points);

    // Build the track object
    track.trackSegments = trackSegments;
    track.trackPath = trackPath;

    return track;
  }

  /// Generate a track using the midpoint displacement algorithm
  Track generateMidpointDisplacement() {
    List<Offset> randomPoints = generateRandomPoints(area, numberOfPoints);
    
    // Step 2: Compute the convex hull
    List<Offset> convexHull = computeConvexHull(randomPoints);
    
    // Step 3: Displace midpoints
    List<Offset> displacedMidpoints = displaceMidpoints(convexHull, displacement);
    
    // Step 4: Push apart points
    List<Offset> pushedApartPoints = pushApartPoints(displacedMidpoints, minDistance, minAngle);
    
    // Step 5: Interpolate points with splines
    Path finalTrackPath = interpolateWithSplines(pushedApartPoints);
    finalTrackPath.close();
    
    // Step 6: Idenfity track segments from interpolated path
    // List<TrackSegment> trackSegments = pathToTrackSegments(finalTrackPath);
    List<TrackSegment> trackSegments = pointsToTrackSegments(pushedApartPoints);
    
    // Step 7: Create a track
    Track track = Track();
    track.trackPoints = pushedApartPoints;
    track.trackSegments = trackSegments;
    track.trackPath = finalTrackPath;
    
    // Return the final track path
    return track;
  }

  /// Generate a list of random points
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

  /// Displace the midpoints of a convex hull
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

  /// Push apart points to satisfy minimum distance and angle constraints
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

  /// Interpolate points with splines
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

  /// Calculate the control point for a cubic Bezier curve
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

/// Convert a list of points to a list of track segments
List<TrackSegment> pointsToTrackSegments(List<Offset> points) {
  List<TrackSegment> segments = [];
  for (int i = 0; i < points.length; i++) {
    Offset start = points[i];
    Offset end = points[(i + 1) % points.length];
    Offset next = points[(i + 2) % points.length];
    
    TrackSegment trackSegment = TrackSegment(id: i, start: start, end: end);

    // Calculate the angle between the current segment and the next
    double angle = calculateAngleBetweenLines(start, end, next);
    if (angle.isNaN || angle < Configurations.minAngle) {
      // No need to adjust the speed
      continue;
    }
    
    // Map the angle to a deceleration factor. 
    // Smaller angles (sharper turns) should result in greater deceleration.
    // If the abs value of the angle is >= 180, then don't decelerate
    double decelerationFactor = 1.0;
    if (angle.abs() < 160) { 
      decelerationFactor = mapAngleToDeceleration(angle);
      trackSegment.decelerationFactor = decelerationFactor;
    }

    // Calculate the braking point for the current segment by 
    Offset brakingPoint = calculateBrakingPoint(trackSegment.start, trackSegment.end, angle, decelerationFactor);
    trackSegment.brakingPoint = end;

    // Add the segment to the list
    segments.add(trackSegment);
  }
  return segments;
}

/// Convert a path to a list of track segments
List<TrackSegment> pathToTrackSegments(Path path) {
  final List<TrackSegment> segments = [];
  final pathMetrics = path.computeMetrics().toList();
  
  final pathSegments = pathMetrics.first.extractPath(0, pathMetrics.first.length,); // Get the metrics of the path
  int id = 0;
  
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

      segments.add(TrackSegment(id: id, start: startOffset, end: endOffset));
      id++;
    }
  }

  return segments;
}