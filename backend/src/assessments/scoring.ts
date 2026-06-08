import { Severity, ScoreResult } from '../shared/types';

// DASS-21 item numbers (1-indexed) mapped to subscales
const DEPRESSION_ITEMS = [3, 5, 10, 13, 16, 17, 21];
const ANXIETY_ITEMS = [2, 4, 7, 9, 15, 19, 20];
const STRESS_ITEMS = [1, 6, 8, 11, 12, 14, 18];

/**
 * Compute DASS-21 scores from raw answers.
 * Ported directly from counsellor_high_risk.dart severity thresholds.
 *
 * @param rawAnswers - Array of 21 integers (0-3 each), 0-indexed where index 0 = Q1
 * @returns ScoreResult with raw, normalised, and severity classifications
 */
export function computeScores(rawAnswers: number[]): ScoreResult {
  if (rawAnswers.length !== 21) {
    throw new Error(`Expected 21 answers, got ${rawAnswers.length}`);
  }

  // Validate answer values
  for (let i = 0; i < rawAnswers.length; i++) {
    if (!Number.isInteger(rawAnswers[i]) || rawAnswers[i] < 0 || rawAnswers[i] > 3) {
      throw new Error(`Answer at index ${i} must be 0-3, got ${rawAnswers[i]}`);
    }
  }

  // Calculate raw scores (sum of items in each subscale)
  // rawAnswers is 0-indexed, so item N (1-indexed) = rawAnswers[N-1]
  const rawDep = DEPRESSION_ITEMS.reduce((sum, itemNum) => sum + rawAnswers[itemNum - 1], 0);
  const rawAnx = ANXIETY_ITEMS.reduce((sum, itemNum) => sum + rawAnswers[itemNum - 1], 0);
  const rawStr = STRESS_ITEMS.reduce((sum, itemNum) => sum + rawAnswers[itemNum - 1], 0);

  // Normalise to DASS-42 benchmark (multiply by 2)
  const normDep = rawDep * 2;
  const normAnx = rawAnx * 2;
  const normStr = rawStr * 2;

  return {
    rawScores: {
      dep: rawDep,
      anx: rawAnx,
      str: rawStr,
    },
    normalisedScores: {
      dep: normDep,
      anx: normAnx,
      str: normStr,
    },
    severities: {
      dep: getDepressionSeverity(normDep),
      anx: getAnxietySeverity(normAnx),
      str: getStressSeverity(normStr),
    },
  };
}

/**
 * Determine depression severity from normalised score.
 * Ported from counsellor_high_risk.dart
 */
export function getDepressionSeverity(score: number): Severity {
  if (score <= 9) return 'Normal';
  if (score <= 13) return 'Mild';
  if (score <= 20) return 'Moderate';
  if (score <= 27) return 'Severe';
  return 'Extremely Severe';
}

/**
 * Determine anxiety severity from normalised score.
 * Ported from counsellor_high_risk.dart
 */
export function getAnxietySeverity(score: number): Severity {
  if (score <= 7) return 'Normal';
  if (score <= 9) return 'Mild';
  if (score <= 14) return 'Moderate';
  if (score <= 19) return 'Severe';
  return 'Extremely Severe';
}

/**
 * Determine stress severity from normalised score.
 * Ported from counsellor_high_risk.dart
 */
export function getStressSeverity(score: number): Severity {
  if (score <= 14) return 'Normal';
  if (score <= 18) return 'Mild';
  if (score <= 25) return 'Moderate';
  if (score <= 33) return 'Severe';
  return 'Extremely Severe';
}

/**
 * Utility: convert severity string to ordinal rank for comparisons.
 * Enables queries like "severity >= Moderate" using numeric comparison.
 */
export function getSeverityRank(severity: Severity): number {
  const rankMap: Record<Severity, number> = {
    'Normal': 0,
    'Mild': 1,
    'Moderate': 2,
    'Severe': 3,
    'Extremely Severe': 4,
  };
  return rankMap[severity];
}
