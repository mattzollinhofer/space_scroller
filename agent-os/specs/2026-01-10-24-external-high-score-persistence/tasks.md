# Task Breakdown: External High Score Persistence

## Overview

Total Slices: 4
Each slice delivers incremental user value and is tested end-to-end.

This feature adds Firebase Realtime Database integration for global high score
persistence. The design philosophy is SIMPLE: 4-second timeout, silent failure,
no retries, no offline queueing.

## Task List

### Slice 1: User's high score is submitted to Firebase when saved locally

**What this delivers:** When a player achieves a high score and it's saved locally, the score is also silently submitted to Firebase. If the network fails, the game continues without interruption.

**Dependencies:** None

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/autoloads/audio_manager.gd:1-77] - Autoload singleton structure, `_ready()` initialization
- [@/Users/matt/dev/space_scroller/scripts/autoloads/audio_manager.gd:324-336] - ConfigFile/JSON loading pattern for configuration
- [@/Users/matt/dev/space_scroller/scripts/score_manager.gd:113-145] - `save_high_score()` entry point for integration
- [@/Users/matt/dev/space_scroller/project.godot:18-24] - Autoload registration pattern
- [commit:b3d7a23] - Adding new autoload with config persistence pattern

#### Tasks

- [x] 1.1 Write integration test that verifies FirebaseService autoload exists and has submit_score method
- [x] 1.2 Run test, verify expected failure (FirebaseService not found) -> Success: "FirebaseService autoload not found"
- [x] 1.3 Create `scripts/autoloads/firebase_service.gd` extending Node with submit_score stub
- [x] 1.4 Register FirebaseService in project.godot autoload section
- [x] 1.5 Run test, verify it finds FirebaseService with submit_score method -> Success
- [x] 1.6 Create `config/firebase_config.json` with placeholder values for project_id and database_url
- [x] 1.7 Add `_ready()` to load firebase config from JSON file
- [x] 1.8 Implement `submit_score(score: int, initials: String = "AAA")` with HTTPRequest POST
- [x] 1.9 Set HTTPRequest timeout to 4 seconds
- [x] 1.10 Add silent error handling (return without action on timeout/error)
- [x] 1.11 Write test that verifies submit_score can be called without crashing
- [x] 1.12 Run test, verify success -> Success
- [x] 1.13 Integrate FirebaseService.submit_score() into ScoreManager.save_high_score()
- [x] 1.14 Write test that verifies ScoreManager.save_high_score() calls FirebaseService
- [x] 1.15 Run test, verify success -> Success
- [x] 1.16 Refactor if needed (keep tests green) -> No refactoring needed
- [x] 1.17 Commit working slice -> Committed: 2a207e0

**Acceptance Criteria:** All met
- FirebaseService autoload exists and is accessible via `/root/FirebaseService`
- submit_score method accepts score and optional initials
- Config is loaded from `config/firebase_config.json`
- HTTPRequest has 4-second timeout
- ScoreManager.save_high_score() calls FirebaseService.submit_score()
- Errors are handled silently (no crashes, no user-facing messages)

---

### Slice 2: User can fetch global high scores from Firebase

**What this delivers:** The game can retrieve top high scores from Firebase. This enables future global leaderboard display. If the network fails, an empty array is returned.

**Dependencies:** Slice 1

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/autoloads/firebase_service.gd] - FirebaseService from Slice 1
- [@/Users/matt/dev/space_scroller/tests/test_high_score_save_load.gd:21-26] - Autoload access pattern in tests

#### Tasks

- [x] 2.1 Write integration test that verifies fetch_top_scores method exists
- [x] 2.2 Run test, verify expected failure (method not found) -> "FirebaseService does not have 'fetch_top_scores' method"
- [x] 2.3 Add `fetch_top_scores(count: int = 10, callback: Callable)` stub
- [x] 2.4 Run test, verify method exists -> Success
- [x] 2.5 Implement HTTPRequest GET with orderBy="score" and limitToLast query params
- [x] 2.6 Parse JSON response into Array of dictionaries
- [x] 2.7 Sort descending by score (Firebase returns ascending for limitToLast)
- [x] 2.8 Call callback with parsed results
- [x] 2.9 Add 4-second timeout handling (via HTTPRequest.timeout = 4.0)
- [x] 2.10 On error/timeout, call callback with empty array
- [x] 2.11 Write test that verifies callback is called (with empty array if no Firebase)
- [x] 2.12 Run test, verify success -> Success (callback received with 0 scores)
- [x] 2.13 Refactor if needed (keep tests green) -> Refactored to use separate HTTPRequest nodes for submit/fetch
- [x] 2.14 Run all slice tests (1 and 2) to verify no regressions -> All 3 Firebase tests pass
- [x] 2.15 Commit working slice -> Committed: f991a4e

**Acceptance Criteria:** All met
- fetch_top_scores method exists with count and callback parameters
- Returns Array of dictionaries with "score" and "initials" keys
- Results are sorted descending by score
- 4-second timeout with silent failure (empty array on error)
- Callback is always called (success or failure)

---

### Slice 3: Firebase configuration is documented for developers

**What this delivers:** A developer can follow the documentation to set up their own Firebase project and configure the game to use it.

**Dependencies:** Slice 1

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/docs/] - Existing documentation structure (if any)
- [@/Users/matt/dev/space_scroller/config/firebase_config.json] - Config file from Slice 1

#### Tasks

- [ ] 3.1 Create `docs/firebase-setup.md` with step-by-step Firebase project creation instructions
- [ ] 3.2 Document enabling Firebase Realtime Database
- [ ] 3.3 Document recommended security rules for public read/write to `/scores` path
- [ ] 3.4 Document expected database structure (scores with score, initials, timestamp fields)
- [ ] 3.5 Document how to copy configuration to firebase_config.json
- [ ] 3.6 Review documentation for clarity and completeness
- [ ] 3.7 Commit documentation

**Acceptance Criteria:**
- docs/firebase-setup.md exists with complete setup instructions
- Instructions cover Firebase project creation
- Security rules are documented
- Database structure is documented
- Configuration file format is documented

---

### Slice 4: Verify end-to-end integration and edge cases

**What this delivers:** Production-ready feature with all edge cases handled and verified working.

**Dependencies:** Slices 1, 2, 3

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/tests/test_high_score_save_load.gd] - Complete test structure
- [@/Users/matt/dev/space_scroller/tests/test_audio_mute.gd] - Testing autoload services

#### Tasks

- [ ] 4.1 Verify config file missing is handled gracefully (silent failure)
- [ ] 4.2 Verify malformed JSON config is handled gracefully
- [ ] 4.3 Verify submit_score with empty initials uses "AAA" default
- [ ] 4.4 Verify fetch_top_scores with count=0 returns empty array
- [ ] 4.5 Verify timeout handling (mock slow response if possible)
- [ ] 4.6 Run all feature tests to verify everything works together
- [ ] 4.7 Run full test suite to verify no regressions
- [ ] 4.8 Final commit

**Acceptance Criteria:**
- All edge cases handled gracefully
- No crashes on missing/malformed config
- Defaults work correctly
- All tests pass
- No regressions in existing functionality
