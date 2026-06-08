// 11 Sophisticated Rules (matching backend implementation)
// 8 Explicit Rules (R-001 to R-007, R-000) + 3 Tacit Rules (R-C01 to R-C03)

enum Severity { normal, mild, moderate, severe, extremelySevere }

class RuleResult {
  final String firedRuleId;
  final String riskLevel;
  final Map<String, String> severities;
  final Map<String, int> scores;
  final Map<String, dynamic> recommendation;
  final List<String> appliedTacitRules;

  RuleResult({
    required this.firedRuleId,
    required this.riskLevel,
    required this.severities,
    required this.scores,
    required this.recommendation,
    this.appliedTacitRules = const [],
  });
}

class RuleEngine {
  // DASS-21 Severity Classification Thresholds
  static Severity classifySeverity(String subscale, int score) {
    switch (subscale) {
      case 'depression':
        if (score <= 9) return Severity.normal;
        if (score <= 13) return Severity.mild;
        if (score <= 20) return Severity.moderate;
        if (score <= 27) return Severity.severe;
        return Severity.extremelySevere;

      case 'anxiety':
        if (score <= 7) return Severity.normal;
        if (score <= 9) return Severity.mild;
        if (score <= 14) return Severity.moderate;
        if (score <= 19) return Severity.severe;
        return Severity.extremelySevere;

      case 'stress':
        if (score <= 14) return Severity.normal;
        if (score <= 18) return Severity.mild;
        if (score <= 25) return Severity.moderate;
        if (score <= 33) return Severity.severe;
        return Severity.extremelySevere;

      default:
        return Severity.normal;
    }
  }

  static String severityToString(Severity severity) {
    return severity.toString().split('.').last;
  }

