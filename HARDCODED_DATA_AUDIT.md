# Hardcoded Data Audit Report

## Executive Summary

**Total Modified Screens: 11**
- ✅ **Fully Dynamic (API-Driven): 7 screens**
- ⚠️ **Partially Hardcoded: 3 screens**
- ❌ **Fully Hardcoded (Display Only): 1 screen**

---

## Screens Status by Type

### ✅ FULLY DYNAMIC (All data from Backend API)

#### 1. `student_login.dart`
- **Status**: Dynamic
- **Data Source**: `ApiService.login()`
- **What Loads**:
  - User credentials validation
  - JWT token
  - User role

#### 2. `staff_login.dart`
- **Status**: Dynamic
- **Data Source**: `ApiService.login()`
- **What Loads**:
  - User credentials validation
  - JWT token
  - User role (counsellor/admin)

#### 3. `assessment.dart`
- **Status**: Dynamic
- **Data Source**: `ApiService.submitAssessment()`
- **What Loads**:
  - Assessment scoring
  - Rule engine result
  - Recommendation text (from backend)
  - Risk level

#### 4. `result.dart`
- **Status**: Dynamic ✅ (with one unused function)
- **Data Source**: `ApiService.getMyHistory()`
- **What Loads**:
  - Assessment ID, timestamp, scores
  - Severities, fired rule, recommendation
  - Risk level
- **⚠️ Unused Dead Code**:
  - `_getSeverity()` function (lines 75-81) — **should be removed**, not used anymore

#### 5. `progress.dart`
- **Status**: Dynamic
- **Data Source**: `ApiService.getMyHistory()`
- **What Loads**:
  - Full assessment history (up to 20 records)
  - Chart data (depression, anxiety, stress per assessment)
  - Risk level labels
  - Timestamps

#### 6. `student_dashboard.dart`
- **Status**: Dynamic
- **Data Source**: `ApiService.getMyHistory()`
- **What Loads**:
  - Latest assessment metrics
  - Current scores and risk level
  - Student name (from session)

#### 7. `counsellor_dashboard.dart`
- **Status**: Dynamic
- **Data Source**:
  - `ApiService.getCampusAnalytics()`
  - `ApiService.getHighRiskQueue()`
- **What Loads**:
  - Total assessed count
  - Campus average scores
  - Risk level distribution
  - High-risk student list

---

### ⚠️ PARTIALLY HARDCODED

#### 8. `counsellor_high_risk.dart`
- **Status**: JUST FIXED ✅ (was hardcoded, now dynamic)
- **What Was Hardcoded**:
  - `'Total Assessed': '184'` (line 368)
  - Campus Averages values (14.5, 13.2, 16.8)
- **Data Source**: `ApiService.getCampusAnalytics()` + `ApiService.getHighRiskQueue()`
- **Still Has**:
  - Placeholder high-risk queue example data (lines 58-170) — **kept for reference but not used**

#### 9. `knowledge_base.dart`
- **Status**: Dynamic
- **Data Source**: `ApiService.getResources()`
- **What Loads**:
  - KB article titles, categories, descriptions
  - Read time (calculated from description length)
  - Resource IDs
- **Hardcoded Elements**:
  - `_getCategoryColor()` function (lines 59-72) — maps category names to colors (this is acceptable — UI styling, not data)

#### 10. `admin_dashboard.dart`
- **Status**: ⚠️ PARTIALLY HARDCODED ⚠️
- **What Is Hardcoded**:

  **A. DASS-21 Questions (lines 38-103)**
  - All 8 sample questions hardcoded
  - Questions Q1, Q2, Q3, Q4, Q5, Q6, Q19, Q21
  - Category, weight, status, mapped rules
  - **Analysis**: These are **OK to hardcode** because:
    - DASS-21 questions are standardized (read-only)
    - Questions never change (standard psychological assessment)
    - "Questions" tab is read-only (no editing capability)

  **B. Rules Configuration (lines 106-175)**
  - All 4 rules hardcoded: R-001, R-C02, R-C01, R-C03
  - Rule titles, descriptions, formulas, actions, parameters
  - **Analysis**: These SHOULD load from backend:
    - Admin can modify rule parameters via sliders
    - Changes should be persisted to Firestore
    - On page refresh, should load current backend state (not reset to hardcoded defaults)
  - **Issue**: No `ApiService.getRules()` call in `initState()`

  **C. Knowledge Resources (lines 178-259+)**
  - All 6 KB resources hardcoded: KB-001 to KB-006
  - Resource titles, categories, descriptions, authors, dates
  - **Analysis**: These SHOULD load from backend:
    - Admin can add/edit/delete resources via CRUD UI
    - Resources are dynamic and user-configurable
    - On page refresh, should load current backend state
  - **Issue**: No `ApiService.getResources()` call in `initState()`

---

### ❌ FULLY HARDCODED (Read-Only Display)

#### 11. `login.dart`
- **Status**: Hardcoded (but this is expected)
- **Hardcoded Elements**:
  - Student/Counsellor/Admin button labels
  - Login form UI text
  - **Analysis**: This is OK — purely UI text, no data

---

## Detailed Findings

### 🔴 Critical Issues (Need Fixing Now)

#### Issue 1: `admin_dashboard.dart` - Rules Not Loading from Backend

**File**: `lib/screens/admin_dashboard.dart`
**Location**: `initState()` and `_initializeData()`
**Problem**:
```dart
void _initializeData() {
  // Hardcoded rules - these should come from API
  _rules = [
    {
      'id': 'R-001',
      'type': 'Escalation',
      // ... all values hardcoded
    },
    // ... 3 more rules hardcoded
  ];
}
```

