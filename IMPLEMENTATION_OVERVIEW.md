# MHSA-KMS Implementation Overview

## Part 1: Flutter UI Changes (Before Backend Integration)

### Files Modified in `/lib/screens/`

#### 1. **student_login.dart**
**Before:** Accepted any non-empty text input, no authentication
**After:** 
- Added `ApiService.login()` call with role='student', identifier, password
- Added async/await error handling
- Added loading spinner during login
- Added error message display

---

#### 2. **staff_login.dart** (Counsellor & Admin Login)
**Before:** Role determined by which button was clicked (no backend validation)
**After:**
- Changed to accept identifier (staffId) and password
- Added `ApiService.login()` call with role parameter
- Role now comes from API response, not button state
- Added loading and error states

---

#### 3. **student_session.dart**
**Before:** Only stored session state in memory
**After:**
- Added `String token` field for JWT storage
- Added `String userId` field for API requests
- Maintains in-memory authentication state

---

#### 4. **assessment.dart**
**Before:** 
- Questions were hardcoded, no persistence
- Used `q % 3` for incorrect DASS-21 bucketing
- No backend scoring
**After:**
- Added `await ApiService.submitAssessment(rawAnswers)` call
- Passes all 21 answers as array to backend
- Receives `AssessmentResult` with scores and recommendation
- Added `_isSubmitting` state for loading spinner
- Added error handling with SnackBar

---

#### 5. **result.dart**
**Before:**
- `_getSeverity()` function with incorrect thresholds
- Hardcoded "R4" recommendation
- Hardcoded timestamp
- Displayed static text
**After:**
- Removed local scoring logic
- Displays `assessmentResult.severities` from API
- Shows dynamic `firedRuleId` (e.g., "R-001", "R-004")
- Shows dynamic recommendation from `assessmentResult.recommendation.title` and `.body`
- Displays `assessmentResult.takenAt` parsed as ISO timestamp
- Shows `assessmentResult.normalisedScores` (0-42 range) in metric cards

---

#### 6. **progress.dart**
**Before:**
- Hardcoded 3 assessment records
- Chart Y-axis divisor: `/30` (incorrect)
- No persistence
**After:**
- Loads from `await ApiService.getMyHistory()` 
- Maps `AssessmentResult[]` to local `_ProgressRecord` objects
- Fixed chart divisor to `/42` (correct for 0-42 score range)
- Shows all historical assessments dynamically
- Added loading and error states

---

#### 7. **student_dashboard.dart**
**Before:**
- Hardcoded "Latest snapshot" metrics (depression: 28, anxiety: 15, stress: 18)
- Hardcoded "Overall: Severe" badge
**After:**
- Loads latest assessment via `ApiService.getMyHistory()` in `initState()`
- Displays live `normalisedScores` from latest assessment
- Shows actual `riskLevel` (NORMAL, LOW, MODERATE, HIGH, CRITICAL)
- Falls back to zeros if no history exists

---

#### 8. **counsellor_dashboard.dart**
**Before:**
- Hardcoded KPI values (0s, hardcoded statistics)
- Hardcoded high-risk student list
- No data persistence
**After:**
- Loads analytics via `await ApiService.getCampusAnalytics()` in `initState()`
- Displays live `totalAssessed`, `averageScores`, `riskLevelCounts`
- Shows `severityDistribution` percentages as bars
- Loads high-risk queue via `ApiService.getHighRiskQueue()`
- Displays weekly trend chart from `weeklyTrend` array
- Added loading and error states

---

#### 9. **counsellor_high_risk.dart**
**Before:**
- All data hardcoded (student IDs, risk flags, timestamps)
- Hardcoded "Contacted" status
**After:**
- Loads high-risk queue from `ApiService.getHighRiskQueue()`
- Maps API response to existing UI (anonymized UUID, risk flag, timestamp, action)
- Loads campus analytics for KPI cards
- Shows actual high-risk student count and crisis alerts
- Added loading and error states

