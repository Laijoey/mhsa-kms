class KnowledgeBase {
  static const copingStrategies = {
    "stress": [
      "Deep breathing (4-7-8 technique)",
      "Exercise 20–30 minutes daily",
      "Time management planning",
      "Reduce caffeine intake"
    ],
    "anxiety": [
      "Grounding technique (5-4-3-2-1)",
      "Progressive muscle relaxation",
      "Mindfulness meditation",
      "Limit negative thinking loops"
    ],
    "depression": [
      "Maintain daily routine",
      "Talk to trusted friends/family",
      "Light outdoor activity",
      "Avoid isolation"
    ]
  };

  static const emergencyAdvice = [
    "Seek immediate counselling support",
    "Contact mental health professional",
    "Do not stay alone",
    "Reach out to hotline or counsellor"
  ];
}

// simulate counsellor thinking
class TacitKnowledge {
  static String interpretHighRisk(int depression, int anxiety, int stress) {
    if (depression >= 28 || anxiety >= 20 || stress >= 34) {
      return "Student shows severe psychological distress pattern. Immediate intervention required.";
    }

    if (depression >= 21 && anxiety >= 15) {
      return "Possible comorbid anxiety-depression pattern. Monitor closely.";
    }

    return "No critical risk pattern detected.";
  }
}