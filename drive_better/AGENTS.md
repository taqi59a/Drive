# Drive Better — AI Agent Handoff Document

> **For any AI agent (Codex, Claude, GPT, Gemini, etc.) continuing this project.**
> This doc is the single source of truth. Read it fully before touching any code.

---

## App Overview

**Name:** Drive Better  
**Platform:** Flutter (Android first, iOS later)  
**Purpose:** UK Driving Theory Test learning app with AI-powered Q&A  
**Status:** ~95% implemented. App runs cleanly on Android emulator (no errors). All screens built and wired to real Isar DB: Home stats, topic carousel, topics grid, practice (questions + bookmark toggle + attempt recording), mock test (attempt recording at submit), bookmarks (real + undo), progress (real stats + topic mastery). Google Sheets sync integrated. Skeleton loading on all screens. Cloudflare Worker backend built (needs deploy). PDF extractor built (needs run). Seed v2 upserts safely (no duplicate index errors).  
**Location:** `/Users/taqi/StudioProjects/Drive Better/drive_better/`  
**Theory Book:** `/Users/taqi/StudioProjects/Drive Better/Driving Theory Book 2022.pdf` (251 pages, text-based PDF)

---

## Architecture (Designed by Claude Opus 4.8 — DO NOT CHANGE)

### Pattern
- **Clean Architecture** — feature-first folder structure
- **State Management:** Riverpod (flutter_riverpod ^2.5.1 + riverpod_annotation)
- **Navigation:** GoRouter with StatefulShellRoute (indexed tabs)
- **Local DB:** Isar v3 (full-text search, typed queries)
- **Network:** Dio with retry + auth interceptors
- **Codegen:** build_runner + freezed + json_serializable + isar_generator

### Critical Security Rule
**NEVER put the Anthropic API key in the app.** The app calls a backend proxy (Cloudflare Worker / Node) that holds `ANTHROPIC_API_KEY`. The app only has an `APP_TOKEN` + `PROXY_BASE_URL` passed via `--dart-define`. See `lib/core/config/app_config.dart`.

### AI Models Used
- **Camera Q&A (live):** `claude-haiku-4-5` via proxy — fast, cheap, vision-capable
- **Content enrichment (dev-time only):** `claude-sonnet-4-6` — generates explanations for questions

### Camera Q&A Pipeline (CRITICAL — do not change this flow)
```
Camera frame (every 800ms)
  → ML Kit OCR (on-device, google_mlkit_text_recognition)
  → TextNormalizer.fixOcrArtifacts() + normalize()
  → FuzzyMatcher against local Isar question bank
  → score ≥ 0.75 → return local answer (INSTANT, OFFLINE, FREE)
  → score < 0.75 → POST to Claude proxy (fallback only)
```
This means 95% of answers are instant and free. Never send camera frames directly to an LLM.

### PDF Pipeline (dev-time, NOT runtime)
The PDF is parsed **once** by a developer tool (`tool/pdf_extractor.dart`) into:
- `assets/seed/questions.json` — all questions
- `assets/seed/topics.json` — all topics  
- `assets/seed/book_images/` — cropped sign/diagram PNGs

The app seeds Isar DB from these JSON files on first launch (`core/database/db_seeder.dart`). The app NEVER parses the PDF at runtime.

### Diving Questions Scraper Pipeline (dev-time)
In addition to the PDF pipeline, questions can be scraped and verified using the Python scripts in `/Diving Questions/`.
- **Location:** `Diving Questions/`
- **Purpose:** Scraping and verifying questions (e.g., driving theory exam questions from Belgium driving license online portals).
- **Core Scripts:**
  - `scrape.py`: Uses Playwright and BeautifulSoup to log in, fetch lessons/questions, and output structured data.
  - `verify_all.py`: Performs verification of scraped questions by simulating exam tests using Playwright.
- **Output Data:**
  - `Diving Questions/data/data.json`: The generated questions database containing question IDs, clean text, and choices.
  - `Diving Questions/data/index.html`: Scraped HTML files for offline reference.

---

## Folder Structure (Complete)

