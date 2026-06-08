import express, { Express, Request, Response, NextFunction } from 'express';
import helmet from 'helmet';
import cors from 'cors';
import { initializeFirestore } from './shared/firestore';
import authRouter from './auth/auth.router';
import assessmentsRouter from './assessments/assessments.router';
import analyticsRouter from './analytics/analytics.router';
import resourcesRouter from './resources/resources.router';
import rulesRouter from './rules/rules.router';
import expertSystemRouter from './expert-system/expertSystem.router';
import { ApiError } from './shared/errors';

export function createApp(): Express {
  const app = express();

  // Initialize Firestore
  initializeFirestore();

  // Security middleware
  app.use(helmet());

  // CORS middleware
  app.use(
    cors({
      origin: (origin, callback) => {
        if (!origin || origin.startsWith('http://localhost:') || origin.startsWith('http://127.0.0.1:')) {
          callback(null, true);
        } else {
          callback(new Error('Not allowed by CORS'));
        }
      },
      credentials: true,
    }),
  );

  // Body parsing
  app.use(express.json());
  app.use(express.urlencoded({ extended: true }));

  // Request logging
  app.use((req: Request, res: Response, next: NextFunction) => {
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.path}`);
    next();
  });

  // Health check
  app.get('/health', (req: Request, res: Response) => {
    res.status(200).json({ status: 'ok' });
  });

  // API routes
  const apiPrefix = '/api/v1';

  app.use(`${apiPrefix}/auth`, authRouter);
  app.use(`${apiPrefix}/assessments`, assessmentsRouter);
  app.use(`${apiPrefix}/analytics`, analyticsRouter);
  app.use(`${apiPrefix}/resources`, resourcesRouter);
  app.use(`${apiPrefix}/rules`, rulesRouter);
  app.use(`${apiPrefix}/assessments`, expertSystemRouter); // Expert system endpoints

  // 404 handler
  app.use((req: Request, res: Response) => {
    res.status(404).json({ error: 'Not found' });
  });

  // Error handler (must be last)
  app.use((err: Error | ApiError, req: Request, res: Response, next: NextFunction) => {
    console.error('Error:', err);

    if (err instanceof ApiError) {
      return res.status(err.statusCode).json({ error: err.message });
    }

    return res.status(500).json({ error: 'Internal server error' });
  });

  return app;
}