---

#### 10. **admin_dashboard.dart** - Rules Tab
**Before:**
- Rule sliders only updated local state
- "Save configuration" button showed SnackBar (no persistence)
**After:**
- Loads rules from `ApiService.getRules()` on startup
- Slider changes update local state
- "Save configuration" calls `ApiService.updateRule(ruleId, data)`
- Shows save success/error feedback

---

#### 11. **admin_dashboard.dart** - Knowledge Base Tab
**Before:**
- Hardcoded 4 KB resources
- Upload dialog showed SnackBar only
**After:**
- Loads resources from `ApiService.getResources()`
- Upload dialog calls `ApiService.createResource()`
- Delete calls `ApiService.deleteResource()`
- Shows persistence feedback

---

#### 12. **knowledge_base.dart**
**Before:**
- Hardcoded 4 resources in list
**After:**
- Loads from `ApiService.getResources()`
- Maps API response to display format
- Shows all KB articles dynamically
- Added loading and error states

---

### New Service Layer: `/lib/services/api_service.dart`

**Created:** Complete HTTP client (350+ lines)

**Key Features:**
- `AuthSession` class: stores token, userId, role, name
- `AssessmentResult` class: complete assessment with scores, severities, rule, recommendation
- `ProgressEntry`, `HighRiskEntry`, `CampusAnalytics`, `KbResource`, `RuleConfig` models
- `ApiService` static class with methods:
  - `login()`, `logout()`, `submitAssessment()`, `getMyHistory()`, `getHighRiskQueue()`
  - `getCampusAnalytics()`, `getResources()`, `getRules()`, `updateRule()`
  - JWT token management (in-memory)
  - Bearer token injection in all requests
  - `ApiException` error handling

---

## Part 2: System Architecture & Data Flow

