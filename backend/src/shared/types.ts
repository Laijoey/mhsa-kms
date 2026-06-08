// Severity levels (DASS-21 clinical classification)
export type Severity = 'Normal' | 'Mild' | 'Moderate' | 'Severe' | 'Extremely Severe';

// Risk levels assigned by the rule engine
export type RiskLevel = 'NORMAL' | 'LOW' | 'MODERATE' | 'HIGH' | 'CRITICAL';

// User roles
export type UserRole = 'student' | 'counsellor' | 'admin';

// Firestore document: users collection
export interface UserDoc {
  uid: string;                    // Firestore doc ID
  role: UserRole;
  name: string;
  matricNumber?: string;          // students only
  staffId?: string;               // staff only
  passwordHash: string;           // bcrypt hash
  createdAt: FirebaseFirestore.Timestamp;
}

// Firestore document: assessments collection
export interface AssessmentDoc {
  id: string;                     // Firestore doc ID
  userId: string;                 // ref to users.uid
  takenAt: FirebaseFirestore.Timestamp;
  rawAnswers: number[];           // length 21, values 0-3
  rawScores: {
    dep: number;
    anx: number;
    str: number;
  };
  normalisedScores: {
    dep: number;                  // 0-42
    anx: number;
    str: number;
  };
  severities: {
    dep: Severity;
    anx: Severity;
    str: Severity;
  };
  firedRuleId: string;            // e.g. "R-004", "R-000"
  riskLevel: RiskLevel;
  recommendation: {
    title: string;
    body: string;
    actions: string[];
  };
  appliedTacitRules: string[];    // e.g. ["R-C01"]
}

// Firestore document: rules collection
export interface RuleDoc {
  id: string;                     // e.g. "R-001"
  type: 'Escalation' | 'Contextual' | 'Core';
  title: string;
  description: string;
  formula: string;                // human-readable condition
  actions: string[];
  isActive: boolean;
  parameters: Array<{
    key: string;                  // e.g. "D_LIMIT"
    label: string;
    value: number;
    min: number;
    max: number;
  }>;
}

// Firestore document: resources collection
export interface ResourceDoc {
  id: string;                     // e.g. "KB-001"
  type: 'Explicit' | 'Tacit';
  title: string;
  category: string;
  author: string;
  date: string;                   // ISO date string
  format: string;
  description: string;
}

// API request/response types
export interface LoginRequest {
  role: UserRole;
  identifier: string;             // matricNumber or staffId
  password: string;
}

export interface LoginResponse {
  token: string;                  // JWT
  userId: string;
  role: UserRole;
  name: string;
}

// Returned from scoring module
export interface ScoreResult {
  rawScores: {
    dep: number;
    anx: number;
    str: number;
  };
  normalisedScores: {
    dep: number;
    anx: number;
    str: number;
  };
  severities: {
    dep: Severity;
    anx: Severity;
    str: Severity;
  };
}

// Rule engine input/output
export interface RuleEngineInput {
  severities: ScoreResult['severities'];
  normalisedScores: ScoreResult['normalisedScores'];
  userId: string;
  previousAssessments: AssessmentDoc[];
  ruleConfigs: RuleDoc[];
  currentDate: Date;
}

export interface RuleEngineResult {
  firedRuleId: string;
  riskLevel: RiskLevel;
  recommendation: {
    title: string;
    body: string;
    actions: string[];
  };
  appliedTacitRules: string[];
}

// JWT payload
export interface JwtPayload {
  userId: string;
  role: UserRole;
  iat?: number;
  exp?: number;
}

// Express request extension for authenticated requests
export interface AuthenticatedRequest {
  user: {
    userId: string;
    role: UserRole;
  };
}
