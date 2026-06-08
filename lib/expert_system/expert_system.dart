import 'dass_rules.dart';
import 'rule_engine.dart';

class ExpertSystem {
  /// Process DASS-21 answers using 11 sophisticated rules
  /// Returns a result compatible with backend API format
  static Map<String, dynamic> process(
    List<int> answers, {
    bool isExamPeriod = false,
    bool previouslyHighRisk = false,
  }) {
    // 1. Calculate DASS scores
    final dass = DASS21Calculator.calculate(answers: answers);

    // 2. Evaluate using 11-rule engine
    final ruleResult = RuleEngine.evaluate(
      depression: dass.depression,
      anxiety: dass.anxiety,
      stress: dass.stress,
      isExamPeriod: isExamPeriod,
      previouslyHighRisk: previouslyHighRisk,
    );

    // 3. Return backend-compatible format
    return {
      'normalisedScores': {
        'depression': dass.depression,
        'anxiety': dass.anxiety,
        'stress': dass.stress,
      },
      'severities': ruleResult.severities,
      'firedRuleId': ruleResult.firedRuleId,
      'riskLevel': ruleResult.riskLevel,
      'recommendation': ruleResult.recommendation,
      'appliedTacitRules': ruleResult.appliedTacitRules,
    };
  }
}