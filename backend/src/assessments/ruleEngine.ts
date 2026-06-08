import {
  Severity,
  RiskLevel,
  RuleEngineInput,
  RuleEngineResult,
  RuleDoc,
  AssessmentDoc,
} from '../shared/types';
import { getSeverityRank } from './scoring';

/**
 * Rule engine: evaluates explicit rules first (first match wins),
 * then applies tacit rules as overrides/supplements.
 */
export async function evaluateRules(input: RuleEngineInput): Promise<RuleEngineResult> {
  // Evaluate explicit rules (R-001 → R-007 → R-000 fallback)
  const explicit = evaluateExplicitRules(
    input.severities,
    input.normalisedScores,
    input.ruleConfigs,
  );

  // Evaluate tacit rules for overrides
  const tacit = evaluateTacitRules(
    explicit,
    input.severities,
    input.normalisedScores,
    input.userId,
    input.previousAssessments,
    input.ruleConfigs,
    input.currentDate,
  );

  // Build the final recommendation
  const recommendation = buildRecommendation(
    explicit.ruleId,
    tacit.riskLevel,
    tacit.appliedTacitRules,
  );

  return {
    firedRuleId: explicit.ruleId,
    riskLevel: tacit.riskLevel,
    recommendation,
    appliedTacitRules: tacit.appliedTacitRules,
  };
}

/**
 * Explicit rule evaluation: first match wins.
 * Returns the fired rule ID and its base risk level.
 */
function evaluateExplicitRules(
  severities: Record<string, Severity>,
  normalisedScores: Record<string, number>,
  configs: RuleDoc[],
): { ruleId: string; riskLevel: RiskLevel } {
  const { dep, anx, str } = severities;

  // R-001: CRITICAL
  const r001 = getConfig(configs, 'R-001');
  if (r001.isActive && (dep === 'Extremely Severe' || anx === 'Extremely Severe')) {
    return { ruleId: 'R-001', riskLevel: 'CRITICAL' };
  }

  // R-002: HIGH
  if (dep === 'Severe' && severityGte(anx, 'Moderate')) {
    return { ruleId: 'R-002', riskLevel: 'HIGH' };
  }

  // R-003: HIGH
  if (str === 'Severe' || str === 'Extremely Severe') {
    return { ruleId: 'R-003', riskLevel: 'HIGH' };
  }

  // R-004: MODERATE
  if (dep === 'Moderate' || anx === 'Moderate') {
    return { ruleId: 'R-004', riskLevel: 'MODERATE' };
  }

  // R-005: MODERATE
  if (str === 'Moderate' && (severityGte(dep, 'Mild') || severityGte(anx, 'Mild'))) {
    return { ruleId: 'R-005', riskLevel: 'MODERATE' };
  }

  // R-006: LOW
  if (dep === 'Mild' && anx === 'Normal' && str === 'Normal') {
    return { ruleId: 'R-006', riskLevel: 'LOW' };
  }

  // R-007: NORMAL
  if (dep === 'Normal' && anx === 'Normal' && severityLte(str, 'Mild')) {
    return { ruleId: 'R-007', riskLevel: 'NORMAL' };
  }

  // R-000: fallback (log that it fired)
  console.warn(
    `R-000 fallback fired. Severities: dep=${dep}, anx=${anx}, str=${str}. Scores: dep=${normalisedScores.dep}, anx=${normalisedScores.anx}, str=${normalisedScores.str}`,
  );
  return { ruleId: 'R-000', riskLevel: 'LOW' };
}

/**
 * Tacit rule evaluation: applies overrides and supplements after explicit resolution.
 */
function evaluateTacitRules(
  explicit: { ruleId: string; riskLevel: RiskLevel },
  severities: Record<string, Severity>,
  normalisedScores: Record<string, number>,
  userId: string,
  previousAssessments: AssessmentDoc[],
  configs: RuleDoc[],
  currentDate: Date,
): { riskLevel: RiskLevel; appliedTacitRules: string[] } {
  const { dep, anx, str } = severities;
  const applied: string[] = [];
  let riskLevel = explicit.riskLevel;

  // R-C01: Triple moderate escalation
  const rc01 = getConfig(configs, 'R-C01');
  if (
    rc01.isActive &&
    dep === 'Moderate' &&
    anx === 'Moderate' &&
    str === 'Moderate'
  ) {
    if (riskLevel === 'MODERATE') riskLevel = 'HIGH';
    applied.push('R-C01');
  }

  // R-C02: Exam period stress escalation
  const rc02 = getConfig(configs, 'R-C02');
  if (rc02.isActive && isExamPeriod(currentDate) && severityGte(str, 'Moderate')) {
    applied.push('R-C02');
    // Note: this doesn't change riskLevel but adds exam resources to recommendation
  }

  // R-C03: Previous high-risk override
  const rc03 = getConfig(configs, 'R-C03');
  if (rc03.isActive && previousAssessments.length > 0) {
    const lastAssessment = previousAssessments[0];
    const lastWasHighPlus = ['HIGH', 'CRITICAL'].includes(lastAssessment.riskLevel);
    const currentHasAnyMild =
      severityGte(dep, 'Mild') || severityGte(anx, 'Mild') || severityGte(str, 'Mild');

    if (lastWasHighPlus && currentHasAnyMild) {
      if (riskLevel === 'MODERATE' || riskLevel === 'LOW') riskLevel = 'HIGH';
      applied.push('R-C03');
    }
  }

  return { riskLevel, appliedTacitRules: applied };
}

/**
 * Check if a given date falls within the configured exam period.
 */
