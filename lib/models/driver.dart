import 'dart:math';

class Driver {
  String name;
  double control;
  double aggression;
  double consistency;
  double experience;

  Driver({
    required this.name,
    required this.control,
    required this.aggression,
    required this.consistency,
    required this.experience,
  });

  double getSkillModifier() {
    // A simplistic formula for a skill modifier
    return (control + aggression + consistency + experience) / 4.0;
  }

  bool makeDecision(double difficulty) {
    // Higher skill increases chances of making a good decision
    double successThreshold = 0.5 + getSkillModifier() * 0.5; // Scale the modifier to a range of 0.5 - 1.0
    return Random().nextDouble() < successThreshold;
  }
}