```
drive_better/
├── lib/
│   ├── main.dart                          ✅ DONE
│   ├── bootstrap.dart                     ✅ DONE
│   ├── app.dart                           ✅ DONE
│   │
│   ├── core/
│   │   ├── config/app_config.dart         ✅ DONE
│   │   ├── constants/app_constants.dart   ✅ DONE
│   │   ├── theme/
│   │   │   ├── app_colors.dart            ✅ DONE
│   │   │   ├── app_typography.dart        ✅ DONE
│   │   │   └── app_theme.dart             ✅ DONE
│   │   ├── router/
│   │   │   ├── routes.dart                ✅ DONE
│   │   │   └── app_router.dart            ✅ DONE
│   │   ├── network/dio_client.dart        ✅ DONE
│   │   ├── database/
│   │   │   ├── isar_service.dart          ✅ DONE
│   │   │   └── db_seeder.dart             ✅ DONE
│   │   ├── error/failure.dart             ✅ DONE
│   │   ├── utils/
│   │   │   ├── text_normalizer.dart       ✅ DONE
│   │   │   └── fuzzy_matcher.dart         ✅ DONE
│   │   └── widgets/
│   │       ├── glass_card.dart            ✅ DONE
│   │       └── primary_button.dart        ✅ DONE
│   │
│   ├── features/
│   │   ├── onboarding/presentation/
│   │   │   └── onboarding_screen.dart     ✅ DONE (by agent)
│   │   │
│   │   ├── home/presentation/
│   │   │   └── home_screen.dart           ✅ DONE (by agent)
│   │   │
│   │   ├── training/
│   │   │   ├── data/models/
│   │   │   │   ├── question.dart          ✅ DONE (Isar collection)
│   │   │   │   └── topic.dart             ✅ DONE (Isar collection)
│   │   │   └── presentation/
│   │   │       ├── topics/topics_screen.dart          ✅ DONE (by agent)
│   │   │       ├── practice/practice_screen.dart      ✅ DONE (by agent)
│   │   │       ├── mock_test/mock_test_screen.dart     ✅ DONE (by agent)
│   │   │       ├── mock_test/mock_test_result_screen.dart ✅ DONE
│   │   │       └── flashcards/flashcards_screen.dart  ✅ DONE (by agent)
│   │   │
│   │   ├── camera_qa/presentation/
│   │   │   ├── scanner_screen.dart        ✅ DONE (by agent)
│   │   │   └── application/scanner_controller.dart ✅ DONE (by agent)
│   │   │
│   │   ├── progress/
│   │   │   ├── data/models/
│   │   │   │   ├── attempt.dart           ✅ DONE (Isar collection)
│   │   │   │   └── test_session.dart      ✅ DONE (Isar collection)
│   │   │   └── presentation/
│   │   │       └── progress_screen.dart   ✅ DONE (by agent)
│   │   │
│   │   ├── bookmarks/presentation/
│   │   │   └── bookmarks_screen.dart      ✅ DONE (by agent)
│   │   │
│   │   └── settings/presentation/
│   │       └── settings_screen.dart       ✅ DONE (by agent)
│   │
│   └── shared/
│       ├── providers/
│       │   ├── isar_provider.dart         ✅ DONE
│       │   ├── theme_provider.dart        ✅ DONE
│       │   └── dio_provider.dart          ✅ DONE
│       └── widgets/
│           └── main_shell.dart            ✅ DONE (bottom nav shell)
│
├── assets/
│   ├── seed/
│   │   ├── questions.json                 ✅ DONE — 160 questions across 8 topics (seed v2)
│   │   └── topics.json                    ✅ DONE — 8 topics with real question counts
│   ├── fonts/                             ❌ TODO — download Plus Jakarta Sans from Google Fonts
│   ├── images/                            ❌ TODO — add placeholder/onboarding images
│   ├── lottie/                            ❌ TODO — add success.json, scanning.json
│   └── icons/                             ❌ TODO
│
├── tool/
│   └── extract_pdf.py                     ✅ DONE — Claude-powered PDF→JSON extractor (pip install pdfplumber anthropic)
│
├── backend/                               ✅ DONE — Cloudflare Worker proxy (see backend/DEPLOY.md)
│   ├── src/index.ts                       ✅ DONE — POST /v1/answer, POST /v1/explain, GET /health
│   ├── wrangler.toml                      ✅ DONE
│   ├── package.json                       ✅ DONE
│   └── DEPLOY.md                          ✅ DONE — step-by-step deploy guide
│
├── pubspec.yaml                           ✅ DONE
├── AGENTS.md                              ✅ THIS FILE
└── android/
    └── gradle/wrapper/gradle-wrapper.properties  ✅ DONE (gradle-8.14-bin)
```

---

## Build Environment Notes (CRITICAL for next agent)

