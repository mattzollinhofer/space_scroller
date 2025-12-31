# Task Breakdown: Score System

## Overview

Total Slices: 5
Each slice delivers incremental user value and is tested end-to-end.

## Task List

### Slice 1: Player sees their score displayed on screen during gameplay

**What this delivers:** Player can see a score counter in the top-right corner of the HUD that starts at zero

**Dependencies:** None

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/ui/health_display.gd:1-46] - CanvasLayer-based HUD element pattern with _connect_to_player() and _update_display()
- [@/Users/matt/dev/space_scroller/scenes/ui/health_display.tscn:1-43] - Scene structure with layer=10 and Container positioning
- [commit:66d8b97] - HUD element creation pattern with signal connections

#### Tasks

- [x] 1.1 Write integration test that verifies score is displayed on screen during gameplay
- [x] 1.2 Run test, verify expected failure [ScoreDisplay node not found in main scene] -> Created test_score_display.gd and test_score_display.tscn
- [x] 1.3-1.6 Red-green iterations:
  - [x] Iteration 1: [ScoreDisplay node not found] -> Created score_display.gd with CanvasLayer pattern
  - [x] Iteration 2: [Scene needed] -> Created score_display.tscn with layer=10, Container, ScoreLabel
  - [x] Iteration 3: [Node not in main scene] -> Added ScoreDisplay instance to main.tscn
  - Success: Test passes - Score display shows "SCORE: 0" in top-right corner
- [x] 1.7 Refactor if needed (keep tests green) - No refactoring needed
- [x] 1.8 Commit working slice (commit: cca17f8)

**Acceptance Criteria:**
- [x] Score label visible in top-right corner showing "SCORE: 0"
- [x] Format includes comma-separated thousands (will show once score increases)
- [x] CanvasLayer uses layer 10 to match other UI elements
- [x] Score display is visible during gameplay

---

### Slice 2: Player earns points when destroying an enemy

**What this delivers:** Player sees their score increase by 100 points when they destroy a stationary enemy (1 HP), and by 200 points when they destroy a patrol enemy (2 HP)

**Dependencies:** Slice 1

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/enemies/enemy_spawner.gd:156-158] - Enemy died signal connection pattern in _setup_enemy()
- [@/Users/matt/dev/space_scroller/scripts/enemies/base_enemy.gd:32-33] - died signal emission in BaseEnemy
- [@/Users/matt/dev/space_scroller/scripts/enemies/patrol_enemy.gd:1-10] - PatrolEnemy class_name for type identification

#### Tasks

- [x] 2.1 Write integration test that verifies score increases when enemy is destroyed
- [x] 2.2 Run test, verify expected failure [Score stays at 0 because no ScoreManager exists]
- [x] 2.3-2.6 Red-green iterations:
  - [x] Iteration 1: [Score 0] -> Created score_manager.gd with autoload, add_points(), award_enemy_kill()
  - [x] Iteration 2: [Score still 0] -> Added ScoreManager as autoload in project.godot
  - [x] Iteration 3: [Score still 0] -> Modified enemy_spawner.gd _on_enemy_killed() to call ScoreManager.award_enemy_kill(enemy)
  - [x] Iteration 4: [Score still 0] -> Fixed test to use spawn_wave() method which properly calls _setup_enemy() and connects signals
  - Success: Test passes - Stationary enemy awards 100 points
- [x] 2.7 Refactor if needed (keep tests green) - Updated score_display.gd to connect to ScoreManager.score_changed signal
- [x] 2.8 Run all slice tests (1 and 2) to verify no regressions - Both tests pass
- [x] 2.9 Commit working slice
- [x] 2.10 Write additional tests for patrol enemy giving 200 points vs stationary giving 100 points - Created test_score_patrol_enemy.gd/tscn, passes

**Acceptance Criteria:**
- [x] Destroying a stationary enemy (1 HP) adds 100 points to score
- [x] Destroying a patrol enemy (2 HP) adds 200 points to score
- [x] Score display updates immediately when points are awarded
- [x] Points awarded on enemy.died signal (death, not just damage)

---

### Slice 3: Player earns bonus points for collecting UFO Friend and completing level

**What this delivers:** Player receives 500 bonus points when collecting a UFO Friend pickup, and 5,000 bonus points when completing the level

**Dependencies:** Slice 2

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/pickups/ufo_friend.gd:30-31] - collected signal definition
- [@/Users/matt/dev/space_scroller/scripts/pickups/ufo_friend.gd:95-101] - collected.emit() after successful gain_life()
- [@/Users/matt/dev/space_scroller/scripts/level_manager.gd:33-34] - level_completed signal definition

