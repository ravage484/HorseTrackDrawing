import 'package:flutter/material.dart';
import 'dart:math';

/// Returns a random color
Color getRandomColor() {
  Random random = Random();
  int r, g, b;

  do {
    r = random.nextInt(256);
    g = random.nextInt(256);
    b = random.nextInt(256);
  } while ((r > 100 && g > 100 && b < 50) || // Avoid brown (loosely defined as high red & green, low blue)
           (g > 150 && r < 100 && b < 100)); // Avoid green (high green, low red & blue)

  return Color.fromRGBO(r, g, b, 1);
}