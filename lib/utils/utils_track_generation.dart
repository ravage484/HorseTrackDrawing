import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui';
import 'package:horse_track_drawing/utils/utils_algorithms.dart';

/// Generate a standard oval track path
Path generateTrackPathStandardOval(Offset centerOffset, Size size, Paint trackOutlinePaint) {
  final trackPath = Path()
  ..addRRect(RRect.fromRectAndRadius(
    Rect.fromCenter(center: centerOffset, width: size.width - trackOutlinePaint.strokeWidth, height: size.height),
    Radius.circular(size.height / 2),
    ));
  return trackPath;
}

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

  // Path interpolateWithSplines(List<Offset> points) {
  //   Path path = Path();

  //   if (points.isEmpty) return path;

  //   // Move to the first point
  //   path.moveTo(points.first.dx, points.first.dy);

  //   for (int i = 1; i < points.length - 2; i++) {
  //     final Offset p0 = points[i];
  //     final Offset p1 = points[i + 1];

  //     // Calculate the control point for the Bezier curve.
  //     // This is the midpoint of the line segment connecting two points.
  //     final Offset controlPoint = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);

  //     // Draw the quadratic Bezier curve to the control point,
  //     // then draw a line to the next point.
  //     path.quadraticBezierTo(p0.dx, p0.dy, controlPoint.dx, controlPoint.dy);
  //     path.lineTo(p1.dx, p1.dy);
  //   }

  //   // Handle the last point to close the loop, drawing a curve back to the start.
  //   final Offset last = points.last;
  //   final Offset secondLast = points[points.length - 2];
  //   final Offset controlPoint = Offset((last.dx + secondLast.dx) / 2, (last.dy + secondLast.dy) / 2);
  //   path.quadraticBezierTo(secondLast.dx, secondLast.dy, controlPoint.dx, controlPoint.dy);
  //   path.lineTo(last.dx, last.dy);
  //   path.lineTo(points.first.dx, points.first.dy);

  //   return path;
  // }
  Path interpolateWithSplines(List<Offset> points) {
    Path path = Path();

    if (points.isEmpty) return path;

    // Move to the first point
    path.moveTo(points.first.dx, points.first.dy);

    // If there are not enough points for cubic Bezier, fall back to a simple line.
    if (points.length < 3) {
      for (Offset point in points) {
        path.lineTo(point.dx, point.dy);
      }
      return path;
    }

    // Calculate control points for the cubic Bezier curves
    for (int i = 1; i < points.length - 2; i++) {
      final Offset p0 = points[i - 1];
      final Offset p1 = points[i];
      final Offset p2 = points[i + 1];
      final Offset p3 = points[i + 2];

      // Control point 1: halfway between p0 and p1
      final Offset cp1 = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
      // Control point 2: p1
      final Offset cp2 = p1;
      // Control point 3: p1
      final Offset cp3 = p1;
      // Control point 4: halfway between p1 and p2
      final Offset cp4 = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);

      // Draw the cubic Bezier curve
      path.cubicTo(cp2.dx, cp2.dy, cp3.dx, cp3.dy, cp4.dx, cp4.dy);
    }

    // Handle the last curve back to the start to close the loop.
    final Offset last = points.last;
    final Offset secondLast = points[points.length - 2];
    // Control point 1: halfway between the second last and the last point
    final Offset cp1 = Offset((secondLast.dx + last.dx) / 2, (secondLast.dy + last.dy) / 2);
    // Control point 2: last point
    final Offset cp2 = last;
    // Control point 3: last point
    final Offset cp3 = last;
    // Control point 4: first point
    final Offset cp4 = points.first;

    path.cubicTo(cp2.dx, cp2.dy, cp3.dx, cp3.dy, cp4.dx, cp4.dy);

    return path;
  }

}
