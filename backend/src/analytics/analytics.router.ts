import { Router, Request, Response } from 'express';
import { requireAuth } from '../auth/jwt.middleware';
import { getCampusAnalytics } from './analytics.service';

const router = Router();

/**
 * GET /analytics/campus
 * Get anonymised campus-wide analytics
 * Requires: counsellor or admin role
 * Returns: aggregates only, NO PII
 */
router.get(
  '/campus',
  requireAuth(['counsellor', 'admin']),
  async (req: Request, res: Response) => {
    try {
      const analytics = await getCampusAnalytics();
      return res.status(200).json(analytics);
    } catch (err) {
      console.error('Analytics fetch error:', err);
      return res.status(500).json({ error: 'Internal server error' });
    }
  },
);

export default router;
