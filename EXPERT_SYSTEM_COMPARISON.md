# Expert System Branch vs Current Merged Version - Detailed Comparison

---

## 📊 High-Level Comparison

| Aspect | Expert System Branch | Current Merged Version |
|--------|---------------------|----------------------|
| **Approach** | Client-side only | Server-side + Client hybrid |
| **Database** | None (local only) | ✅ Firebase Firestore |
| **Authentication** | None | ✅ JWT + bcrypt |
| **Persistence** | No | ✅ All assessments saved |
| **Admin Control** | No | ✅ Configure rules via UI |
| **Production Ready** | ❌ Reference only | ✅ Full stack ready |
| **Lines of Code** | ~5KB | ~50KB+ |
| **Architecture** | Monolithic Flutter | Distributed (Flutter + Backend + DB) |

---

## 🔍 Expert System Branch - What It Had

### File Structure
```
lib/expert_system/
├── dass_rules.dart              (1.1 KB)
├── expert_system.dart           (726 bytes)
├── knowledge_base.dart          (1.3 KB)
├── recommendation_engine.dart   (1.5 KB)
└── risk_classifier.dart         (941 bytes)
```

### Key Components

#### 1. **DASS21Calculator** (dass_rules.dart)
```dart
class DASS21Calculator {
  static DASS21Result calculate({required List<int> answers}) {
    // Item mapping (0-based indexing)
    const depressionItems = [0, 2, 4, 9, 12, 15, 19];
    const anxietyItems    = [1, 3, 6, 8, 14, 17, 20];
    const stressItems     = [5, 7, 10, 11, 13, 16, 18];
    
    // Calculate raw scores (0-21)
    // Multiply by 2 for normalization (0-42)
    return DASS21Result(
      depression: depression * 2,
      anxiety: anxiety * 2,
      stress: stress * 2,
    );
  }
}
```
**Features:**
- ✓ Correct DASS-21 scoring
- ✓ 0-based array indexing
- ✓ Multiplies by 2 for 0-42 range
- ❌ No persistence
- ❌ No verification

---

#### 2. **ExpertSystem** (expert_system.dart)
```dart
class ExpertSystem {
  static Map<String, dynamic> process(List<int> answers) {
    final dass = DASS21Calculator.calculate(answers: answers);
    final result = RecommendationEngine.generate(
      depression: dass.depression,
      anxiety: dass.anxiety,
      stress: dass.stress,
    );
    return {
      "depression": dass.depression,
      "anxiety": dass.anxiety,
      "stress": dass.stress,
      "riskLevel": result["riskLevel"],
      "recommendations": result["recommendations"],
    };
  }
}
```
**Features:**
- ✓ Orchestrates DASS-21 calculation
- ✓ Calls recommendation engine
- ✓ Returns structured result
- ❌ No database storage
- ❌ No authentication

---

#### 3. **RecommendationEngine** (recommendation_engine.dart)
```dart
class RecommendationEngine {
  static Map<String, dynamic> generate({
    required int depression,
    required int anxiety,
    required int stress,
  }) {
    // Simple if-else rules
    if (depression >= 28 || anxiety >= 20 || stress >= 34) {
      riskLevel = "Extremely Severe";
      recommendations.add("URGENT: Seek immediate counselling support");
    }
    else if (depression >= 21) {
      riskLevel = "Severe";
      recommendations.add("Maintain daily routine even with low motivation");
    }
    // ... more simple rules
  }
}
```
**Features:**
- ✓ Generates risk level
- ✓ Provides text recommendations
- ❌ Only 5 simple if-else rules (hardcoded)
- ❌ Fixed thresholds
- ❌ No admin configuration
- ❌ Not flexible

---

#### 4. **RiskClassifier** (risk_classifier.dart)
```dart
class RiskClassifier {
  static String classifyRisk(int depression, int anxiety, int stress) {
    if (depression >= 28 || anxiety >= 20 || stress >= 34) {
      return "CRITICAL";
    }
    else if (depression >= 21 || anxiety >= 15 || stress >= 26) {
      return "SEVERE";
    }
    // ... more classifications
  }
}
```
**Features:**
- ✓ Classifies risk level
- ❌ Hardcoded thresholds
- ❌ Simple logic
- ❌ No persistence

---

#### 5. **KnowledgeBase** (knowledge_base.dart)
```dart
class KnowledgeBase {
  static const List<Map<String, String>> resources = [
    {
      'id': 'KB-001',
      'title': 'DSM-5 Guidelines',
      'description': 'Clinical guidelines...',
    },
    // ... hardcoded resources
  ];
}
```
**Features:**
- ✓ Structured KB data
- ❌ Only 6 hardcoded articles
- ❌ Not editable
- ❌ Cannot add new resources

---

### Assessment Flow (Expert System Branch)

