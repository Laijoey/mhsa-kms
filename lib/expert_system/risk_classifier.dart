enum RiskLevel { normal, mild, moderate, severe, extremelySevere }

class RiskClassifier {
  static RiskLevel classifyDepression(int score) {
    if (score <= 9) return RiskLevel.normal;
    if (score <= 13) return RiskLevel.mild;
    if (score <= 20) return RiskLevel.moderate;
    if (score <= 27) return RiskLevel.severe;
    return RiskLevel.extremelySevere;
  }

  static RiskLevel classifyAnxiety(int score) {
    if (score <= 7) return RiskLevel.normal;
    if (score <= 9) return RiskLevel.mild;
    if (score <= 14) return RiskLevel.moderate;
    if (score <= 19) return RiskLevel.severe;
    return RiskLevel.extremelySevere;
  }

  static RiskLevel classifyStress(int score) {
    if (score <= 14) return RiskLevel.normal;
    if (score <= 18) return RiskLevel.mild;
    if (score <= 25) return RiskLevel.moderate;
    if (score <= 33) return RiskLevel.severe;
    return RiskLevel.extremelySevere;
  }
}