import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
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