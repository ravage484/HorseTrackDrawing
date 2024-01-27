import 'package:flutter/material.dart';
import 'package:horse_track_drawing/resources/configurations.dart';
import 'package:horse_track_drawing/models/vehicle.dart';
import 'package:horse_track_drawing/models/driver.dart';
import 'package:horse_track_drawing/models/performance.dart';
import 'package:horse_track_drawing/widgets/custom_animation_controller.dart';

/// This class is a combination of the [Vehicle] and [Driver] classes
/// It is used as a model for the simulations for each dot
/// the Simluation is a calculation of the dot/driver effectiveness
class RaceEntity {
  late Vehicle vehicle;
  late Driver driver;
  late Duration loopDuration = Duration(milliseconds: 30000); // The base starting duration
  late double progress = 0;
  late CustomAnimationController controller;

  // Read Only Properties
  String get name => vehicle.name;
  String get driverName => driver.name;
  Color get color => vehicle.color;
  PerformanceScore get performanceScore => driver.performanceScore!;

  /// Constructor for the DotCombo class
  RaceEntity({required this.vehicle, required this.driver});

  /// Dispose of the CustomAnimationController
  void dispose() {
    controller.dispose();
  }

  /// Initialize the CustomAnimationController
  void initializeController(TickerProvider vsync) {
    controller = CustomAnimationController(vsync: vsync, duration: loopDuration)..repeat();
  }

  /// Update the loopDuration based on the driver's performanceScore
  void adjustLoopDuration() {

    // Adjust duration based on performance. Higher score results in shorter duration.
    // Adjust the range of duration as needed.

    // Interpolate duration based on the score percentage
    int adjustedDurationMs = Configurations.maxDurationMs - ((Configurations.maxDurationMs - Configurations.minDurationMs) * performanceScore.scorePercentage).toInt();
    
    // Update the loop duration
    loopDuration = Duration(milliseconds: adjustedDurationMs);
    
    // Reinitialize the controller if it's already been created
    controller.duration = loopDuration;
    controller.repeat();
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