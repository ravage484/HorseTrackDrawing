import 'dart:math';
import 'dart:ui';

import 'package:horse_track_drawing/models/driver.dart';
import 'package:horse_track_drawing/models/performance.dart';

double distanceTo(Offset a, Offset b) {
  return sqrt(pow(b.dx - a.dx, 2) + pow(b.dy - a.dy, 2));
}

Driver generateRandomDriver(String name) {
  final random = Random();
  // Generates a random value between 60 and 100
  double randomValue() => random.nextDouble() * 40 + 60;

  PerformanceCategory control = PerformanceCategory(
    name: 'Control',
    description: 'The ability to control the vehicle',
    value: randomValue(),
  );

  PerformanceCategory aggression = PerformanceCategory(
    name: 'Aggression',
    description: 'The aggression used with other race entities',
    value: randomValue(),
  );

  PerformanceCategory consistency = PerformanceCategory(
    name: 'Consistency',
    description: 'The consistency of the driver (How often they make good decisions)',
    value: randomValue(),
  );

  PerformanceCategory experience = PerformanceCategory(
    name: 'Experience',
    description: 'The experienced of the driver',
    value: randomValue(),
  );

  return Driver(
    name: name,
    control: control,
    aggression: aggression,
    consistency: consistency,
    experience: experience,
  );
}
