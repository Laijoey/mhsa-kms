import { Router, Request, Response } from 'express';
import { body, validationResult } from 'express-validator';
import { getFirestore } from '../shared/firestore';
import { requireAuth } from '../auth/jwt.middleware';
import { ApiError, NotFoundError } from '../shared/errors';

const router = Router();

/**
 * GET /rules
 * Get all rule configs
 * Requires: admin role
 */
router.get('/', requireAuth(['admin']), async (req: Request, res: Response) => {
  try {
    const db = getFirestore();
    const snapshot = await db.collection('rules').orderBy('id').get();

    const rules = snapshot.docs.map((doc) => {
      const data = doc.data();
      return { ...data, id: doc.id };
    });

    return res.status(200).json(rules);
  } catch (err) {
    console.error('Rules fetch error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
});

/**
 * PUT /rules/:id
 * Update a rule config (isActive, parameters)
 * Requires: admin role
 */
router.put(
  '/:id',
  requireAuth(['admin']),
  [body('isActive').optional().isBoolean().withMessage('isActive must be boolean')],
  async (req: Request, res: Response) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    try {
      const db = getFirestore();
      const { id } = req.params;

      const docRef = db.collection('rules').doc(id);
      const docSnap = await docRef.get();

      if (!docSnap.exists) {
        throw new NotFoundError('Rule not found');
      }

      const updateData: Record<string, any> = {};

      if (req.body.isActive !== undefined) {
        updateData.isActive = req.body.isActive;
      }

      if (req.body.parameters !== undefined) {
        updateData.parameters = req.body.parameters;
      }

      if (Object.keys(updateData).length === 0) {
        return res.status(400).json({ error: 'No valid fields to update' });
      }

      await docRef.update(updateData);

      const updated = (await docRef.get()).data();
      return res.status(200).json(updated);
    } catch (err) {
      if (err instanceof ApiError) {
        return res.status(err.statusCode).json({ error: err.message });
      }
      console.error('Rule update error:', err);
      return res.status(500).json({ error: 'Internal server error' });
    }
  },
);

export default router;
