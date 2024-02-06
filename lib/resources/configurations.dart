import 'package:flutter/material.dart';
import 'package:horse_track_drawing/resources/enums.dart';

/// Class for storing configuration values such as colors, fonts, and images.
class Configurations {

  /// Track Type
  static TrackType trackType = TrackType.midpointDisplacement; 

  /// Track Width
  static const double trackWidth = 1000.0;

  /// Track Height
  static const double trackHeight = 1000.0;

  /// Number of Dots to be drawn
  static const int numberOfRaceEntities = 3;

  /// Default weight for the conicTo method
  static const double conicToDefaultWeight = 1; 

  /// Paint for the TrackType.horseTrack outline
  static Paint horseTrackOutlinePaint = Paint()
    ..color = Colors.brown
    ..style = PaintingStyle.stroke
    ..strokeWidth = 60.0;//60.0;

  /// Paint for the TrackType.horseTrack fill
  static Paint horseTrackFillPaint = Paint()
    ..color = Colors.green[800]!
    ..style = PaintingStyle.fill;

  /// Paint for the TrackType.standardOval outline
  static Paint standardOvalOutlinePaint = Paint()
    ..color = Colors.grey[500]!
    ..style = PaintingStyle.stroke
    ..strokeWidth = 60.0;

  /// Paint for the TrackType.standardOval fill
  static Paint standardOvalFillPaint = Paint()
    ..color = Colors.green[800]!
    ..style = PaintingStyle.fill;

  /// Minimum duration for a full loop at 100% performance
  static const minDurationMs = 5000; 

  /// Maximum duration at 0% performance
  static const maxDurationMs = 60000;

  /// Minimum angle in degrees between three consecutive points
  static num minAngle = 45.0;
}