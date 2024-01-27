import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui';
import 'package:horse_track_drawing/utils/utils_algorithms.dart';
import 'package:horse_track_drawing/utils/utils_extensions.dart';

/// Generate a standard oval track path
Path generateTrackPathStandardOval(Offset centerOffset, Size size, Paint trackOutlinePaint) {
  final trackPath = Path()
  ..addRRect(RRect.fromRectAndRadius(
    Rect.fromCenter(center: centerOffset, width: size.width - trackOutlinePaint.strokeWidth, height: size.height),
    Radius.circular(size.height / 2),
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

  TrackGenerator({
    required this.area,
    required this.numberOfPoints,
    required this.displacement,
    required this.minDistance,
    required this.minAngle,
  });

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


  // /// v1
  // Path interpolateWithSplines(List<Offset> points) {
  //   Path path = Path();
  //   if (points.isEmpty) return path;

  //   // The first and last control points are determined by the tangent
  //   // at the midpoint between the last and first points.
  //   final Offset firstPoint = points.first;
  //   final Offset lastPoint = points.last;
  //   final Offset tangent = (firstPoint - lastPoint) / 2;

  //   // The control points for the first point
  //   Offset firstControlPoint = firstPoint + tangent;
  //   Offset lastControlPoint = lastPoint - tangent;

  //   path.moveTo(firstPoint.dx, firstPoint.dy);

  //   for (int i = 0; i < points.length; i++) {
  //     final Offset currentPoint = points[i];
  //     final Offset nextPoint = points[(i + 1) % points.length];
  //     final Offset nextTangent = (points[(i + 2) % points.length] - currentPoint) / 2;

  //     final Offset nextControlPoint = nextPoint - nextTangent;

  //     path.cubicTo(
  //       firstControlPoint.dx, firstControlPoint.dy,
  //       lastControlPoint.dx, lastControlPoint.dy,
  //       nextPoint.dx, nextPoint.dy,
  //     );

  //     firstControlPoint = nextPoint + nextTangent;
  //     lastControlPoint = nextControlPoint;
  //   }

  //   // Close the path
  //   path.close();

  //   return path;
  // }
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
