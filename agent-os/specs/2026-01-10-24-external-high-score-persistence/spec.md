# Specification: External High Score Persistence

## Goal

Add Firebase Realtime Database integration for global high score persistence, enabling score submission and retrieval via REST API with simple error handling (4-second timeout, silent failure).

## User Stories

- As a player, I want my high scores to be saved to a global leaderboard so that I can compete with other players worldwide
- As a player, I want the game to work seamlessly even when the network is unavailable so that my local gameplay experience is not interrupted

## Specific Requirements

**Firebase service autoload for centralized API access**

- Create new `FirebaseService` autoload (singleton) at `scripts/autoloads/firebase_service.gd`
- Register in project.godot autoload section following existing pattern (ScoreManager, AudioManager, etc.)
- Load Firebase configuration from `res://config/firebase_config.json` at startup
- Provide public methods: `submit_score()` and `fetch_top_scores()`
- Use HTTPRequest node for all network operations with 4-second timeout
- Silent failure on all errors (no UI feedback, no retries, no offline queueing)

**Firebase configuration file**

- Create `config/firebase_config.json` with Firebase project settings
- Store: project_id, database_url (e.g., `https://project-id-default-rtdb.firebaseio.com`)
- Commit to repository (public API keys are acceptable, security via Firebase rules)
- Configuration must be readable at runtime without build-time processing

**Score submission function**

- Method signature: `submit_score(score: int, initials: String = "AAA") -> void`
- POST to Firebase REST API: `{database_url}/scores.json`
- Payload: `{"score": score, "initials": initials, "timestamp": unix_timestamp}`
- 4-second timeout via HTTPRequest.timeout property
- On timeout or error: silently return without retry
- Fire-and-forget pattern (no callback, no promise, no await in caller)

**Score retrieval function**

- Method signature: `fetch_top_scores(count: int = 10, callback: Callable) -> void`
- GET from Firebase REST API: `{database_url}/scores.json?orderBy="score"&limitToLast={count}`
- Parse JSON response into Array of dictionaries with "score" and "initials" keys
- Sort descending by score (Firebase returns ascending for limitToLast)
- 4-second timeout via HTTPRequest.timeout property
- On timeout or error: call callback with empty array

**Integration with existing ScoreManager**

- Call `FirebaseService.submit_score()` from `ScoreManager.save_high_score()` after local save
- Pass initials if available (defaults to "AAA" for compatibility with item 23)
- No changes to local score storage behavior (ConfigFile persistence unchanged)
- Local scores remain authoritative - Firebase is supplementary

**Firebase project setup documentation**

- Create `docs/firebase-setup.md` with step-by-step instructions
- Cover: creating Firebase project, enabling Realtime Database, copying configuration
- Include recommended security rules for public read/write to `/scores` path
- Document the expected database structure

## Visual Design

No visual assets provided. This is a backend/persistence feature with no UI changes in scope.

## Leverage Existing Knowledge

**Code, component, or existing logic found**

Autoload singleton pattern for services

- [@/Users/matt/dev/space_scroller/scripts/autoloads/audio_manager.gd:1-77] - AudioManager autoload structure
  - Extends Node (not CanvasLayer since no UI needed)
  - Use `_ready()` for initialization (preload config)
  - Store internal state with underscore-prefixed vars
  - Process mode can stay default (paused is fine for network)
  - Follow same naming conventions for consistency

- [@/Users/matt/dev/space_scroller/project.godot autoload section] - Autoload registration pattern
  - Add `FirebaseService="*res://scripts/autoloads/firebase_service.gd"` line
  - Asterisk prefix makes it a singleton
  - Accessible via `get_node("/root/FirebaseService")` or `has_node()` check

Configuration file loading pattern

- [@/Users/matt/dev/space_scroller/scripts/autoloads/audio_manager.gd:324-336] - ConfigFile load pattern
  - Use `config.load(path)` with error check
  - Handle missing file gracefully (return/skip operations)
  - For JSON: use `FileAccess.open()` and `JSON.parse_string()`

Score persistence and save timing

- [@/Users/matt/dev/space_scroller/scripts/score_manager.gd:113-145] - `save_high_score()` entry point
  - Add Firebase submission call after local save completes
  - Pass current score and initials (when item 23 is implemented)
  - Pattern: `if has_node("/root/FirebaseService"): get_node("/root/FirebaseService").submit_score(...)`

- [@/Users/matt/dev/space_scroller/scripts/score_manager.gd:20-27] - High score entry structure
  - Current: `{"score": int, "date": String}`
  - Will extend to: `{"score": int, "date": String, "initials": String}` (item 23)
  - Firebase submission should mirror this structure

HTTPRequest node usage in Godot

- [@/Users/matt/dev/space_scroller/scripts/enemies/boss.gd:47-51] - Dynamic node creation pattern
  - Create HTTPRequest node in `_ready()`: `var http = HTTPRequest.new()`
  - Add as child: `add_child(http)`
  - Connect signals: `http.request_completed.connect(_on_request_completed)`
  - Set timeout: `http.timeout = 4.0` (4 seconds)

Test patterns for autoload services

- [@/Users/matt/dev/space_scroller/tests/test_high_score_save_load.gd:21-26] - Autoload access pattern
  - Check existence: `if not has_node("/root/FirebaseService")`
  - Get reference: `var firebase = get_node("/root/FirebaseService")`
  - Test methods directly on autoload instance

- [@/Users/matt/dev/space_scroller/tests/test_audio_mute.gd:1-81] - Testing autoload with persistence
  - Pattern for testing service that uses external storage
  - Clean up test artifacts after test completes

**Git Commit found**

Autoload service with persistence

- [b3d7a23:Add mute toggle with persistent settings] - Adding new autoload with config persistence
  - Shows how to add ConfigFile-based persistence to an autoload
  - Demonstrates `_save_settings()` and `_load_settings()` pattern
  - Pattern for checking autoload existence before calling methods

Level unlock persistence extension

- [20e6d91:Add level unlock persistence and Level 2/3 locked buttons] - Extending existing persistence
  - Shows how to add new data to existing save file
  - Demonstrates backwards compatibility (default values for missing keys)
  - Pattern for integrating new service calls into existing code paths

Score system completion

- [fd0163a:Complete Score System verification and update roadmap] - Score system architecture
  - Documents ScoreManager as central score authority
  - Shows save/load flow for high scores
  - Pattern for signal-based score updates

## Out of Scope

- UI/display changes for global leaderboards (future roadmap item)
- High score initials entry UI (roadmap item 23 - separate feature)
- Anti-cheat or score validation mechanisms
- Device identification or rate limiting
- Offline score queueing or retry logic
- Sophisticated error handling or user-facing error messages
- Firebase Authentication or user accounts
- Firestore (using Realtime Database instead)
- Firebase SDK (using REST API via HTTPRequest)
- Real-time score updates or websocket connections