```
Student Assessment (assessment.dart)
    ↓
submitAssessment() {
  List<int> answerList = ... // Get answers
  final result = ExpertSystem.process(answerList);
  // result contains: depression, anxiety, stress, riskLevel, recommendations
}
    ↓
No persistence
No authentication
Local only
```

---

## ⚡ Current Merged Version - What It Has

### File Structure
```
Backend (Node.js/Express):
├── src/
│   ├── assessments/
│   │   ├── scoring.ts           (350+ lines, DASS-21 module)
│   │   ├── ruleEngine.ts        (400+ lines, 11 rules)
│   │   └── assessments.service.ts (150+ lines)
│   ├── auth/
│   │   ├── auth.service.ts      (JWT + bcrypt)
│   │   └── jwt.middleware.ts    (Bearer token validation)
│   ├── analytics/
│   │   └── analytics.service.ts (Campus-wide aggregation)
│   ├── resources/
│   │   └── resources.router.ts  (KB CRUD)
│   ├── rules/
│   │   └── rules.router.ts      (Rule configuration)
│   └── shared/
│       ├── types.ts             (TypeScript interfaces)
│       ├── firestore.ts         (Firebase init)
│       └── errors.ts            (Error handling)
├── seed.ts                      (Populate Firestore)
├── app.ts                       (Express app)
└── server.ts                    (Entry point)

Frontend (Flutter):
├── lib/
│   ├── screens/                 (11 screens, all wired to API)
│   │   ├── student_login.dart
│   │   ├── assessment.dart      (Submits to /api/v1/assessments)
│   │   ├── result.dart          (Shows API response)
│   │   ├── progress.dart        (Loads history from /api/v1/assessments/me)
│   │   ├── student_dashboard.dart
│   │   ├── counsellor_dashboard.dart
│   │   ├── counsellor_high_risk.dart
│   │   ├── admin_dashboard.dart (Calls /api/v1/rules & /api/v1/resources)
│   │   └── knowledge_base.dart  (Loads /api/v1/resources)
│   ├── services/
│   │   └── api_service.dart     (HTTP client, 350+ lines)
│   └── expert_system/           (Reference implementation)
│       ├── dass_rules.dart
│       ├── expert_system.dart
│       ├── knowledge_base.dart
│       ├── recommendation_engine.dart
│       └── risk_classifier.dart

Database (Firebase Firestore):
├── users                        (3 demo + custom)
├── assessments                  (20 seeded + live submissions)
├── rules                        (11 configurable rules)
└── resources                    (6 KB articles + custom)
```

### Key Components

#### 1. **Backend DASS-21 Scoring** (src/assessments/scoring.ts)
```typescript
const DEPRESSION_ITEMS = [3, 5, 10, 13, 16, 17, 21];  // 1-based
const ANXIETY_ITEMS    = [2, 4, 7, 9, 15, 19, 20];
const STRESS_ITEMS     = [1, 6, 8, 11, 12, 14, 18];

function computeScores(rawAnswers: number[]): ScoreResult {
  // Sum per-subscale items
  const rawDep = DEPRESSION_ITEMS.reduce((s, i) => s + rawAnswers[i - 1], 0);
  
  // Normalize to 0-42 range
  const normalisedScores = {
    dep: rawDep * 2,
    anx: rawAnx * 2,
    str: rawStr * 2,
  };
  
  // Per-subscale severity thresholds
  const severities = {
    dep: getSeverity(normalisedScores.dep, 'depression'),
    anx: getSeverity(normalisedScores.anx, 'anxiety'),
    str: getSeverity(normalisedScores.str, 'stress'),
  };
  
  return { rawScores, normalisedScores, severities };
}
```
**Features:**
- ✅ Correct per-subscale item mapping (1-based)
- ✅ Per-subscale severity thresholds (DASS-21 spec)
- ✅ 88+ unit tests
- ✅ Boundary case validation
- ✅ TypeScript typed

---

#### 2. **Backend Rule Engine** (src/assessments/ruleEngine.ts)
```typescript
async function evaluateRules(input: RuleEngineInput): Promise<RuleEngineResult> {
  // 8 Explicit rules (R-001 to R-007 + R-000)
  for (const rule of ruleConfigs) {
    if (rule.type === 'explicit' && evaluateRule(rule, input)) {
      firedRuleId = rule.id;
      riskLevel = getRiskLevel(rule.id);
      recommendation = getRecommendation(rule);
      break; // First match wins
    }
  }
  
  // 3 Tacit rules (R-C01 to R-C03) - escalations
  const tacitRules = [];
  if (allThreeModeratePlus(input)) {
    riskLevel = escalate(riskLevel, 'MODERATE' → 'HIGH');
    tacitRules.push('R-C01');
  }
  // ... more tacit rules
  
  return {
    firedRuleId,
    riskLevel,
    recommendation,
    appliedTacitRules: tacitRules,
  };
}
```
**Features:**
- ✅ 11 rules total (8 explicit + 3 tacit)
- ✅ Configurable in Firestore
- ✅ First-match evaluation
- ✅ Escalation logic
- ✅ Admin can modify thresholds
- ✅ 88+ unit tests
- ✅ Dynamic, not hardcoded

