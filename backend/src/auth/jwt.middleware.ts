import { Request, Response, NextFunction } from 'express';
import { verifyToken } from './auth.service';
import { UnauthorizedError, ForbiddenError } from '../shared/errors';
import { UserRole, AuthenticatedRequest } from '../shared/types';

declare global {
  namespace Express {
    interface Request {
      user?: { userId: string; role: UserRole };
    }
  }
}

/**
 * Middleware: require authentication via Bearer token.
 * Optionally enforce role restrictions.
 */
export function requireAuth(allowedRoles?: UserRole[]) {
  return (req: Request, res: Response, next: NextFunction) => {
    try {
      const authHeader = req.headers.authorization;

      if (!authHeader || !authHeader.startsWith('Bearer ')) {
        throw new UnauthorizedError('Missing or invalid authorization header');
      }

      const token = authHeader.slice(7);
      const payload = verifyToken(token);

      // Enforce role restriction if provided
      if (allowedRoles && !allowedRoles.includes(payload.role)) {
        throw new ForbiddenError(`This resource requires one of these roles: ${allowedRoles.join(', ')}`);
      }

      // Attach user to request
      (req as AuthenticatedRequest).user = {
        userId: payload.userId,
        role: payload.role,
      };

      return next();
    } catch (err) {
      if (err instanceof UnauthorizedError || err instanceof ForbiddenError) {
        return res.status(err.statusCode).json({ error: err.message });
      }
      return res.status(401).json({ error: 'Unauthorized' });
    }
  };
}
