/// A performance category which can be applied to the final performance score of a race entity (dotCombo)
class PerformanceCategory {
  final String name;
  final String description;
  final double value;

  PerformanceCategory({
    required this.name,
    required this.description,
    required this.value,
  });
}

/// The final Performance Score for the race entity (dotCombo)
class PerformanceScore {
  final List<PerformanceCategory> categories;

  PerformanceScore({
    required this.categories,
  });
  
  double get totalScore {
    double total = 0;
    for (var category in categories) {
      total += category.value;
    }
    return total;
  }

  double get scorePercentage {
    // Assuming the base score is 100 (sum of each category if each had a max value of 25)
    const baseScore = 100.0;

    // Calculate the score percentage (totalScore / baseScore)
    double scorePercentage = (totalScore / categories.length) / baseScore;

    // Ensure the percentage is between 0 and 1
    scorePercentage = scorePercentage.clamp(0.0, 1.0);

    return scorePercentage;
  }
}