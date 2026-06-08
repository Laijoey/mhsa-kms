import { Router, Request, Response } from 'express';
import { body, validationResult } from 'express-validator';
import { getFirestore } from '../shared/firestore';
import { requireAuth } from '../auth/jwt.middleware';
import { ApiError, NotFoundError } from '../shared/errors';

const router = Router();

/**
 * GET /resources
 * Get all knowledge base resources
 * Requires: authentication
 */
router.get('/', requireAuth(), async (req: Request, res: Response) => {
  try {
    const db = getFirestore();
    const snapshot = await db.collection('resources').orderBy('id').get();

    const resources = snapshot.docs.map((doc) => {
      const data = doc.data();
      return { ...data, id: doc.id };
    });

    return res.status(200).json(resources);
  } catch (err) {
    console.error('Resources fetch error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
});

/**
 * POST /resources
 * Create a new knowledge base resource
 * Requires: admin role
 */
router.post(
  '/',
  requireAuth(['admin']),
  [
    body('type').isIn(['Explicit', 'Tacit']).withMessage('Type must be Explicit or Tacit'),
    body('title').notEmpty().withMessage('Title is required'),
    body('category').notEmpty().withMessage('Category is required'),
    body('author').notEmpty().withMessage('Author is required'),
    body('date').isISO8601().withMessage('Date must be ISO 8601 format'),
    body('format').notEmpty().withMessage('Format is required'),
    body('description').notEmpty().withMessage('Description is required'),
  ],
  async (req: Request, res: Response) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    try {
      const db = getFirestore();

      // Generate ID (could be UUID or simple counter)
      const maxIdSnap = await db.collection('resources').orderBy('id', 'desc').limit(1).get();
      let newId = 'KB-001';
      if (!maxIdSnap.empty) {
        const lastId = maxIdSnap.docs[0].data().id;
        const match = lastId.match(/KB-(\d+)/);
        if (match) {
          const num = parseInt(match[1]) + 1;
          newId = `KB-${String(num).padStart(3, '0')}`;
        }
      }

      const resourceData = {
        ...req.body,
        id: newId,
      };

      await db.collection('resources').doc(newId).set(resourceData);

      return res.status(201).json(resourceData);
    } catch (err) {
      console.error('Resource creation error:', err);
      return res.status(500).json({ error: 'Internal server error' });
    }
  },
);

/**
 * PUT /resources/:id
 * Update a knowledge base resource
 * Requires: admin role
 */
router.put(
  '/:id',
  requireAuth(['admin']),
  async (req: Request, res: Response) => {
    try {
      const db = getFirestore();
      const { id } = req.params;

      const docRef = db.collection('resources').doc(id);
      const docSnap = await docRef.get();

      if (!docSnap.exists) {
        throw new NotFoundError('Resource not found');
      }

      const allowedFields = ['type', 'title', 'category', 'author', 'date', 'format', 'description'];
      const updateData: Record<string, any> = {};

      allowedFields.forEach((field) => {
        if (req.body[field] !== undefined) {
          updateData[field] = req.body[field];
        }
      });

      await docRef.update(updateData);

      const updated = (await docRef.get()).data();
      return res.status(200).json(updated);
    } catch (err) {
      if (err instanceof ApiError) {
        return res.status(err.statusCode).json({ error: err.message });
      }
      console.error('Resource update error:', err);
      return res.status(500).json({ error: 'Internal server error' });
    }
  },
);

/**
 * DELETE /resources/:id
 * Delete a knowledge base resource
 * Requires: admin role
 */
router.delete('/:id', requireAuth(['admin']), async (req: Request, res: Response) => {
  try {
    const db = getFirestore();
    const { id } = req.params;

    const docRef = db.collection('resources').doc(id);
    const docSnap = await docRef.get();

    if (!docSnap.exists) {
      throw new NotFoundError('Resource not found');
    }

    await docRef.delete();

    return res.status(204).send();
  } catch (err) {
    if (err instanceof ApiError) {
      return res.status(err.statusCode).json({ error: err.message });
    }
    console.error('Resource deletion error:', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;
