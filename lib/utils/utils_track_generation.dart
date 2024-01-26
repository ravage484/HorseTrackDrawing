import 'package:flutter/material.dart';
import 'dart:math';

/// Generate a standard oval track path
Path generateTrackPathStandardOval(Offset centerOffset, Size size, Paint trackOutlinePaint) {
  final trackPath = Path()
  ..addRRect(RRect.fromRectAndRadius(
    Rect.fromCenter(center: centerOffset, width: size.width - trackOutlinePaint.strokeWidth, height: size.height),
    Radius.circular(size.height / 2),
    ));
  return trackPath;
}

/// Generate a random track path
Path generateRandomTrackPath(Offset centerOffset, Size size, Paint trackOutlinePaint) {
  // Determine the maximum radius for the curves based on the track size
  double maxCurveRadius = size.height / 2 - trackOutlinePaint.strokeWidth;

  // Randomize the length of the straightaways
  Random random = Random();
  double straightawayLength = size.width / 2 - maxCurveRadius * 2;
  double randomStraightawayFactor = 0.8 + random.nextDouble() * 0.4; // Random factor between 0.8 and 1.2
  double randomStraightawayLength = straightawayLength * randomStraightawayFactor;

  // Start the path at the center bottom of the straightaway
  final Path trackPath = Path();
  trackPath.moveTo(centerOffset.dx - randomStraightawayLength / 2, centerOffset.dy + maxCurveRadius);

  // Bottom straightaway
  trackPath.lineTo(centerOffset.dx + randomStraightawayLength / 2, centerOffset.dy + maxCurveRadius);

  // Bottom right curve
  trackPath.arcToPoint(
    Offset(centerOffset.dx + randomStraightawayLength / 2, centerOffset.dy - maxCurveRadius),
    radius: Radius.circular(maxCurveRadius),
    clockwise: true,
  );

  // Top straightaway
  trackPath.lineTo(centerOffset.dx - randomStraightawayLength / 2, centerOffset.dy - maxCurveRadius);

  // Top left curve
  trackPath.arcToPoint(
    Offset(centerOffset.dx - randomStraightawayLength / 2, centerOffset.dy + maxCurveRadius),
    radius: Radius.circular(maxCurveRadius),
    clockwise: true,
  );

  // Close the path to create a loop
  trackPath.close();

  return trackPath;
}