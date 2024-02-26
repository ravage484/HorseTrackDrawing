import 'package:flutter/material.dart';
import 'package:horse_track_drawing/models/track/track.dart';
import 'package:horse_track_drawing/models/track/track_offset.dart';
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
        return generateMidpointDisplacement(debug: true);
      case TrackType.square:
        return generateDebugSquare();
      default:
        return generateStandardOval();
    }
  }

  /// Generate a debug square track
  Track generateDebugSquare() {
    
    // Define the square's corner points
    Offset p0 = const Offset(100, 100); // Top left
    Offset p1 = const Offset(500, 100); // Top right
    Offset p2 = const Offset(500, 500); // Bottom right
    Offset p3 = const Offset(100, 500); // Bottom left

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
  Track generateMidpointDisplacement({bool debug = false}) {
    // Initialize the list of points
    List<Offset> points = [];

    // Step 1: Generate random points
    if (debug) {
      // Define the hexagon's corner points
      Offset p0 = const Offset(100, 100); // Top left
      Offset p1 = const Offset(500, 100); // Top right
      Offset p2 = const Offset(600, 300); // Right
      Offset p3 = const Offset(500, 500); // Bottom right
      Offset p4 = const Offset(100, 500); // Bottom left
      Offset p5 = const Offset(0, 300); // Left
      points = [p0, p1, p2, p3, p4, p5];

      // // Define the square's corner points
      // Offset p0 = const Offset(100, 100); // Top left
      // Offset p1 = const Offset(1000, 100); // Top right
      // Offset p2 = const Offset(1000, 1000); // Bottom right
      // Offset p3 = const Offset(100, 1000); // Bottom left
      // points = [p0, p1, p2, p3];

      // // Define an equalateral triangle's corner points
      // Offset p0 = const Offset(100, 100); // Top left
      // Offset p1 = const Offset(500, 100); // Top right
      // Offset p2 = const Offset(300, 500); // Bottom
      // points = [p0, p1, p2];

      // // Define a rectangle (3x2) corner points
      // Offset p0 = const Offset(100, 100); // Top left
      // Offset p1 = const Offset(350, 100); // Top middle
      // Offset p2 = const Offset(600, 100); // Top right
      // Offset p3 = const Offset(100, 600); // Bottom left
      // Offset p4 = const Offset(350, 600); // Bottom middle
      // Offset p5 = const Offset(600, 600); // Bottom right
      // points = [p0, p1, p2, p3, p4, p5];
    } else {
      // Generate random points
      points = generateRandomPoints(area, numberOfPoints);
    }
    
    // Step 2: Compute the convex hull
    List<Offset> convexHull = computeConvexHull(points);
    
    // Step 3: Displace midpoints
    List<Offset> displacedMidpoints = displaceMidpoints(convexHull, displacement);
    
    // Step 4: Push apart points
    // List<Offset> pushedApartPoints = pushApartPoints(displacedMidpoints, minDistance, minAngle);

    // Step 5: Fillet the track
    Track finalTrack = filletTrack(displacedMidpoints);

    // Step 5: Interpolate points with splines
    // Track finalTrack = interpolateWithSplines(pushedApartPoints);
    
    // Include the other points and details in the final track
    finalTrack.trackPointsConvexHull = TrackOffset.createList(convexHull);
    finalTrack.trackPointsDisplaced = TrackOffset.createList(displacedMidpoints);
    // finalTrack.trackPointsPushedApart = TrackOffset.createList(pushedApartPoints);
    
    // Return the final track path
    return finalTrack;
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
    bool alternating = false;
    for (int i = 0; i < convexHull.length; i++) {
      Offset p1 = convexHull[i];
      Offset p2 = convexHull[(i + 1) % convexHull.length]; // Wrap around

      // If alternating reverse the displacement
      if (alternating) {
        displacement = -displacement;
      }
      alternating = !alternating;
      Offset midPoint = findPerpendicularOffset(p1, p2, displacement);

      // // Displace midpoint at a random angle
      // midPoint = Offset(midPoint.dx, midPoint.dy + (Random().nextDouble() - 0.5) * displacement);

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

Track interpolateWithSplines(List<Offset> points) {
  Track track = Track();
  Path path = Path();
  List<BezierSegment> bSegments = []; // List to store Bezier segments

  if (points.isEmpty) return track;
  path.moveTo(points.first.dx, points.first.dy);

  if (points.length == 2) {
    path.lineTo(points.last.dx, points.last.dy);
    return track;
  }

  Offset firstControlPoint = getControlPoint(points.last, points.first, points[1]);
  Offset lastControlPoint = firstControlPoint;

  for (int i = 0; i < points.length; i++) {
    final Offset current = points[i];
    final Offset next = points[(i + 1) % points.length];
    final Offset afterNext = points[(i + 2) % points.length];

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
    lastControlPoint = nextControlPoint;
  }

  path.close();

  track.trackPath = path;
  track.trackSegments = generateTrackSegments(points);
  
  return track;
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
  
  Track filletTrack(List<Offset> points) {
    // Create a track
    Track track = Track();

    // Add the points to the track
    track.allPoints = TrackOffset.createList(points);
    
    // Build segments from the points
    List<TrackSegment> segments = pointsToTrackSegments(points);
    track.trackSegments = segments;

    // Create a path from each segment, and draw curves at every braking point to the next segment's acceleration point
    // If on the last segment, draw a curve to the first segment's acceleration point
    // Then close the path
    Path path = Path();
    path.moveTo(track.trackSegments.first.brakingPoint.dx, track.trackSegments.first.brakingPoint.dy);
    for(int i = 0; i < track.trackSegments.length -1; i++) {
      TrackSegment segment = track.trackSegments[i];
      
      // Get the next segment
      TrackSegment nextSegment = track.trackSegments[(i + 1) % track.trackSegments.length];
      
      // Get the Offset at the segment.brakingDistance from the nextSegment.start to the nextSegment.end
      Offset accelerationPoint = OffsetUtils.atDistanceBetween(nextSegment.start, nextSegment.end, segment.brakingDistance);

      // Weight for the conicTo curve
      double weight = Configurations.conicToDefaultWeight;

      // // flip the weight if alternating
      // if (i % 2 == 0) {
      //   weight = weight * -1;
      // }

      // Draw a curve from the braking point to the next acceleration point
      path.conicTo(
        nextSegment.start.dx, nextSegment.start.dy,
        accelerationPoint.dx, accelerationPoint.dy,
        weight,
      );

      // Update the next segment's start to the acceleration point
      nextSegment.start = TrackOffset.create(accelerationPoint, i + 1);
    }
    // path.closec();

    track.trackPath = path;

    return track;

  }
}

List<TrackSegment> generateTrackSegments(List<Offset> points) {
  List<TrackSegment> segments = [];
  for (int i = 0; i < points.length; i++) {
    Offset start = points[i];
    Offset end = points[(i + 1) % points.length];
    Offset next = points[(i + 2) % points.length];
    // BezierSegment bSegment = bSegments[i];
    
    TrackSegment trackSegment = TrackSegment(id: i, 
    start: TrackOffset.create(start, i), 
    end: TrackOffset.create(end, i + 1));

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
    trackSegment.brakingPoint = TrackOffset.create(brakingPoint, i);

    // Add the segment to the list
    segments.add(trackSegment);
  }
  return segments;
}

/// Convert a list of points to a list of track segments
List<TrackSegment> pointsToTrackSegments(List<Offset> points) {
  List<TrackSegment> segments = [];
  
  for (int i = 0; i < points.length; i++) {
    // Get the current segment start/end points and the next point for angle calculation
    Offset start = points[i];
    Offset end = points[(i + 1) % points.length];
    Offset next = points[(i + 2) % points.length];
    
    // Create a track segment
    TrackSegment trackSegment = TrackSegment(id: i, 
      start: TrackOffset.create(start, i), 
      end: TrackOffset.create(end, i + 1));

    // Calculate the angle between the current segment and the next
    double angle = calculateAngleBetweenLines(start, end, next);
    if (angle.isNaN || angle < Configurations.minAngle) {
      // No need to adjust the speed
      // Set the default Braking Point to 1% of the segment length
      Offset brakingPoint = OffsetUtils.atDistanceBetween(start, end, (end - start).distance * 0.1);
      trackSegment.brakingPoint = TrackOffset.create(brakingPoint, i);
      segments.add(trackSegment);
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
    trackSegment.brakingPoint = TrackOffset.create(brakingPoint, i);

    // Add the segment to the list
    segments.add(trackSegment);
  }

  // Loop over each segment again and set the acceleration point for the next segment
  // If on the last segment, look towards the first segment.
  for (int i = 0; i < segments.length; i++) {
    TrackSegment currentSegment = segments[i];
    TrackSegment nextSegment = segments[(i + 1) % segments.length];
    Offset accelerationPoint = nextSegment.start;
    if (i < segments.length - 1) {
      // Set the nextSegments acceleration point based on the percentage distance of the current braking point


      // REVIEW THIS DISTANCE AND PERCENTAGE VALUES
      accelerationPoint = OffsetUtils.atDistanceBetween(nextSegment.start, nextSegment.end, nextSegment.distance * currentSegment.brakingDistancePercentage);
    }
    nextSegment.accelerationPoint = TrackOffset.create(accelerationPoint, i);
  }
  return segments;
}

// /// Convert a path to a list of track segments
// List<TrackSegment> pathToTrackSegments(Path path) {
//   final List<TrackSegment> segments = [];
//   final pathMetrics = path.computeMetrics().toList();
  
//   final pathSegments = pathMetrics.first.extractPath(0, pathMetrics.first.length,); // Get the metrics of the path
//   int id = 0;
  
//   for (final metric in pathMetrics) {
//     final pathLength = metric.length;

//     // Use a small delta to get the start and end points of the segment
//     // We use delta because getTangentForOffset doesn't work well exactly at 0 or the maximum length
//     const double delta = 0.01;

//     // Get the start point tangent
//     final startTangent = metric.getTangentForOffset(delta);
//     // Get the end point tangent
//     final endTangent = metric.getTangentForOffset(pathLength - delta);

//     if (startTangent != null && endTangent != null) {
//       final startOffset = startTangent.position;
//       final endOffset = endTangent.position;
//       // final distance = (endOffset - startOffset).distance; // Calculate the distance between start and end

//       segments.add(TrackSegment(id: id, start: startOffset, end: endOffset));
//       id++;
//     }
//   }

//   return segments;
// }