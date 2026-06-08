import * as admin from 'firebase-admin';
import { getFirestore } from '../shared/firestore';
import {
  AssessmentDoc,
  RuleDoc,
  RuleEngineInput,
} from '../shared/types';
import { ValidationError } from '../shared/errors';
import { computeScores } from './scoring';
import { evaluateRules } from './ruleEngine';

/**
 * Submit a new DASS-21 assessment for a student.
 * Scores the assessment, evaluates rules, stores the result, and returns it.
 */
export async function submitAssessment(
  userId: string,
  rawAnswers: number[],
): Promise<Omit<AssessmentDoc, 'rawAnswers'>> {
  // Validate input
  if (!Array.isArray(rawAnswers) || rawAnswers.length !== 21) {
    throw new ValidationError('rawAnswers must be an array of exactly 21 integers');
  }

  for (let i = 0; i < rawAnswers.length; i++) {
    if (!Number.isInteger(rawAnswers[i]) || rawAnswers[i] < 0 || rawAnswers[i] > 3) {
      throw new ValidationError(`Answer at index ${i} must be an integer between 0 and 3`);
    }
  }

  const db = getFirestore();

  // Compute scores
  const scoreResult = computeScores(rawAnswers);

  // Fetch student's previous assessments for R-C03 tacit rule
  const prevAssessmentsSnap = await db
    .collection('assessments')
    .where('userId', '==', userId)
    .orderBy('takenAt', 'desc')
    .limit(10)
    .get();

  const previousAssessments = prevAssessmentsSnap.docs.map(
    (doc) => ({ ...doc.data(), id: doc.id } as AssessmentDoc)
  );

  // Fetch rule configs from Firestore
  const rulesSnap = await db.collection('rules').get();
  const ruleConfigs = rulesSnap.docs.map(
    (doc) => ({ ...doc.data(), id: doc.id } as RuleDoc)
  );

  // Evaluate rules
  const ruleEngineInput: RuleEngineInput = {
    severities: scoreResult.severities,
    normalisedScores: scoreResult.normalisedScores,
    userId,
    previousAssessments,
    ruleConfigs,
    currentDate: new Date(),
  };

  const ruleResult = await evaluateRules(ruleEngineInput);

  // Create assessment document
  const assessment: AssessmentDoc = {
    id: '',  // Will be set by Firestore
    userId,
    takenAt: admin.firestore.Timestamp.now(),
    rawAnswers,
    rawScores: scoreResult.rawScores,
    normalisedScores: scoreResult.normalisedScores,
    severities: scoreResult.severities,
    firedRuleId: ruleResult.firedRuleId,
    riskLevel: ruleResult.riskLevel,
    recommendation: ruleResult.recommendation,
    appliedTacitRules: ruleResult.appliedTacitRules,
  };

  // Store in Firestore
  const docRef = await db.collection('assessments').add(assessment);
  assessment.id = docRef.id;

  // Return assessment without rawAnswers (for privacy) and convert timestamp to ISO string
  const { rawAnswers: _, ...returnData } = assessment;
  return {
    ...returnData,
    takenAt: assessment.takenAt.toDate().toISOString(),
  } as any;
}

/**
 * Get a student's assessment history.
 */
export async function getStudentHistory(userId: string, limit: number = 20) {
  const db = getFirestore();

  const snapshot = await db
    .collection('assessments')
    .where('userId', '==', userId)
    .orderBy('takenAt', 'desc')
    .limit(limit)
    .get();

  return snapshot.docs.map((doc) => {
    const data = doc.data();
    // Exclude rawAnswers for privacy and convert timestamp to ISO string
    const { rawAnswers, ...result } = data;
    return {
      ...result,
      id: doc.id,
      takenAt: data.takenAt?.toDate?.()?.toISOString?.() || new Date().toISOString(),
    };
  });
}

/**
 * Get all HIGH and CRITICAL assessments (for counsellor queue).
 */
export async function getHighRiskQueue(limit: number = 50) {
  const db = getFirestore();

  const snapshot = await db
    .collection('assessments')
    .where('riskLevel', 'in', ['HIGH', 'CRITICAL'])
    .orderBy('takenAt', 'desc')
    .limit(limit)
    .select(
      'id',
      'takenAt',
      'normalisedScores',
      'severities',
      'firedRuleId',
      'recommendation',
      'appliedTacitRules',
      'riskLevel',
    )
    .get();

  return snapshot.docs.map((doc) => {
    const data = doc.data();
    return {
      uuid: doc.id,  // assessment doc ID serves as UUID for anonymity
      riskLevel: data.riskLevel,
      timestamp: data.takenAt?.toDate?.()?.toISOString?.() || new Date().toISOString(),
      depression: data.normalisedScores.dep,
      anxiety: data.normalisedScores.anx,
      stress: data.normalisedScores.str,
      ruleTriggered: data.firedRuleId,
      ruleDescription: data.recommendation?.title || '',
      tacitBadges: data.appliedTacitRules || [],
      intervention: data.recommendation?.body || '',
      contacted: false,  // Not persisted yet; for UI state only
    };
  });
}
