class DASS21Result {
  final int depression;
  final int anxiety;
  final int stress;

  DASS21Result({
    required this.depression,
    required this.anxiety,
    required this.stress,
  });
}

class DASS21Calculator {
  static DASS21Result calculate({
    required List<int> answers,
  }) {
    int depression = 0;
    int anxiety = 0;
    int stress = 0;

    // ✅ OFFICIAL DASS-21 INDEXING (0-based)

    const depressionItems = [0, 2, 4, 9, 12, 15, 19];
    const anxietyItems    = [1, 3, 6, 8, 14, 17, 20];
    const stressItems     = [5, 7, 10, 11, 13, 16, 18];

    for (int i = 0; i < answers.length; i++) {
      int score = answers[i];

      if (depressionItems.contains(i)) {
        depression += score;
      } 
      else if (anxietyItems.contains(i)) {
        anxiety += score;
      } 
      else if (stressItems.contains(i)) {
        stress += score;
      }
    }

    // DASS-21 multiplier
    return DASS21Result(
      depression: depression * 2,
      anxiety: anxiety * 2,
      stress: stress * 2,
    );
  }
}