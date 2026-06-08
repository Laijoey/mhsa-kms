# MHSA-KMS Project Setup Guide

**Mental Health Student Assessment - Knowledge Management System**

This guide will help you set up the MHSA-KMS project on your local machine.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Project Structure](#project-structure)
3. [Clone the Repository](#clone-the-repository)
4. [Firebase Setup](#firebase-setup)
5. [Backend Setup](#backend-setup)
6. [Frontend Setup](#frontend-setup)
7. [Running the Project](#running-the-project)
8. [Database Initialization](#database-initialization)
9. [Demo Credentials](#demo-credentials)
10. [Troubleshooting](#troubleshooting)

---

## Prerequisites

Make sure you have these installed on your machine:

### Required Software
- **Node.js** (v16 or higher) - [Download](https://nodejs.org/)
- **Flutter** (latest stable) - [Download](https://flutter.dev/docs/get-started/install)
- **Firebase CLI** - Install via npm:
  ```bash
  npm install -g firebase-tools
  ```
- **Git** - [Download](https://git-scm.com/)
- **Google Chrome** (for Flutter web testing)

### Verify Installation
```bash
node --version
npm --version
flutter --version
firebase --version
git --version
```

---

## Project Structure

```
mhsa-kms/
├── backend/                          # Node.js/Express backend
│   ├── src/
│   │   ├── auth/                     # Authentication module
│   │   ├── assessments/              # Assessment scoring & rules
│   │   ├── analytics/                # Campus analytics
│   │   ├── expert-system/            # Expert system engine
│   │   ├── shared/                   # Firestore & types
│   │   └── app.ts                    # Express app factory
│   ├── firebase-key.json             # Firebase credentials (LOCAL ONLY)
│   ├── seed.ts                       # Database seeding script
│   ├── package.json
│   └── tsconfig.json
├── lib/                              # Flutter app (Dart)
│   ├── screens/                      # UI screens
│   ├── services/                     # API service layer
│   ├── expert_system/                # Expert system (reference)
│   └── main.dart
├── pubspec.yaml                      # Flutter dependencies
├── firebase.json                     # Firebase emulator config
└── README.md                         # Project overview
```

---

## Clone the Repository

```bash
# Clone the project
git clone https://github.com/Laijoey/mhsa-kms.git
cd mhsa-kms

# Verify you're on main branch
git branch
# Output should show: * main
```

---

## Firebase Setup

### Step 1: Get the Firebase Key

**⚠️ IMPORTANT: The `firebase-key.json` file is NOT in the repository for security reasons.**

Ask your project lead (Jiaye) for the `firebase-key.json` file via:
- Email
- Slack
- WhatsApp
- In-person

**Do NOT share this file publicly or commit it to git!**

### Step 2: Install Firebase Key

```bash
# Navigate to backend directory
cd backend

# Create a new folder if it doesn't exist
mkdir -p .

# Paste the firebase-key.json file here
# File location: backend/firebase-key.json
```

The file structure should look like:
```
backend/
├── firebase-key.json      ← Your secret key (keep private!)
├── package.json
├── tsconfig.json
└── src/
```

### Step 3: Verify Firebase Access

```bash
# Still in backend/ directory
npm install
npm run dev
```

You should see:
```
MHSA-KMS Backend listening on port 3000
Firebase Emulator: disabled
```

If it fails with "firebase-key.json not found", the key file is missing.

---

## Backend Setup

### Step 1: Install Dependencies

```bash
cd backend
npm install
```

### Step 2: Environment Configuration

The `.env` file is already configured. Verify `backend/.env` exists:

```bash
# backend/.env (should already exist)
FIREBASE_PROJECT_ID=mhsa-kms
FIREBASE_DATABASE_URL=https://mhsa-kms.firebaseio.com
NODE_ENV=production
PORT=3000
```

No changes needed unless you're using Firebase Emulator.

### Step 3: Verify Backend Compiles

```bash
npm run build
# Should complete with no errors
```

---

## Frontend Setup

### Step 1: Install Flutter Dependencies

```bash
cd lib  # or stay in root
flutter pub get
```

### Step 2: Verify Flutter Environment

```bash
flutter doctor
```

All items should have checkmarks (✓). If not, follow the instructions.

### Step 3: Check for Type Errors

```bash
flutter analyze
```

Should show no errors (warnings are okay).

---

## Running the Project

You'll need **3 terminal windows** to run everything:

### Terminal 1: Firebase (Optional - for emulator)

If using Firebase Emulator:
```bash
firebase emulators:start
```

**Skip this if using production Firebase** (recommended for now).

### Terminal 2: Backend Server

```bash
cd backend
npm run dev
```

Expected output:
```
[nodemon] starting `ts-node src/server.ts`
MHSA-KMS Backend listening on port 3000
Environment: production
Firebase Emulator: disabled
```

### Terminal 3: Flutter App

```bash
flutter run -d chrome
```

This opens the app in Chrome. Available devices:
- `chrome` — Web browser
- `windows` — Windows desktop
- `macos` — macOS desktop

---

## Database Initialization

### Option 1: Seed Test Data (Recommended First Time)

```bash
cd backend
npx ts-node seed.ts
```

This creates:
- 3 demo users (student, counsellor, admin)
- 11 rules
- 6 resources
- 20 test assessments across 14 weeks

Output:
```
✓ Seed completed successfully!

Demo credentials:
  Student: S001 / demo1234
  Counsellor: C001 / demo1234
  Admin: A001 / demo1234
```

### Option 2: Manual Database Setup

If you prefer to set up Firebase manually:
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select `mhsa-kms` project
3. Create collections: `users`, `assessments`, `rules`, `resources`
4. Add documents manually (not recommended)

---

## Demo Credentials

Use these to test the app:

| Role | Identifier | Password | Notes |
|------|-----------|----------|-------|
| **Student** | S001 | demo1234 | Can submit assessments, view results, track progress |
| **Counsellor** | C001 | demo1234 | Can view high-risk queue, campus analytics, knowledge base |
| **Admin** | A001 | demo1234 | Can manage rules, manage resources, view all data |

### Testing Flow

1. **Student Assessment:**
   - Login as S001
   - Go to Assessment tab
   - Fill out DASS-21 questions
   - Submit → See result with risk level
   - View progress chart

2. **Counsellor Dashboard:**
   - Login as C001
   - See campus overview (severity distribution, high-risk count)
   - Click "High Risk" tab to see flagged students
   - Select a student to see detailed breakdown

3. **Admin Dashboard:**
   - Login as A001
   - Manage rules (sliders, parameters)
   - Manage knowledge base articles
   - View all analytics

---

## Project Features

### Backend API Endpoints

| Method | Path | Auth | Purpose |
|--------|------|------|---------|
| POST | /auth/login | None | Student/Counsellor/Admin login |
| POST | /assessments | Student | Submit DASS-21 assessment |
| GET | /assessments/me | Student | Get your assessment history |
| GET | /assessments/high-risk | Counsellor | Get flagged students |
| GET | /analytics/campus | Counsellor | Campus-wide analytics |
| GET | /resources | Any | Get knowledge base articles |
| GET | /rules | Admin | View all rules |
| PUT | /rules/:id | Admin | Update rule configuration |

### Expert System

The backend includes an **11-rule expert system** for mental health assessment:

- **8 Explicit Rules** (R-001 to R-007, R-000)
- **3 Tacit Rules** (R-C01, R-C02, R-C03)
- Evaluates: Depression, Anxiety, Stress
- Outputs: Risk level (NORMAL, LOW, MODERATE, HIGH, CRITICAL)

Test via: `POST /api/v1/assessments/expert-system`

### DASS-21 Assessment

The app implements the **Depression Anxiety Stress Scales (DASS-21)**:
- 21 questions
- Answers: 0-3 scale
- Measures: Depression, Anxiety, Stress
- Normalized scores: 0-42 per subscale

---

## Troubleshooting

### Backend Issues

**Error: "Cannot find module 'firebase-admin'"**
```bash
cd backend
npm install
```

**Error: "firebase-key.json not found"**
- Ask project lead for the file
- Save it to `backend/firebase-key.json`
- Verify file exists: `ls backend/firebase-key.json`

**Error: "Port 3000 already in use"**
```bash
# Kill the process using port 3000
# On Windows:
netstat -ano | findstr :3000
taskkill /PID <PID> /F

# On macOS/Linux:
lsof -i :3000
kill -9 <PID>
```

**Backend won't connect to Firebase**
- Verify `firebase-key.json` exists
- Check Firebase credentials are valid
- Verify internet connection

### Frontend Issues

**Flutter pub get fails**
```bash
flutter clean
flutter pub get
```

**Chrome driver error**
```bash
flutter clean
flutter pub get
flutter run -d chrome
```

**Port 3000 connection error in app**
- Verify backend is running: `http://localhost:3000`
- Check firewall isn't blocking port 3000
- Restart both backend and app

**CORS errors**
- Backend should have CORS enabled
- Verify `lib/services/api_service.dart` uses `http://localhost:3000/api/v1`

### Database Issues

**Seed script fails**
```bash
cd backend
npm install
npx ts-node seed.ts
```

**No data in dashboards**
- Run seed script: `npx ts-node seed.ts`
- Check Firebase has collections: users, assessments, rules, resources
- Verify Firebase credentials in `firebase-key.json`

---

## Git Workflow

### Pull Latest Changes

```bash
git pull origin main
```

### Create a New Branch

```bash
git checkout -b feature/your-feature-name
# Make changes
git add .
git commit -m "feat: describe your changes"
git push origin feature/your-feature-name
```

Then create a Pull Request on GitHub.

### Important Files - DO NOT COMMIT

These files are in `.gitignore` and should NEVER be committed:

```
backend/firebase-key.json    # Firebase credentials
backend/.env                 # Environment variables
.env                        # Local config
```

If you accidentally commit secrets, **STOP and tell the project lead immediately!**

---

## Common Commands

### Backend

```bash
cd backend

npm install          # Install dependencies
npm run dev         # Start development server
npm run build       # Compile TypeScript
npm test            # Run tests
npx ts-node seed.ts # Seed database
```

### Frontend

```bash
cd lib  # or stay in root

flutter pub get                    # Install dependencies
flutter run -d chrome              # Run on web
flutter run -d windows             # Run on Windows
flutter clean                      # Clean build
flutter analyze                    # Check for errors
```

### Git

```bash
git status                    # Check changes
git pull origin main          # Get latest code
git push origin main          # Push your changes
git log --oneline             # View commit history
```

---

## Support & Questions

If you have issues:

1. **Check this guide** — Solutions for common problems are in [Troubleshooting](#troubleshooting)
2. **Check README.md** — Project overview and architecture
3. **Ask the team** — Ask Jiaye or other groupmates
4. **Check GitHub Issues** — See if someone reported it

---

## Next Steps

1. ✅ Clone the repository
2. ✅ Get `firebase-key.json` from project lead
3. ✅ Install dependencies (backend & frontend)
4. ✅ Run seed script to populate database
5. ✅ Start backend server (Terminal 2)
6. ✅ Start Flutter app (Terminal 3)
7. ✅ Login with demo credentials
8. ✅ Test each feature

**You're ready to develop! 🚀**

---

## Project Details

- **GitHub**: https://github.com/Laijoey/mhsa-kms
- **Backend**: Node.js + Express + TypeScript
- **Frontend**: Flutter (Dart)
- **Database**: Firebase Firestore
- **Authentication**: JWT + Firebase Auth
- **Expert System**: 11-rule mental health assessment engine

---

**Last Updated**: June 9, 2026
**Version**: 1.0
**Status**: Production Ready
