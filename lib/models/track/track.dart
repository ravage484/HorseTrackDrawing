import 'package:flutter/material.dart';
import 'package:horse_track_drawing/models/track/track_segment.dart';
import 'package:horse_track_drawing/models/track/track_offset.dart';

/// A track is a collection of track segments
class Track {
  /// The path of the track
  Path trackPath = Path();

  /// List of all points generated
  List<TrackOffset> allPoints = [];

  /// List of the points that make the convex hull
  List<TrackOffset> trackPointsConvexHull = [];

  /// List of points from the convex hull displacement algorithm
  List<TrackOffset> trackPointsDisplaced = [];
  
  /// List of points from the midpoint displacement algorithm
  List<TrackOffset> trackPointsPushedApart = [];

  /// List of final track points
  List<TrackOffset> finalTrackPoints = [];

  /// The segments of the track
  List<TrackSegment> trackSegments = [];

  /// Returns the total length of the track
  double get totalTrackLength {
    double totalLength = 0;
    for (TrackSegment segment in trackSegments) {
      totalLength += segment.distance;
    }
    return totalLength;
  }

  /// Get the current segment in the track based on the current progress
  TrackSegment getCurrentSegment(double progress) {
    double distanceCovered = progress * totalTrackLength; // Calculate the distance covered along the track

    double cumulativeDistance = 0;
    for (TrackSegment segment in trackSegments) {
      cumulativeDistance += segment.distance;
      if (cumulativeDistance >= distanceCovered) {
        return segment;
      }
    }

    // Return the last segment by default (in case progress is near 1.0)
    return trackSegments.last;
  }
  
  /// Get the current segment in the track based on the current progress
  TrackSegment getPreviousSegment(double progress) {
    double distanceCovered = progress * totalTrackLength; // Calculate the distance covered along the track

    double cumulativeDistance = 0;
    for (int i = 0; i < trackSegments.length; i++) {
      cumulativeDistance += trackSegments[i].distance;
      if (cumulativeDistance >= distanceCovered) {
        // Return the previous segment, or the current one if we're at the first segment
        return (i > 0) ? trackSegments[i - 1] : trackSegments[i];
      }
    }

    // Return the first segment by default (in case progress is near 0.0)
    return trackSegments.first;
  }

  /// Get the next segment in the track based on the current progress
  TrackSegment getNextSegment(double progress) {
    double distanceCovered = progress * totalTrackLength; // Calculate the distance covered along the track

    double cumulativeDistance = 0;
    for (int i = 0; i < trackSegments.length; i++) {
      cumulativeDistance += trackSegments[i].distance;
      if (cumulativeDistance >= distanceCovered) {
        // Return the next segment, or the current one if we're at the last segment
        return (i < trackSegments.length - 1) ? trackSegments[i + 1] : trackSegments[i];
      }
    }

    // Return the last segment by default (in case progress is near 1.0)
    return trackSegments.last;
  }
}
