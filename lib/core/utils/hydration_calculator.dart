class HydrationCalculator {
  /// Calculates daily water intake goal in milliliters.
  ///
  /// Formula:
  ///   base = weightKg * 35 ml
  ///   age factor: <30 → +0%, 30-55 → -5%, >55 → -10%
  ///   gender factor: female → -10%, male/other → +0%
  ///   result rounded to nearest 50 ml
  ///   clamped to [1000, 5000] ml
  static int calculate({
    required double weightKg,
    required int age,
    required String gender, // 'male' | 'female' | 'other'
  }) {
    double base = weightKg * 35.0;

    // Age adjustment
    if (age >= 55) {
      base *= 0.90;
    } else if (age >= 30) {
      base *= 0.95;
    }

    // Gender adjustment
    if (gender == 'female') {
      base *= 0.90;
    }

    // Round to nearest 50
    int rounded = ((base / 50).round() * 50).toInt();

    // Clamp to safe range
    return rounded.clamp(1000, 5000);
  }
}
