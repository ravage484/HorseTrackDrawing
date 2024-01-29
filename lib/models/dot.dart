import 'package:flutter/material.dart';

class Dot {
  final Color color;
  final Duration loopDuration;
  late AnimationController controller;

  Dot({required this.color, required this.loopDuration});

  void initializeController(TickerProvider vsync) {
    controller = AnimationController(vsync: vsync, duration: loopDuration)..forward();
  }
}