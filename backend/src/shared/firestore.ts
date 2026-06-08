import * as admin from 'firebase-admin';
import * as fs from 'fs';
import * as path from 'path';

let db: FirebaseFirestore.Firestore | null = null;

export function initializeFirestore(): FirebaseFirestore.Firestore {
  if (db) return db;

  // Initialize Firebase Admin SDK with service account
  if (!admin.apps.length) {
    const keyPath = path.join(__dirname, '../../firebase-key.json');
    const serviceAccount = JSON.parse(fs.readFileSync(keyPath, 'utf8'));

    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      projectId: serviceAccount.project_id,
    });
  }

  db = admin.firestore();
  return db;
}

export function getFirestore(): FirebaseFirestore.Firestore {
  if (!db) {
    return initializeFirestore();
  }
  return db;
}

export function getAuth(): admin.auth.Auth {
  if (!admin.apps.length) {
    const keyPath = path.join(__dirname, '../../firebase-key.json');
    const serviceAccount = JSON.parse(fs.readFileSync(keyPath, 'utf8'));

    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      projectId: serviceAccount.project_id,
    });
  }
  return admin.auth();
}