function isExamPeriod(date: Date): boolean {
  const startStr = process.env.EXAM_PERIOD_START || '2026-06-15';
  const endStr = process.env.EXAM_PERIOD_END || '2026-07-15';

  const start = new Date(startStr);
  const end = new Date(endStr);

  return date >= start && date <= end;
}

/**
 * Build the recommendation object from the fired rule and risk level.
 */
function buildRecommendation(
  ruleId: string,
  riskLevel: RiskLevel,
  appliedTacitRules: string[],
): { title: string; body: string; actions: string[] } {
  // Recommendations based on rule ID and risk level
  const recommendations: Record<string, { title: string; body: string; actions: string[] }> = {
    'R-001': {
      title: 'Crisis Alert - Immediate Support Needed',
      body: 'Your assessment indicates extremely high levels of psychological distress requiring immediate professional intervention. Please contact the Campus Crisis Hotline immediately. We are also notifying the Student Wellness Centre to ensure you receive urgent support.',
      actions: [
        'Call Campus Crisis Hotline: +603-7967-3245 (24/7)',
        'Email: wellness@campus.edu.my',
        'Walk-in to Student Wellness Centre - Bangunan D, Level 2',
      ],
    },
    'R-002': {
      title: 'Urgent Counsellor Referral',
      body: 'Your assessment shows severe depression combined with significant anxiety. We recommend booking an urgent counselling session with a campus counsellor as soon as possible, ideally within the same day. Emergency support contacts are available below.',
      actions: [
        'Book urgent appointment: wellness-appointments@campus.edu.my',
        'Call Counselling Services: +603-7965-8899',
        'Access 24/7 text support: Crisis Chat at wellness.campus.edu.my',
      ],
    },
    'R-003': {
      title: 'Immediate Stress Management Intervention',
      body: 'Your stress levels are significantly elevated and require immediate management. We recommend structured stress relief interventions and professional counselling support to help you build effective coping strategies.',
      actions: [
        'Try guided relaxation exercises (see resources)',
        'Book counselling session: wellness-appointments@campus.edu.my',
        'Join stress-management workshop (see knowledge base)',
        'Practice grounding techniques (5-4-3-2-1 sensory technique)',
      ],
    },
    'R-004': {
      title: 'Professional Counselling Recommended',
      body: 'Your assessment indicates moderate levels of psychological distress. We recommend scheduling a counselling appointment within the next week to discuss coping strategies and access appropriate support.',
      actions: [
        'Book appointment: wellness-appointments@campus.edu.my (within 1 week)',
        'Access CBT-based self-help resources (see knowledge base)',
        'Join peer support group: peer-support@campus.edu.my',
        'Review lifestyle and stress-management tips',
      ],
    },
    'R-005': {
      title: 'Time Management & Stress Relief Support',
      body: 'Your stress levels combined with other concerns suggest a need for structured support in managing time and workload. Consider exploring time-management techniques and stress-relief resources while scheduling a follow-up assessment in two weeks.',
      actions: [
        'Access time-management resources (see knowledge base)',
        'Try relaxation and mindfulness exercises',
        'Consider light counselling consultation (optional)',
        'Schedule follow-up DASS-21 assessment in 2 weeks',
      ],
    },
    'R-006': {
      title: 'Mood Management & Wellness Tips',
      body: 'Your assessment is mostly positive with only mild depressive symptoms. Focus on maintaining wellness through healthy lifestyle practices and psychoeducation about mood management.',
      actions: [
        'Review psychoeducation materials on mood (see knowledge base)',
        'Maintain healthy sleep, exercise, and social connection',
        'Practice positive psychology techniques',
        'Schedule reassessment in 1 month',
      ],
    },
    'R-007': {
      title: 'Excellent Psychological Well-Being',
      body: 'Your assessment shows good psychological health across all areas. Maintain these positive patterns through regular self-care, social connection, and healthy lifestyle habits.',
      actions: [
        'Continue current well-being practices',
        'Explore general well-being resources if interested',
        'Schedule routine reassessment in 3 months',
        'Support peers with their mental health journey',
      ],
    },
    'R-000': {
      title: 'General Well-Being & Monitoring',
      body: 'Your assessment pattern suggests a need for monitoring and general support. We recommend reviewing well-being resources and scheduling a follow-up assessment to track your progress.',
      actions: [
        'Review general well-being resources',
        'Practice self-monitoring of mood and stress',
        'Schedule follow-up assessment in 2 weeks',
        'Contact wellness services for guidance: wellness@campus.edu.my',
      ],
    },
  };

  let recommendation = recommendations[ruleId] || recommendations['R-000'];

  // Append exam context if R-C02 was applied
  if (appliedTacitRules.includes('R-C02')) {
    recommendation.body +=
      ' Note: Our resources include exam-specific stress management strategies. You will be contacted for a follow-up assessment two weeks after the exam period.';
    recommendation.actions.push('Access exam stress-management guide (see resources)');
  }

  return recommendation;
}

/**
 * Helper: get a rule config by ID, with default if not found.
 */
function getConfig(configs: RuleDoc[], ruleId: string): RuleDoc {
  const config = configs.find((r) => r.id === ruleId);
  if (!config) {
    // Return a sensible default (inactive)
    return {
      id: ruleId,
      type: 'Core',
      title: ruleId,
      description: '',
      formula: '',
      actions: [],
      isActive: false,
      parameters: [],
    };
  }
  return config;
}

/**
 * Helper: check if severity A >= severity B (ordinal comparison).
 */
function severityGte(a: Severity, b: Severity): boolean {
  return getSeverityRank(a) >= getSeverityRank(b);
}

/**
 * Helper: check if severity A <= severity B (ordinal comparison).
 */
function severityLte(a: Severity, b: Severity): boolean {
  return getSeverityRank(a) <= getSeverityRank(b);
}
