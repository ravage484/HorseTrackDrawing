import 'package:flutter/material.dart';

class Dot {
  final Color color;
  final Duration loopDuration;
  late double progress = 0;
  late AnimationController controller;

  Dot({required this.color, required this.loopDuration});

  void initializeController(TickerProvider vsync) {
    controller = AnimationController(vsync: vsync, duration: loopDuration)..repeat();
  }

  void updateProgress() {
    progress = controller.value;
  }
}