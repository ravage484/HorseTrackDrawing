import 'package:flutter/material.dart';

class Dot {
  final Color color;
  final Duration loopDuration;
  late AnimationController controller;
  late final Animation<double> animation;
  final Curve curve;

  Dot({required this.color, required this.loopDuration, required this.curve});

  void initializeController(TickerProvider vsync) {
    controller = AnimationController(vsync: vsync, duration: loopDuration)
      ..repeat();

    animation = CurvedAnimation(parent: controller, curve: curve);
  }
}
