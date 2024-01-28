import 'package:flutter/material.dart';

class TrackSegment {
  final int id;

  /// Starting point of the segment
  final Offset start;

  /// Ending point of the segment
  final Offset end;

  /// Returns the distance between the start and end points
  double get distance => (end - start).distance;

  Offset brakingPoint = Offset.zero;
  
  double decelerationFactor = 2.5;

  double accelerationFactor = 0.8;

  /// Constructor
  TrackSegment({required this.id, required this.start, required this.end,});
}