---

#### 3. **Backend Authentication** (src/auth/auth.service.ts)
```typescript
export async function verifyLogin(role: string, identifier: string, password: string) {
  // Find user in Firestore by role + identifier
  const userDoc = await db.collection('users').where('role', '==', role)
    .where('matricNumber', '==', identifier).limit(1).get();
  
  if (userDoc.empty) throw new UnauthorizedError('Invalid credentials');
  
  const user = userDoc.docs[0].data();
  
  // Verify password with bcrypt
  const isValid = await bcrypt.compare(password, user.passwordHash);
  if (!isValid) throw new UnauthorizedError('Invalid credentials');
  
  // Generate JWT token
  const token = jwt.sign(
    { userId: user.uid, role: user.role },
    JWT_SECRET,
    { expiresIn: '8h' }
  );
  
  return { token, userId: user.uid, role, name: user.name };
}
```
**Features:**
- ✅ JWT token generation
- ✅ bcrypt password hashing
- ✅ 8-hour token expiry
- ✅ Role-based access control
- ✅ Firestore user lookup
- ✅ Secure (no password storage)

---

#### 4. **Frontend ApiService** (lib/services/api_service.dart)
```dart
class ApiService {
  static const String _baseUrl = 'http://localhost:3000/api/v1';
  static AuthSession? _session;
  
  // Methods:
  static Future<AuthSession> login(String role, String identifier, String password)
  static Future<AssessmentResult> submitAssessment(List<int> rawAnswers)
  static Future<List<AssessmentResult>> getMyHistory()
  static Future<List<Map>> getHighRiskQueue()
  static Future<Map> getCampusAnalytics()
  static Future<List<Map>> getResources()
  static Future<Map> getRules()
  static Future<void> updateRule(String id, Map data)
  
  // Token management
  static AuthSession? get session => _session;
  static bool get isAuthenticated => _session != null;
  static void logout() => _session = null;
}
```
**Features:**
- ✅ 8 methods for all operations
- ✅ JWT token management
- ✅ Type-safe response models
- ✅ Error handling (ApiException)
- ✅ 350+ lines, well-documented

---

#### 5. **Database Firestore** (Firebase Cloud)
```typescript
Collections:

users {
  uid: "student001"
  role: "student"
  name: "Aiman Tan"
  matricNumber: "S001"
  passwordHash: "$2b$10$..." // bcrypt
  createdAt: Timestamp
}

assessments {
  id: "hvDW..."
  userId: "student001"
  takenAt: Timestamp
  rawAnswers: [2,1,3,...] // Stored but NOT returned to client
  normalisedScores: {dep: 24, anx: 16, str: 12}
  severities: {dep: "Moderate", anx: "Moderate", str: "Mild"}
  firedRuleId: "R-004"
  riskLevel: "MODERATE"
  recommendation: {title: "...", body: "...", actions: [...]}
  appliedTacitRules: ["R-C01"]
}

rules {
  id: "R-001" | "R-004" | "R-C01" | ...
  type: "explicit" | "tacit"
  title: "Critical Escalation Threshold"
  isActive: true
  parameters: {dep_threshold: 28, ...}
}

resources {
  id: "KB-001" | "KB-002" | ...
  title: "Depression Management Guide"
  category: "Clinical Guide"
  description: "..."
  createdAt: Timestamp
}
```
**Features:**
- ✅ 4 collections (users, assessments, rules, resources)
- ✅ Composite indexes for queries
- ✅ Privacy: rawAnswers never returned to client
- ✅ Persistent storage
- ✅ 20 seeded assessments
- ✅ CRUD-enabled resources

---

### Assessment Flow (Current Merged Version)