#### Tasks

- [x] 3.1 Write integration test that verifies 500 points awarded when UFO Friend collected
  - Created test_score_ufo_friend.gd and test_score_ufo_friend.tscn
- [x] 3.2 Run test, verify expected failure [Score 0, expected 500 - UFO collected but no points awarded]
- [x] 3.3-3.6 Red-green iterations:
  - [x] Iteration 1: [Score 0] -> Added POINTS_UFO_FRIEND constant (500) and award_ufo_friend_bonus() to ScoreManager
  - [x] Iteration 2: [Score still 0] -> Added _award_bonus_points() to ufo_friend.gd that calls ScoreManager.award_ufo_friend_bonus()
  - Success: Test passes - UFO Friend awards 500 bonus points
- [x] 3.7 Write integration test for level completion bonus (5,000 points)
  - Created test_score_level_complete.gd and test_score_level_complete.tscn
- [x] 3.8 Run test and iterate until passing
  - [x] Iteration 1: [Score 1000, expected 6000] -> Added POINTS_LEVEL_COMPLETE constant (5000) and award_level_complete_bonus() to ScoreManager
  - [x] Iteration 2: [Score still 1000] -> Added _award_level_complete_bonus() to level_manager.gd that calls ScoreManager.award_level_complete_bonus()
  - Success: Test passes - Level completion awards 5,000 bonus points
- [x] 3.9 Refactor if needed (keep tests green) - Cleaned up ScoreManager to remove unused connection method
- [x] 3.10 Run all slice tests (1, 2, and 3) to verify no regressions - All 4 tests pass
- [x] 3.11 Commit working slice

**Acceptance Criteria:**
- [x] Collecting UFO Friend adds 500 points to score
- [x] Points only awarded if UFO was actually collected (life was gained)
- [x] Level completion adds 5,000 points to score
- [x] Bonus added before displaying on Level Complete screen

---

### Slice 4: Player sees their score on end screens (Game Over and Level Complete)

**What this delivers:** Player sees their final score displayed on both Game Over and Level Complete screens

**Dependencies:** Slices 1-3

**Reference patterns:**
- [@/Users/matt/dev/space_scroller/scripts/game_over_screen.gd:1-24] - Game over screen script with show_game_over()
- [@/Users/matt/dev/space_scroller/scenes/ui/game_over_screen.tscn:1-26] - VBoxContainer structure for labels
- [@/Users/matt/dev/space_scroller/scripts/ui/level_complete_screen.gd:1-24] - Level complete screen script
- [@/Users/matt/dev/space_scroller/scenes/ui/level_complete_screen.tscn:1-26] - Same VBoxContainer pattern

#### Tasks

- [x] 4.1 Write integration test that verifies score is shown on Game Over screen
  - Created test_score_game_over.gd and test_score_game_over.tscn
- [x] 4.2 Run test, verify expected failure [ScoreLabel not found in game over screen]
- [x] 4.3-4.6 Red-green iterations for Game Over screen:
  - [x] Iteration 1: [ScoreLabel not found] -> Added ScoreLabel node to game_over_screen.tscn
  - [x] Iteration 2: [Score shows 0, expected 1,500] -> Updated game_over_screen.gd with _score_label reference, _update_score_display(), _format_number()
  - Success: Test passes - Game Over screen shows "SCORE: 1,500" correctly formatted
- [x] 4.7 Write integration test for Level Complete screen showing score
  - Created test_score_level_complete_screen.gd and test_score_level_complete_screen.tscn
- [x] 4.8 Red-green iterations for Level Complete screen:
  - [x] Iteration 1: [ScoreLabel not found] -> Added ScoreLabel node to level_complete_screen.tscn
  - [x] Iteration 2: [Score shows 0, expected 6,500] -> Updated level_complete_screen.gd with _score_label reference, _update_score_display(), _format_number()
  - Success: Test passes - Level Complete screen shows "SCORE: 6,500" correctly formatted
- [x] 4.9 Refactor if needed (keep tests green) - No refactoring needed, code follows same pattern as game_over_screen.gd
- [x] 4.10 Run all slice tests to verify no regressions - All tests pass (slice 1-4)
- [x] 4.11 Commit working slice

**Acceptance Criteria:**
- [x] Game Over screen shows "SCORE: X,XXX" with player's final score
- [x] Level Complete screen shows "SCORE: X,XXX" (includes level bonus)
- [x] Score labels appear below the main title text
- [x] Score uses same comma-separated thousands format as HUD

---

### Slice 5: Player's high scores persist across game sessions

