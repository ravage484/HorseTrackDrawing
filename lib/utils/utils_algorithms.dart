import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:horse_track_drawing/models/track/track_segment.dart';
import 'package:horse_track_drawing/utils/utils_other.dart';

Offset _findLowestPoint(List<Offset> points) {
  Offset lowest = points[0];
  for (Offset point in points) {
    if (point.dy > lowest.dy || (point.dy == lowest.dy && point.dx < lowest.dx)) {
      lowest = point;
    }
  }
  return lowest;
}

int _orientation(Offset p, Offset q, Offset r) {
  double val = (q.dy - p.dy) * (r.dx - q.dx) - (q.dx - p.dx) * (r.dy - q.dy);
  if (val == 0) return 0;  // colinear
  return (val > 0) ? 1 : 2; // clock or counterclock wise
}

List<Offset> computeConvexHull(List<Offset> points) {
  // Find the lowest point
  Offset start = _findLowestPoint(points);

  // Sort points by polar angle with 'start'
  points.sort((a, b) {
    int order = _orientation(start, a, b);
    if (order == 0) {
      return (distanceTo(start, a) < distanceTo(start, b)) ? -1 : 1;
    }
    return (order == 2) ? -1 : 1;
  });

  // Create an empty stack and push first three points to it
  List<Offset> stack = [];
  stack.add(points[0]);
  stack.add(points[1]);
  stack.add(points[2]);

  // Process remaining points
  for (int i = 3; i < points.length; i++) {
    // Keep removing top while the angle formed by points next-to-top, top, and points[i] makes a non-left turn
    while (stack.length > 1 && _orientation(stack[stack.length - 2], stack.last, points[i]) != 2) {
      stack.removeLast();
    }
    stack.add(points[i]);
  }

  return stack;
}

/// Calculate the angle between two lines
double calculateAngleBetweenLines(Offset xStart, Offset xEnd, Offset yEnd) {
  // Convert line segments to vectors
  Offset vx = xEnd - xStart; // Vector for line X
  Offset vy = yEnd - xEnd; // Vector for line Y, using xEnd as the start point

  // Calculate the dot product of vx and vy
  double dotProduct = vx.dx * vy.dx + vx.dy * vy.dy;

  // Calculate the magnitudes of vx and vy
  double magnitudeVx = sqrt(vx.dx * vx.dx + vx.dy * vx.dy);
  double magnitudeVy = sqrt(vy.dx * vy.dx + vy.dy * vy.dy);

  // Calculate the cosine of the angle
  double cosTheta = dotProduct / (magnitudeVx * magnitudeVy);

  // Calculate the angle in radians and then convert to degrees
  double angleRadians = acos(cosTheta); // Angle in radians
  double angleDegrees = angleRadians * 180 / pi; // Convert to degrees

  return angleDegrees;
}

/// Calculate the braking point for a given segment, turn angle, and braking factor
Offset calculateBrakingPoint(Offset startPoint, Offset endPoint, double turnAngle, double brakingFactor) {
  // Normalize the turn angle to [0, 180], where 180 is a straight line
  // and smaller angles represent sharper turns.
  double normalizedAngle = turnAngle.clamp(0, 180);

  // Calculate the total segment length
  double segmentLength = (endPoint - startPoint).distance;

  // Calculate the braking distance as a function of the segment length, turn angle, and braking factor.
  // This is a heuristic and might need adjustment based on your specific needs.
  double brakingDistance = segmentLength * (1 - (normalizedAngle / 180)) * brakingFactor;

  // Ensure braking distance is within the segment
  brakingDistance = brakingDistance.clamp(0, segmentLength);

  // Calculate the direction vector of the segment
  Offset directionVector = (endPoint - startPoint) / segmentLength;

  // Calculate the braking point by scaling the direction vector by the braking distance
  // and adding the result to the start point
  Offset brakingPoint = startPoint + directionVector * (segmentLength - brakingDistance);

  return brakingPoint;
}

