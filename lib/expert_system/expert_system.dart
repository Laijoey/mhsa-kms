import 'dass_rules.dart';
import 'recommendation_engine.dart';

class ExpertSystem {

  static Map<String, dynamic> process(List<int> answers) {

    // 1. Calculate DASS scores
    final dass = DASS21Calculator.calculate(answers: answers);

    // 2. Generate recommendations using rule engine
    final result = RecommendationEngine.generate(
      depression: dass.depression,
      anxiety: dass.anxiety,
      stress: dass.stress,
    );

    // 3. Return EVERYTHING in one object
    return {
      "depression": dass.depression,
      "anxiety": dass.anxiety,
      "stress": dass.stress,
      "riskLevel": result["riskLevel"],
      "recommendations": result["recommendations"],
    };
  }
}