**Impact**:
- Admin slider changes are saved via `ApiService.updateRule()` ✓
- BUT on page refresh, rules reset to hardcoded defaults instead of loading from Firestore
- Admin's changes are persisted to backend but UI doesn't reflect them on reload

**Fix Needed**:
```dart
void initState() {
  super.initState();
  _loadData();  // Add this
}

Future<void> _loadData() async {
  try {
    final rules = await ApiService.getRules();
    final resources = await ApiService.getResources();
    if (mounted) {
      setState(() {
        _rules = rules;
        _knowledgeResources = resources;
      });
    }
  } catch (e) {
    // Load hardcoded fallback if API fails
    _initializeData();
  }
}
```

---

#### Issue 2: `admin_dashboard.dart` - Knowledge Base Not Loading from Backend

**File**: `lib/screens/admin_dashboard.dart`
**Location**: `_knowledgeResources` list (lines 178-259+)
**Problem**:
```dart
_knowledgeResources = [
  {
    'id': 'KB-001',
    'title': 'DSM-5-TR General Anxiety Diagnostic Reference',
    // ... all values hardcoded
  },
  // ... 5 more KB articles hardcoded
];
```

**Impact**:
- Admin can add new resources via CRUD UI
- BUT on page refresh, only hardcoded KB-001 to KB-006 appear
- Any newly added resources disappear on page reload
- Admin changes not persisted to client state

**Fix Needed**: Same as Issue 1 — call `ApiService.getResources()` in `_loadData()`

---

#### Issue 3: `result.dart` - Dead Code: `_getSeverity()` Function

**File**: `lib/screens/result.dart`
**Location**: Lines 75-81
**Problem**:
```dart
String _getSeverity(int score) {
  if (score < 5) return 'Normal';
  if (score < 10) return 'Mild';
  if (score < 15) return 'Moderate';
  if (score < 21) return 'Severe';
  return 'Extremely Severe';
}
```

**Issue**:
- This function is **never called** anywhere in the file
- Severities now come from `_result.severities` (from API response)
- Function uses wrong thresholds anyway (should be per-subscale)

**Fix**: Delete lines 75-81

---

### 🟡 Minor Issues (Acceptable But Could Improve)

#### Issue 4: `counsellor_high_risk.dart` - Placeholder Data Comments

**File**: `lib/screens/counsellor_high_risk.dart`
**Location**: Lines 57-170
**Content**: `_highRiskQueuePlaceholder` — hardcoded example data
**Analysis**:
- ✅ **Not actually used** (marked as "Placeholder - old data")
- ✅ Just reference documentation
- ✅ Can be safely deleted if not needed for documentation

**Recommendation**: Keep as reference or delete if confusing

---

#### Issue 5: `counsellor_high_risk.dart` - Hardcoded Campus Averages Text

**File**: `lib/screens/counsellor_high_risk.dart`
**Location**: Lines 403-406 (JUST FIXED)
**Status**: ✅ FIXED — now loads from `_campusAnalytics`
```dart
// BEFORE (hardcoded):
Text('Depression: 14.5/42 (Mod)',...)

// AFTER (dynamic):
Text('Depression: ${(_campusAnalytics?['averageScores']?['dep']...}',...)
```

---

## Summary Table

| Screen | Status | Data Source | Hardcoded | Action |
|--------|--------|-------------|-----------|--------|
| student_login.dart | ✅ Dynamic | ApiService.login() | None | None needed |
| staff_login.dart | ✅ Dynamic | ApiService.login() | None | None needed |
| assessment.dart | ✅ Dynamic | ApiService.submitAssessment() | None | None needed |
| result.dart | ✅ Dynamic | ApiService.getMyHistory() | Dead code only | Remove `_getSeverity()` |
| progress.dart | ✅ Dynamic | ApiService.getMyHistory() | None | None needed |
| student_dashboard.dart | ✅ Dynamic | ApiService.getMyHistory() | None | None needed |
| counsellor_dashboard.dart | ✅ Dynamic | ApiService.getCampusAnalytics() | None | None needed |
| counsellor_high_risk.dart | ✅ FIXED | ApiService.getCampusAnalytics() | Placeholder only | Delete placeholder comments |
| knowledge_base.dart | ✅ Dynamic | ApiService.getResources() | UI colors only | None needed |
| admin_dashboard.dart | ⚠️ Partial | None (all hardcoded) | **Rules + KB** | Load from ApiService.getRules() + ApiService.getResources() |
| login.dart | ℹ️ UI Text | None | Button labels (OK) | None needed |

---

## Recommended Fixes (Priority Order)

### 🔴 Priority 1: CRITICAL
1. **admin_dashboard.dart** - Add `ApiService.getRules()` call
2. **admin_dashboard.dart** - Add `ApiService.getResources()` call

### 🟡 Priority 2: CLEANUP
1. **result.dart** - Remove dead `_getSeverity()` function
2. **counsellor_high_risk.dart** - Clean up placeholder example data comments

### 🟢 Priority 3: OPTIONAL
1. **counsellor_high_risk.dart** - Delete `_highRiskQueuePlaceholder` if not needed for documentation

---

## Verification Checklist

After fixes:
- [ ] Admin loads rules on page entry (not hardcoded defaults)
- [ ] Admin loads KB resources on page entry
- [ ] Admin slider changes persist after page refresh
- [ ] New KB articles appear after admin adds them
- [ ] No hardcoded data visible except UI text (labels, colors)
- [ ] Dead code removed (result.dart `_getSeverity()`)

