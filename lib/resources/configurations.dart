import 'package:flutter/material.dart';

// Class for storing configuration values such as colors, fonts, and images.
class Configurations {

  /// Number of Dots to be drawn
  static const int numberOfDots = 20;

  /// Paint for the track outline
  static Paint trackOutlinePaint = Paint()
    ..color = Colors.brown
    ..style = PaintingStyle.stroke
    ..strokeWidth = 60.0;//60.0;

  /// Paint for the track fill
  static Paint trackFillPaint = Paint()
    ..color = Colors.green[800]!
    ..style = PaintingStyle.fill;

  // Minimum duration for a full loop at 100% performance
  static const minDurationMs = 15000; 

  // Maximum duration at 0% performance
  static const maxDurationMs = 60000; 
}