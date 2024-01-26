import 'package:flutter/material.dart';

class CustomAnimationController extends AnimationController {
  CustomAnimationController({required super.vsync, required super.duration});
  // Common functionality or properties for all painters

  void toggle() {
    if (this.isAnimating) {
      this.stop();
    } else {
      this.repeat();
    }
  }

  // Method to update the duration of the animation
  void updateDuration(Duration duration) {
    this.duration = duration;
  }

  // event handler for the animation
  void onTick(void Function() callback) {
    this.addListener(callback);
  }
  
}
