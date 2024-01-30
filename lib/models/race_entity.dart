import 'package:flutter/material.dart';
import 'package:horse_track_drawing/models/track/track.dart';
import 'package:horse_track_drawing/models/track/track_segment.dart';
import 'package:horse_track_drawing/resources/configurations.dart';
import 'package:horse_track_drawing/models/vehicle.dart';
import 'package:horse_track_drawing/models/driver.dart';
import 'package:horse_track_drawing/models/performance.dart';
import 'package:horse_track_drawing/utils/utils_algorithms.dart';
import 'package:horse_track_drawing/widgets/custom_animation_controller.dart';

/// This class is a combination of the [Vehicle] and [Driver] classes
/// It is used as a model for the simulations for each dot
/// the Simluation is a calculation of the dot/driver effectiveness
class RaceEntity {
  // Properties
  late Vehicle vehicle;
  late Driver driver;
  late Duration baseDuration = const Duration(milliseconds: 30000); // The base starting duration
  late Duration variableDuration = const Duration(milliseconds: 30000); // The variable duration
  late Duration adjustedDuration; // The adjusted duration based on the driver's performance
  late double progress = 0;
  late Offset position = Offset.zero;
  late CustomAnimationController controller;
  final Track track;

  // Read Only Properties
  String get name => vehicle.name;
  String get driverName => driver.name;
  Color get color => vehicle.color;
  PerformanceScore get performanceScore => driver.performanceScore!;

  /// Constructor
  RaceEntity({required this.vehicle, required this.driver, required this.track});
  
  void adjustSpeedForTurn() {
    if (track.trackSegments.isEmpty) {
      return;
    }
    
    // Assuming you have a method to get the current and next segment based on the RaceEntity's progress
    TrackSegment currentSegment = track.getCurrentSegment(progress);
    TrackSegment prevSegment = track.getPreviousSegment(progress);

    // If the RaceEntity's position is at or past the braking point, then decelerate
    position = getOffsetAtProgress(track.trackPath, progress);

    // Calculate the distance between the position and the braking point
    double distanceToBrakingPoint = (position - currentSegment.end).distance;
    double distanceFromPreviousBrakingPoint = (position - prevSegment.end).distance;
    
    // write to console the distance to braking point
    // print('distanceToBrakingPoint: $distanceToBrakingPoint');
    // print('duration' + variableDuration.toString());

    // If we are entering a turn, or getting closer to the braking point, then decelerate
    if (distanceFromPreviousBrakingPoint > 80 && distanceToBrakingPoint < 80) {
      // Calculate the new duration
      int newDurationMs = (adjustedDuration.inMilliseconds * currentSegment.decelerationFactor).toInt();
      newDurationMs = newDurationMs.clamp(Configurations.minDurationMs, Configurations.maxDurationMs); // Ensure within bounds

      // Update the loop duration
      variableDuration = Duration(milliseconds: newDurationMs);

      // Update the controller with the new duration
      controller.duration = variableDuration;
      controller.repeat();
    } else if(distanceFromPreviousBrakingPoint > 30 && distanceToBrakingPoint > 30) {
      // Calculate the new duration
      int newDurationMs = (adjustedDuration.inMilliseconds * currentSegment.accelerationFactor).toInt();
      newDurationMs = newDurationMs.clamp(Configurations.minDurationMs, Configurations.maxDurationMs); // Ensure within bounds

      // Update the loop duration
      variableDuration = Duration(milliseconds: newDurationMs);

      // Update the controller with the new duration
      controller.duration = variableDuration;
      controller.repeat();
    }
  }


  /// Dispose of the CustomAnimationController
  void dispose() {
    controller.dispose();
  }

  /// Initialize the CustomAnimationController
  void initializeController(TickerProvider vsync) {
    controller = CustomAnimationController(vsync: vsync, duration: variableDuration)..repeat();
  }

  /// Update the loopDuration based on the driver's performanceScore
  void adjustLoopDuration() {

    // Adjust duration based on performance. Higher score results in shorter duration.
    // Adjust the range of duration as needed.

    // Interpolate duration based on the score percentage
    int adjustedDurationMs = Configurations.maxDurationMs - ((Configurations.maxDurationMs - Configurations.minDurationMs) * performanceScore.scorePercentage).toInt();
    
    // Update the loop duration
    adjustedDuration = Duration(milliseconds: adjustedDurationMs);
    
    // // Reinitialize the controller if it's already been created
    // controller.duration = adjustedDuration;
    // controller.repeat();
  }

  /// Update the progress of the dot
  void updateProgress() {
    progress = controller.value;
  }

  /// Toggle the animation
  void toggle() {
    controller.toggle();
  }
}