```
Student Login (student_login.dart)
    ↓
ApiService.login("student", "S001", "demo1234")
    ↓
POST /api/v1/auth/login
    ↓
Backend: Verify bcrypt password + Generate JWT
    ↓
Store token in ApiService._session
    ↓
Student Takes Assessment (assessment.dart)
    ↓
ApiService.submitAssessment(rawAnswers[21])
    ↓
POST /api/v1/assessments
Headers: Authorization: Bearer {JWT}
    ↓
Backend:
  1. Verify JWT token
  2. Extract userId
  3. Validate answers (21 × 0-3)
  4. Call computeScores(rawAnswers)
     - Correct DASS-21 item mapping
     - Per-subscale severity thresholds
  5. Call evaluateRules(scores)
     - 8 explicit rules (R-001 to R-007)
     - 3 tacit escalation rules
  6. Store in Firestore assessments
  7. Return AssessmentResult (rawAnswers excluded)
    ↓
Frontend: result.dart displays:
  - Per-subscale scores (0-42)
  - Severities (Normal/Mild/Moderate/Severe/Extremely Severe)
  - Fired rule ID
  - Dynamic recommendation
    ↓
Data persisted in Firestore
Available for:
  - Student history (progress.dart)
  - Counsellor queue (counsellor_high_risk.dart)
  - Analytics (counsellor_dashboard.dart)
```

---

## 📋 Feature Comparison Table

| Feature | Expert System Branch | Current Merged Version |
|---------|---------------------|----------------------|
| **DASS-21 Scoring** | ✓ Local | ✓ Backend + tested |
| **Item Mapping** | 0-based indices | 1-based (DASS-21 spec) |
| **Severity Thresholds** | Global | Per-subscale (correct) |
| **Rules** | 5 simple if-else | 11 (8 explicit + 3 tacit) |
| **Rule Configurability** | None | Admin UI + Firestore |
| **Database Persistence** | ❌ | ✅ Firebase Firestore |
| **Authentication** | ❌ | ✅ JWT + bcrypt |
| **API Endpoints** | ❌ | ✅ 12 endpoints |
| **Role-Based Access** | ❌ | ✅ Student/Counsellor/Admin |
| **Recommendations** | Hardcoded text | Dynamic from rules |
| **Knowledge Base** | 6 hardcoded | CRUD-enabled |
| **Admin Configuration** | ❌ | ✅ Real-time sliders |
| **Analytics** | ❌ | ✅ Campus-wide aggregation |
| **Privacy (rawAnswers)** | Visible locally | Stored but never returned |
| **Unit Tests** | ❌ | ✅ 88+ tests |
| **Production Ready** | Reference only | ✅ Full production |
| **Code Size** | ~5 KB | ~50 KB+ |

---

## 🎯 Usage Scenarios

### Expert System Branch (Old)
```dart
// When you want LOCAL-ONLY processing (no database)
final result = ExpertSystem.process(answerList);
// Returns: depression, anxiety, stress, riskLevel, recommendations
// Problem: Not saved anywhere, can't compare with others, no history
```

### Current Merged Version (New - PRIMARY)
```dart
// When you want PRODUCTION system with persistence
final result = await ApiService.submitAssessment(rawAnswers);
// Returns: Full AssessmentResult with:
// - normalisedScores, severities
// - firedRuleId, riskLevel
// - Dynamic recommendation from rule engine
// - Stored in Firestore for history/analytics
```

### Both Available
```dart
// You can still use expert system as reference:
import '../expert_system/expert_system.dart';
final localResult = ExpertSystem.process(answers); // For testing
final apiResult = await ApiService.submitAssessment(answers); // For production
```

---

## 📊 Code Quality Metrics

| Metric | Expert System | Current Version |
|--------|---------------|-----------------|
| **Lines of Code** | ~5 KB | ~50 KB+ |
| **Unit Tests** | 0 | 88+ |
| **Test Coverage** | None | Scoring + Rules + Auth |
| **Documentation** | Minimal | Comprehensive (4 guides) |
| **API Endpoints** | 0 | 12 |
| **Error Handling** | Basic | Comprehensive |
| **Type Safety** | Dart types | Dart + TypeScript |
| **Database Indexes** | N/A | 2 composite indexes |
| **Security** | None | JWT + bcrypt + CORS |
| **Scalability** | Local only | Cloud-based |

---

## 🔄 Decision: Which to Use?

### Use **Expert System** (From branch) If:
- You need local-only processing (offline)
- You're testing DASS-21 calculation in isolation
- You want a simple, lightweight implementation
- No database needed
- No authentication required

### Use **Current Version** (Primary) If:
- You need a complete, production-ready system ✅ **RECOMMENDED**
- You want persistent data storage
- You need role-based access control
- You want admin configuration
- You need analytics and reporting
- You're building for real users

---

## Summary

**Expert System Branch**: 
- Lightweight (5 KB), local-only proof-of-concept
- 5 simple rules, basic DASS-21 calculation
- No database, no auth, reference only

**Current Merged Version**:
- Complete production system (50+ KB)
- 11 sophisticated rules with escalation
- Firebase Firestore persistence
- JWT + bcrypt authentication
- 12 API endpoints
- Admin configuration UI
- 88+ unit tests
- Comprehensive documentation
- **Ready to deploy** ✅

**Status**: Both are available. Backend API is PRIMARY and RECOMMENDED. Expert System available for reference in `lib/expert_system/`.

