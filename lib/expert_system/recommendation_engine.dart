// DEPRECATED: This file is kept for reference only.
// The expert system now uses rule_engine.dart with 11 sophisticated rules.
// See: lib/expert_system/rule_engine.dart

class RecommendationEngine {
  static Map<String, dynamic> generate({
    required int depression,
    required int anxiety,
    required int stress,
  }) {
    List<String> recommendations = [];
    String riskLevel = "Normal";

    // EXTREMELY SEVERE (highest priority)
    if (depression >= 28 || anxiety >= 20 || stress >= 34) {
      riskLevel = "Extremely Severe";
      recommendations.add("URGENT: Seek immediate counselling support");
      recommendations.add("Do not isolate yourself");
    }

    // SEVERE
    else if (depression >= 21) {
      riskLevel = "Severe";
      recommendations.add("Maintain daily routine even with low motivation");
      recommendations.add("Talk to trusted friends or counsellor");
    }

    // MODERATE (anxiety)
    else if (anxiety >= 15) {
      riskLevel = "Moderate";
      recommendations.add("Practice grounding technique (5-4-3-2-1)");
    }

    // MODERATE (stress)
    else if (stress >= 26) {
      riskLevel = "Moderate";
      recommendations.add("Use breathing technique (4-7-8)");
      recommendations.add("Reduce workload");
    }

    // DEFAULT
    else {
      riskLevel = "Normal";
      recommendations.add("Continue healthy lifestyle habits");
      recommendations.add("Maintain good sleep and exercise routine");
    }

    return {
      "riskLevel": riskLevel,
      "recommendations": recommendations,
    };
  }
}