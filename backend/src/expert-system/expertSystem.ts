/**
 * Expert System: 11 Sophisticated Rules (Dart → TypeScript port)
 * 8 Explicit Rules (R-001 to R-007, R-000) + 3 Tacit Rules (R-C01 to R-C03)
 *
 * This is a standalone expert system that can evaluate DASS-21 scores
 * independently, matching the frontend Dart implementation exactly.
 *
 * Use case: Offline assessment, comparison/validation, local processing
 */

import { Severity, RiskLevel } from '../shared/types';

interface SeverityClassification {
  depression: Severity;
  anxiety: Severity;
  stress: Severity;
}

interface ExpertSystemResult {
  firedRuleId: string;
  riskLevel: RiskLevel;
  severities: SeverityClassification;
  scores: {
    depression: number;
    anxiety: number;
    stress: number;
  };
  recommendation: {
    title: string;
    body: string;
    actions: string[];
  };
  appliedTacitRules: string[];
}

/**
 * Classify a single subscale score to severity level
 */
function classifySeverity(subscale: 'depression' | 'anxiety' | 'stress', score: number): Severity {
  switch (subscale) {
    case 'depression':
      if (score <= 9) return 'Normal';
      if (score <= 13) return 'Mild';
      if (score <= 20) return 'Moderate';
      if (score <= 27) return 'Severe';
      return 'Extremely Severe';

    case 'anxiety':
      if (score <= 7) return 'Normal';
      if (score <= 9) return 'Mild';
      if (score <= 14) return 'Moderate';
      if (score <= 19) return 'Severe';
      return 'Extremely Severe';

    case 'stress':
      if (score <= 14) return 'Normal';
      if (score <= 18) return 'Mild';
      if (score <= 25) return 'Moderate';
      if (score <= 33) return 'Severe';
      return 'Extremely Severe';

    default:
      return 'Normal';
  }
}

/**
 * Compare severity levels (e.g., "Moderate" >= "Mild")
 */
function severityGte(sev1: Severity, sev2: Severity): boolean {
  const rank: Record<Severity, number> = {
    'Normal': 0,
    'Mild': 1,
    'Moderate': 2,
    'Severe': 3,
    'Extremely Severe': 4,
  };
  return rank[sev1] >= rank[sev2];
}

/**
 * EXPLICIT RULE: R-001
 */
function checkR001(dep: Severity, anx: Severity): boolean {
  return dep === 'Extremely Severe' || anx === 'Extremely Severe';
}

/**
 * EXPLICIT RULE: R-002
 */
function checkR002(dep: Severity, anx: Severity): boolean {
  return dep === 'Severe' && severityGte(anx, 'Moderate');
}

/**
 * EXPLICIT RULE: R-003
 */
function checkR003(str: Severity): boolean {
  return str === 'Severe' || str === 'Extremely Severe';
}

/**
 * EXPLICIT RULE: R-004
 */
function checkR004(dep: Severity, anx: Severity): boolean {
  return (
    (dep === 'Moderate' || dep === 'Severe' || dep === 'Extremely Severe') ||
    (anx === 'Moderate' || anx === 'Severe' || anx === 'Extremely Severe')
  );
}

/**
 * EXPLICIT RULE: R-005
 */
function checkR005(str: Severity, dep: Severity, anx: Severity): boolean {
  return (
    str === 'Moderate' &&
    (severityGte(dep, 'Mild') || severityGte(anx, 'Mild'))
  );
}

/**
 * EXPLICIT RULE: R-006
 */
function checkR006(dep: Severity, anx: Severity, str: Severity): boolean {
  return dep === 'Mild' && anx === 'Normal' && str === 'Normal';
}

/**
 * EXPLICIT RULE: R-007
 */
function checkR007(dep: Severity, anx: Severity, str: Severity): boolean {
  return dep === 'Normal' && anx === 'Normal' && str === 'Normal';
}

/**
 * EXPLICIT RULE: R-000 (fallback)
 */
function checkR000(): boolean {
  return true;
}

/**
 * TACIT RULE: R-C01 - Multi-Domain Moderate Escalation
 */
function checkRC01(dep: Severity, anx: Severity, str: Severity): boolean {
  return dep === 'Moderate' && anx === 'Moderate' && str === 'Moderate';
}

/**
 * TACIT RULE: R-C02 - Exam Period Context
 */
function checkRC02(isExamPeriod: boolean, str: Severity): boolean {
  return isExamPeriod && severityGte(str, 'Moderate');
}

/**
 * TACIT RULE: R-C03 - Previous High-Risk Override
 */
function checkRC03(
  previouslyHighRisk: boolean,
  dep: Severity,
  anx: Severity,
  str: Severity
): boolean {
  return (
    previouslyHighRisk &&
    (dep !== 'Normal' || anx !== 'Normal' || str !== 'Normal')
  );
}

/**
 * Generate recommendation based on risk level and context
 */
