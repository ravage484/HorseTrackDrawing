import 'dart:math';
import 'dart:ui';

double distanceTo(Offset a, Offset b) {
  return sqrt(pow(b.dx - a.dx, 2) + pow(b.dy - a.dy, 2));
}