- **Java:** Must use Java 21 (`$HOME/Library/Java/JavaVirtualMachines/jdk-21.0.7+6/Contents/Home`). Java 25 is installed but incompatible with Gradle 8.14. Run: `flutter config --jdk-dir="$HOME/Library/Java/JavaVirtualMachines/jdk-21.0.7+6/Contents/Home"`
- **Gradle:** 8.14-bin (already in wrapper properties)
- **AGP:** 8.11.1 (in android/settings.gradle.kts)
- **isar_flutter_libs:** Patched copy in `patches/isar_flutter_libs/` with namespace added. `pubspec.yaml` uses `dependency_overrides` to point to it.
- **flutter pub get + build_runner:** Already run. `.g.dart` files exist for all Isar models.
- **App runs:** `flutter run -d emulator-5554` works. Isar DB initialises. All screens render.

## What Still Needs To Be Done (Priority Order)

### 0. DONE — `flutter pub get`, codegen, app runs on emulator ✅
```bash
cd "/Users/taqi/StudioProjects/Drive Better/drive_better"
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```
This generates: `question.g.dart`, `topic.g.dart`, `attempt.g.dart`, `test_session.g.dart`

### 2. Create seed data files
The app crashes on first launch without these. Create minimal valid JSON:

**`assets/seed/topics.json`** — array of objects with:
```json
[
  {"id": "road_signs", "title": "Road Signs", "description": "...", "order": 1, "questionCount": 125, "iconName": "sign", "colorHex": "#1B3A6B"},
  {"id": "hazard_awareness", "title": "Hazard Awareness", "description": "...", "order": 2, "questionCount": 150, "iconName": "warning", "colorHex": "#E5484D"},
  ...8 total topics
]
```

**`assets/seed/questions.json`** — array of question objects:
```json
[
  {
    "id": "q_001",
    "topicId": "road_signs",
    "text": "What does a circular red sign mean?",
    "options": [
      {"text": "Warning"},
      {"text": "Order/prohibition"},
      {"text": "Information"},
      {"text": "Direction"}
    ],
    "correctIndex": 1,
    "explanation": "Circular red signs give orders and prohibitions...",
    "imageAsset": null,
    "sourcePage": 12
  }
]
```
Start with at least 50 questions across the 8 topics for a functional demo.

### 3. Download Plus Jakarta Sans font files
Go to https://fonts.google.com/specimen/Plus+Jakarta+Sans — download and place .ttf files in `assets/fonts/`:
- PlusJakartaSans-Regular.ttf (400)
- PlusJakartaSans-Medium.ttf (500)
- PlusJakartaSans-SemiBold.ttf (600)
- PlusJakartaSans-Bold.ttf (700)
- PlusJakartaSans-ExtraBold.ttf (800)

OR: Remove the font declarations from pubspec.yaml and let `google_fonts` package download them at runtime (simpler for development).

### 4. Android permissions
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />
```
Also set `minSdkVersion 21` in `android/app/build.gradle`.

### 5. Fix any compilation errors from screen files
The agent-written screens may have minor import path issues. Run `flutter analyze` and fix.

### 6. Backend proxy (Cloudflare Worker)
Create `backend/src/index.ts`:
- POST /v1/answer endpoint
- Validates `Authorization: Bearer <APP_TOKEN>` header
- Calls Claude `claude-haiku-4-5` with the question
- Returns `{answer, explanation, confidence}`
- Deploy to Cloudflare Workers

### 7. PDF extraction pipeline
Create `tool/pdf_extractor.dart` using `syncfusion_flutter_pdf` (dev dependency) to:
- Parse the PDF at `/Users/taqi/StudioProjects/Drive Better/Driving Theory Book 2022.pdf`
- Extract question text, options, answers
- Output to `assets/seed/questions.json`

---

## Key Design Tokens

### Colors
| Token | Value | Use |
|---|---|---|
| `AppColors.primary` | `#1B3A6B` | Deep blue — brand, buttons, active states |
| `AppColors.primaryLight` | `#2D5BB8` | Gradients, highlights |
| `AppColors.accent` | `#F5A623` | Amber — CTAs, warnings, scanner |
| `AppColors.success` | `#2EBD85` | Correct answers, pass state |
| `AppColors.error` | `#E5484D` | Wrong answers, fail state |
| `AppColors.lightBg` | `#F7F9FC` | Light theme scaffold background |
| `AppColors.darkBg` | `#0B1421` | Dark theme scaffold background |

