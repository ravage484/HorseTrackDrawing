import 'package:flutter/material.dart';

/// Extension methods for the [Offset] class
extension OffsetUtils on Offset {
  Offset normalize() {
    double length = distance;
    return length > 0 ? this / length : Offset.zero;
  }
}