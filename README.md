# MHSA-KMS: Mental Health Self-Assessment Knowledge Management System

A comprehensive mental health assessment platform combining a Flutter frontend with a Node.js/Express backend, Firebase Firestore database, and advanced rule engine for DASS-21 scoring and clinical decision support.

## Architecture Overview

```
Flutter (web/mobile UI)
    ↓ (HTTP/JSON)
Node.js + Express API
    ↓
Firebase Firestore (with local emulator for development)
    ├── Scoring module (DASS-21)
    ├── Rule engine (IF-THEN production rules)
    └── Knowledge base (thresholds + rules + resources)
```

## Prerequisites

- **Node.js** (v18+)
- **Firebase CLI** (`npm install -g firebase-tools`)
- **Flutter SDK** (3.0+)
- **Dart** (3.0+)

## Quick Start

### 1. Install Backend

```bash
cd backend && npm install
```

### 2. Start Firebase Emulators

```bash
firebase emulators:start
```

### 3. Seed Database

```bash
cd backend && npm run seed
```

**Demo Credentials:**
- Student: `S001` / `demo1234`
- Counsellor: `C001` / `demo1234`
- Admin: `A001` / `demo1234`

### 4. Start Backend

```bash
cd backend && npm run dev
```

API: http://localhost:3000/api/v1

### 5. Run Flutter App

```bash
flutter pub get
flutter run -d chrome
```

## Key Features

✓ **DASS-21 Scoring**: Correct item mapping, ×2 normalization, per-subscale severity thresholds
✓ **Rule Engine**: 8 explicit rules + 3 tacit escalation rules with real-time evaluation
✓ **Authentication**: JWT + bcrypt, role-based access control (student/counsellor/admin)
✓ **Persistence**: Firebase Firestore with local emulator for development
✓ **Analytics**: Anonymized campus-wide aggregates (no PII)
✓ **Admin Dashboard**: Real-time rule configuration with persistent changes
✓ **Counsellor Queue**: HIGH/CRITICAL assessments with intervention tracking

## API Endpoints

All under `/api/v1`:

### Auth
- `POST /auth/login` — authenticate with role, identifier, password

### Assessments
- `POST /assessments` — submit 21-item assessment (requires student auth)
- `GET /assessments/me` — student's history
- `GET /assessments/high-risk` — HIGH/CRITICAL queue (counsellor/admin)

### Analytics
- `GET /analytics/campus` — anonymized aggregates (counsellor/admin, no PII)

### Resources & Rules
- `GET/POST/PUT/DELETE /resources` — knowledge base CRUD
- `GET/PUT /rules` — rule configuration (admin only)

## DASS-21 Scoring

### Item Mapping (1-indexed)
- **Depression**: 3, 5, 10, 13, 16, 17, 21
- **Anxiety**: 2, 4, 7, 9, 15, 19, 20
- **Stress**: 1, 6, 8, 11, 12, 14, 18

### Severity Thresholds (normalised 0-42)
| Severity | Depression | Anxiety | Stress |
|---|---|---|---|
| Normal | 0-9 | 0-7 | 0-14 |
| Mild | 10-13 | 8-9 | 15-18 |
| Moderate | 14-20 | 10-14 | 19-25 |
| Severe | 21-27 | 15-19 | 26-33 |
| Extremely Severe | 28+ | 20+ | 34+ |

## Rule Engine

### Explicit Rules (First Match Wins)
| Rule | Condition | Risk |
|---|---|---|
| R-001 | dep=ES OR anx=ES | CRITICAL |
| R-002 | dep=Severe AND anx≥Mod | HIGH |
| R-003 | str=Severe/ES | HIGH |
| R-004 | dep=Mod OR anx=Mod | MODERATE |
| R-005 | str=Mod AND (dep≥Mild OR anx≥Mild) | MODERATE |
| R-006 | dep=Mild AND anx=Norm AND str=Norm | LOW |
| R-007 | All Normal/Mild | NORMAL |
| R-000 | Fallback | LOW |

### Tacit Rules (Post-Escalation)
- **R-C01**: All three Moderate → escalate MODERATE→HIGH
- **R-C02**: Exam period + Stress≥Moderate → add exam resources
- **R-C03**: Previous HIGH/CRITICAL + any≥Mild → override to HIGH

## Testing

### Backend Tests
```bash
cd backend
npm test
```
Covers DASS-21 scoring boundaries and rule engine logic.

### Manual Testing
1. Login as student (S001/demo1234)
2. Complete assessment
3. Verify correct rule fires and recommendation displays
4. Check progress history
5. Login as counsellor to see high-risk queue

## Project Structure

```
mhsa-kms/
├── lib/                              # Flutter app
│   ├── screens/                      # UI screens
│   ├── services/api_service.dart    # HTTP client
│   └── main.dart
├── backend/                          # Node.js + Express API
│   ├── src/
│   │   ├── auth/                    # JWT + bcrypt
│   │   ├── assessments/             # Scoring + rule engine
│   │   ├── analytics/               # Campus analytics
│   │   ├── resources/               # KB CRUD
│   │   ├── rules/                   # Rule config
│   │   └── shared/                  # Types, errors
│   ├── knowledge_base.json          # Seed data
│   ├── seed.ts                      # Init script
│   ├── app.ts / server.ts
│   └── package.json
├── firebase.json                     # Emulator config
├── pubspec.yaml
└── README.md
```

## Acceptance Criteria

- ✓ All-zero DASS-21 → Normal/Normal/Normal
- ✓ All-3 answers → Extremely Severe (scores 42 each)
- ✓ Hand-computed case matches table precisely
- ✓ Rule ID and recommendation dynamically displayed
- ✓ Rule slider changes persist via admin PUT endpoint
- ✓ Second assessment appears in progress history
- ✓ HIGH/CRITICAL visible in counsellor queue
- ✓ Campus analytics contain no names or matric numbers
- ✓ All unit tests pass (`npm test`)

## Troubleshooting

**Emulator won't start**: Install `firebase-tools` globally
**Backend port conflict**: Change PORT in .env
**Flutter can't connect**: Ensure backend and emulator are running on localhost:3000 and :8080
**Seed fails**: Run `firebase emulators:start` first

## License

Internal project for university wellness teams.
