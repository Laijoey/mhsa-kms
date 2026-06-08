import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { getFirestore } from '../shared/firestore';
import { UnauthorizedError } from '../shared/errors';
import { LoginRequest, LoginResponse, JwtPayload } from '../shared/types';

const JWT_SECRET = process.env.JWT_SECRET || 'your_jwt_secret_key_here';
const JWT_EXPIRY = '8h';

export async function login(req: LoginRequest): Promise<LoginResponse> {
  const { role, identifier, password } = req;

  const db = getFirestore();

  // Query for user: role + (matricNumber OR staffId)
  let query = db.collection('users').where('role', '==', role);

  if (role === 'student') {
    query = query.where('matricNumber', '==', identifier);
  } else {
    query = query.where('staffId', '==', identifier);
  }

  const snapshot = await query.get();

  if (snapshot.empty) {
    // User not found — return generic error to prevent enumeration
    throw new UnauthorizedError('Invalid credentials');
  }

  const userDoc = snapshot.docs[0];
  const userData = userDoc.data();

  // Verify password
  const passwordMatch = await bcrypt.compare(password, userData.passwordHash);
  if (!passwordMatch) {
    throw new UnauthorizedError('Invalid credentials');
  }

  // Sign JWT
  const payload: JwtPayload = {
    userId: userDoc.id,
    role: userData.role,
  };

  const token = jwt.sign(payload, JWT_SECRET, { expiresIn: JWT_EXPIRY });

  return {
    token,
    userId: userDoc.id,
    role: userData.role,
    name: userData.name,
  };
}

export function verifyToken(token: string): JwtPayload {
  try {
    return jwt.verify(token, JWT_SECRET) as JwtPayload;
  } catch (err) {
    throw new UnauthorizedError('Invalid or expired token');
  }
}

export async function hashPassword(password: string): Promise<string> {
  return bcrypt.hash(password, 12);
}