### Typography
Font: **Plus Jakarta Sans** (via google_fonts package)
- Display/Headline: ExtraBold (800) or Bold (700)
- Body: Regular (400) or Medium (500)
- Labels/Buttons: SemiBold (600)

### Spacing Scale
4, 8, 12, 16, 20, 24, 32, 48px

### Border Radius
- Cards: 20px
- Buttons: 14px
- Chips: 20px (pill)
- Bottom sheets: 28px top

---

## Routes Table

| Name | Path | Screen |
|---|---|---|
| onboarding | `/onboarding` | OnboardingScreen |
| home | `/` | HomeScreen (shell tab 0) |
| topics | `/training` | TopicsScreen (shell tab 1) |
| practice | `/training/practice/:topicId` | PracticeScreen |
| mockTest | `/training/mock-test` | MockTestScreen |
| mockTestResult | `/training/mock-test/result` | MockTestResultScreen |
| flashcards | `/training/flashcards/:topicId` | FlashcardsScreen |
| scanner | `/scan` | ScannerScreen (shell tab 2, center) |
| progress | `/progress` | ProgressScreen (shell tab 3) |
| bookmarks | `/bookmarks` | BookmarksScreen |
| settings | `/settings` | SettingsScreen (shell tab 4) |

---

## Isar Collections (Data Models)

### Question (`lib/features/training/data/models/question.dart`)
- `externalId: String` — stable ID like "q_0421"
- `topicId: String` — FK to Topic.externalId
- `text: String` — question stem
- `searchTokens: List<String>` — normalized tokens for fuzzy matching
- `options: List<AnswerOption>` — embedded, each has `text` + optional `imageAsset`
- `correctIndex: int`
- `explanation: String?`
- `imageAsset: String?` — path like `assets/seed/book_images/sign_042.png`
- `isBookmarked: bool`
- `timesSeen, timesCorrect: int`
- `easeFactor: double` — SM-2 for flashcards

### Topic (`lib/features/training/data/models/topic.dart`)
- `externalId: String` (unique indexed)
- `title, description, iconName, colorHex: String?`
- `order, questionCount: int`

### Attempt (`lib/features/progress/data/models/attempt.dart`)
- `questionExternalId: String`
- `answeredAt: DateTime`
- `chosenIndex: int`, `wasCorrect: bool`, `msToAnswer: int`
- `mode: AttemptMode` enum (practice | mockTest | flashcard)

### TestSession (`lib/features/progress/data/models/test_session.dart`)
- `startedAt, finishedAt: DateTime`
- `totalQuestions, correctCount, durationSeconds: int`
- `passed: bool` (UK threshold: 43/50)
- `questionIds: List<String>`

---

## pubspec.yaml Key Dependencies

```yaml
flutter_riverpod: ^2.5.1
riverpod_annotation: ^2.3.5
go_router: ^14.3.0
dio: ^5.7.0
isar: ^3.1.0+1
isar_flutter_libs: ^3.1.0+1
google_mlkit_text_recognition: ^0.13.0
camera: ^0.10.5+9
flutter_animate: ^4.5.2
google_fonts: ^6.2.1
fl_chart: ^0.68.0
string_similarity: ^2.1.1
permission_handler: ^11.3.1
shared_preferences: ^2.3.3
```

---

## How to Continue (Step by Step)

1. **Open terminal**, `cd "/Users/taqi/StudioProjects/Drive Better/drive_better"`
2. Run `flutter pub get`
3. Run `dart run build_runner build --delete-conflicting-outputs`
4. Create `assets/seed/topics.json` and `assets/seed/questions.json` with sample data
5. Run `flutter analyze` — fix any errors
6. Run `flutter run` on an Android device/emulator
7. Fix any runtime errors
8. Then tackle: PDF pipeline, real seed data, backend proxy, polish

## DO NOT
- Change the architecture (clean arch + Riverpod + GoRouter) — it was designed by Opus 4.8
- Add the Anthropic API key to the Flutter app — use the proxy
- Change the OCR pipeline to stream frames to LLM — too slow and expensive
- Use Hive instead of Isar — Isar has full-text search needed for question matching
- Use Gemini as the AI — Claude is already wired in (single provider)
- Parse the PDF at app runtime — it's a dev-time pipeline only

---

*Last updated: 2026-06-18. App built by Claude Sonnet 4.6, architecture by Claude Opus 4.8.*
