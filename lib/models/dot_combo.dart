import 'package:flutter/material.dart';
import 'package:horse_track_drawing/models/dot.dart';
import 'package:horse_track_drawing/models/driver.dart';

/// This class is a combination of the [Dot] and [Driver] classes
/// It is used as a model for the simulations for each dot
/// the Simluation is a calculation of the dot/driver effectiveness
class DotCombo {
  late Dot dot;
  late Driver driver;

  // Read Only Properties
  double get progress => dot.progress;
  String get name => dot.name;
  String get driverName => driver.name;
  Color get color => dot.color;

  /// Constructor for the DotCombo class
  DotCombo({required this.dot, required this.driver});

  void dispose() {
    dot.controller.dispose();
  }

  /// Initialize the controller for the dot
  void initializeController(TickerProvider vsync) {
    dot.initializeController(vsync);
  }

  /// Update the progress of the dot
  void updateProgress() {
    dot.updateProgress();
  }

  /// Get the skill modifier of the driver
  double getSkillModifier() {
    return driver.getSkillModifier();
  }

  /// Make a decision based on the difficulty
  bool makeDecision(double difficulty) {
    return driver.makeDecision(difficulty);
  }
}