  static String capitalizeFirst(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  // EXPLICIT RULE: R-001
  static bool checkR001(Severity dep, Severity anx, Severity str) {
    return dep == Severity.extremelySevere || anx == Severity.extremelySevere;
  }

  // EXPLICIT RULE: R-002
  static bool checkR002(Severity dep, Severity anx, Severity str) {
    return dep == Severity.severe &&
        (anx == Severity.moderate ||
            anx == Severity.severe ||
            anx == Severity.extremelySevere);
  }

  // EXPLICIT RULE: R-003
  static bool checkR003(Severity dep, Severity anx, Severity str) {
    return str == Severity.severe || str == Severity.extremelySevere;
  }

  // EXPLICIT RULE: R-004
  static bool checkR004(Severity dep, Severity anx, Severity str) {
    return (dep == Severity.moderate ||
            dep == Severity.severe ||
            dep == Severity.extremelySevere) ||
        (anx == Severity.moderate ||
            anx == Severity.severe ||
            anx == Severity.extremelySevere);
  }

  // EXPLICIT RULE: R-005
  static bool checkR005(Severity dep, Severity anx, Severity str) {
    return (str == Severity.moderate) &&
        ((dep == Severity.mild ||
                dep == Severity.moderate ||
                dep == Severity.severe ||
                dep == Severity.extremelySevere) ||
            (anx == Severity.mild ||
                anx == Severity.moderate ||
                anx == Severity.severe ||
                anx == Severity.extremelySevere));
  }

  // EXPLICIT RULE: R-006
  static bool checkR006(Severity dep, Severity anx, Severity str) {
    return dep == Severity.mild &&
        anx == Severity.normal &&
        str == Severity.normal;
  }

  // EXPLICIT RULE: R-007
  static bool checkR007(Severity dep, Severity anx, Severity str) {
    return dep == Severity.normal &&
        anx == Severity.normal &&
        str == Severity.normal;
  }

  // EXPLICIT RULE: R-000 (fallback)
  static bool checkR000() => true;

  // TACIT RULE: R-C01 - Multi-Domain Moderate Escalation
  static bool checkRC01(Severity dep, Severity anx, Severity str) {
    return dep == Severity.moderate &&
        anx == Severity.moderate &&
        str == Severity.moderate;
  }

  // TACIT RULE: R-C02 - Exam Period (would need external context)
  static bool checkRC02(bool isExamPeriod, Severity str) {
    return isExamPeriod && (str == Severity.moderate || str == Severity.severe);
  }

  // TACIT RULE: R-C03 - Previous HIGH/CRITICAL (would need previous assessment)
  static bool checkRC03(bool previouslyHigh, Severity dep, Severity anx,
      Severity str) {
    return previouslyHigh &&
        (dep != Severity.normal ||
            anx != Severity.normal ||
            str != Severity.normal);
  }

  // Main evaluation logic
  static RuleResult evaluate({
    required int depression,
    required int anxiety,
    required int stress,
    bool isExamPeriod = false,
    bool previouslyHighRisk = false,
  }) {
    // Classify severities
    final depSeverity = classifySeverity('depression', depression);
    final anxSeverity = classifySeverity('anxiety', anxiety);
    final strSeverity = classifySeverity('stress', stress);

    final severities = {
      'depression': capitalizeFirst(severityToString(depSeverity)),
      'anxiety': capitalizeFirst(severityToString(anxSeverity)),
      'stress': capitalizeFirst(severityToString(strSeverity)),
    };

    final scores = {
      'depression': depression,
      'anxiety': anxiety,
      'stress': stress,
    };

    String riskLevel = 'LOW';
    String firedRuleId = 'R-000';
    List<String> appliedTacitRules = [];

    // Evaluate explicit rules in priority order (first match wins)
    if (checkR001(depSeverity, anxSeverity, strSeverity)) {
      riskLevel = 'CRITICAL';
      firedRuleId = 'R-001';
    } else if (checkR002(depSeverity, anxSeverity, strSeverity)) {
      riskLevel = 'HIGH';
      firedRuleId = 'R-002';
    } else if (checkR003(depSeverity, anxSeverity, strSeverity)) {
      riskLevel = 'HIGH';
      firedRuleId = 'R-003';
    } else if (checkR004(depSeverity, anxSeverity, strSeverity)) {
      riskLevel = 'MODERATE';
      firedRuleId = 'R-004';
    } else if (checkR005(depSeverity, anxSeverity, strSeverity)) {
      riskLevel = 'MODERATE';
      firedRuleId = 'R-005';
    } else if (checkR006(depSeverity, anxSeverity, strSeverity)) {
      riskLevel = 'LOW';
      firedRuleId = 'R-006';
    } else if (checkR007(depSeverity, anxSeverity, strSeverity)) {
      riskLevel = 'NORMAL';
      firedRuleId = 'R-007';
    } else {
      riskLevel = 'LOW';
      firedRuleId = 'R-000';
    }

    // Apply tacit rules (can override explicit rules)
    if (checkRC01(depSeverity, anxSeverity, strSeverity)) {
      riskLevel = 'HIGH';
      appliedTacitRules.add('R-C01');
    }

    if (checkRC02(isExamPeriod, strSeverity)) {
      appliedTacitRules.add('R-C02');
    }

    if (checkRC03(previouslyHighRisk, depSeverity, anxSeverity, strSeverity)) {
      riskLevel = 'HIGH';
      appliedTacitRules.add('R-C03');
    }

    // Generate recommendation based on fired rule
    final recommendation = _generateRecommendation(
      firedRuleId,
      riskLevel,
      depSeverity,
      anxSeverity,
      strSeverity,
      isExamPeriod,
    );

    return RuleResult(
      firedRuleId: firedRuleId,
      riskLevel: riskLevel,
      severities: severities,
      scores: scores,
      recommendation: recommendation,
      appliedTacitRules: appliedTacitRules,
    );
  }

  static Map<String, dynamic> _generateRecommendation(
    String ruleId,
    String riskLevel,
    Severity depSeverity,
    Severity anxSeverity,
    Severity strSeverity,
    bool isExamPeriod,
  ) {
    switch (riskLevel) {
      case 'CRITICAL':
        return {
          'title': 'CRITICAL - Immediate Support Needed',
          'body':
              'Your assessment indicates critical mental health concerns. Please contact the Student Wellness Centre immediately for urgent support.',
          'actions': [
            'Contact campus crisis hotline',
            'Schedule immediate counselling appointment',
            'Inform trusted friend or family member',
          ],
        };

      case 'HIGH':
        return {
          'title': 'HIGH RISK - Counsellor Referral Recommended',
          'body':
              'Your assessment shows elevated mental health concerns. We recommend booking a counselling appointment soon.',
          'actions': [
            'Schedule counselling within 48 hours',
            'Try stress management exercises',
            'Practice self-care activities',
          ],
        };

      case 'MODERATE':
        return {
          'title': 'MODERATE - Professional Support Suggested',
          'body':
              'Your assessment shows moderate mental health concerns. Consider speaking with a counsellor to develop coping strategies.',
          'actions': [
            'Book counselling appointment within 1 week',
            'Practice relaxation techniques',
            'Maintain regular sleep and exercise',
          ],
        };

      case 'LOW':
        return {
          'title': 'LOW RISK - Self-Care Recommended',
          'body':
              'Your assessment shows mild concerns. Focus on maintaining healthy lifestyle habits and reach out if symptoms worsen.',
          'actions': [
            'Maintain healthy sleep schedule',
            'Exercise regularly',
            'Connect with friends and family',
          ],
        };

      default:
        return {
          'title': 'NORMAL - You\'re Doing Well',
          'body':
              'Your assessment shows positive mental health. Continue your healthy habits and routine self-care.',
          'actions': [
            'Maintain your current healthy routine',
            'Continue regular exercise and sleep',
            'Re-assess in 3 months',
          ],
        };
    }
  }
}
