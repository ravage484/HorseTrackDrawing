import 'package:flutter/material.dart';
import 'package:horse_track_drawing/widgets/custom_animation_controller.dart';

class Dot {
  final String name;
  final Color color;
  final Duration loopDuration;
  late double progress = 0;
  late CustomAnimationController controller;

  Dot({required this.name, required this.color, required this.loopDuration});

  void initializeController(TickerProvider vsync) {
    controller = CustomAnimationController(vsync: vsync, duration: loopDuration)..repeat();
  }

  void updateProgress() {
    progress = controller.value;
  }
}