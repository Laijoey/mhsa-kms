import dotenv from 'dotenv';
dotenv.config();

import * as admin from 'firebase-admin';
import { getFirestore, initializeFirestore } from './src/shared/firestore';
import { hashPassword } from './src/auth/auth.service';
import { computeScores } from './src/assessments/scoring';
import fs from 'fs';
import path from 'path';

const knowledgeBase = JSON.parse(
  fs.readFileSync(path.join(__dirname, 'knowledge_base.json'), 'utf-8'),
);

async function seed() {
  console.log('Starting seed...');

  const db = initializeFirestore();

  try {
    // Clear existing data (optional, for dev only)
    console.log('Clearing existing collections...');
    const collections = ['users', 'assessments', 'rules', 'resources'];
    for (const collName of collections) {
      const snap = await db.collection(collName).get();
      const batch = db.batch();
      snap.docs.forEach((doc) => batch.delete(doc.ref));
      if (snap.docs.length > 0) {
        await batch.commit();
        console.log(`Cleared ${snap.docs.length} documents from ${collName}`);
      }
    }

    // 1. Create demo users
    console.log('\nCreating demo users...');

    const studentPasswordHash = await hashPassword('demo1234');
    const counsellorPasswordHash = await hashPassword('demo1234');
    const adminPasswordHash = await hashPassword('demo1234');

    const users = [
      {
        uid: 'student001',
        role: 'student',
        name: 'Aiman Tan',
        matricNumber: 'S001',
        passwordHash: studentPasswordHash,
        createdAt: admin.firestore.Timestamp.now(),
      },
      {
        uid: 'counsellor001',
        role: 'counsellor',
        name: 'Dr. Evelyn Wong',
        staffId: 'C001',
        passwordHash: counsellorPasswordHash,
        createdAt: admin.firestore.Timestamp.now(),
      },
      {
        uid: 'admin001',
        role: 'admin',
        name: 'Admin User',
        staffId: 'A001',
        passwordHash: adminPasswordHash,
        createdAt: admin.firestore.Timestamp.now(),
      },
    ];

    for (const user of users) {
      await db.collection('users').doc(user.uid).set(user);
      console.log(`Created user: ${user.name} (${user.role})`);
    }

    // 2. Seed rules
    console.log('\nSeeding rules...');

    for (const rule of knowledgeBase.rules) {
      await db.collection('rules').doc(rule.id).set(rule);
      console.log(`Seeded rule: ${rule.id}`);
    }

    // 3. Seed resources
    console.log('\nSeeding resources...');

    for (const resource of knowledgeBase.resources) {
      await db.collection('resources').doc(resource.id).set(resource);
      console.log(`Seeded resource: ${resource.id}`);
    }

    // 4. Seed historical assessments for the demo student
    console.log('\nSeeding historical assessments...');

    const assessments = generateSampleAssessments();

    for (let i = 0; i < assessments.length; i++) {
      const assessment = assessments[i];
      await db.collection('assessments').add(assessment);
      console.log(
        `Added assessment ${i + 1}/${assessments.length}: ${assessment.firedRuleId} (${assessment.riskLevel})`,
      );
    }

    console.log('\n✓ Seed completed successfully!');
    console.log('\nDemo credentials:');
    console.log('  Student: S001 / demo1234');
    console.log('  Counsellor: C001 / demo1234');
    console.log('  Admin: A001 / demo1234');
  } catch (err) {
    console.error('Seed failed:', err);
    process.exit(1);
  }
}

/**
 * Generate 20 sample assessments spanning 14 weeks with various risk levels.
 */
function generateSampleAssessments() {
  const assessments = [];
  const now = new Date();
  const baseRules = knowledgeBase.rules;

  // Patterns for different risk levels
  const patterns = [
    // Normal (R-007)
    { answers: generateAnswers([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]), rule: 'R-007' },
    // Low (R-006 or R-000)
    { answers: generateAnswers([1, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]), rule: 'R-006' },
    // Moderate (R-004 or R-005)
    { answers: generateAnswers([0, 0, 2, 0, 2, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 2]), rule: 'R-004' },
    // High (R-002)
    { answers: generateAnswers([0, 0, 2, 0, 2, 0, 0, 0, 2, 0, 0, 0, 2, 1, 2, 1, 2, 0, 2, 1, 2]), rule: 'R-002' },
    // Critical (R-001)
    { answers: generateAnswers([3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3]), rule: 'R-001' },
  ];

  // Generate 20 assessments across 14 weeks
  for (let i = 0; i < 20; i++) {
    const weeksAgo = Math.floor((i / 20) * 14);
    const date = new Date(now);
    date.setDate(date.getDate() - weeksAgo * 7 - Math.random() * 7);

    const pattern = patterns[i % patterns.length];
    const scores = computeScores(pattern.answers);

    // Map rule ID to recommendation
    const ruleDoc = baseRules.find((r: any) => r.id === pattern.rule);
    let recommendation = {
      title: `Generated Rule ${pattern.rule}`,
      body: `Assessment generated for testing purposes with ${pattern.rule}`,
      actions: [],
    };

    if (ruleDoc) {
      recommendation = {
        title: ruleDoc.title,
        body: ruleDoc.description || '',
        actions: ruleDoc.actions,
      };
    }

    // Map rule ID to risk level
    const riskLevelMap: Record<string, string> = {
      'R-001': 'CRITICAL',
      'R-002': 'HIGH',
      'R-003': 'HIGH',
      'R-004': 'MODERATE',
      'R-005': 'MODERATE',
      'R-006': 'LOW',
      'R-007': 'NORMAL',
      'R-000': 'LOW',
    };

    const assessment = {
      userId: 'student001',
      takenAt: admin.firestore.Timestamp.fromDate(date),
      rawAnswers: pattern.answers,
      rawScores: scores.rawScores,
      normalisedScores: scores.normalisedScores,
      severities: scores.severities,
      firedRuleId: pattern.rule,
      riskLevel: riskLevelMap[pattern.rule] || 'LOW',
      recommendation,
      appliedTacitRules: [],
    };

    assessments.push(assessment);
  }

  // Sort by date ascending for natural progression
  assessments.sort((a, b) => a.takenAt.seconds - b.takenAt.seconds);

  return assessments;
}

/**
 * Generate answer array from a pattern.
 * If pattern length < 21, pad with 0s.
 */
function generateAnswers(pattern: number[]): number[] {
  const answers = [...pattern];
  while (answers.length < 21) {
    answers.push(0);
  }
  return answers.slice(0, 21);
}

// Run the seed
seed().catch(console.error);
