import 'package:horse_track_drawing/models/performance.dart';

/// Driver of the vehicle
class Driver {

  /// Name of the driver
  String name;

  /// Control of the driver
  PerformanceCategory control = PerformanceCategory(
    name: 'Control',
    description: 'The ability to control the vehicle',
    value: 0,
  );

  /// Aggression of the driver
  PerformanceCategory aggression = PerformanceCategory(
    name: 'Aggression',
    description: 'The aggression used with other race entities',
    value: 0,
  );

  /// Consistency of the driver
  PerformanceCategory consistency = PerformanceCategory(
    name: 'Consistency',
    description: 'The consistency of the driver (How often they make good decisions)',
    value: 0,
  );

  //// Experience of the driver
  PerformanceCategory experience = PerformanceCategory(
    name: 'Experience',
    description: 'The experienced of the driver',
    value: 0,
  );

  /// The performance score of the driver's performance categories
  PerformanceScore? performanceScore;

  /// Constructor for the Driver class
  Driver({
    required this.name,
    required this.control,
    required this.aggression,
    required this.consistency,
    required this.experience,
  }) {
    performanceScore = PerformanceScore(
      categories: [control, aggression, consistency, experience],
    );
  }
}