function generateRecommendation(
  riskLevel: RiskLevel,
  isExamPeriod: boolean = false
): { title: string; body: string; actions: string[] } {
  const baseRecommendations: Record<RiskLevel, { title: string; body: string; actions: string[] }> = {
    CRITICAL: {
      title: 'CRITICAL - Immediate Support Needed',
      body:
        'Your assessment indicates critical mental health concerns. Please contact the Student Wellness Centre immediately for urgent support.',
      actions: [
        'Contact campus crisis hotline',
        'Schedule immediate counselling appointment',
        'Inform trusted friend or family member',
      ],
    },
    HIGH: {
      title: 'HIGH RISK - Counsellor Referral Recommended',
      body:
        'Your assessment shows elevated mental health concerns. We recommend booking a counselling appointment soon.',
      actions: [
        'Schedule counselling within 48 hours',
        'Try stress management exercises',
        'Practice self-care activities',
      ],
    },
    MODERATE: {
      title: 'MODERATE - Professional Support Suggested',
      body:
        'Your assessment shows moderate mental health concerns. Consider speaking with a counsellor to develop coping strategies.',
      actions: [
        'Book counselling appointment within 1 week',
        'Practice relaxation techniques',
        'Maintain regular sleep and exercise',
      ],
    },
    LOW: {
      title: 'LOW RISK - Self-Care Recommended',
      body:
        'Your assessment shows mild concerns. Focus on maintaining healthy lifestyle habits and reach out if symptoms worsen.',
      actions: [
        'Maintain healthy sleep schedule',
        'Exercise regularly',
        'Connect with friends and family',
      ],
    },
    NORMAL: {
      title: "NORMAL - You're Doing Well",
      body:
        'Your assessment shows positive mental health. Continue your healthy habits and routine self-care.',
      actions: [
        'Maintain your current healthy routine',
        'Continue regular exercise and sleep',
        'Re-assess in 3 months',
      ],
    },
  };

  const recommendation = baseRecommendations[riskLevel];

  // Add exam-specific actions if applicable
  if (isExamPeriod && (riskLevel === 'MODERATE' || riskLevel === 'HIGH')) {
    recommendation.actions.unshift('Exam stress management resource pack');
    recommendation.actions.push('Schedule DASS-21 follow-up after exam period');
  }

  return recommendation;
}

/**
 * Main evaluation function
 * Evaluates 11 rules and returns structured result
 */
export function evaluateExpertSystem(
  depression: number,
  anxiety: number,
  stress: number,
  options: {
    isExamPeriod?: boolean;
    previouslyHighRisk?: boolean;
  } = {}
): ExpertSystemResult {
  const { isExamPeriod = false, previouslyHighRisk = false } = options;

  // Classify severities
  const depSeverity = classifySeverity('depression', depression);
  const anxSeverity = classifySeverity('anxiety', anxiety);
  const strSeverity = classifySeverity('stress', stress);

  const severities: SeverityClassification = {
    depression: depSeverity,
    anxiety: anxSeverity,
    stress: strSeverity,
  };

  const scores = { depression, anxiety, stress };

  let riskLevel: RiskLevel = 'LOW';
  let firedRuleId = 'R-000';
  const appliedTacitRules: string[] = [];

  // ===== EXPLICIT RULES (First match wins) =====

  if (checkR001(depSeverity, anxSeverity)) {
    riskLevel = 'CRITICAL';
    firedRuleId = 'R-001';
  } else if (checkR002(depSeverity, anxSeverity)) {
    riskLevel = 'HIGH';
    firedRuleId = 'R-002';
  } else if (checkR003(strSeverity)) {
    riskLevel = 'HIGH';
    firedRuleId = 'R-003';
  } else if (checkR004(depSeverity, anxSeverity)) {
    riskLevel = 'MODERATE';
    firedRuleId = 'R-004';
  } else if (checkR005(strSeverity, depSeverity, anxSeverity)) {
    riskLevel = 'MODERATE';
    firedRuleId = 'R-005';
  } else if (checkR006(depSeverity, anxSeverity, strSeverity)) {
    riskLevel = 'LOW';
    firedRuleId = 'R-006';
  } else if (checkR007(depSeverity, anxSeverity, strSeverity)) {
    riskLevel = 'NORMAL';
    firedRuleId = 'R-007';
  } else if (checkR000()) {
    riskLevel = 'LOW';
    firedRuleId = 'R-000';
  }

  // ===== TACIT RULES (Can override/escalate) =====

  // R-C01: Multi-domain moderate escalation
  if (checkRC01(depSeverity, anxSeverity, strSeverity)) {
    riskLevel = 'HIGH';
    appliedTacitRules.push('R-C01');
  }

  // R-C02: Exam period context
  if (checkRC02(isExamPeriod, strSeverity)) {
    appliedTacitRules.push('R-C02');
  }

  // R-C03: Previous high-risk override
  if (checkRC03(previouslyHighRisk, depSeverity, anxSeverity, strSeverity)) {
    riskLevel = 'HIGH';
    appliedTacitRules.push('R-C03');
  }

  // Generate recommendation
  const recommendation = generateRecommendation(riskLevel, isExamPeriod);

  return {
    firedRuleId,
    riskLevel,
    severities,
    scores,
    recommendation,
    appliedTacitRules,
  };
}