### High-Level Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                      FLUTTER WEB APP (Client)                   │
│                     (lib/screens/*.dart)                        │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           │ HTTP Requests (GET, POST, PUT, DELETE)
                           │ Bearer JWT Token in Authorization Header
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                    NODE.JS/EXPRESS BACKEND                      │
│                  (backend/src/*/router.ts)                      │
│                                                                 │
│  ├─ /api/v1/auth/login          (POST) → Auth Service         │
│  ├─ /api/v1/assessments         (POST) → Scoring + Rules      │
│  ├─ /api/v1/assessments/me      (GET)  → History             │
│  ├─ /api/v1/assessments/high-risk (GET) → Queue              │
│  ├─ /api/v1/analytics/campus    (GET)  → Analytics           │
│  ├─ /api/v1/resources/*         (CRUD) → KB Management       │
│  └─ /api/v1/rules/*             (CRUD) → Rule Config         │
│                                                                 │
│  Core Services:                                                 │
│  ├─ Auth Service (JWT + bcrypt)                               │
│  ├─ Scoring Service (DASS-21 algorithm)                       │
│  ├─ Rule Engine (8 explicit + 3 tacit rules)                  │
│  ├─ Analytics Service (campus-wide aggregates)                │
│  └─ Resource Service (KB CRUD)                                │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           │ Admin SDK Calls
                           │ (read/write/query)
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                  FIREBASE FIRESTORE (Database)                  │
│                                                                 │
│  Collections:                                                   │
│  ├─ users (uid, role, name, passwordHash, ...)               │
│  ├─ assessments (userId, rawAnswers, scores, ...)            │
│  ├─ rules (R-001 to R-007, R-000, R-C01/C02/C03)             │
│  └─ resources (KB-001 to KB-006)                             │
└─────────────────────────────────────────────────────────────────┘
```

---

### Detailed Data Flow by User Role

#### **Student Flow**

```
1. LOGIN
   ├─ Flutter: student_login.dart
   │  └─ ApiService.login(role="student", identifier="S001", password="demo1234")
   │     └─ POST /api/v1/auth/login
   │        └─ Backend: Query users collection, verify bcrypt hash
   │           └─ Return JWT token + userId
   │        └─ Flutter stores token in memory
   │
2. TAKE ASSESSMENT
   ├─ Flutter: assessment.dart
   │  └─ User answers 21 DASS-21 questions (0-3 scale)
   │  └─ ApiService.submitAssessment(rawAnswers[21])
   │     └─ POST /api/v1/assessments
   │        └─ Backend: Scoring Service
   │           ├─ computeScores(rawAnswers) → {normalisedScores, severities}
   │           ├─ evaluateRules(scores) → {firedRuleId, riskLevel, recommendation}
   │           ├─ Store in assessments collection
   │           └─ Return AssessmentResult
   │        └─ Flutter: result.dart displays scores & recommendation
   │
3. VIEW HISTORY
   ├─ Flutter: progress.dart
   │  └─ ApiService.getMyHistory()
   │     └─ GET /api/v1/assessments/me
   │        └─ Backend: Query assessments by userId, orderBy takenAt desc
   │           └─ Return AssessmentResult[] (excluding rawAnswers for privacy)
   │        └─ Flutter: Display assessment history + chart
```

---

#### **Counsellor Flow**

```
1. LOGIN
   ├─ Flutter: staff_login.dart
   │  └─ ApiService.login(role="counsellor", identifier="C001", password="demo1234")
   │     └─ POST /api/v1/auth/login
   │        └─ Backend: Query users by staffId, verify bcrypt
   │           └─ Return token + role="counsellor"
   │
2. VIEW DASHBOARD
   ├─ Flutter: counsellor_dashboard.dart
   │  ├─ ApiService.getCampusAnalytics()
   │  │  └─ GET /api/v1/analytics/campus
   │  │     └─ Backend: Query ALL assessments (anonymized)
   │  │        ├─ Count unique students → totalAssessed
   │  │        ├─ Calculate averages → averageScores
   │  │        ├─ Count risk levels → riskLevelCounts
   │  │        ├─ Calculate percentages → severityDistribution
   │  │        └─ Return CampusAnalytics
   │  │
   │  └─ ApiService.getHighRiskQueue()
   │     └─ GET /api/v1/assessments/high-risk
   │        └─ Backend: Query assessments WHERE riskLevel IN ['HIGH','CRITICAL']
   │           └─ Return HighRiskEntry[] with anonymized UUIDs
   │
3. REVIEW HIGH-RISK STUDENTS
   ├─ Flutter: counsellor_high_risk.dart
   │  └─ Click student → See full assessment details
   │     └─ Shows scores, rule fired, recommendation, intervention
```

---

#### **Admin Flow**

```
1. LOGIN
   ├─ Same as counsellor (role="admin")
   │
2. MANAGE RULES
   ├─ Flask: admin_dashboard.dart (Rules tab)
   │  ├─ ApiService.getRules()
   │  │  └─ GET /api/v1/rules
   │  │     └─ Backend: Return all RuleConfig[]
   │  │
   │  ├─ User adjusts slider (e.g., depression threshold: 20 → 25)
   │  │  └─ ApiService.updateRule("R-001", {parameters: {dep_threshold: 25}})
   │  │     └─ PUT /api/v1/rules/R-001
   │  │        └─ Backend: Update rules collection
   │  │           └─ Future assessments use new thresholds
   │  │
   │  └─ Click "Save" → shows success feedback
   │
3. MANAGE KNOWLEDGE BASE
   ├─ Flutter: admin_dashboard.dart (KB tab) or knowledge_base.dart
   │  ├─ ApiService.getResources()
   │  │  └─ GET /api/v1/resources
   │  │
   │  ├─ Upload KB article
   │  │  └─ ApiService.createResource({title, category, description, ...})
   │  │     └─ POST /api/v1/resources
   │  │
   │  └─ Delete article
   │     └─ ApiService.deleteResource(resourceId)
   │        └─ DELETE /api/v1/resources/:id
```

---

### Key Data Structures

#### **Assessment Flow** (Most Complex)

```
Student submits 21 answers:
rawAnswers = [2, 1, 3, 0, 2, 1, 0, 3, 1, 2, ...]  // 0-3 scale

↓ Backend: Scoring Service

computeScores(rawAnswers):
├─ Group by DASS-21 mapping:
│  ├─ Depression items [3,5,10,13,16,17,21] → sum = 12 → normalized = 24/42
│  ├─ Anxiety items [2,4,7,9,15,19,20] → sum = 8 → normalized = 16/42
│  └─ Stress items [1,6,8,11,12,14,18] → sum = 6 → normalized = 12/42
│
├─ Determine severities:
│  ├─ Depression 24 → "Moderate" (20-27 range)
│  ├─ Anxiety 16 → "Moderate" (14-20 range)
│  └─ Stress 12 → "Mild" (11-18 range)
│
└─ Return ScoreResult = {
     rawScores: {dep: 12, anx: 8, str: 6},
     normalisedScores: {dep: 24, anx: 16, str: 12},
     severities: {dep: "Moderate", anx: "Moderate", str: "Mild"}
   }

↓ Backend: Rule Engine

evaluateRules(scoreResult):
├─ Check explicit rules in order (first match wins):
│  ├─ R-001: dep=ES OR anx=ES? → NO
│  ├─ R-002: dep=Severe AND anx≥Moderate? → NO
│  ├─ R-003: str=Severe OR str=ES? → NO
│  ├─ R-004: dep=Moderate OR anx=Moderate? → YES! ✓
│  │  firedRuleId = "R-004"
│  │  riskLevel = "MODERATE"
│  │  recommendation = {title: "...", body: "...", actions: [...]}
│  │
│  └─ (skip R-005 through R-000 since we matched)
│
└─ Check tacit rules (post-explicit):
   ├─ R-C01: All three moderate? dep=Moderate, anx=Moderate, str=Mild → NO
   ├─ R-C02: Exam period + str≥Moderate? → NO
   └─ R-C03: Previous assessment HIGH/CRITICAL AND current≥Mild? → NO

↓ Backend: Store & Return

Store in assessments collection:
{
  id: "hvDWTHEQhq3lUvYu93KP",
  userId: "student001",
  takenAt: Timestamp(2026-06-07T17:55:38Z),
  rawAnswers: [2, 1, 3, ...],        // stored but not returned to client
  rawScores: {dep: 12, anx: 8, str: 6},
  normalisedScores: {dep: 24, anx: 16, str: 12},
  severities: {dep: "Moderate", anx: "Moderate", str: "Mild"},
  firedRuleId: "R-004",
  riskLevel: "MODERATE",
  recommendation: {
    title: "Moderate Support Recommended",
    body: "Your assessment indicates moderate stress levels...",
    actions: ["Schedule counselling session", "Practice stress management"]
  },
  appliedTacitRules: []
}

↓ Flutter: result.dart displays to student

Shows:
├─ Depression: 24/42 (Moderate)
├─ Anxiety: 16/42 (Moderate)
├─ Stress: 12/42 (Mild)
├─ Rule: "R-004"
├─ Recommendation: "Moderate Support Recommended"
└─ Actions: [action1, action2, ...]
```

---

### Authentication & Security Flow

```
Login:
┌─────────────────────────────────────┐
│ Flutter: Enter credentials          │
│ (role, identifier, password)        │
└────────────────────┬────────────────┘
                     │ HTTP POST
                     ▼
┌─────────────────────────────────────┐
│ Backend: POST /auth/login           │
│ ├─ Query users by role + identifier│
│ ├─ bcrypt.compare(password, hash)  │
│ └─ If match: generate JWT          │
│    jwt.sign({userId, role}, secret)│
│    Return: {token, userId, ...}    │
└────────────────────┬────────────────┘
                     │
                     ▼
┌─────────────────────────────────────┐
│ Flutter: Store token in memory      │
│ Add to all future requests:         │
│ Authorization: Bearer <token>       │
└─────────────────────────────────────┘

Subsequent API calls:
┌─────────────────────────────────────┐
│ Flutter: Any GET/POST/PUT/DELETE    │
│ + Authorization: Bearer <token>     │
└────────────────────┬────────────────┘
                     │
                     ▼
┌─────────────────────────────────────┐
│ Backend: jwt.verify(token)          │
│ ├─ If valid: extract {userId, role}│
│ ├─ Attach to req.user               │
│ ├─ Check role permissions           │
│ └─ Process request                  │
└─────────────────────────────────────┘
```

---

### Privacy & Data Masking

```
Student's own data (private):
├─ rawAnswers[21] → stored but NEVER sent to client or counsellor
├─ Visible to: student only
└─ Stored in: assessments collection

Counsellor/Admin view (anonymized):
├─ UUID: "hvDWTHEQhq3lUvYu93KP" (assessment ID, not student ID)
├─ NOT visible: student name, matric number, any PII
├─ Visible: scores, severities, rule, recommendation
└─ Used for: high-risk queue, clinical support

Campus analytics (fully aggregated):
├─ totalAssessed: 1 (count of unique students)
├─ averageScores: {dep: 16.3, anx: 11.5, str: 9.0}
├─ riskLevelCounts: {NORMAL: 4, LOW: 7, ...}
├─ severityDistribution: {dep: {Normal: 47.8%, ...}, ...}
└─ NOT visible: any student identifiers, individual assessments
```

---

## Part 3: Validation Checklist for Groupmates

Use this checklist to verify the system works end-to-end:

### Authentication ✓
- [ ] Student can login with S001 / demo1234
- [ ] Counsellor can login with C001 / demo1234
- [ ] Admin can login with A001 / demo1234
- [ ] Wrong password shows error
- [ ] Logout works

### Scoring (DASS-21) ✓
- [ ] All-zero answers → Normal/Normal/Normal
- [ ] All-3 answers → Extremely Severe/Extremely Severe/Extremely Severe
- [ ] Scores are in 0-42 range (not 0-84)
- [ ] Severities match thresholds per subscale

### Rule Engine ✓
- [ ] Different answer patterns fire different rules (R-001 through R-007)
- [ ] Correct riskLevel assigned (NORMAL, LOW, MODERATE, HIGH, CRITICAL)
- [ ] Recommendations are dynamic (not hardcoded)

### Data Persistence ✓
- [ ] Assessment submitted → appears in student's history
- [ ] History shows all past assessments with timestamps
- [ ] Counsellor can see high-risk assessments in queue
- [ ] Analytics show correct totals and averages

### Privacy ✓
- [ ] rawAnswers not visible to counsellor/admin
- [ ] High-risk queue shows UUID only (not student name)
- [ ] Campus analytics show no PII

### Admin Functions ✓
- [ ] Can load rule configurations
- [ ] Can adjust rule parameters (sliders)
- [ ] Can save rule changes → affects future assessments
- [ ] Can CRUD knowledge base resources

---

## Summary

**Before:** Flutter prototype with hardcoded data, broken scoring, no persistence
**After:** Full-stack system with:
- ✅ Correct DASS-21 scoring (per-subscale mapping + 0-42 normalization)
- ✅ Dynamic rule engine (8 explicit + 3 tacit rules)
- ✅ Real authentication (JWT + bcrypt)
- ✅ Firestore persistence (4 collections)
- ✅ Complete API integration (12 endpoints)
- ✅ Privacy/anonymization (no PII in counsellor/admin views)
- ✅ All 11 screens wired to live data

**Key Architectural Decision:** Backend handles all business logic (scoring, rules, persistence); Flutter is just a presentation layer that consumes APIs.