Offset getOffsetAtProgress(Path path, double progress) {
  // Ensure progress is clamped between 0.0 and 1.0
  progress = progress.clamp(0.0, 1.0);

  // Extract path metrics to get path length and other properties
  final pathMetrics = path.computeMetrics().first; // Assuming only one path or subpath

  // Calculate the exact distance along the path for the given progress
  final distance = pathMetrics.length * progress;

  // Use getTangentForOffset to get position and tangent at the given distance
  // Tangent provides the direction of the path at that point, which might be useful for rotations
  final tangent = pathMetrics.getTangentForOffset(distance);

  // Return the position at the given distance along the path
  // If the tangent is null (which shouldn't normally happen if the progress is within bounds), return Offset.zero
  return tangent?.position ?? Offset.zero;
}

/// Map the angle between the current segment and the next to a deceleration factor
double mapAngleToDeceleration(double angle) {
  // Example mapping function: sharper angles result in greater deceleration
  const double maxAngle = 180.0; // Straight line
  return 1 + (maxAngle - angle) / maxAngle; // Adjust this formula as needed
}

/// Find the points of maximum curvature in a list of Bezier segments
List<Offset> findPointsOfMaximumCurvature(List<BezierSegment> segments) {
  List<Offset> maxCurvaturePoints = [];

  for (BezierSegment segment in segments) {
    double maxCurvature = 0.0;
    Offset pointOfMaxCurvature = Offset.zero;
    const int samples = 10000; // Number of samples per segment

    for (int i = 0; i <= samples; i++) {
      double t = i / samples;
      Offset derivative1 = segment.firstDerivative(t);
      Offset derivative2 = segment.secondDerivative(t);

      // Calculate curvature using the formula given above
      double curvatureNumerator = (derivative1.dx * derivative2.dy) - (derivative1.dy * derivative2.dx);
      num curvatureDenominator = pow(derivative1.dx * derivative1.dx + derivative1.dy * derivative1.dy, 1.5);
      double curvature = curvatureNumerator / curvatureDenominator;

      // Check for maximum curvature
      if (curvature.abs() > maxCurvature) {
        maxCurvature = curvature.abs();
        pointOfMaxCurvature = segment.pointAt(t);
      }
    }

    if (maxCurvature > 0) {
      maxCurvaturePoints.add(pointOfMaxCurvature);
    }
  }

  return maxCurvaturePoints;
}

Offset findPerpendicularOffset(Offset start, Offset end, double distance) {
  // Find the midPoint of the line segment
  Offset midPoint = calculateMidpoint(start, end);
  
  // Calculate the slope of the line
  double slope = calculateSlope(start, end);

  // Calculate the perpendicular slope
  Offset perpOffset = Offset.zero;
  try {
    // Assuming we want the point above the segment
    bool above = true;
    perpOffset = calculatePerpendicularOffset(midPoint, slope, distance, above);
    print("Perpendicular point at distance: $perpOffset");
  } catch (e) {
    print(e);
  }

  return perpOffset;
}

Offset calculateMidpoint(Offset start, Offset end) {
  return Offset(
    (start.dx + end.dx) / 2.0,
    (start.dy + end.dy) / 2.0,
  );
}

double calculateSlope(Offset start, Offset end) {
  // Check for vertical line to avoid division by zero
  if (end.dx == start.dx) {
    // throw Exception('Vertical line segment; slope is undefined.');
  }
  return (end.dy - start.dy) / (end.dx - start.dx);
}

Offset calculatePerpendicularOffset(Offset point, double slope, double distance, bool above) {
  // Calculate the angle of the line with the slope
  double theta = atan(slope);

  // If the point is to be above the line, add PI/2 to the angle to rotate it 90 degrees;
  // if below, subtract PI/2.
  double adjustedTheta = above ? theta + pi / 2 : theta - pi / 2;

  // Calculate the x and y using cosine and sine functions
  double dx = distance * cos(adjustedTheta);
  double dy = distance * sin(adjustedTheta);

  // Return the new offset
  return Offset(point.dx + dx, point.dy + dy);
}
