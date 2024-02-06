import "package:flutter/material.dart";
import "package:horse_track_drawing/models/track/track_offset.dart";

/// A segment of the track containing the points of the segment
class TrackSegment {
  final int id;

  /// Starting point of the segment
  TrackOffset start;

  /// Ending point of the segment
  TrackOffset end;

  /// Returns the distance between the start and end points
  double get distance => (end - start).distance;

  /// The braking point for the segment
  TrackOffset brakingPoint = TrackOffset.zero();

  /// The acceleration point for the segment
  TrackOffset accelerationPoint = TrackOffset.zero();

  /// The distance to the braking point
  /// This is the distance the RaceEntity will travel at the 
  double get distanceToBrakingPoint => (brakingPoint - start).distance;

  /// The distance from the braking point to the end
  /// This is the distance the RaceEntity will travel at the deceleration factor
  double get brakingDistance => (end - brakingPoint).distance;

  double get brakingDistancePercentage => brakingDistance / distance;
  
  /// The deceleration factor for the segment
  double decelerationFactor = 0.0;

  /// The acceleration factor for the segment
  double accelerationFactor = 0.0;
  
  /// Constructor
  TrackSegment({required this.id, required this.start, required this.end,});

  /// Named constructor with Offsets
  TrackSegment.named({required this.id, Offset start = Offset.zero, Offset end= Offset.zero})
      : start = TrackOffset.create(start, 0),
        end = TrackOffset.create(end, 1);

}

/// A BezierSegment is a segment of a Bezier curve
class BezierSegment {
  final Offset p0, p1, p2, p3;

  BezierSegment(this.p0, this.p1, this.p2, this.p3);

  Offset pointAt(double t) {
    final u = 1 - t;
    final tt = t * t;
    final uu = u * u;
    final uuu = uu * u;
    final ttt = tt * t;

    double x = uuu * p0.dx + // first term for x
                3 * uu * t * p1.dx + // second term for x
                3 * u * tt * p2.dx + // third term for x
                ttt * p3.dx; // fourth term for x

    double y = uuu * p0.dy + // first term for y
                3 * uu * t * p1.dy + // second term for y
                3 * u * tt * p2.dy + // third term for y
                ttt * p3.dy; // fourth term for y

    return Offset(x, y);
  }

  // First derivative of the Bezier curve
  Offset firstDerivative(double t) {
    return Offset(
      3 * (1 - t) * (1 - t) * (p1.dx - p0.dx) +
          6 * (1 - t) * t * (p2.dx - p1.dx) +
          3 * t * t * (p3.dx - p2.dx),
      3 * (1 - t) * (1 - t) * (p1.dy - p0.dy) +
          6 * (1 - t) * t * (p2.dy - p1.dy) +
          3 * t * t * (p3.dy - p2.dy),
    );
  }

  // Second derivative of the Bezier curve
  Offset secondDerivative(double t) {
    return Offset(
      6 * (1 - t) * (p2.dx - 2 * p1.dx + p0.dx) +
          6 * t * (p3.dx - 2 * p2.dx + p1.dx),
      6 * (1 - t) * (p2.dy - 2 * p1.dy + p0.dy) +
          6 * t * (p3.dy - 2 * p2.dy + p1.dy),
    );
  }
}