import 'package:flutter/material.dart';

/// Extension methods for the [Offset] class
extension OffsetUtils on Offset {
  Offset normalize() {
    double length = distance;
    return length > 0 ? this / length : Offset.zero;
  }

  /// Returns the Offset at the given distance between two points
  static Offset atDistanceBetween(Offset start, Offset end, double distance) {
    // Calculate the total distance between start and end
    double totalDistance = (start - end).distance;

    if (totalDistance == 0) {
      // return the end point if the total distance is 0
      return end;
    } else if (distance > totalDistance) {
      // return the end point if the distance is greater than the total distance
      return end;
    }

    // Calculate the ratio of the given distance to the total distance
    double ratio = distance / totalDistance;

    // Find the offset at the given distance
    double dx = start.dx + ratio * (end.dx - start.dx);
    double dy = start.dy + ratio * (end.dy - start.dy);

    return Offset(dx, dy);
  }
}