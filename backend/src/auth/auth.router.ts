import { Router, Request, Response } from 'express';
import { body, validationResult } from 'express-validator';
import { login } from './auth.service';
import { ApiError } from '../shared/errors';

const router = Router();

/**
 * POST /auth/login
 * Body: { role, identifier, password }
 * Returns: { token, userId, role, name }
 */
router.post(
  '/login',
  [
    body('role')
      .isIn(['student', 'counsellor', 'admin'])
      .withMessage('Role must be student, counsellor, or admin'),
    body('identifier').notEmpty().withMessage('Identifier (matricNumber or staffId) is required'),
    body('password').notEmpty().withMessage('Password is required'),
  ],
  async (req: Request, res: Response) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    try {
      const result = await login(req.body);
      return res.status(200).json(result);
    } catch (err) {
      if (err instanceof ApiError) {
        return res.status(err.statusCode).json({ error: err.message });
      }
      console.error('Login error:', err);
      return res.status(500).json({ error: 'Internal server error' });
    }
  },
);

export default router;