**What this delivers:** Player sees their high score displayed on end screens, and the game remembers top scores between sessions

**Dependencies:** Slice 4

**Reference patterns:**
- Godot ConfigFile API for local file storage
- user://high_scores.cfg path for cross-platform compatibility

#### Tasks

- [x] 5.1 Write integration test that verifies high score is saved and loaded between sessions
  - Created test_high_score_save_load.gd and test_high_score_save_load.tscn
- [x] 5.2 Run test, verify expected failure [ScoreManager missing save_high_score() method]
- [x] 5.3-5.6 Red-green iterations for high score persistence:
  - [x] Iteration 1: [save_high_score() missing] -> Added full high score system to ScoreManager:
    - _high_scores array, MAX_HIGH_SCORES constant (10), HIGH_SCORE_PATH constant
    - get_high_score(), get_high_scores(), save_high_score(), load_high_scores()
    - is_new_high_score(), qualifies_for_top_10()
    - _save_to_file() and _sort_high_scores() helpers
    - new_high_score signal
    - Automatic load on _ready()
  - Success: Test passes - High scores saved and loaded correctly
- [x] 5.7 Write test for top 10 high scores list (sorted descending)
  - Created test_high_score_top10.gd and test_high_score_top10.tscn
- [x] 5.8 Run test and iterate until passing
  - Success: Test passes - Top 10 sorted descending, entries include dates, lowest scores dropped
- [x] 5.9 Add HIGH SCORE label to Game Over screen
  - Added HighScoreLabel node to game_over_screen.tscn (gold color, 48pt font)
  - Updated game_over_screen.gd with _high_score_label and _update_high_score_display()
- [x] 5.10 Add HIGH SCORE label to Level Complete screen
  - Added HighScoreLabel node to level_complete_screen.tscn (gold color, 48pt font)
  - Updated level_complete_screen.gd with _high_score_label and _update_high_score_display()
- [x] 5.11 Add "NEW HIGH SCORE!" indicator when applicable
  - Added NewHighScoreLabel to both screens (hidden by default, gold color, 56pt font)
  - Updated _update_high_score_display() in both screens to show/hide based on is_new_high_score()
  - Fixed is_new_high_score() to only return true when beating #1 score, not just making top 10
  - Created test_high_score_game_over.gd/tscn, test_high_score_level_complete.gd/tscn
  - Created test_high_score_not_new.gd/tscn to verify indicator hidden when not beating high score
- [x] 5.12 Refactor if needed (keep tests green) - No refactoring needed
- [x] 5.13 Run all feature tests to verify everything works together - All 12 tests pass
- [x] 5.14 Commit working slice

**Acceptance Criteria:**
- [x] High scores saved to user://high_scores.cfg using ConfigFile
- [x] Top 10 high scores stored with score (int) and date (ISO string)
- [x] Scores sorted descending, oldest duplicate scores dropped first
- [x] Game Over screen shows "HIGH SCORE: X,XXX"
- [x] Level Complete screen shows "HIGH SCORE: X,XXX"
- [x] "NEW HIGH SCORE!" indicator appears when player achieves a new high score
- [x] High scores persist across game sessions

---

## Implementation Notes

### ScoreManager Design

The ScoreManager should be an autoload (singleton) that:
- Tracks current score for the active game session
- Provides add_points(amount: int) method
- Emits score_changed signal for UI updates
- Handles high score loading/saving via ConfigFile
- Connects to enemy.died, UfoFriend.collected, and LevelManager.level_completed signals

### Signal Connections

ScoreManager needs to connect to:
1. Enemy died signals - via EnemySpawner (follow existing pattern in _setup_enemy)
2. UfoFriend.collected signal - when UFO friends are spawned
3. LevelManager.level_completed signal - for level completion bonus

### Point Values Reference

| Source | Points |
|--------|--------|
| Stationary enemy (BaseEnemy, 1 HP) | 100 |
| Patrol enemy (PatrolEnemy, 2 HP) | 200 |
| UFO Friend collected | 500 |
| Level completion bonus | 5,000 |

### File Structure

Expected new files:
- scripts/score_manager.gd - Autoload singleton for score tracking
- scripts/ui/score_display.gd - HUD score display script
- scenes/ui/score_display.tscn - HUD score display scene

Modified files:
- project.godot - Add ScoreManager autoload
- scenes/main.tscn - Add ScoreDisplay instance
- scripts/game_over_screen.gd - Add score display logic
- scenes/ui/game_over_screen.tscn - Add score labels
- scripts/ui/level_complete_screen.gd - Add score display logic
- scenes/ui/level_complete_screen.tscn - Add score labels
