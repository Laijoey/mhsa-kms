/**
 * Expert System Router
 * Exposes the expert system as a standalone endpoint
 *
 * POST /api/v1/assessments/expert-system
 * - No persistence (local evaluation only)
 * - No rule configuration (hardcoded 11 rules)
 * - Immediate response (no database calls)
 *
 * Use case: Testing, comparison, offline fallback validation
 */

import { Router, Request, Response } from 'express';
import { evaluateExpertSystem } from './expertSystem';

const router = Router();

interface ExpertSystemRequest {
  rawAnswers: number[];
  isExamPeriod?: boolean;
  previouslyHighRisk?: boolean;
}

/**
 * POST /api/v1/assessments/expert-system
 *
 * Evaluate DASS-21 answers using the 11-rule expert system (offline/local).
 * This does NOT persist to database - it's for testing/comparison/offline use.
 *
 * Request:
 * {
 *   "rawAnswers": [0, 1, 2, 3, ..., 0],  // 21 items, each 0-3
 *   "isExamPeriod": false,
 *   "previouslyHighRisk": false
 * }
 *
 * Response:
 * {
 *   "firedRuleId": "R-001",
 *   "riskLevel": "CRITICAL",
 *   "severities": { "depression": "...", "anxiety": "...", "stress": "..." },
 *   "scores": { "depression": 42, "anxiety": 42, "stress": 42 },
 *   "recommendation": { "title": "...", "body": "...", "actions": [...] },
 *   "appliedTacitRules": []
 * }
 */
router.post('/expert-system', (req: Request, res: Response): void => {
  try {
    const body: ExpertSystemRequest = req.body;

    // Validate input
    if (!Array.isArray(body.rawAnswers) || body.rawAnswers.length !== 21) {
      res.status(400).json({
        error: 'Invalid rawAnswers: must be array of 21 integers (0-3 each)',
      });
      return;
    }

    // Validate each answer
    for (let i = 0; i < body.rawAnswers.length; i++) {
      const answer = body.rawAnswers[i];
      if (!Number.isInteger(answer) || answer < 0 || answer > 3) {
        res.status(400).json({
          error: `Invalid answer at index ${i}: must be 0-3, got ${answer}`,
        });
        return;
      }
    }

    // Calculate DASS-21 scores
    const DEPRESSION_ITEMS = [3, 5, 10, 13, 16, 17, 21];
    const ANXIETY_ITEMS = [2, 4, 7, 9, 15, 19, 20];
    const STRESS_ITEMS = [1, 6, 8, 11, 12, 14, 18];

    const rawDep = DEPRESSION_ITEMS.reduce((sum, itemNum) => sum + body.rawAnswers[itemNum - 1], 0);
    const rawAnx = ANXIETY_ITEMS.reduce((sum, itemNum) => sum + body.rawAnswers[itemNum - 1], 0);
    const rawStr = STRESS_ITEMS.reduce((sum, itemNum) => sum + body.rawAnswers[itemNum - 1], 0);

    // Normalise to DASS-42 (multiply by 2)
    const depression = rawDep * 2;
    const anxiety = rawAnx * 2;
    const stress = rawStr * 2;

    // Evaluate using expert system
    const result = evaluateExpertSystem(depression, anxiety, stress, {
      isExamPeriod: body.isExamPeriod || false,
      previouslyHighRisk: body.previouslyHighRisk || false,
    });

    // Return result (no persistence)
    res.status(200).json(result);
  } catch (error) {
    console.error('Expert system evaluation error:', error);
    res.status(500).json({
      error: 'Expert system evaluation failed',
      details: error instanceof Error ? error.message : String(error),
    });
  }
});

/**
 * GET /api/v1/assessments/expert-system/rules
 *
 * Return the 11 hardcoded rules (for reference/testing)
 */
