import { Router, Request, Response } from 'express';
import { body, validationResult } from 'express-validator';
import { requireAuth } from '../auth/jwt.middleware';
import { submitAssessment, getStudentHistory, getHighRiskQueue } from './assessments.service';
import { ApiError } from '../shared/errors';
import { AuthenticatedRequest } from '../shared/types';

const router = Router();

/**
 * POST /assessments
 * Submit a new DASS-21 assessment
 * Requires: student role
 * Body: { rawAnswers: number[21] }
 */
router.post(
  '/',
  requireAuth(['student']),
  [body('rawAnswers').isArray({ min: 21, max: 21 }).withMessage('rawAnswers must be array of 21 items')],
  async (req: Request, res: Response) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    try {
      const user = (req as AuthenticatedRequest).user!;
      const result = await submitAssessment(user.userId, req.body.rawAnswers);
      return res.status(201).json(result);
    } catch (err) {
      if (err instanceof ApiError) {
        return res.status(err.statusCode).json({ error: err.message });
      }
      console.error('Assessment submission error:', err);
      return res.status(500).json({ error: 'Internal server error' });
    }
  },
);

/**
 * GET /assessments/me
 * Get logged-in student's assessment history
 * Requires: student role
 */
router.get(
  '/me',
  requireAuth(['student']),
  async (req: Request, res: Response) => {
    try {
      const user = (req as AuthenticatedRequest).user!;
      const limit = Math.min(parseInt(req.query.limit as string) || 20, 100);
      const history = await getStudentHistory(user.userId, limit);
      return res.status(200).json(history);
    } catch (err) {
      console.error('History fetch error:', err);
      return res.status(500).json({ error: 'Internal server error' });
    }
  },
);

/**
 * GET /assessments/high-risk
 * Get HIGH and CRITICAL assessments (for counsellor queue)
 * Requires: counsellor or admin role
 */
router.get(
  '/high-risk',
  requireAuth(['counsellor', 'admin']),
  async (req: Request, res: Response) => {
    try {
      const limit = Math.min(parseInt(req.query.limit as string) || 50, 100);
      const queue = await getHighRiskQueue(limit);
      return res.status(200).json(queue);
    } catch (err) {
      console.error('High-risk queue fetch error:', err);
      return res.status(500).json({ error: 'Internal server error' });
    }
  },
);

export default router;