router.get('/expert-system/rules', (req: Request, res: Response) => {
  const rules = [
    {
      id: 'R-001',
      name: 'Extremely Severe Crisis',
      condition: 'Depression = ES OR Anxiety = ES',
      riskLevel: 'CRITICAL',
      type: 'explicit',
    },
    {
      id: 'R-002',
      name: 'Severe Depression + Moderate Anxiety',
      condition: 'Depression = Severe AND Anxiety >= Moderate',
      riskLevel: 'HIGH',
      type: 'explicit',
    },
    {
      id: 'R-003',
      name: 'Severe Stress',
      condition: 'Stress = Severe OR Stress = ES',
      riskLevel: 'HIGH',
      type: 'explicit',
    },
    {
      id: 'R-004',
      name: 'Moderate Depression or Anxiety',
      condition: 'Depression = Moderate OR Anxiety = Moderate',
      riskLevel: 'MODERATE',
      type: 'explicit',
    },
    {
      id: 'R-005',
      name: 'Moderate Stress + Mild+',
      condition: 'Stress = Moderate AND (Depression >= Mild OR Anxiety >= Mild)',
      riskLevel: 'MODERATE',
      type: 'explicit',
    },
    {
      id: 'R-006',
      name: 'Mild Depression Only',
      condition: 'Depression = Mild AND Anxiety = Normal AND Stress = Normal',
      riskLevel: 'LOW',
      type: 'explicit',
    },
    {
      id: 'R-007',
      name: 'All Normal',
      condition: 'Depression = Normal AND Anxiety = Normal AND Stress <= Mild',
      riskLevel: 'NORMAL',
      type: 'explicit',
    },
    {
      id: 'R-000',
      name: 'Fallback',
      condition: 'None of R-001 to R-007 match',
      riskLevel: 'LOW',
      type: 'explicit',
    },
    {
      id: 'R-C01',
      name: 'Multi-Domain Moderate Escalation',
      condition: 'Depression = Moderate AND Anxiety = Moderate AND Stress = Moderate',
      action: 'Escalate MODERATE → HIGH',
      type: 'tacit',
    },
    {
      id: 'R-C02',
      name: 'Exam Period Context',
      condition: 'Exam period = true AND Stress >= Moderate',
      action: 'Add exam resources to recommendation',
      type: 'tacit',
    },
    {
      id: 'R-C03',
      name: 'Repeat High-Risk Student',
      condition: 'Previous = HIGH/CRITICAL AND Current >= Mild in any subscale',
      action: 'Override to HIGH',
      type: 'tacit',
    },
  ];

  res.status(200).json(rules);
});

/**
 * GET /api/v1/assessments/expert-system/compare
 *
 * Compare main backend rules with expert system for same input.
 * Useful for validation and debugging.
 *
 * Query params:
 * ?rawAnswers=0,1,2,3,...
 */
router.get('/expert-system/compare', (req: Request, res: Response): void => {
  try {
    const answersParam = req.query.rawAnswers as string;

    if (!answersParam) {
      res.status(400).json({
        error: 'Missing query param: ?rawAnswers=0,1,2,3,...',
      });
      return;
    }

    const rawAnswers = answersParam.split(',').map((a) => parseInt(a, 10));

    if (rawAnswers.length !== 21 || rawAnswers.some((a) => isNaN(a) || a < 0 || a > 3)) {
      res.status(400).json({
        error: 'Invalid rawAnswers: must be 21 comma-separated integers (0-3)',
      });
      return;
    }

    // Calculate DASS-21 scores
    const DEPRESSION_ITEMS = [3, 5, 10, 13, 16, 17, 21];
    const ANXIETY_ITEMS = [2, 4, 7, 9, 15, 19, 20];
    const STRESS_ITEMS = [1, 6, 8, 11, 12, 14, 18];

    const rawDep = DEPRESSION_ITEMS.reduce((sum, itemNum) => sum + rawAnswers[itemNum - 1], 0);
    const rawAnx = ANXIETY_ITEMS.reduce((sum, itemNum) => sum + rawAnswers[itemNum - 1], 0);
    const rawStr = STRESS_ITEMS.reduce((sum, itemNum) => sum + rawAnswers[itemNum - 1], 0);

    const depression = rawDep * 2;
    const anxiety = rawAnx * 2;
    const stress = rawStr * 2;

    // Evaluate using expert system
    const expertResult = evaluateExpertSystem(depression, anxiety, stress);

    res.status(200).json({
      input: { rawAnswers, depression, anxiety, stress },
      expertSystem: expertResult,
      note: 'To compare with backend, submit same rawAnswers to /api/v1/assessments',
    });
  } catch (error) {
    console.error('Comparison error:', error);
    res.status(500).json({
      error: 'Comparison failed',
      details: error instanceof Error ? error.message : String(error),
    });
  }
});

export default router;
